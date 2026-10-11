import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/fische.dart';
import '../models/fang.dart';
import 'fang_dienst.dart';

/// Wonach gewertet wird.
enum Wertung {
  laenge('Größter Fisch', 'cm'),
  anzahl('Meiste Fische', 'Fische'),
  arten('Meiste Arten', 'Arten');

  const Wertung(this.text, this.einheit);
  final String text;
  final String einheit;
}

/// Ein selbst angelegtes Wettfischen (Freunde, Verein, Familie).
class Wettfischen {
  Wettfischen(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        titel = doc.data()?['titel'] as String? ?? '',
        gewaesser = doc.data()?['gewaesser'] as String? ?? '',
        fischId = doc.data()?['fischId'] as String? ?? '',
        code = doc.data()?['code'] as String? ?? '',
        ersteller = doc.data()?['ersteller'] as String? ?? '',
        erstellerName = doc.data()?['erstellerName'] as String? ?? '',
        wertung = Wertung.values.asNameMap()[doc.data()?['wertung']] ??
            Wertung.laenge,
        von = (doc.data()?['von'] as Timestamp?)?.toDate() ?? DateTime.now(),
        bis = (doc.data()?['bis'] as Timestamp?)?.toDate() ?? DateTime.now();

  final String id;
  final String titel;
  final String gewaesser;

  /// Leer = alle Fischarten zählen.
  final String fischId;
  final String code;
  final String ersteller;
  final String erstellerName;
  final Wertung wertung;
  final DateTime von;
  final DateTime bis;

  bool laeuft(DateTime jetzt) => !jetzt.isBefore(von) && jetzt.isBefore(bis);
  bool vorbei(DateTime jetzt) => !jetzt.isBefore(bis);

  String get fischText => fischId.isEmpty
      ? 'alle Fischarten'
      : (fischById(fischId)?.name ?? fischId).split(' (').first;
}

/// Stand eines Teilnehmers.
class Teilnehmer {
  Teilnehmer(this.uid, Map<String, dynamic> d)
      : name = d['name'] as String? ?? '',
        faenge = (d['faenge'] as num?)?.toInt() ?? 0,
        groesster = (d['groesster'] as num?)?.toDouble() ?? 0,
        arten = (d['arten'] as num?)?.toInt() ?? 0,
        besterFisch = d['besterFisch'] as String? ?? '';

  final String uid;
  final String name;
  final int faenge;
  final double groesster;
  final int arten;
  final String besterFisch;

  num wert(Wertung w) => switch (w) {
        Wertung.laenge => groesster,
        Wertung.anzahl => faenge,
        Wertung.arten => arten,
      };

  String wertText(Wertung w) => switch (w) {
        Wertung.laenge => groesster == 0 ? '–' : '${groesster.round()} cm',
        Wertung.anzahl => '$faenge',
        Wertung.arten => '$arten',
      };
}

/// Mein Stand aus meinen Fängen im Zeitraum (und ggf. nur einer Art).
Map<String, Object> standAus(Wettfischen w, List<Fang> faenge) =>
    standImZeitraum(w.von, w.bis, w.fischId, faenge);

Map<String, Object> standImZeitraum(
    DateTime von, DateTime bis, String fischId, List<Fang> faenge) {
  final zaehlt = faenge.where((f) =>
      !f.datum.isBefore(von) &&
      f.datum.isBefore(bis) &&
      (fischId.isEmpty || f.fischId == fischId));
  var groesster = 0.0;
  var bester = '';
  for (final f in zaehlt) {
    if ((f.laengeCm ?? 0) > groesster) {
      groesster = f.laengeCm!;
      bester = f.fischId;
    }
  }
  return {
    'faenge': zaehlt.length,
    'groesster': groesster,
    'arten': zaehlt.map((f) => f.fischId).toSet().length,
    'besterFisch': bester,
  };
}

/// Teilnehmer nach Wertung sortiert (Gleichstand: mehr Fische zuerst).
List<Teilnehmer> sortiert(List<Teilnehmer> t, Wertung w) => [...t]
  ..sort((a, b) {
    final c = b.wert(w).compareTo(a.wert(w));
    return c != 0 ? c : b.faenge.compareTo(a.faenge);
  });

class WettfischenDienst {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _wf =>
      _db.collection('wettfischen');
  CollectionReference<Map<String, dynamic>> _teilnehmer(String id) =>
      _db.collection('wettfischen/$id/teilnehmer');
  CollectionReference<Map<String, dynamic>> _meine(String uid) =>
      _db.collection('nutzer/$uid/wettfischen');

