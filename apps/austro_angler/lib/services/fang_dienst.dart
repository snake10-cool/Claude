import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

import '../models/fang.dart';

/// Ein Wunsch oder eine Meldung.
class Eintrag {
  Eintrag(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        uid = doc.data()?['uid'] as String? ?? '',
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        text = doc.data()?['text'] as String? ?? '',
        typ = doc.data()?['typ'] as String? ?? '',
        bezug = doc.data()?['bezug'] as String? ?? '',
        status = doc.data()?['status'] as String? ?? 'neu',
        antwort = doc.data()?['antwort'] as String?,
        erstellt =
            (doc.data()?['erstellt'] as Timestamp?)?.toDate() ?? DateTime.now();

  final String id;
  final String uid;
  final String nutzerName;
  final String text;
  final String typ;
  final String bezug;
  final String status;
  final String? antwort;
  final DateTime erstellt;
}

class PreisVorschlag {
  PreisVorschlag(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        gewaesserId = doc.data()?['gewaesserId'] as String? ?? '',
        gewaesserName = doc.data()?['gewaesserName'] as String? ?? '',
        art = doc.data()?['art'] as String? ?? '',
        euro = (doc.data()?['euro'] as num?)?.toDouble() ?? 0,
        notiz = doc.data()?['notiz'] as String? ?? '';

  final String id;
  final String nutzerName;
  final String gewaesserId;
  final String gewaesserName;
  final String art;
  final double euro;
  final String notiz;
}

/// Von Anglern eingereichte Infos zu einem Gewässer (wartet auf Prüfung).
class InfoVorschlag {
  InfoVorschlag(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        gewaesserId = doc.data()?['gewaesserId'] as String? ?? '',
        gewaesserName = doc.data()?['gewaesserName'] as String? ?? '',
        fische = [
          for (final f in (doc.data()?['fische'] as List?) ?? const [])
            f as String,
        ],
        verkauf = doc.data()?['verkauf'] as String? ?? '',
        url = doc.data()?['url'] as String? ?? '',
        text = doc.data()?['text'] as String? ?? '';

  final String id;
  final String nutzerName;
  final String gewaesserId;
  final String gewaesserName;
  final List<String> fische;
  final String verkauf;
  final String url;
  final String text;
}

/// Geprüfte Community-Infos zu einem Gewässer.
class GepruefteInfos {
  GepruefteInfos(Map<String, dynamic>? d)
      : fische = [
          for (final f in (d?['fische'] as List?) ?? const []) f as String,
        ],
        eintraege = [
          for (final e in (d?['eintraege'] as List?) ?? const [])
            e as Map<String, dynamic>,
        ];

  final List<String> fische;

  /// {verkauf, url, text, von, datum}
  final List<Map<String, dynamic>> eintraege;

  bool get leer => fische.isEmpty && eintraege.isEmpty;
}

class Ausruestung {
  const Ausruestung({
    this.id = '',
    required this.name,
    this.art = 'Rute',
    this.notiz = '',
  });

  factory Ausruestung.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) =>
      Ausruestung(
        id: d.id,
        name: d.data()?['name'] as String? ?? '',
        art: d.data()?['art'] as String? ?? 'Rute',
        notiz: d.data()?['notiz'] as String? ?? '',
      );

  final String id;
  final String name;
  final String art;
  final String notiz;
}

class Messung {
  Messung(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        uid = doc.data()?['uid'] as String? ?? '',
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        grad = (doc.data()?['grad'] as num?)?.toDouble() ?? 0,
        zeit = (doc.data()?['zeit'] as Timestamp?)?.toDate() ?? DateTime.now();

  final String id;
  final String uid;
  final String nutzerName;
  final double grad;
  final DateTime zeit;
}

class CommunityPreis {
  CommunityPreis(this.roh)
      : art = roh['art'] as String? ?? '',
        euro = (roh['euro'] as num?)?.toDouble() ?? 0,
        von = roh['von'] as String? ?? '',
        datum = DateTime.fromMillisecondsSinceEpoch(
            (roh['datum'] as num?)?.toInt() ?? 0);

