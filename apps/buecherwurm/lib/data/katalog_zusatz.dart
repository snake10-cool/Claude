import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/buch.dart';

/// Bücher aus Wikidata (tools/wikidata_buecher.py) – zu viele für den
/// Programmcode, daher als gepacktes Datenpaket, beim Start geladen.
final katalogZusatz = <Buch>[];
final _nachId = <String, Buch>{};

Buch? zusatzBuch(String id) => _nachId[id];

Future<void> katalogZusatzLaden() async {
  try {
    final daten = await rootBundle.load('assets/daten/katalog_wikidata.json.gz');
    final liste = await compute(entpacken, daten.buffer.asUint8List());
    katalogZusatz
      ..clear()
      ..addAll(liste);
    _nachId
      ..clear()
      ..addEntries(liste.map((b) => MapEntry(b.id, b)));
  } catch (e) {
    debugPrint('Zusatz-Katalog nicht geladen: $e');
  }
}

/// Läuft in einem eigenen Isolate (20.000 Bücher entpacken dauert kurz).
List<Buch> entpacken(Uint8List gepackt) {
  final roh = jsonDecode(utf8.decode(gzip.decode(gepackt))) as List;
  return [
    for (final j in roh.cast<Map<String, dynamic>>())
      Buch(
        id: j['id'] as String,
        titel: j['t'] as String,
        autor: j['a'] as String? ?? 'Unbekannt',
        jahr: j['j'] as int? ?? 0,
        seiten: j['s'] as int? ?? 0,
        zielgruppe: Zielgruppe.values.asNameMap()[j['z']] ?? Zielgruppe.erwachsene,
        tags: {...(j['g'] as List? ?? const []).cast<String>()},
        beschreibung: j['b'] as String? ?? '',
        minAlter: j['m'] as int? ?? 0,
      ),
  ];
}
