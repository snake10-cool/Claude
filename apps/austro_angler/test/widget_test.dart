import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/data/fragen.dart';
import 'package:austro_angler/data/gewaesser.dart';
import 'package:austro_angler/main.dart';
import 'package:austro_angler/models/bundesland.dart';
import 'package:austro_angler/models/fang.dart';
import 'package:austro_angler/models/fisch.dart';
import 'package:austro_angler/screens/kalender_screen.dart';
import 'package:austro_angler/services/alle_gewaesser.dart';
import 'package:austro_angler/services/konto.dart';
import 'package:austro_angler/services/speicher.dart';
import 'package:austro_angler/services/wetter.dart';
import 'package:austro_angler/services/wochen_challenges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Schonzeit', () {
    const ueberJahreswechsel = Regel(von: Tag(16, 9), bis: Tag(15, 3));
    const imSommer = Regel(von: Tag(1, 6), bis: Tag(30, 6));

    test('über den Jahreswechsel', () {
      expect(ueberJahreswechsel.istGeschont(DateTime(2026, 12, 24)), isTrue);
      expect(ueberJahreswechsel.istGeschont(DateTime(2026, 3, 15)), isTrue);
      expect(ueberJahreswechsel.istGeschont(DateTime(2026, 3, 16)), isFalse);
      expect(ueberJahreswechsel.istGeschont(DateTime(2026, 9, 15)), isFalse);
    });

    test('innerhalb eines Jahres', () {
      expect(imSommer.istGeschont(DateTime(2026, 6, 1)), isTrue);
      expect(imSommer.istGeschont(DateTime(2026, 7, 1)), isFalse);
    });

    test('ohne Daten und ganzjährig', () {
      expect(const Regel.unbekannt().istGeschont(DateTime(2026)), isNull);
      expect(const Regel.ganzjaehrig().istGeschont(DateTime(2026)), isTrue);
      expect(const Regel().istGeschont(DateTime(2026)), isFalse);
    });

    test('Kalender-Monate', () {
      expect(monatStatus(imSommer, 6), MonatStatus.geschont);
      expect(monatStatus(imSommer, 7), MonatStatus.offen);
      expect(monatStatus(ueberJahreswechsel, 3), MonatStatus.teilweise);
      expect(monatStatus(const Regel.unbekannt(), 1), MonatStatus.unbekannt);
    });
  });

  test('Daten sind stimmig', () {
    final ids = fische.map((f) => f.id).toSet();
    expect(ids.length, fische.length, reason: 'Fisch-IDs doppelt');
    for (final f in fische) {
      // OÖ und Salzburg sind Pflicht, fehlende Länder gelten als "unbekannt".
      expect(f.regeln.keys,
          containsAll([Bundesland.ooe, Bundesland.sbg]), reason: f.name);
    }
    final gIds = gewaesserListe.map((g) => g.id).toSet();
    expect(gIds.length, gewaesserListe.length, reason: 'Gewässer-IDs doppelt');
    for (final g in gewaesserListe) {
      for (final id in g.fischarten) {
        expect(ids, contains(id), reason: '${g.name}: $id');
      }
    }
    for (final g in gewaesserListe) {
      expect(zuordnung, contains(g.id), reason: 'Bezirk fehlt: ${g.name}');
    }
    for (final land in Bundesland.values) {
      expect(fischerkarten.where((k) => k.land == land), hasLength(1),
          reason: 'Fischerkarte ${land.name}');
    }
    for (final q in pruefungsfragen) {
      expect(q.antworten.toSet().length, 4, reason: q.text);
    }
  });

  test('Fang lokal speichern und laden', () {
    final f = Fang(
      id: '1',
      fischId: 'hecht',
      datum: DateTime(2026, 6, 1),
      laengeCm: 72,
      gewichtG: 2500,
      bundesland: 'Salzburg',
    );
    final zurueck = Fang.fromJson(f.toJson());
    expect(zurueck.fischId, 'hecht');
    expect(zurueck.laengeCm, 72);
    expect(zurueck.bundesland, 'Salzburg');
  });

  test('@Namen', () {
    expect(Konto.handle(' @HechtJaeger99 '), 'hechtjaeger99');
    expect(Konto.nameProblem('@max_1'), isNull);
    expect(Konto.nameProblem('ab'), isNotNull);
    expect(Konto.nameProblem('Jäger'), isNotNull);
    expect(Konto.nameProblem('mit leer'), isNotNull);
  });

  test('Kalenderwoche und Countdown über die Sommerzeit', () {
    expect(kalenderwoche(DateTime(2026, 3, 26)), 13);
    expect(kalenderwoche(DateTime(2026, 4, 2)), 14);
    expect(kalenderwoche(DateTime(2026, 10, 8)), 41);
    expect(kalenderwoche(DateTime(2026, 10, 22)), 43);
    expect(kalenderwoche(DateTime(2026, 12, 31)), 53);
    expect(kalenderwoche(DateTime(2027, 1, 1)), 53);
    expect(wochenjahr(DateTime(2027, 1, 1)), 2026);
    expect(kalenderwoche(DateTime(2025, 12, 31)), 1);
    expect(wochenjahr(DateTime(2025, 12, 31)), 2026);
    const regel = Regel(von: Tag(1, 1), bis: Tag(31, 3));
    expect(regel.tageBisOffen(DateTime(2026, 3, 1)), 31);
  });

  test('Mondphase', () {
    // Vollmond am 3.1.2026, Neumond am 18.1.2026.
    expect(mondText(mondphase(DateTime.utc(2026, 1, 3, 12))).$2, 'Vollmond');
    expect(mondText(mondphase(DateTime.utc(2026, 1, 18, 20))).$2, 'Neumond');
  });

  testWidgets('App startet ohne Firebase und alle Tabs öffnen',
      (tester) async {
    SharedPreferences.setMockInitialValues({'einfuehrung': true});
    final speicher = await Speicher.oeffnen();
    await tester.runAsync(alleGewaesser.laden);
    await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
    expect(find.text('Wo darf ich fischen?'), findsOneWidget);
    expect(alleGewaesser.geladen, isTrue);
    expect(find.textContaining(RegExp(r'^\d+ Gewässer$')), findsOneWidget);
    await tester.scrollUntilVisible(find.text('✅ Inn bei Braunau'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('✅ Inn bei Braunau'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 5000));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText?.startsWith('Gewässer') ?? false)),
        'Enknach');
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('✅ Enknach (Bach)'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('✅ Enknach (Bach)'), findsOneWidget);

    for (final tab in ['Fangbuch', 'Feed', 'Wünsche', 'Mehr']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('FAQ – Fragen & Antworten'), findsOneWidget);
    await tester.tap(find.text('FAQ – Fragen & Antworten'));
    await tester.pumpAndSettle();
    expect(find.text('Was ist Austro Angler?'), findsOneWidget);
  });
}
