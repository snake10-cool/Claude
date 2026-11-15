import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:buecherwurm/data/quiz_zusatz.dart';
import 'package:buecherwurm/models/buch.dart';
import 'package:buecherwurm/services/quiz_fragen.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;

void main() {
  test('Zusatz-Quizze werden entpackt und zählen für das Buch', () {
    final roh = {
      'wd_Q1': {
        's': 'schwierig',
        'q': [for (var i = 0; i < 5; i++) ['Frage $i?', 'Richtig', 'A', 'B', 'C']],
      },
    };
    final (fragen, stufen) = quizEntpacken(Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(roh)))));
    expect(fragen['wd_Q1']!.length, 5);
    expect(fragen['wd_Q1']!.first.antworten.first, 'Richtig');
    expect(stufen['wd_Q1'], Schwierigkeit.schwierig);

    const buch = Buch(id: 'wd_Q1', titel: 'T', autor: 'A', jahr: 2000, seiten: 100, zielgruppe: Zielgruppe.kinder, tags: {}, beschreibung: '');
    expect(quizVerfuegbar(buch, null), isFalse);
    zusatzFragen.addAll(fragen);
    zusatzStufe.addAll(stufen);
    addTearDown(() {
      zusatzFragen.clear();
      zusatzStufe.clear();
    });
    expect(quizVerfuegbar(buch, null), isTrue);
    expect(stufeVon(buch), Schwierigkeit.schwierig);
    expect(quizFragen(buch, null).length, 5);
  });
}