  final Map<String, dynamic> roh;
  final String art;
  final double euro;
  final String von;
  final DateTime datum;
}

class Treffen {
  Treffen(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        uid = doc.data()?['uid'] as String? ?? '',
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        gewaesser = doc.data()?['gewaesser'] as String? ?? '',
        text = doc.data()?['text'] as String? ?? '',
        zeit = (doc.data()?['zeit'] as Timestamp?)?.toDate() ?? DateTime.now(),
        zusagen = (doc.data()?['zusagen'] as Map?)?.map(
                (k, v) => MapEntry(k as String, v as String)) ??
            const {},
        fahrten = (doc.data()?['fahrten'] as Map?)?.map(
                (k, v) => MapEntry(k as String, Fahrt(v as Map))) ??
            const {};

  final String id;
  final String uid;
  final String nutzerName;
  final String gewaesser;
  final String text;
  final DateTime zeit;

  /// uid → @Name.
  final Map<String, String> zusagen;

  /// uid → Mitfahr-Angebot oder -Wunsch.
  final Map<String, Fahrt> fahrten;
}

/// "Ich fahre ab Braunau, 2 Plätze frei" oder "Suche Mitfahrt ab Ried".
class Fahrt {
  Fahrt(Map roh)
      : name = roh['name'] as String? ?? '',
        biete = roh['biete'] as bool? ?? true,
        plaetze = (roh['plaetze'] as num?)?.toInt() ?? 0,
        von = roh['von'] as String? ?? '';

  final String name;
  final bool biete;
  final int plaetze;
  final String von;
}

class Bewertung {
  Bewertung(DocumentSnapshot<Map<String, dynamic>> doc)
      : uid = doc.id,
        nutzerName = doc.data()?['nutzerName'] as String? ?? '',
        sterne = (doc.data()?['sterne'] as num?)?.toInt() ?? 0,
        tipp = doc.data()?['tipp'] as String? ?? '',
        erstellt =
            (doc.data()?['erstellt'] as Timestamp?)?.toDate() ?? DateTime.now();

  final String uid;
  final String nutzerName;
  final int sterne;
  final String tipp;
  final DateTime erstellt;
}

class Koeder {
  Koeder({
    this.id = '',
    required this.name,
    this.art = '',
    this.notiz = '',
    this.foto,
  });

  Koeder.ausDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()?['name'] as String? ?? '',
        art = doc.data()?['art'] as String? ?? '',
        notiz = doc.data()?['notiz'] as String? ?? '',
        foto = doc.data()?['foto'] as String?;

  final String id;
  final String name;
  final String art;
  final String notiz;

  /// Kleines Foto als Base64.
  final String? foto;

  Map<String, dynamic> daten() =>
      {'name': name, 'art': art, 'notiz': notiz, 'foto': foto};
}

class Ausflug {
  Ausflug({
    this.id = '',
    required this.gewaesser,
    required this.start,
    required this.ende,
    this.notiz = '',
  });

  Ausflug.ausDoc(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        gewaesser = doc.data()?['gewaesser'] as String? ?? '',
        start = (doc.data()?['start'] as Timestamp?)?.toDate() ?? DateTime.now(),
        ende = (doc.data()?['ende'] as Timestamp?)?.toDate() ?? DateTime.now(),
        notiz = doc.data()?['notiz'] as String? ?? '';

  final String id;
  final String gewaesser;
  final DateTime start;
  final DateTime ende;
  final String notiz;

  Duration get dauer => ende.difference(start);

  Map<String, dynamic> daten() => {
        'gewaesser': gewaesser,
        'start': Timestamp.fromDate(start),
        'ende': Timestamp.fromDate(ende),
        'notiz': notiz,
      };
}

/// Wird erst benutzt, wenn Firebase eingerichtet ist (Dart-Globals sind lazy).
final fangDienst = FangDienst();

/// Fänge in Firestore.
///
/// Öffentliche Fänge liegen in `faenge`, private in `nutzer/{uid}/privat`.
/// So kommt der Feed ohne zusammengesetzten Index aus. Fotos liegen
/// verkleinert als Base64 in `fotos/{fangId}` (funktioniert im Gratis-Tarif).
class FangDienst {
  final _db = FirebaseFirestore.instance;

