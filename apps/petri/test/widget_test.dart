import 'package:flutter_test/flutter_test.dart';
import 'package:petri/data/fische.dart';
import 'package:petri/data/fragen.dart';
import 'package:petri/data/gewaesser.dart';
import 'package:petri/main.dart';
import 'package:petri/models/bundesland.dart';
import 'package:petri/models/fisch.dart';
import 'package:petri/services/speicher.dart';
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
  });

  test('Daten sind stimmig', () {
    final ids = fische.map((f) => f.id).toSet();
    expect(ids.length, fische.length, reason: 'Fisch-IDs doppelt');
    for (final f in fische) {
      expect(f.regeln.keys, containsAll(Bundesland.values), reason: f.name);
    }
    for (final g in gewaesserListe) {
      for (final id in g.fischarten) {
        expect(ids, contains(id), reason: '${g.name}: $id');
      }
    }
    for (final q in pruefungsfragen) {
      expect(q.antworten.length, 4, reason: q.text);
      expect(q.antworten.toSet().length, 4, reason: q.text);
    }
  });

  testWidgets('App startet und alle Tabs öffnen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final speicher = await Speicher.oeffnen();
    await tester.pumpWidget(PetriApp(speicher: speicher));
    expect(find.text('Wo darf ich fischen?'), findsOneWidget);
    expect(find.text('Inn bei Braunau'), findsOneWidget);

    await tester.tap(find.text('Sbg'));
    await tester.pumpAndSettle();
    expect(find.text('Mattsee'), findsOneWidget);

    for (final tab in ['Fangbuch', 'Fische', 'Prüfung']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('Runde starten'), findsOneWidget);
  });
}
