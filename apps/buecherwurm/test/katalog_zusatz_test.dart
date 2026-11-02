import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:buecherwurm/data/katalog_zusatz.dart';
import 'package:buecherwurm/models/buch.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;

void main() {
  test('Wikidata-Paket wird richtig entpackt', () {
    final roh = [
      {'id': 'wd_Q1', 't': 'Der Zauberwald', 'a': 'Anna Muster', 'j': 1932, 's': 0, 'z': 'kinder',
        'g': ['fantasy', 'klassiker'], 'b': 'Kinderbuch', 'm': 0},
      {'id': 'wd_Q2', 't': 'Nacht', 'a': 'B', 'j': 2001, 's': 300, 'z': 'erwachsene', 'g': ['horror'], 'b': '', 'm': 16},
    ];
    final gepackt = Uint8List.fromList(gzip.encode(utf8.encode(jsonEncode(roh))));
    final buecher = entpacken(gepackt);
    expect(buecher.length, 2);
    expect(buecher.first.zielgruppe, Zielgruppe.kinder);
    expect(buecher.first.tags, {'fantasy', 'klassiker'});
    expect(buecher.last.minAlter, 16);
    expect(buecher.every((b) => !b.hatQuiz), isTrue);
  });
}
