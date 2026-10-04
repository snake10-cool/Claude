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
  Iterable<Gewaesser> suchen(String text, {int max = 30}) {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return gewaesserListe;
    return liste
        .where((g) => g.anzeigeName.toLowerCase().contains(t))
        .take(max);
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