  /// Ohne Netz bestätigt Firestore Schreibvorgänge erst, wenn wieder Empfang
  /// da ist. Die Änderung ist aber schon lokal gespeichert und wird später
  /// automatisch hochgeladen – deshalb nicht ewig warten.
  static Future<void> _offline(Future<void> schreiben) => schreiben.timeout(
        const Duration(seconds: 4),
        onTimeout: () {},
      );
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
  /// Gibt die ID des Fangs zurück.
  Future<String> speichern(
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
      await _offline(ziel.doc(id).update(daten));
    } else {
      if (vorher != null) {
        final alt = vorher.oeffentlich ? _oeff : _privat(vorher.uid);
        await _offline(alt.doc(id).delete());
      }
      await _offline(ziel.doc(id).set({
        ...daten,
        'petriHeil': <String>[],
        'erstellt': FieldValue.serverTimestamp(),
      }));
    }

    if (foto != null) {
      await _offline(_fotos.doc(id).set({
        'uid': fang.uid,
        'oeffentlich': fang.oeffentlich,
        'daten': base64Encode(foto),
      }));
      _fotoCache[id] = foto;
    } else if (fotoEntfernen) {
      await _offline(_fotos.doc(id).delete());
      _fotoCache.remove(id);
    } else if (hatFoto && vorher?.oeffentlich != fang.oeffentlich) {
      await _offline(_fotos.doc(id).update({'oeffentlich': fang.oeffentlich}));
    }
    return id;
  }

  // ── Fangorte (immer privat) ──

  CollectionReference<Map<String, dynamic>> _fangorte(String uid) =>
      _db.collection('nutzer/$uid/fangorte');

  Future<void> fangortSpeichern(String uid, String fangId, LatLng? ort) =>
      _offline(ort == null
          ? _fangorte(uid).doc(fangId).delete()
          : _fangorte(uid).doc(fangId).set({
              'lat': ort.latitude,
              'lng': ort.longitude,
            }));

  /// Fang-ID → Ort, nur für den Besitzer lesbar.
  Stream<Map<String, LatLng>> fangorte(String uid) =>
      _fangorte(uid).snapshots().map((s) => {
            for (final d in s.docs)
              d.id: LatLng((d.data()['lat'] as num).toDouble(),
                  (d.data()['lng'] as num).toDouble()),
          });

  Future<void> loeschen(Fang fang) async {
    final ort = fang.oeffentlich ? _oeff : _privat(fang.uid);
    await ort.doc(fang.id).delete();
    await _fangorte(fang.uid).doc(fang.id).delete().catchError((_) {});
    if (fang.hatFoto) await _fotos.doc(fang.id).delete();
    _fotoCache.remove(fang.id);
  }

  Future<void> petriHeil(Fang fang, String uid,
      {required bool an, String name = ''}) async {
    await _oeff.doc(fang.id).update({
      'petriHeil':
          an ? FieldValue.arrayUnion([uid]) : FieldValue.arrayRemove([uid]),
    });
    if (an) await _aktivitaet(fang, uid, name, 'petri', '');
  }

  // ── Kommentare ──

  CollectionReference<Map<String, dynamic>> _kommentare(String fangId) =>
      _db.collection('faenge/$fangId/kommentare');

  Stream<List<Eintrag>> kommentare(String fangId) => _kommentare(fangId)
      .orderBy('erstellt')
      .snapshots()
      .map((s) => s.docs.map(Eintrag.new).toList());

  Future<void> kommentieren(Fang fang, String uid, String name, String text) async {
    await _kommentare(fang.id).add({
      'uid': uid,
      'nutzerName': name,
      'text': text,
      'erstellt': FieldValue.serverTimestamp(),
    });
    await _aktivitaet(fang, uid, name, 'kommentar', text);
  }

