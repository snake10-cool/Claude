import 'package:buecherwurm/data/fragebogen.dart';
import 'package:buecherwurm/main.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Ganzer Ablauf: Fragebogen, Bücher wählen, Quiz', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final speicher = await Speicher.laden();
    await tester.pumpWidget(BuecherwurmApp(speicher: speicher));

    await tester.enterText(find.byType(TextField), 'Lea');
    await tester.pump();
    await tester.tap(find.text('Fragebogen starten'));
    await tester.pumpAndSettle();

    for (final frage in fragebogen) {
      expect(find.text(frage.text), findsOneWidget);
      await tester.tap(find.text(frage.optionen.first.text));
      await tester.pump(const Duration(milliseconds: 300));
      // Einfachauswahl springt von selbst weiter.
      if (frage.mehrfach) await tester.tap(find.text('Weiter'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Was hast du schon gelesen?'), findsOneWidget);
    await tester.tap(find.text('Pippi Langstrumpf'));
    await tester.pump();
    await tester.tap(find.text('Fertig (1 gewählt)'));
    await tester.pumpAndSettle();

    expect(speicher.einrichtungFertig, isTrue);
    expect(find.text('Hallo Lea! 👋'), findsOneWidget);

    // Quiz für Pippi: Ehrenwort, dann alle Fragen richtig beantworten.
    await tester.tap(find.text('Quiz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pippi Langstrumpf'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Versprochen!'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Los geht\'s'));
    await tester.pump();
    final pippi = speicher.buch('pippi')!;
    for (var i = 0; i < pippi.quiz.length; i++) {
      final frage = pippi.quiz.firstWhere((f) => find.text(f.text).evaluate().isNotEmpty);
      await tester.tap(find.text(frage.richtig));
      await tester.pump();
      await tester.tap(find.text(i == pippi.quiz.length - 1 ? 'Ergebnis' : 'Nächste Frage'));
      await tester.pump();
    }
    await tester.pump();
    expect(find.text('${pippi.quiz.length} von ${pippi.quiz.length} richtig'), findsOneWidget);
    expect(speicher.bewiesen, 1);
    expect(speicher.punkte, greaterThanOrEqualTo(30));
    await tester.tap(find.text('Fertig'));
    await tester.pumpAndSettle();
  });
}
