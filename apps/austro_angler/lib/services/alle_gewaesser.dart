import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

import '../data/bekannte_fische.dart';
import '../data/gewaesser.dart';
import '../models/bundesland.dart';
import '../models/gewaesser.dart';

/// Alle Gewässer Österreichs: die geprüften aus `gewaesser.dart` plus alle
/// benannten Gewässer aus OpenStreetMap (assets/daten/gewaesser_at.json.gz,
/// erzeugt von tools/gewaesser_holen.py).
class AlleGewaesser extends ChangeNotifier {
  AlleGewaesser._();

  static final instanz = AlleGewaesser._();

  bool geladen = false;
  String stand = '';

  /// Geprüfte zuerst, danach OSM.
  List<Gewaesser> liste = gewaesserListe;

  /// Bezirke je Bundesland (alphabetisch).
  final Map<Bundesland, List<String>> bezirke = {};

  /// Gemeinden je "Bundesland|Bezirk" (alphabetisch).
  final Map<String, List<String>> gemeinden = {};

  final Map<String, Gewaesser> _nachName = {};

  /// Mittelpunkt je "Bundesland|Bezirk|Gemeinde".
  final Map<String, LatLng> ortMitte = {};

  /// Angelgeschäfte aus OpenStreetMap.
  List<Angelgeschaeft> geschaefte = const [];

  LatLng? mitteVon(Bundesland land, String bezirk, String gemeinde) =>
      ortMitte['${land.name}|$bezirk|$gemeinde'];

  Future<void>? _laden;

  Future<void> laden() => _laden ??= _ladeJetzt();

  Future<void> _ladeJetzt() async {
    try {
      final daten = await rootBundle.load('assets/daten/gewaesser_at.json.gz');
      final roh = await compute(_entpacken, daten.buffer.asUint8List());
      _uebernehmen(roh);
    } catch (e) {
      debugPrint('Gewässerliste nicht geladen: $e');
      liste = [
        for (final g in gewaesserListe)
          if (zuordnung[g.id] case final z?)
            g.mitOrt(bezirk: z.bezirk, gemeinden: z.gemeinden)
          else
            g,
      ];
      for (final g in liste) {
        _nachName[g.anzeigeName.toLowerCase()] = g;
      }
    }
    geladen = true;
    notifyListeners();
  }

  void _uebernehmen(Map<String, dynamic> roh) {
    stand = roh['stand'] as String? ?? '';
    final laender = [
      for (final n in roh['laender'] as List) Bundesland.ausName(n as String),
    ];
    final bez = [
      for (final b in roh['bezirke'] as List)
        (name: b[0] as String, land: laender[b[1] as int]),
    ];
    final gem = [
      for (final g in roh['gemeinden'] as List)
        (name: g[0] as String, bezirk: g[1] as int),
    ];
    for (final g in roh['gemeinden'] as List) {
      final b = bez[g[1] as int];
      if (b.land == null || (g as List).length < 4) continue;
      ortMitte['${b.land!.name}|${b.name}|${g[0]}'] =
          LatLng((g[2] as num).toDouble(), (g[3] as num).toDouble());
    }
    geschaefte = [
      for (final l in (roh['geschaefte'] as List?) ?? const [])
        if (bez[l[4] as int].land case final land?)
          Angelgeschaeft(
            name: l[0] as String,
            position: LatLng((l[1] as num).toDouble(), (l[2] as num).toDouble()),
            land: land,
            bezirk: bez[l[4] as int].name,
            ort: (l[3] as int) >= 0 ? gem[l[3] as int].name : '',
            website: l[5] as String,
            telefon: l[6] as String,
            oeffnungszeiten: l[7] as String,
            adresse: l[8] as String,
          ),
    ];

    // Geprüfte Gewässer ersetzen gleichnamige OSM-Einträge im selben Bezirk
    // und übernehmen deren Gemeinden (für den Ort-Filter).
    final geprueft = <String, Gewaesser>{};
    final ersetzt = <String, String>{}; // "name|bezirk" -> geprüfte ID
    final gemZusatz = <String, Set<String>>{};
    for (final g in gewaesserListe) {
      final z = zuordnung[g.id];
      if (z == null) continue;
      for (final n in z.osmNamen) {
        ersetzt['${n.toLowerCase()}|${z.bezirk}'] = g.id;
      }
      gemZusatz[g.id] = {...z.gemeinden};
    }

    final osm = <Gewaesser>[];
    for (final e in roh['gewaesser'] as List) {
      final orte = [for (final i in e[5] as List) gem[i as int]];
      final bezirkIndex = orte.isNotEmpty ? orte.first.bezirk : e[7] as int;
      final b = bez[bezirkIndex];
      final land = b.land;
      if (land == null) continue;
      final name = e[1] as String;
      String? ersetztDurch;
      for (final teil in _teile(name)) {
        ersetztDurch ??= ersetzt['$teil|${b.name}'];
      }
      if (ersetztDurch != null) {
        gemZusatz[ersetztDurch]!.addAll(orte.map((o) => o.name));
        continue;
      }
      BekannteFische? bekannt;
      for (final teil in _teile(name)) {
        final b = bekannteFische[teil];
        if (b != null && (b.land == null || b.land == land)) {
          bekannt ??= b;
        }
      }
      osm.add(Gewaesser.osm(
        id: e[0] as String,
        name: name,
        typ: switch (e[2]) {
          'f' => GewaesserTyp.fluss,
          'k' => GewaesserTyp.kanal,
          's' => GewaesserTyp.see,
          't' => GewaesserTyp.teich,
          _ => GewaesserTyp.bach,
        },
        land: land,
        bezirk: b.name,
        gemeinden: [for (final o in orte) o.name],
        position: LatLng((e[3] as num).toDouble(), (e[4] as num).toDouble()),
        groesse: (e[6] as num).toDouble(),
        stand: stand,
        bekannteFische: bekannt?.fische,
      ));
    }

    for (final g in gewaesserListe) {
      final z = zuordnung[g.id];
      geprueft[g.id] = z == null
          ? g
          : g.mitOrt(bezirk: z.bezirk, gemeinden: gemZusatz[g.id]!.toList()..sort());
    }

    liste = [...geprueft.values, ...osm];

    // Filter-Listen
    final bezSets = <Bundesland, Set<String>>{};
    final gemSets = <String, Set<String>>{};
    for (final b in bez) {
      if (b.land != null) bezSets.putIfAbsent(b.land!, () => {}).add(b.name);
    }
    for (final g in gem) {
      final b = bez[g.bezirk];
      if (b.land == null) continue;
      gemSets.putIfAbsent('${b.land!.name}|${b.name}', () => {}).add(g.name);
    }
    for (final e in bezSets.entries) {
      bezirke[e.key] = e.value.toList()..sort(_deutsch);
    }
    for (final e in gemSets.entries) {
      gemeinden[e.key] = e.value.toList()..sort(_deutsch);
    }
    for (final g in liste.reversed) {
      _nachName[g.anzeigeName.toLowerCase()] = g;
    }
  }