  Future<void> kommentarLoeschen(String fangId, String id) =>
      _kommentare(fangId).doc(id).delete();

  // ── Aktivitäten (Benachrichtigungen in der App) ──

  CollectionReference<Map<String, dynamic>> _aktivitaeten(String uid) =>
      _db.collection('nutzer/$uid/aktivitaeten');

  Future<void> _aktivitaet(
      Fang fang, String von, String name, String typ, String text) async {
    if (fang.uid == von) return; // Keine Nachricht an sich selbst.
    try {
      await _aktivitaeten(fang.uid).add({
        'von': von,
        'nutzerName': name,
        'typ': typ,
        'text': text.length > 100 ? '${text.substring(0, 100)}…' : text,
        'bezug': fang.fischId,
        'erstellt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Nicht schlimm, wenn die Benachrichtigung fehlschlägt.
    }
  }

  Stream<List<Eintrag>> aktivitaeten(String uid) => _aktivitaeten(uid)
      .orderBy('erstellt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Eintrag.new).toList());

  Future<void> aktivitaetenLeeren(String uid) async {
    for (final d in (await _aktivitaeten(uid).get()).docs) {
      await d.reference.delete();
    }
  }

  // ── Angeltage ──

  CollectionReference<Map<String, dynamic>> get _treffen =>
      _db.collection('treffen');

  Stream<List<Treffen>> kommendeTreffen() => _treffen
      .where('zeit',
          isGreaterThan: Timestamp.fromDate(
              DateTime.now().subtract(const Duration(hours: 6))))
      .orderBy('zeit')
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Treffen.new).toList());

  Future<void> treffenAnlegen({
    required String uid,
    required String name,
    required String gewaesser,
    required DateTime zeit,
    required String text,
  }) =>
      _treffen.add({
        'uid': uid,
        'nutzerName': name,
        'gewaesser': gewaesser,
        'zeit': Timestamp.fromDate(zeit),
        'text': text,
        'zusagen': {uid: name},
      });

  Future<void> zusagen(String treffenId, String uid, String name,
          {required bool dabei}) =>
      _treffen.doc(treffenId).update({
        'zusagen.$uid': dabei ? name : FieldValue.delete(),
      });

  Future<void> fahrtSetzen(String treffenId, String uid,
          {required String name,
          required bool biete,
          required int plaetze,
          required String von}) =>
      _offline(_treffen.doc(treffenId).update({
        'fahrten.$uid': {
          'name': name,
          'biete': biete,
          'plaetze': plaetze,
          'von': von,
        },
      }));

  Future<void> fahrtLoeschen(String treffenId, String uid) =>
      _offline(_treffen.doc(treffenId).update({
        'fahrten.$uid': FieldValue.delete(),
      }));

  Future<void> treffenLoeschen(String id) => _treffen.doc(id).delete();

  // ── Premium (z. B. als Gewinn der Monats-Challenge) ──

  Future<DateTime?> premiumBis(String uid) async {
    try {
      final d = await _db.doc('premium/$uid').get();
      return (d.data()?['bis'] as Timestamp?)?.toDate();
    } catch (_) {
      return null;
    }
  }

  /// Nur der Admin darf das (siehe Regeln).
  Future<void> premiumVergeben(String uid, String grund, {int tage = 31}) async {
    final jetzt = DateTime.now();
    final bisher = await premiumBis(uid);
    final start = bisher != null && bisher.isAfter(jetzt) ? bisher : jetzt;
    await _db.doc('premium/$uid').set({
      'bis': Timestamp.fromDate(start.add(Duration(days: tage))),
      'grund': grund,
    });
  }

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

  /// Die neuesten öffentlichen Fänge für die Rangliste.
  Future<List<Fang>> neuesteFaenge({int anzahl = 500}) async {
    final s = await _oeff
        .orderBy('erstellt', descending: true)
        .limit(anzahl)
        .get();
    return s.docs.map((d) => Fang.fromFirestore(d, oeffentlich: true)).toList();
  }

  // ── Freunde ──

  CollectionReference<Map<String, dynamic>> _freunde(String uid) =>
      _db.collection('nutzer/$uid/freunde');

  /// Freunde als Map uid → @Name.
  Stream<Map<String, String>> freunde(String uid) =>
      _freunde(uid).snapshots().map((s) => {
            for (final d in s.docs) d.id: d.data()['name'] as String? ?? '',
          });

  /// Fügt einen Freund über seinen @Namen hinzu. Gibt den Namen zurück.
  Future<String> freundHinzufuegen(String meineUid, String handle) async {
    final doc = await _db.doc('namen/$handle').get();
    final uid = doc.data()?['uid'] as String?;
    if (uid == null) throw Exception('@$handle gibt es nicht.');
    if (uid == meineUid) throw Exception('Das bist du selbst 😉');
    await _freunde(meineUid).doc(uid).set({
      'name': handle,
      'seit': FieldValue.serverTimestamp(),
    });
    return handle;
  }

  Future<void> freundEntfernen(String meineUid, String freundUid) =>
      _freunde(meineUid).doc(freundUid).delete();

  /// Öffentliche Fänge eines Nutzers, neueste zuerst.
  Future<List<Fang>> faengeVon(String uid) async {
    final s = await _oeff.where('uid', isEqualTo: uid).get();
    return s.docs.map((d) => Fang.fromFirestore(d, oeffentlich: true)).toList()
      ..sort((a, b) => b.datum.compareTo(a.datum));
  }

  /// Die neuesten Fänge aller Freunde.
  Future<List<Fang>> freundeFeed(Iterable<String> uids) async {
    final listen = await Future.wait(uids.map(faengeVon));
    return listen.expand((l) => l).toList()
      ..sort((a, b) => b.datum.compareTo(a.datum));
  }

  // ── Preisvorschläge ──

  Future<void> preisVorschlagen({
    required String uid,
    required String nutzerName,
    required String gewaesserId,
    required String gewaesserName,
    required String art,
    required double euro,
    required String notiz,
  }) =>
      _db.collection('preisvorschlaege').add({
        'uid': uid,
        'nutzerName': nutzerName,
        'gewaesserId': gewaesserId,
        'gewaesserName': gewaesserName,
        'art': art,
        'euro': euro,
        'notiz': notiz,
        'erstellt': FieldValue.serverTimestamp(),
      });

  /// Offene Vorschläge (nur für den Administrator).
  Stream<List<PreisVorschlag>> preisVorschlaege() => _db
      .collection('preisvorschlaege')
      .orderBy('erstellt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(PreisVorschlag.new).toList());

  /// Gibt einen Vorschlag frei: der Preis erscheint bei allen in der App.
  Future<void> preisFreigeben(PreisVorschlag v) async {
    final batch = _db.batch()
      ..set(
        _db.doc('gepruefte_preise/${v.gewaesserId}'),
        {
          'preise': FieldValue.arrayUnion([
            {
              'art': v.art,
              'euro': v.euro,
              'von': v.nutzerName,
              'datum': DateTime.now().millisecondsSinceEpoch,
            },
          ]),
        },
        SetOptions(merge: true),
      )
      ..delete(_db.doc('preisvorschlaege/${v.id}'));
    await batch.commit();
  }

  Future<void> preisAblehnen(PreisVorschlag v) =>
      _db.doc('preisvorschlaege/${v.id}').delete();

  /// Geprüfte Community-Preise eines Gewässers.
  Stream<List<CommunityPreis>> gepruefteCommunityPreise(String gewaesserId) => _db
      .doc('gepruefte_preise/$gewaesserId')
      .snapshots()
      .map((d) => [
            for (final p in (d.data()?['preise'] as List?) ?? const [])
              CommunityPreis(p as Map<String, dynamic>),
          ]);

  /// Admin: einen freigegebenen Preis wieder entfernen.
  Future<void> gepruefterPreisEntfernen(String gewaesserId, CommunityPreis p) =>
      _db.doc('gepruefte_preise/$gewaesserId').update({
        'preise': FieldValue.arrayRemove([p.roh]),
      });

  // ── Gewässer-Infos von Anglern ──

  /// "Mehr Infos gewünscht": landet als Wunsch beim Administrator.
  Future<void> infosWuenschen({
    required String uid,
    required String nutzerName,
    required String gewaesserId,
    required String gewaesserName,
  }) =>
      _offline(_wuensche.add({
        'uid': uid,
        'nutzerName': nutzerName,
        'text': '@$nutzerName wünscht sich mehr Infos zum Gewässer '
            '"$gewaesserName" (Fischarten, Lizenz, Preise).',
        'typ': 'infos',
        'bezug': gewaesserId,
        'status': 'neu',
        'erstellt': FieldValue.serverTimestamp(),
      }));

  Future<void> infosVorschlagen({
    required String uid,
    required String nutzerName,
    required String gewaesserId,
    required String gewaesserName,
    required List<String> fische,
    required String verkauf,
    required String url,
    required String text,
  }) =>
      _offline(_db.collection('gewaesser_infos').add({
        'uid': uid,
        'nutzerName': nutzerName,
        'gewaesserId': gewaesserId,
        'gewaesserName': gewaesserName,
        'fische': fische,
        'verkauf': verkauf,
        'url': url,
        'text': text,
        'erstellt': FieldValue.serverTimestamp(),
      }));

  /// Offene Info-Vorschläge (nur für den Administrator).
  Stream<List<InfoVorschlag>> infoVorschlaege() => _db
      .collection('gewaesser_infos')
      .orderBy('erstellt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(InfoVorschlag.new).toList());

  Future<void> infoFreigeben(InfoVorschlag v) async {
    final eintrag = {
      if (v.verkauf.isNotEmpty) 'verkauf': v.verkauf,
      if (v.url.isNotEmpty) 'url': v.url,
      if (v.text.isNotEmpty) 'text': v.text,
      'von': v.nutzerName,
      'datum': DateTime.now().millisecondsSinceEpoch,
    };
    final batch = _db.batch()
      ..set(
        _db.doc('gepruefte_infos/${v.gewaesserId}'),
        {
          'name': v.gewaesserName,
          if (v.fische.isNotEmpty) 'fische': FieldValue.arrayUnion(v.fische),
          if (eintrag.length > 2) 'eintraege': FieldValue.arrayUnion([eintrag]),
        },
        SetOptions(merge: true),
      )
      ..delete(_db.doc('gewaesser_infos/${v.id}'));
    await batch.commit();
  }

  Future<void> infoAblehnen(InfoVorschlag v) =>
      _db.doc('gewaesser_infos/${v.id}').delete();

  Stream<GepruefteInfos> gepruefteInfos(String gewaesserId) => _db
      .doc('gepruefte_infos/$gewaesserId')
      .snapshots()
      .map((d) => GepruefteInfos(d.data()));

  /// Admin: geprüfte Infos eines Gewässers ganz entfernen.
  Future<void> gepruefteInfosLoeschen(String gewaesserId) =>
      _db.doc('gepruefte_infos/$gewaesserId').delete();

  /// IDs der Gewässer, bei denen Angler [fischId] eingetragen haben (geprüft).
  Future<Set<String>> gewaesserMitFischLautInfos(String fischId) async {
    final s = await _db
        .collection('gepruefte_infos')
        .where('fische', arrayContains: fischId)
        .limit(500)
        .get();
    return {for (final d in s.docs) d.id};
  }

  /// Gewässernamen, an denen [fischId] schon gefangen wurde (öffentliche Fänge).
  Future<Map<String, int>> gewaesserMitFang(String fischId) async {
    final s = await _oeff.where('fischId', isEqualTo: fischId).limit(500).get();
    final zaehler = <String, int>{};
    for (final d in s.docs) {
      final g = (d.data()['gewaesser'] as String? ?? '').trim();
      if (g.isNotEmpty) zaehler[g] = (zaehler[g] ?? 0) + 1;
    }
    return zaehler;
  }

  // ── Wassertemperatur (von Anglern gemessen) ──

  CollectionReference<Map<String, dynamic>> _messungen(String gewaesserId) =>
      _db.collection('wassertemp/$gewaesserId/messungen');

  Stream<List<Messung>> wassertemperaturen(String gewaesserId) =>
      _messungen(gewaesserId)
          .orderBy('zeit', descending: true)
          .limit(5)
          .snapshots()
          .map((s) => s.docs.map(Messung.new).toList());

  Future<void> wassertemperaturMelden(
          String gewaesserId, String uid, String name, double grad) =>
      _offline(_messungen(gewaesserId).add({
        'uid': uid,
        'nutzerName': name,
        'grad': grad,
        'zeit': FieldValue.serverTimestamp(),
      }));

  Future<void> messungLoeschen(String gewaesserId, String id) =>
      _messungen(gewaesserId).doc(id).delete();

  // ── Gewässer: Bewertungen und aktuelle Fänge ──

  CollectionReference<Map<String, dynamic>> _bewertungen(String gewaesserId) =>
      _db.collection('gewaesser/$gewaesserId/bewertungen');

  /// Eine Bewertung pro Nutzer (Dokument-ID = uid).
  Stream<List<Bewertung>> bewertungen(String gewaesserId) =>
      _bewertungen(gewaesserId)
          .orderBy('erstellt', descending: true)
          .limit(100)
          .snapshots()
          .map((s) => s.docs.map(Bewertung.new).toList());

  Future<void> bewerten(String gewaesserId, String uid, String name,
          int sterne, String tipp) =>
      _offline(_bewertungen(gewaesserId).doc(uid).set({
        'nutzerName': name,
        'sterne': sterne,
        'tipp': tipp,
        'erstellt': FieldValue.serverTimestamp(),
      }));

  Future<void> bewertungLoeschen(String gewaesserId, String uid) =>
      _bewertungen(gewaesserId).doc(uid).delete();

  /// Öffentliche Fänge an einem Gewässer, neueste zuerst.
  Future<List<Fang>> faengeAn(String gewaesserName) async {
    final s = await _oeff.where('gewaesser', isEqualTo: gewaesserName).get();
    return s.docs.map((d) => Fang.fromFirestore(d, oeffentlich: true)).toList()
      ..sort((a, b) => b.datum.compareTo(a.datum));
  }

  // ── Ausrüstung (privat) ──

  CollectionReference<Map<String, dynamic>> _ausruestung(String uid) =>
      _db.collection('nutzer/$uid/ausruestung');

  Stream<List<Ausruestung>> ausruestung(String uid) => _ausruestung(uid)
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(Ausruestung.ausDoc).toList());

  Future<void> ausruestungSpeichern(String uid, Ausruestung a) => _offline(
      (a.id.isEmpty ? _ausruestung(uid).doc() : _ausruestung(uid).doc(a.id))
          .set({'name': a.name, 'art': a.art, 'notiz': a.notiz}));

  Future<void> ausruestungLoeschen(String uid, String id) =>
      _offline(_ausruestung(uid).doc(id).delete());

  // ── Köder-Box (privat) ──

  CollectionReference<Map<String, dynamic>> _koeder(String uid) =>
      _db.collection('nutzer/$uid/koeder');

  Stream<List<Koeder>> koederBox(String uid) => _koeder(uid)
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(Koeder.ausDoc).toList());

  Future<void> koederSpeichern(String uid, Koeder k) => _offline((k.id.isEmpty
          ? _koeder(uid).doc()
          : _koeder(uid).doc(k.id))
      .set(k.daten()));

  Future<void> koederLoeschen(String uid, String id) =>
      _offline(_koeder(uid).doc(id).delete());

  // ── Angel-Ausflüge (privat) ──

  CollectionReference<Map<String, dynamic>> _ausfluege(String uid) =>
      _db.collection('nutzer/$uid/ausfluege');

  Stream<List<Ausflug>> ausfluege(String uid) => _ausfluege(uid)
      .orderBy('start', descending: true)
      .snapshots()
      .map((s) => s.docs.map(Ausflug.ausDoc).toList());

  Future<void> ausflugSpeichern(String uid, Ausflug a) => _offline(
      (a.id.isEmpty ? _ausfluege(uid).doc() : _ausfluege(uid).doc(a.id))
          .set(a.daten()));

  Future<void> ausflugLoeschen(String uid, String id) =>
      _offline(_ausfluege(uid).doc(id).delete());

  // ── Vereins-Termine (nur der Admin schreibt) ──

  Stream<List<Eintrag>> vereinsTermine(String vereinId) => _db
      .collection('vereine/$vereinId/termine')
      .orderBy('erstellt')
      .snapshots()
      .map((s) => s.docs.map(Eintrag.new).toList());

  Future<void> vereinsTerminAnlegen(String vereinId, String text, String datum) =>
      _db.collection('vereine/$vereinId/termine').add({
        'text': text,
        'bezug': datum,
        'erstellt': FieldValue.serverTimestamp(),
      });

  Future<void> vereinsTerminLoeschen(String vereinId, String id) =>
      _db.doc('vereine/$vereinId/termine/$id').delete();

  // ── Blockieren ──

  CollectionReference<Map<String, dynamic>> _blockiert(String uid) =>
      _db.collection('nutzer/$uid/blockiert');

  /// uid → @Name der blockierten Nutzer.
  Stream<Map<String, String>> blockiert(String uid) =>
      _blockiert(uid).snapshots().map((s) => {
            for (final d in s.docs) d.id: d.data()['name'] as String? ?? '',
          });

  Future<void> blockieren(String uid, String andere, String name) async {
    await _offline(_blockiert(uid).doc(andere).set({'name': name}));
    // Blockierte sind auch keine Freunde mehr.
    await _offline(_freunde(uid).doc(andere).delete());
  }

  Future<void> entblocken(String uid, String andere) =>
      _offline(_blockiert(uid).doc(andere).delete());

  // ── Wünsche ──

  CollectionReference<Map<String, dynamic>> get _wuensche =>
      _db.collection('wuensche');

  Future<void> wunschSenden({
    required String uid,
    required String nutzerName,
    required String text,
  }) =>
      _wuensche.add({
        'uid': uid,
        'nutzerName': nutzerName,
        'text': text,
        'status': 'neu',
        'erstellt': FieldValue.serverTimestamp(),
      });

  /// Eigene Wünsche – oder alle, wenn [admin] true ist.
  Stream<List<Eintrag>> wuensche({required String uid, required bool admin}) {
    final abfrage = admin
        ? _wuensche.orderBy('erstellt', descending: true).limit(200)
        : _wuensche.where('uid', isEqualTo: uid);
    return abfrage.snapshots().map((s) => s.docs.map(Eintrag.new).toList()
      ..sort((a, b) => b.erstellt.compareTo(a.erstellt)));
  }

  Future<void> wunschBeantworten(String id, {String? status, String? antwort}) =>
      _wuensche.doc(id).update({
        'status': ?status,
        'antwort': ?antwort,
      });

  Future<void> wunschLoeschen(String id) => _wuensche.doc(id).delete();

  /// Alle Meldungen (nur für den Administrator lesbar).
  Stream<List<Eintrag>> meldungen() => _db
      .collection('meldungen')
      .orderBy('erstellt', descending: true)
      .limit(200)
      .snapshots()
      .map((s) => s.docs.map(Eintrag.new).toList());

  Future<void> meldungLoeschen(String id) =>
      _db.doc('meldungen/$id').delete();

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
    for (final sammlung in [_fangorte(uid), _aktivitaeten(uid), _freunde(uid),
        _koeder(uid), _ausfluege(uid), _blockiert(uid), _ausruestung(uid)]) {
      for (final d in (await sammlung.get()).docs) {
        await d.reference.delete();
      }
    }
    for (final doc in [...oeff.docs, ...privat.docs]) {
      if (doc.data()['hatFoto'] == true) await _fotos.doc(doc.id).delete();
      await doc.reference.delete();
    }
    if (name != null) await _db.doc('namen/${name.toLowerCase()}').delete();
    await _db.doc('nutzer/$uid').delete();
  }
}
