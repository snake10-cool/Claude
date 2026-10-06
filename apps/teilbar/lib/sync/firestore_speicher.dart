import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fernspeicher.dart';

/// Firestore-Aufbau:
///   gruppen/{gruppeId}                 { mitglieder: [uid], erstellt }
///   gruppen/{gruppeId}/objekte/{id}    { typ, geaendert, daten }
///   einladungen/{code}                 { gruppeId }
/// Die Sicherheitsregeln stehen in `firestore.rules`.
class FirestoreSpeicher implements Fernspeicher {
  final _db = FirebaseFirestore.instance;

  @override
  Future<String> anmelden() async {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    return user.uid;
  }

  @override
  Future<bool> gruppeErstellen(String gruppeId, String code) async {
    final uid = await anmelden();
    final einladung = _db.collection('einladungen').doc(code);
    try {
      await _db.runTransaction((tx) async {
        final vorhanden = await tx.get(einladung);
        if (vorhanden.exists) throw StateError('Code vergeben');
        tx.set(_db.collection('gruppen').doc(gruppeId), {
          'mitglieder': [uid],
          'erstellt': FieldValue.serverTimestamp(),
        });
        tx.set(einladung, {'gruppeId': gruppeId});
      });
      return true;
    } on StateError {
      return false;
    }
  }

  @override
  Future<String?> beitreten(String code) async {
    final uid = await anmelden();
    final einladung = await _db.collection('einladungen').doc(code).get();
    final gid = einladung.data()?['gruppeId'] as String?;
    if (gid == null) return null;
    await _db.collection('gruppen').doc(gid).update({
      'mitglieder': FieldValue.arrayUnion([uid]),
      'beitrittCode': code,
    });
    return gid;
  }

  @override
  Stream<List<FernObjekt>> beobachten(String gruppeId) => _db
      .collection('gruppen')
      .doc(gruppeId)
      .collection('objekte')
      .snapshots()
      .map(
        (s) => [
          for (final d in s.docChanges.map((c) => c.doc))
            if (d.data() case final m?)
              FernObjekt(
                typ: m['typ'] as String,
                id: d.id,
                geaendert: DateTime.fromMillisecondsSinceEpoch(
                  m['geaendert'] as int,
                ),
                daten: Map<String, dynamic>.from(m['daten'] as Map),
              ),
        ],
      );

  @override
  Future<void> schreiben(String gruppeId, List<FernObjekt> objekte) async {
    final sammlung = _db
        .collection('gruppen')
        .doc(gruppeId)
        .collection('objekte');
    // Firestore erlaubt höchstens 500 Schreibvorgänge pro Batch.
    for (var i = 0; i < objekte.length; i += 400) {
      final batch = _db.batch();
      for (final o in objekte.skip(i).take(400)) {
        batch.set(sammlung.doc(o.id), {
          'typ': o.typ,
          'geaendert': o.geaendert.millisecondsSinceEpoch,
          'daten': o.daten,
        });
      }
      await batch.commit();
    }
  }
}
