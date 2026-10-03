import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/fang.dart';

/// Wird erst benutzt, wenn Firebase eingerichtet ist (Dart-Globals sind lazy).
final fangDienst = FangDienst();

/// Fänge in Firestore.
///
/// Öffentliche Fänge liegen in `faenge`, private in `nutzer/{uid}/privat`.
/// So kommt der Feed ohne zusammengesetzten Index aus. Fotos liegen
/// verkleinert als Base64 in `fotos/{fangId}` (funktioniert im Gratis-Tarif).
class FangDienst {
  final _db = FirebaseFirestore.instance;
  final _fotoCache = <String, Uint8List?>{};

  CollectionReference<Map<String, dynamic>> get _oeff =>
      _db.collection('faenge');
  CollectionReference<Map<String, dynamic>> _privat(String uid) =>
      _db.collection('nutzer/$uid/privat');
  CollectionReference<Map<String, dynamic>> get _fotos =>
      _db.collection('fotos');

  /// Alle eigenen Fänge (öffentlich und privat), neueste zuerst.
  Stream<List<Fang>> meineFaenge(String uid) {
    late StreamController<List<Fang>> controller;
    var oeffentlich = <Fang>[];
    var privat = <Fang>[];
    final abos = <StreamSubscription<dynamic>>[];

    void senden() {
      controller.add([...oeffentlich, ...privat]
        ..sort((a, b) => b.datum.compareTo(a.datum)));
    }

    controller = StreamController<List<Fang>>(
      onListen: () {
        abos
          ..add(_oeff.where('uid', isEqualTo: uid).snapshots().listen((s) {
            oeffentlich = s.docs
                .map((d) => Fang.fromFirestore(d, oeffentlich: true))
                .toList();
            senden();
          }, onError: controller.addError))
          ..add(_privat(uid).snapshots().listen((s) {
            privat = s.docs
                .map((d) => Fang.fromFirestore(d, oeffentlich: false))
                .toList();
            senden();
          }, onError: controller.addError));
      },
      onCancel: () async {
        for (final a in abos) {
          await a.cancel();
        }
      },
    );
    return controller.stream;
  }

  /// Die neuesten öffentlichen Fänge aller Nutzer.
  Stream<List<Fang>> feed({int anzahl = 50}) => _oeff
      .orderBy('erstellt', descending: true)
      .limit(anzahl)
      .snapshots()
      .map((s) => s.docs
          .map((d) => Fang.fromFirestore(d, oeffentlich: true))
          .toList());

  /// Die längsten öffentlichen Fänge (für Rekorde pro Fischart).
  Future<List<Fang>> laengsteFaenge({int anzahl = 300}) async {
    final s = await _oeff
        .orderBy('laengeCm', descending: true)
        .limit(anzahl)
        .get();
    return s.docs.map((d) => Fang.fromFirestore(d, oeffentlich: true)).toList();
  }

  /// Speichert einen neuen oder geänderten Fang.
  ///
  /// [vorher] ist der alte Stand beim Bearbeiten (für den Wechsel
  /// öffentlich ↔ privat).
  Future<void> speichern(
    Fang fang, {
    Fang? vorher,
    Uint8List? foto,
    bool fotoEntfernen = false,
  }) async {
    final ziel = fang.oeffentlich ? _oeff : _privat(fang.uid);
    final hatFoto = foto != null || (!fotoEntfernen && (vorher?.hatFoto ?? false));
    final id = vorher?.id ?? ziel.doc().id;
    final daten = fang.kopie(id: id, hatFoto: hatFoto).toFirestore();

    if (vorher != null && vorher.oeffentlich == fang.oeffentlich) {
      await ziel.doc(id).update(daten);
    } else {
      if (vorher != null) {
        final alt = vorher.oeffentlich ? _oeff : _privat(vorher.uid);
        await alt.doc(id).delete();
      }
      await ziel.doc(id).set({
        ...daten,
        'petriHeil': <String>[],
        'erstellt': FieldValue.serverTimestamp(),
      });
    }

    if (foto != null) {
      await _fotos.doc(id).set({
        'uid': fang.uid,
        'oeffentlich': fang.oeffentlich,
        'daten': base64Encode(foto),
      });
      _fotoCache[id] = foto;
    } else if (fotoEntfernen) {
      await _fotos.doc(id).delete();
      _fotoCache.remove(id);
    } else if (hatFoto && vorher?.oeffentlich != fang.oeffentlich) {
      await _fotos.doc(id).update({'oeffentlich': fang.oeffentlich});
    }
  }

  Future<void> loeschen(Fang fang) async {
    final ort = fang.oeffentlich ? _oeff : _privat(fang.uid);
    await ort.doc(fang.id).delete();
    if (fang.hatFoto) await _fotos.doc(fang.id).delete();
    _fotoCache.remove(fang.id);
  }

  Future<void> petriHeil(Fang fang, String uid, {required bool an}) =>
      _oeff.doc(fang.id).update({
        'petriHeil':
            an ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
      });

  Future<Uint8List?> foto(String fangId) async {
    if (_fotoCache.containsKey(fangId)) return _fotoCache[fangId];
    try {
      final doc = await _fotos.doc(fangId).get();
      final daten = doc.data()?['daten'] as String?;
      return _fotoCache[fangId] = daten == null ? null : base64Decode(daten);
    } catch (_) {
      return null;
    }
  }

  /// Meldung an den Betreiber (falsche Infos, neues Gewässer, Missbrauch).
  Future<void> melden({
    required String uid,
    required String typ,
    required String bezug,
    required String text,
  }) =>
      _db.collection('meldungen').add({
        'uid': uid,
        'typ': typ,
        'bezug': bezug,
        'text': text,
        'erstellt': FieldValue.serverTimestamp(),
      });

  /// Entfernt alle Daten eines Nutzers (vor dem Löschen des Kontos).
  Future<void> allesLoeschen(String uid, String? name) async {
    final oeff = await _oeff.where('uid', isEqualTo: uid).get();
    final privat = await _privat(uid).get();
    for (final doc in [...oeff.docs, ...privat.docs]) {
      if (doc.data()['hatFoto'] == true) await _fotos.doc(doc.id).delete();
      await doc.reference.delete();
    }
    if (name != null) await _db.doc('namen/${name.toLowerCase()}').delete();
    await _db.doc('nutzer/$uid').delete();
  }
}
