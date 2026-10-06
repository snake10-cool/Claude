import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:druckkasse/daten/beispieldaten.dart';
import 'package:druckkasse/daten/datenbank.dart';
import 'package:druckkasse/daten/sicherung.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temp;
  setUp(() async => temp = await Directory.systemTemp.createTemp('sicherung'));
  tearDown(() => temp.delete(recursive: true));

  test(
    'Sicherung erstellen und in eine andere Datenbank zurückspielen',
    () async {
      final quelle = AppDatenbank(NativeDatabase.memory());
      await beispieldatenLaden(quelle);
      final produkte = await quelle.anzahlAktiverProdukte();
      final verkaeufe = await quelle.anzahlVerkaeufe();
      expect(produkte, 5);
      expect(verkaeufe, greaterThan(10));

      final bytes = await Sicherung(
        quelle,
        tempOrdner: () async => temp,
      ).erstellen();
      await quelle.close();

      final ziel = AppDatenbank(NativeDatabase.memory());
      await ziel.druckerSpeichern(
        DruckerTabelleCompanion.insert(
          name: 'Wird überschrieben',
          leistungWatt: 1,
          anschaffungCent: 1,
          lebensdauerStunden: 1,
        ),
      );
      await Sicherung(
        ziel,
        tempOrdner: () async => temp,
      ).wiederherstellen(bytes);
      expect(await ziel.anzahlAktiverProdukte(), produkte);
      expect(await ziel.anzahlVerkaeufe(), verkaeufe);
      expect(await ziel.anzahlAktiverDrucker(), 2);
      expect((await ziel.auftraegeLaden()).single.positionen, hasLength(2));
      await ziel.close();
    },
  );

  test('ungültige Datei wird abgelehnt und ändert nichts', () async {
    final d = AppDatenbank(NativeDatabase.memory());
    await beispieldatenLaden(d);
    await expectLater(
      Sicherung(
        d,
        tempOrdner: () async => temp,
      ).wiederherstellen(Uint8List.fromList(List.filled(100, 7))),
      throwsA(isA<FormatException>()),
    );
    expect(await d.anzahlAktiverProdukte(), 5);
    await d.close();
  });
}
