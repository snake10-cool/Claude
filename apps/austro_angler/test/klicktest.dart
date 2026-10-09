// Klickt sich durch die ganze App (ohne Firebase und ohne Netz) und
// prüft, dass kein Bildschirm abstürzt.
import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/main.dart';
import 'package:austro_angler/screens/lexikon_screen.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:austro_angler/services/speicher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Alle Einträge unter "Mehr", die einen Bildschirm in der App öffnen.
const _mehr = [
  'Einführung ansehen',
  '⭐ Premium',
  'Einstellungen',
  'FAQ – Fragen & Antworten',
  'Statistik & Abzeichen',
  'Meine Angeltage ⭐',
  'Köder-Box',
  'Meine Ausrüstung',
  'Meine Lizenzen',
  'Mein Heimatort',
  'Angelgeschäfte',
  'Vereine & Verbände',
  'Fisch-Quiz',
  'Ausrüstungs-Checkliste',
  'Welcher Fisch ist das?',
  'Fischlexikon',
  'Schonzeit-Kalender',
  'Angel-Wörterbuch',
  'Fischerprüfung üben',
  'Knoten',
];

Future<void> _warten(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _zurueck(WidgetTester tester) async {
  final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
  nav.pop();
  await _warten(tester);
}

Future<void> _starten(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'einfuehrung': true});
  final speicher = await Speicher.oeffnen();
  await tester.runAsync(alleGewaesser.laden);
  await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
  await _warten(tester);
}

void main() {
  testWidgets('Jeder Eintrag unter "Mehr" öffnet ohne Fehler', (tester) async {
    await _starten(tester);
    await tester.tap(find.text('Mehr').last);
    await _warten(tester);
    for (final titel in _mehr) {
      final ziel = find.text(titel);
      await tester.scrollUntilVisible(ziel, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(ziel);
      await _warten(tester);
      expect(tester.takeException(), isNull, reason: titel);
      await _zurueck(tester);
      expect(tester.takeException(), isNull, reason: '$titel (zurück)');
    }
  });

  testWidgets('Alle Tabs und ein Gewässer öffnen', (tester) async {
    await _starten(tester);
    await tester.scrollUntilVisible(find.text('✅ Inn bei Braunau'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('✅ Inn bei Braunau'));
    await _warten(tester);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await _warten(tester);
    expect(tester.takeException(), isNull);
    await _zurueck(tester);

    for (final tab in ['Fangbuch', 'Feed', 'Wünsche', 'Mehr', 'Gewässer']) {
      await tester.tap(find.text(tab).last);
      await _warten(tester);
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('Jeder Fisch im Lexikon öffnet', (tester) async {
    await _starten(tester);
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .push(MaterialPageRoute(builder: (_) => const LexikonScreen()));
    await _warten(tester);
    expect(find.byType(LexikonScreen), findsOneWidget);
    final suche = find.byWidgetPredicate((w) =>
        w is TextField && w.decoration?.hintText == 'Fisch oder Familie suchen');
    final liste = find
        .descendant(
            of: find.byType(LexikonScreen), matching: find.byType(Scrollable))
        .first;
    // Ausgestorbene stehen nur im Filter "Ausgestorben".
    for (final f in fische.where((f) => !f.ausgestorben)) {
      await tester.drag(liste, const Offset(0, 5000));
      await _warten(tester);
      await tester.enterText(suche, f.name);
      await _warten(tester);
      final ziel = find.ancestor(
          of: find.textContaining(RegExp('^${RegExp.escape(f.name)}( |\$)')),
          matching: find.byType(ListTile));
      await tester.scrollUntilVisible(ziel, 200, scrollable: liste);
      await tester.tap(ziel.first);
      await _warten(tester);
      expect(tester.takeException(), isNull, reason: f.name);
      expect(find.byType(FischDetail), findsOneWidget, reason: f.name);
      await _zurueck(tester);
    }
  });

  testWidgets('Einführung beim ersten Start durchklicken', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final speicher = await Speicher.oeffnen();
    await tester.runAsync(alleGewaesser.laden);
    await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
    await _warten(tester);
    expect(find.text('Servus und Petri Heil!'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Weiter'));
      await _warten(tester);
    }
    expect(find.text('Wo fischst du?'), findsOneWidget);
    await tester.tap(find.text('Los geht\'s!'));
    await _warten(tester);
    expect(find.text('Wo fischst du?'), findsNothing);
    expect(speicher.einfuehrungGesehen, isTrue);
    expect(tester.takeException(), isNull);
  });
}