  List<String> gemeindenVon(Bundesland land, String bezirk) =>
      gemeinden['${land.name}|$bezirk'] ?? const [];

  /// Gewässer zum Anzeigenamen (wie im Fangbuch gespeichert).
  Gewaesser? zuName(String name) => _nachName[name.trim().toLowerCase()];

  /// Für Eingabefelder: passende Gewässer, geprüfte zuerst.
  /// Ohne Text: die größten Gewässer im gewählten Bezirk bzw. Bundesland.
  /// Mit Text: Treffer im gewählten Bundesland zuerst, dann ganz Österreich.
  Iterable<Gewaesser> suchen(String text,
      {int max = 30, Bundesland? land, String bezirk = ''}) {
    final t = text.trim().toLowerCase();
    bool imGebiet(Gewaesser g) =>
        (land == null || g.land == land) &&
        (bezirk.isEmpty || g.bezirk == bezirk);
    if (t.isEmpty) {
      final nah = liste.where(imGebiet).toList()
        ..sort((a, b) {
          if (a.ausOsm != b.ausOsm) return a.ausOsm ? 1 : -1;
          return (b.groesse ?? 0).compareTo(a.groesse ?? 0);
        });
      return nah.take(max);
    }
    final treffer =
        liste.where((g) => g.anzeigeName.toLowerCase().contains(t)).toList();
    final hier = treffer.where(imGebiet);
    final land2 = treffer.where((g) => !imGebiet(g) && g.land == land);
    final rest = treffer.where((g) => !imGebiet(g) && g.land != land);
    return [...hier, ...land2, ...rest].take(max);
  }
}

final alleGewaesser = AlleGewaesser.instanz;

/// "Ibmer See / Heratinger See" -> ["ibmer see / heratinger see",
/// "ibmer see", "heratinger see"].
Iterable<String> _teile(String name) sync* {
  final n = name.toLowerCase();
  yield n;
  for (final t in n.split(RegExp(r' / |\(|\)'))) {
    final s = t.trim();
    if (s.isNotEmpty && s != n) yield s;
  }
}

Map<String, dynamic> _entpacken(Uint8List bytes) =>
    jsonDecode(utf8.decode(gzip.decode(bytes))) as Map<String, dynamic>;

/// Sortiert Umlaute wie im Telefonbuch (Ä wie A …).
int _deutsch(String a, String b) => _schluessel(a).compareTo(_schluessel(b));

String _schluessel(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss');

int deutschSortieren(String a, String b) => _deutsch(a, b);

class Angelgeschaeft {
  const Angelgeschaeft({
    required this.name,
    required this.position,
    required this.land,
    required this.bezirk,
    required this.ort,
    required this.website,
    required this.telefon,
    required this.oeffnungszeiten,
    required this.adresse,
  });

  final String name;
  final LatLng position;
  final Bundesland land;
  final String bezirk;
  final String ort;
  final String website;
  final String telefon;
  final String oeffnungszeiten;
  final String adresse;
}
