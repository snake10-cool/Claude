import 'package:austro_angler/data/fische.dart';
import 'package:austro_angler/data/fragen.dart';
import 'package:austro_angler/data/gewaesser.dart';
import 'package:austro_angler/main.dart';
import 'package:austro_angler/models/bundesland.dart';
import 'package:austro_angler/models/fang.dart';
import 'package:austro_angler/models/fisch.dart';
import 'package:austro_angler/screens/kalender_screen.dart';
import 'package:austro_angler/services/speicher.dart';
import 'package:austro_angler/services/wetter.dart';
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
      expect(f.regeln.keys.toSet(), Bundesland.values.toSet(), reason: f.name);
    }
    final gIds = gewaesserListe.map((g) => g.id).toSet();
    expect(gIds.length, gewaesserListe.length, reason: 'Gewässer-IDs doppelt');
    for (final g in gewaesserListe) {
      for (final id in g.fischarten) {
        expect(ids, contains(id), reason: '${g.name}: $id');
      }
    }
    for (final land in Bundesland.values) {
      expect(gewaesserListe.where((g) => g.land == land), isNotEmpty,
          reason: 'Keine Gewässer in ${land.name}');
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
      bundesland: 'Kärnten',
    );
    final zurueck = Fang.fromJson(f.toJson());
    expect(zurueck.fischId, 'hecht');
    expect(zurueck.laengeCm, 72);
    expect(zurueck.bundesland, 'Kärnten');
  });

  test('Mondphase', () {
    // Vollmond am 3.1.2026, Neumond am 18.1.2026.
    expect(mondText(mondphase(DateTime.utc(2026, 1, 3, 12))).$2, 'Vollmond');
    expect(mondText(mondphase(DateTime.utc(2026, 1, 18, 20))).$2, 'Neumond');
  });

  testWidgets('App startet ohne Firebase und alle Tabs öffnen',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final speicher = await Speicher.oeffnen();
    await tester.pumpWidget(AustroAnglerApp(speicher: speicher));
    expect(find.text('Wo darf ich fischen?'), findsOneWidget);
    expect(find.text('Inn bei Braunau'), findsOneWidget);

    await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText?.startsWith('Gewässer') ?? false)),
        'Achen');
    await tester.pumpAndSettle();
    expect(find.text('Achensee'), findsOneWidget);

    for (final tab in ['Fangbuch', 'Community', 'Mehr']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('Schonzeit-Kalender'), findsOneWidget);

    await tester.tap(find.text('Schonzeit-Kalender'));
    await tester.pumpAndSettle();
    expect(find.text('Hecht'), findsOneWidget);
  });
}
