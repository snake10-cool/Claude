import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'speicher.dart';

/// Ein Eintrag in der Online-Rangliste.
class Spieler {
  const Spieler(this.uid, this.name, this.punkte, this.bewiesen, this.gelesen);

  final String uid;
  final String name;
  final int punkte;
  final int bewiesen;
  final int gelesen;

  factory Spieler.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Spieler(
      d.id,
      j['name'] as String? ?? '?',
      j['punkte'] as int? ?? 0,
      j['bewiesen'] as int? ?? 0,
      j['gelesen'] as int? ?? 0,
    );
  }
}

class KontoFehler implements Exception {
  const KontoFehler(this.text);
  final String text;
  @override
  String toString() => text;
}

/// @Name: 3–20 Zeichen, nur Kleinbuchstaben, Ziffern, Punkt und Unterstrich.
final nameMuster = RegExp(r'^[a-z0-9_.]{3,20}$');

String nameNormal(String eingabe) => eingabe.trim().toLowerCase().replaceFirst('@', '');

/// Konto und Online-Rangliste über Firebase. Lädt den eigenen Stand
/// automatisch hoch, sobald sich Punkte ändern.
class Konto extends ChangeNotifier {
  Konto(this._speicher) {
    _abo = _auth.authStateChanges().listen(_nutzerGeaendert);
    _speicher.addListener(_hochladen);
  }

  final Speicher _speicher;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _abo;

  /// Eigener @Name, sobald das Profil geladen ist.
  String? name;
  String? _hochgeladen;

  User? get nutzer => _auth.currentUser;
  bool get angemeldet => nutzer != null;

  CollectionReference<Map<String, dynamic>> get _spieler => _db.collection('spieler');
  DocumentReference<Map<String, dynamic>> _namensDoc(String n) => _db.collection('namen').doc(n);
  CollectionReference<Map<String, dynamic>> _freunde(String uid) =>
      _spieler.doc(uid).collection('freunde');

  @override
  void dispose() {
    _abo.cancel();
    _speicher.removeListener(_hochladen);
    super.dispose();
  }

  Future<void> _nutzerGeaendert(User? u) async {
    name = null;
    _hochgeladen = null;
    if (u != null) {
      try {
        name = (await _spieler.doc(u.uid).get()).data()?['name'] as String?;
      } catch (e) {
        debugPrint('Profil nicht geladen: $e');
      }
    }
    notifyListeners();
    _hochladen();
  }

  Map<String, dynamic> _stand(String n) => {
        'name': n,
        'punkte': _speicher.punkte,
        'bewiesen': _speicher.bewiesen,
        'gelesen': _speicher.gelesen,
        'aktualisiert': FieldValue.serverTimestamp(),
      };

  void _hochladen() {
    final u = nutzer;
    final n = name;
    if (u == null || n == null) return;
    final kennung = '${_speicher.punkte}/${_speicher.bewiesen}/${_speicher.gelesen}';
    if (kennung == _hochgeladen) return;
    _hochgeladen = kennung;
    _spieler.doc(u.uid).set(_stand(n)).catchError((Object e) {
      _hochgeladen = null;
      debugPrint('Stand nicht hochgeladen: $e');
    });
  }

  Future<void> registrieren(String email, String passwort, String wunschname) async {
    final n = nameNormal(wunschname);
    if (!nameMuster.hasMatch(n)) {
      throw const KontoFehler('Der @Name braucht 3–20 Zeichen: a–z, 0–9, Punkt oder Unterstrich.');
    }
    if ((await _fehler(() => _namensDoc(n).get())).exists) {
      throw KontoFehler('@$n ist schon vergeben.');
    }
    final zugang = await _fehler(
      () => _auth.createUserWithEmailAndPassword(email: email.trim(), password: passwort),
    );
    final uid = zugang.user!.uid;
    final batch = _db.batch()
      ..set(_namensDoc(n), {'uid': uid})
      ..set(_spieler.doc(uid), _stand(n));
    try {
      await batch.commit();
    } catch (e) {
      // Name in der Zwischenzeit vergeben: Konto wieder entfernen.
      await zugang.user!.delete().catchError((_) {});
      throw KontoFehler('@$n ist schon vergeben.');
    }
    name = n;
    _hochgeladen = '${_speicher.punkte}/${_speicher.bewiesen}/${_speicher.gelesen}';
    notifyListeners();
  }