  static const _zeichen = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String neuerCode() {
    final r = Random.secure();
    return List.generate(6, (_) => _zeichen[r.nextInt(_zeichen.length)])
        .join();
  }

  /// Meine Wettfischen (angelegt oder beigetreten), neueste zuerst.
  Stream<List<String>> meine(String uid) => _meine(uid)
      .orderBy('bis', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toList());

  Stream<Wettfischen?> wettfischen(String id) => _wf
      .doc(id)
      .snapshots()
      .map((d) => d.exists ? Wettfischen(d) : null);

  Stream<List<Teilnehmer>> teilnehmer(String id) => _teilnehmer(id)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map((d) => Teilnehmer(d.id, d.data())).toList());

  Future<String> anlegen({
    required String uid,
    required String name,
    required String titel,
    required String gewaesser,
    required String fischId,
    required Wertung wertung,
    required DateTime von,
    required DateTime bis,
  }) async {
    final doc = _wf.doc();
    final batch = _db.batch()
      ..set(doc, {
        'titel': titel,
        'gewaesser': gewaesser,
        'fischId': fischId,
        'wertung': wertung.name,
        'von': Timestamp.fromDate(von),
        'bis': Timestamp.fromDate(bis),
        'code': neuerCode(),
        'ersteller': uid,
        'erstellerName': name,
        'erstellt': FieldValue.serverTimestamp(),
      })
      ..set(_teilnehmer(doc.id).doc(uid), _leer(name))
      ..set(_meine(uid).doc(doc.id),
          {'titel': titel, 'bis': Timestamp.fromDate(bis)});
    await batch.commit();
    return doc.id;
  }

  static Map<String, Object> _leer(String name) => {
        'name': name,
        'faenge': 0,
        'groesster': 0.0,
        'arten': 0,
        'besterFisch': '',
      };

  /// Mit Code beitreten. Gibt das Wettfischen zurück.
  Future<Wettfischen> beitreten(String uid, String name, String code) async {
    final s = await _wf
        .where('code', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (s.docs.isEmpty) throw Exception('Kein Wettfischen mit diesem Code.');
    final w = Wettfischen(s.docs.first);
    if (w.vorbei(DateTime.now())) throw Exception('Dieses Wettfischen ist vorbei.');
    final batch = _db.batch()
      ..set(_teilnehmer(w.id).doc(uid), _leer(name))
      ..set(_meine(uid).doc(w.id),
          {'titel': w.titel, 'bis': Timestamp.fromDate(w.bis)});
    await batch.commit();
    await fangDienst.nachricht(
        w.ersteller, uid, name, 'wettfischen', 'ist „${w.titel}“ beigetreten');
    return w;
  }

  /// Eigenen Stand schreiben (nur während und kurz nach dem Wettfischen).
  Future<void> standMelden(
      Wettfischen w, String uid, String name, List<Fang> faenge) async {
    final jetzt = DateTime.now();
    if (jetzt.isBefore(w.von) ||
        jetzt.isAfter(w.bis.add(const Duration(days: 3)))) {
      return;
    }
    await _teilnehmer(w.id)
        .doc(uid)
        .set({'name': name, ...standAus(w, faenge)});
  }

  Future<void> verlassen(String id, String uid) async {
    final batch = _db.batch()
      ..delete(_teilnehmer(id).doc(uid))
      ..delete(_meine(uid).doc(id));
    await batch.commit();
  }

  /// Nur der Ersteller: Wettfischen ganz löschen.
  Future<void> loeschen(String id, String uid) async {
    for (final d in (await _teilnehmer(id).get()).docs) {
      await d.reference.delete();
    }
    await _wf.doc(id).delete();
    await _meine(uid).doc(id).delete();
  }

  /// Beim Konto-Löschen: Teilnahmen und eigene Wettfischen entfernen.
  Future<void> allesLoeschen(String uid) async {
    try {
      for (final d in (await _meine(uid).get()).docs) {
        try {
          await _teilnehmer(d.id).doc(uid).delete();
        } catch (_) {}
        await d.reference.delete();
      }
      for (final d
          in (await _wf.where('ersteller', isEqualTo: uid).get()).docs) {
        try {
          await loeschen(d.id, uid);
        } catch (_) {}
      }
    } catch (_) {}
  }
}

final wettfischenDienst = WettfischenDienst();
