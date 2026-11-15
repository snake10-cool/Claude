import 'package:buecherwurm/main.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Erster Start zeigt Willkommen, dann den Fragebogen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final speicher = await Speicher.laden();
    await tester.pumpWidget(BuecherwurmApp(speicher: speicher));

    expect(find.text('Willkommen beim Bücherwurm!'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Lea');
    await tester.pump();
    await tester.tap(find.text('Fragebogen starten'));
    await tester.pumpAndSettle();
    expect(find.text('Wie alt bist du?'), findsOneWidget);
  });

  testWidgets('Nach der Einrichtung gibt es Empfehlungen', (tester) async {
    SharedPreferences.setMockInitialValues({
      'name': 'Lea',
      'einrichtungFertig': true,
      'antworten': '{"alter":["14"],"genres":["fantasy"]}',
    });
    final speicher = await Speicher.laden();
    await tester.pumpWidget(BuecherwurmApp(speicher: speicher));
    expect(find.text('Hallo Lea! 👋'), findsOneWidget);
    expect(find.textContaining('#1'), findsOneWidget);
  });

  test('Punkte-Code lässt sich wieder einlesen', () async {
    SharedPreferences.setMockInitialValues({'name': 'Max'});
    final a = await Speicher.laden();
    final code = 'Mein Stand: 0 Punkte. Code: ${a.meinCode}';
    SharedPreferences.setMockInitialValues({'name': 'Lea'});
    final b = await Speicher.laden();
    final f = await b.codeEinlesen(code);
    expect(f?.name, 'Max');
    expect(b.freunde.length, 1);
    expect(await b.codeEinlesen('Unsinn'), isNull);
  });
}
