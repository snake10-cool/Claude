import 'package:buecherwurm/data/fragebogen.dart';
import 'package:buecherwurm/data/katalog.dart';
import 'package:buecherwurm/models/buch.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;

void main() {
  test('Buch-IDs und Titel sind eindeutig', () {
    final ids = katalog.map((b) => b.id).toList();
    expect(ids.toSet().length, ids.length);
    final titel = katalog.map((b) => b.titel.toLowerCase()).toList();
    final doppelt = titel.where((t) => titel.indexOf(t) != titel.lastIndexOf(t)).toSet();
    expect(doppelt, isEmpty);
  });

  test('Alle Tags sind bekannt', () {
    for (final b in katalog) {
      for (final t in b.tags) {
        expect(Tags.namen.containsKey(t), isTrue, reason: '${b.id}: $t');
      }
    }
    for (final f in fragebogen) {
      for (final o in f.optionen) {
        for (final t in o.gewichte.keys) {
          expect(Tags.namen.containsKey(t), isTrue, reason: '${f.id}/${o.id}: $t');
        }
      }
    }
  });

  test('Jedes Quiz-Buch hat mindestens 3 Fragen mit 4 verschiedenen Antworten', () {
    for (final b in katalogMitQuiz) {
      expect(b.quiz.length, greaterThanOrEqualTo(3), reason: b.id);
      for (final f in b.quiz) {
        expect(f.antworten.length, 4, reason: '${b.id}: ${f.text}');
        expect(f.antworten.toSet().length, 4, reason: '${b.id}: ${f.text}');
      }
    }
  });

  test('Fragebogen-IDs sind eindeutig', () {
    final ids = fragebogen.map((f) => f.id).toList();
    expect(ids.toSet().length, ids.length);
    for (final f in fragebogen) {
      final o = f.optionen.map((o) => o.id).toList();
      expect(o.toSet().length, o.length, reason: f.id);
    }
  });
}