  Future<void> anmelden(String email, String passwort) => _fehler(
        () => _auth.signInWithEmailAndPassword(email: email.trim(), password: passwort),
      );

  Future<void> passwortVergessen(String email) =>
      _fehler(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> abmelden() => _auth.signOut();

  /// Löscht Rangliste-Eintrag, Freunde, @Name und das Konto selbst.
  Future<void> kontoLoeschen(String passwort) async {
    final u = nutzer;
    if (u == null) return;
    await _fehler(() => u.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: u.email ?? '', password: passwort),
        ));
    final freunde = await _freunde(u.uid).get();
    final batch = _db.batch();
    for (final f in freunde.docs) {
      batch.delete(f.reference);
    }
    batch.delete(_spieler.doc(u.uid));
    if (name != null) batch.delete(_namensDoc(name!));
    await _fehler(batch.commit);
    await _fehler(u.delete);
  }

  // ───────── Rangliste ─────────

  Stream<List<Spieler>> weltweit() => _spieler
      .orderBy('punkte', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Spieler.ausDoc).toList());

  Stream<List<String>> freundUids() {
    final u = nutzer;
    if (u == null) return Stream.value(const []);
    return _freunde(u.uid).snapshots().map((s) => s.docs.map((d) => d.id).toList());
  }

  /// Stände mehrerer Spieler (Firestore erlaubt höchstens 30 IDs pro Abfrage).
  Future<List<Spieler>> staende(List<String> uids) async {
    final ergebnis = <Spieler>[];
    for (var i = 0; i < uids.length; i += 30) {
      final teil = uids.sublist(i, i + 30 > uids.length ? uids.length : i + 30);
      final s = await _spieler.where(FieldPath.documentId, whereIn: teil).get();
      ergebnis.addAll(s.docs.map(Spieler.ausDoc));
    }
    return ergebnis;
  }

  Future<void> freundHinzufuegen(String eingabe) async {
    final u = nutzer;
    if (u == null) return;
    final n = nameNormal(eingabe);
    if (n == name) throw const KontoFehler('Das bist du selbst. 😉');
    final doc = await _fehler(() => _namensDoc(n).get());
    final uid = doc.data()?['uid'] as String?;
    if (uid == null) throw KontoFehler('@$n gibt es nicht.');
    await _fehler(() => _freunde(u.uid).doc(uid).set({'name': n, 'seit': FieldValue.serverTimestamp()}));
  }

  Future<void> freundEntfernen(String uid) async {
    final u = nutzer;
    if (u == null) return;
    await _fehler(() => _freunde(u.uid).doc(uid).delete());
  }

  /// Übersetzt Firebase-Fehler in verständliche deutsche Meldungen.
  Future<T> _fehler<T>(Future<T> Function() aktion) async {
    try {
      return await aktion();
    } on FirebaseAuthException catch (e) {
      throw KontoFehler(switch (e.code) {
        'email-already-in-use' => 'Mit dieser E-Mail gibt es schon ein Konto. Melde dich an.',
        'invalid-email' => 'Die E-Mail-Adresse stimmt nicht.',
        'weak-password' => 'Das Passwort ist zu schwach (mindestens 6 Zeichen).',
        'wrong-password' || 'invalid-credential' || 'user-not-found' => 'E-Mail oder Passwort falsch.',
        'too-many-requests' => 'Zu viele Versuche. Probier es später noch einmal.',
        'network-request-failed' => 'Keine Internetverbindung.',
        'requires-recent-login' => 'Bitte melde dich neu an und versuch es dann noch einmal.',
        _ => 'Das hat nicht geklappt (${e.code}).',
      });
    } on FirebaseException catch (e) {
      throw KontoFehler(e.code == 'unavailable'
          ? 'Keine Internetverbindung.'
          : e.code == 'permission-denied'
              ? 'Die Online-Rangliste ist noch nicht freigeschaltet.'
              : 'Das hat nicht geklappt (${e.code}).');
    }
  }
}
