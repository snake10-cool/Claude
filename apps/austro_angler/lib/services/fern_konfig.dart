import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/bundesland.dart';
import '../models/fisch.dart';
import 'alle_gewaesser.dart';

/// Funktionen, die der Admin aus der Ferne abschalten kann (Schlüssel → Name).
const fernFunktionen = <String, String>{
  'darf_ich': 'Darf ich …?',
  'zielfisch': 'Zielfisch',
  'wetter': 'Wetter & Beißzeit',
  'feed': 'Community-Feed',
  'angeltage': 'Angeltage',
  'wettfischen': 'Eigene Wettfischen',
  'album': 'Arten-Sammelalbum',
  'fang_link': 'Fang-Link teilen',
  'csv': 'CSV-Export',
};

typedef FernBanner = ({String id, String text, bool warnung});
typedef GewaesserKorrektur = ({LatLng? position, String? hinweis});

/// Inhalt von `konfig/app` in Firestore, z. B.
/// ```
/// { aus: ['darf_ich'],
///   banner: {id: '2026-10-14', text: 'Wetter gestört', art: 'warnung'},
///   gewaesser: {'inn-braunau': {lat: 48.26, lon: 13.04, hinweis: '…'}},
///   schonzeiten: {'hecht': {'Oberösterreich': {von: '1.2.', bis: '31.3.',
///                                              mass: 50, ganzjaehrig: false}}} }
/// ```
class FernDaten {
  FernDaten({
    this.aus = const {},
    this.banner,
    this.gewaesser = const {},
    this.schonzeiten = const {},
  });

  final Set<String> aus;
  final FernBanner? banner;
  final Map<String, GewaesserKorrektur> gewaesser;
  final Map<String, Map<Bundesland, Regel>> schonzeiten;

  /// Liest das Dokument. Unbrauchbare Einträge werden übersprungen, damit ein
  /// Tippfehler in der Konsole nie die App stört.
  factory FernDaten.aus(Map<String, dynamic>? d) {
    if (d == null) return FernDaten();
    final aus = <String>{
      for (final a in (d['aus'] as List?) ?? const [])
        if (a is String) a,
    };

    FernBanner? banner;
    final b = d['banner'];
    if (b is Map && b['text'] is String && (b['text'] as String).trim().isNotEmpty) {
      final text = (b['text'] as String).trim();
      banner = (
        id: b['id'] is String ? b['id'] as String : text,
        text: text,
        warnung: b['art'] == 'warnung',
      );
    }

    final gewaesser = <String, GewaesserKorrektur>{};
    final g = d['gewaesser'];
    if (g is Map) {
      for (final e in g.entries) {
        final v = e.value;
        if (e.key is! String || v is! Map) continue;
        final lat = v['lat'], lon = v['lon'];
        final pos = lat is num && lon is num && lat.abs() <= 90 && lon.abs() <= 180
            ? LatLng(lat.toDouble(), lon.toDouble())
            : null;
        final hinweis = v['hinweis'] is String ? v['hinweis'] as String : null;
        if (pos != null || hinweis != null) {
          gewaesser[e.key as String] = (position: pos, hinweis: hinweis);
        }
      }
    }

    final schonzeiten = <String, Map<Bundesland, Regel>>{};
    final s = d['schonzeiten'];
    if (s is Map) {
      for (final f in s.entries) {
        if (f.key is! String || f.value is! Map) continue;
        final regeln = <Bundesland, Regel>{};
        for (final l in (f.value as Map).entries) {
          final land = Bundesland.ausName(l.key as String?);
          final r = l.value;
          if (land == null || r is! Map) continue;
          final regel = _regel(r);
          if (regel != null) regeln[land] = regel;
        }
        if (regeln.isNotEmpty) schonzeiten[f.key as String] = regeln;
      }
    }
    return FernDaten(
        aus: aus, banner: banner, gewaesser: gewaesser, schonzeiten: schonzeiten);
  }

  static Regel? _regel(Map r) {
    final mass = r['mass'] is num ? (r['mass'] as num).toInt() : null;
    final hinweis = r['hinweis'] is String ? r['hinweis'] as String : null;
    if (r['ganzjaehrig'] == true) {
      return Regel(ganzjaehrigGeschont: true, hinweis: hinweis);
    }
    final von = _tag(r['von']), bis = _tag(r['bis']);
    if ((von == null) != (bis == null)) return null; // nur eins von beiden
    return Regel(von: von, bis: bis, mindestmassCm: mass, hinweis: hinweis);
  }

  /// "1.2." oder "1.2" → Tag(1, 2).
  static Tag? _tag(Object? t) {
    if (t is! String) return null;
    final m = RegExp(r'^\s*(\d{1,2})\.(\d{1,2})\.?\s*$').firstMatch(t);
    if (m == null) return null;
    final tag = int.parse(m[1]!), monat = int.parse(m[2]!);
    if (monat < 1 || monat > 12 || tag < 1 || tag > 31) return null;
    return Tag(tag, monat);
  }
}

/// Hält die Fern-Einstellungen aktuell (Firestore merkt sich den letzten
/// Stand auch offline) und wendet Daten-Korrekturen sofort an.
class FernKonfig extends ChangeNotifier {
  FernKonfig._();

  static final instanz = FernKonfig._();

  FernDaten daten = FernDaten();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _abo;

  DocumentReference<Map<String, dynamic>> get _doc =>
      FirebaseFirestore.instance.doc('konfig/app');

  void starten() {
    _abo ??= _doc.snapshots().listen(
          (s) => uebernehmen(FernDaten.aus(s.data())),
          onError: (Object e) => debugPrint('Fern-Konfig: $e'),
        );
  }

  void uebernehmen(FernDaten neu) {
    daten = neu;
    regelKorrekturen
      ..clear()
      ..addAll(neu.schonzeiten);
    alleGewaesser.korrekturenSetzen(neu.gewaesser);
    notifyListeners();
  }

  bool an(String funktion) => !daten.aus.contains(funktion);

  // ── Nur Admin (siehe Regeln) ──

  Future<void> funktionSetzen(String funktion, {required bool an}) =>
      _doc.set({
        'aus': an
            ? FieldValue.arrayRemove([funktion])
            : FieldValue.arrayUnion([funktion]),
      }, SetOptions(merge: true));

  Future<void> bannerSetzen(String text, {required bool warnung}) =>
      _doc.set({
        'banner': text.trim().isEmpty
            ? FieldValue.delete()
            : {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'text': text.trim(),
                'art': warnung ? 'warnung' : 'info',
              },
      }, SetOptions(merge: true));
}

final fernKonfig = FernKonfig.instanz;

/// Kurzform für Widgets: ob eine Funktion gerade an ist.
bool funktionAn(String funktion) => fernKonfig.an(funktion);
