import 'dart:convert';
import 'dart:io' show gzip;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/buch.dart';

/// Quizfragen, die nicht im Programmcode stehen (zu viele): aus
/// tools/quellen/quiz_zusatz/ von tools/quiz_packen.py gepackt, beim Start geladen.
/// Gelten für Bücher aus allen Katalogen, auch für die aus Wikidata.
final zusatzFragen = <String, List<Frage>>{};
final zusatzStufe = <String, Schwierigkeit>{};

Future<void> quizZusatzLaden() async {
  try {
    final daten = await rootBundle.load('assets/daten/quiz_zusatz.json.gz');
    final (fragen, stufen) = await compute(quizEntpacken, daten.buffer.asUint8List());
    zusatzFragen
      ..clear()
      ..addAll(fragen);
    zusatzStufe
      ..clear()
      ..addAll(stufen);
  } catch (e) {
    debugPrint('Zusatz-Quizze nicht geladen: $e');
  }
}

/// Format: {buchId: {"s": "leicht|mittel|schwierig" (optional), "q": [[Frage, richtig, falsch, falsch, falsch], …]}}
(Map<String, List<Frage>>, Map<String, Schwierigkeit>) quizEntpacken(Uint8List gepackt) {
  final roh = jsonDecode(utf8.decode(gzip.decode(gepackt))) as Map<String, dynamic>;
  final fragen = <String, List<Frage>>{};
  final stufen = <String, Schwierigkeit>{};
  roh.forEach((id, wert) {
    final w = wert as Map<String, dynamic>;
    fragen[id] = [
      for (final f in (w['q'] as List).cast<List>()) Frage(f.first as String, [for (final a in f.skip(1)) a as String]),
    ];
    final s = Schwierigkeit.values.asNameMap()[w['s']];
    if (s != null) stufen[id] = s;
  });
  return (fragen, stufen);
}
