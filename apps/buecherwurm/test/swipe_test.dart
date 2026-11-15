import 'package:buecherwurm/main.dart';
import 'package:buecherwurm/screens/swipe_screen.dart';
import 'package:buecherwurm/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Swipen: Knöpfe für alle vier Richtungen', (tester) async {
    SharedPreferences.setMockInitialValues({'antworten': '{"alter":["14"],"genres":["fantasy"]}'});
    final s = await Speicher.laden();
    await tester.pumpWidget(SpeicherScope(speicher: s, child: const MaterialApp(home: SwipeScreen())));
    await tester.pump();

    final erstes = s.empfehlungen.first.buch.id;
    await tester.tap(find.byTooltip('Wunschliste'));
    await tester.pumpAndSettle();
    expect(s.eintraege.containsKey(erstes), isTrue);

    await tester.tap(find.byTooltip('Nicht für mich'));
    await tester.pumpAndSettle();
    expect(s.abgelehnt.length, 1);

    await tester.tap(find.byTooltip('Schon gelesen'));
    await tester.pumpAndSettle();
    expect(s.gelesen, 1);

    final vorher = s.eintraege.length + s.abgelehnt.length;
    await tester.tap(find.byTooltip('Überspringen'));
    await tester.pumpAndSettle();
    expect(s.eintraege.length + s.abgelehnt.length, vorher, reason: 'Überspringen speichert nichts');
  });

  testWidgets('Nach rechts wischen landet auf der Wunschliste', (tester) async {
    SharedPreferences.setMockInitialValues({'antworten': '{"alter":["14"]}'});
    final s = await Speicher.laden();
    await tester.pumpWidget(SpeicherScope(speicher: s, child: const MaterialApp(home: SwipeScreen())));
    await tester.pump();
    final erstes = s.empfehlungen.first.buch;
    await tester.drag(find.text(erstes.titel), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(s.eintraege[erstes.id]?.status.name, 'wunschliste');
  });
}
