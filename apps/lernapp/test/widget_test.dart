import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lernapp/data/faecher.dart';
import 'package:lernapp/main.dart';
import 'package:lernapp/models/lehrplan.dart';
import 'package:lernapp/services/fortschritt.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Jede Klasse hat Themen in allen Hauptfächern', () {
    for (final stufe in Stufe.values) {
      for (final fach in hauptfaecher) {
        expect(themen(fach, stufe), isNotEmpty, reason: '${fach.name} $stufe');
      }
    }
  });

  test('Alle Aufgaben sind gültig', () {
    final ids = <String>{};
    for (final stufe in Stufe.values) {
      for (final fach in hauptfaecher) {
        for (final thema in themen(fach, stufe)) {
          expect(ids.add(thema.id), isTrue, reason: 'ID doppelt: ${thema.id}');
          // Zufallsgeneratoren mehrfach prüfen.
          for (var seed = 0; seed < 200; seed++) {
            final a = thema.generator(Random(seed));
            final antworten = a.gemischt(Random(seed));
            final grund = '${thema.id}: ${a.frage}';
            expect(a.frage, isNotEmpty, reason: grund);
            expect(antworten, contains(a.richtig), reason: grund);
            expect(antworten.length, greaterThanOrEqualTo(2), reason: grund);
            expect(antworten.toSet().length, antworten.length, reason: grund);
          }
        }
      }
    }
  });

  test('Sterne', () {
    expect(Fortschritt.sterneFuer(10, 10), 3);
    expect(Fortschritt.sterneFuer(7, 10), 2);
    expect(Fortschritt.sterneFuer(5, 10), 1);
    expect(Fortschritt.sterneFuer(4, 10), 0);
  });

  testWidgets('Klasse wählen und eine Aufgabe lösen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final fortschritt = await Fortschritt.laden();
    await tester.pumpWidget(LernApp(fortschritt: fortschritt));
    expect(find.text('In welche Klasse gehst du?'), findsOneWidget);

    await tester.tap(find.text('2').first); // VS 2
    await tester.pumpAndSettle();
    expect(find.text('Hauptfächer'), findsOneWidget);
    expect(fortschritt.stufe, Stufe.vs2);

    await tester.tap(find.text('Mathematik'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kleines Einmaleins'));
    await tester.pumpAndSettle();
    expect(find.text('Aufgabe 1 von 10'), findsOneWidget);
  });
}
