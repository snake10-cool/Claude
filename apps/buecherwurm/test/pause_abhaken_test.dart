import 'package:buecherwurm/main.dart';
import 'package:buecherwurm/screens/abhaken_screen.dart';
import 'package:buecherwurm/screens/quiz_screen.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Speicher> _speicher() async {
  SharedPreferences.setMockInitialValues({'name': 'Lea', 'einrichtungFertig': true, 'ehrenwort': true});
  return Speicher.laden();
}

Widget _app(Speicher s, Widget seite) => SpeicherScope(speicher: s, child: MaterialApp(home: seite));

void main() {
  testWidgets('Quiz pausieren und genau dort weitermachen', (tester) async {
    final s = await _speicher();
    final pippi = s.buch('pippi')!;
    await tester.pumpWidget(_app(s, Builder(builder: (context) {
      return Scaffold(
        body: TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => QuizScreen(buch: pippi))),
          child: const Text('öffnen'),
        ),
      );
    })));

    await tester.tap(find.text('öffnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Los geht\'s'));
    await tester.pump();
    // Erste Frage richtig beantworten, dann pausieren.
    final frage = pippi.quiz.firstWhere((f) => find.text(f.text).evaluate().isNotEmpty);
    await tester.tap(find.text(frage.richtig));
    await tester.pump();
    await tester.tap(find.text('Pausieren – später weitermachen'));
    await tester.pumpAndSettle();

    expect(s.pausierteQuizze['pippi']?['naechste'], 1);
    expect(s.pausierteQuizze['pippi']?['richtig'], 1);
    expect(s.quiz.containsKey('pippi'), isFalse);

    await tester.tap(find.text('öffnen'));
    await tester.pumpAndSettle();
    expect(find.text('Weiter geht\'s!'), findsOneWidget);
    expect(find.textContaining('Weiter mit Frage 2 von 10'), findsOneWidget);
  });

  test('Mitten in einer Frage geschlossen: diese Frage zählt als falsch', () async {
    final s = await _speicher();
    await s.quizPausieren('pippi', {
      'fragen': [
        {'f': 'A?', 'r': 'a', 'a': ['a', 'b', 'c', 'd']},
        {'f': 'B?', 'r': 'b', 'a': ['a', 'b', 'c', 'd']},
      ],
      'naechste': 0,
      'aktiv': true,
      'richtig': 0,
      'punkte': 0,
      'verlassen': 0,
    });
    // Neu laden wie nach einem App-Neustart.
    final neu = Speicher(await SharedPreferences.getInstance());
    expect(neu.pausierteQuizze['pippi']?['aktiv'], isTrue);
  });

  testWidgets('Bücher abhaken: ja, nein und Fortschritt', (tester) async {
    final s = await _speicher();
    await tester.pumpWidget(_app(s, const AbhakenScreen()));
    await tester.pump();
    expect(find.textContaining('0 von ${s.alleBuecher.length} erledigt'), findsOneWidget);

    await tester.tap(find.byTooltip('Gelesen').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Nicht gelesen').at(1));
    await tester.pump();

    expect(s.gelesen, 1);
    expect(s.geprueft.length, 1);
    expect(find.textContaining('2 von ${s.alleBuecher.length} erledigt'), findsOneWidget);
  });

  test('Fragebogen-Entwurf bleibt gespeichert', () async {
    final s = await _speicher();
    await s.fragebogenEntwurfSpeichern({'alter': ['14'], 'genres': ['fantasy']}, 2);
    final neu = Speicher(await SharedPreferences.getInstance());
    expect(neu.fragebogenEntwurf?.$2, 2);
    expect(neu.fragebogenEntwurf?.$1['genres'], ['fantasy']);
    await neu.fragebogenEntwurfLoeschen();
    expect(neu.fragebogenEntwurf, isNull);
  });
}
