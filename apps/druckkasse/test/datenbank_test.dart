import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:druckkasse/daten/datenbank.dart';
import 'package:druckkasse/logik/statistik.dart';
import 'package:druckkasse/logik/typen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatenbank d;

  setUp(() {
    d = AppDatenbank(NativeDatabase.memory());
  });
  tearDown(() => d.close());

  Future<int> flexiDragon() async {
    await d.einstellungenSpeichern(
      const EinstellungenTabelleCompanion(
        strompreisCentProKwh: Value(25),
        standardAufschlagProzent: Value(200),
        fehldruckProzent: Value(0),
        rundungCent: Value(50),
        gebuehrKarteProzent: Value(2),
      ),
    );
    final drucker = await d.druckerSpeichern(
      DruckerTabelleCompanion.insert(
        name: 'Bambu Lab A1',
        leistungWatt: 100,
        anschaffungCent: 30000,
        lebensdauerStunden: 5000,
      ),
    );
    final pla = await d.filamentSpeichern(
      FilamentTabelleCompanion.insert(
        name: 'Bambu PLA Basic Rot',
        material: 'PLA',
        farbe: 0xFFE53935,
        preisProKgCent: 2000,
      ),
    );
    final schachtel = await d.extraSpeichern(
      ExtraTabelleCompanion.insert(name: 'Schachtel', kostenCent: 23),
    );
    return d.produktSpeichern(
      ProduktTabelleCompanion.insert(
        name: 'Flexi Dragon',
        farbe: 0xFFE53935,
        druckerId: Value(drucker),
        druckzeitMinuten: 120,
      ),
      filamente: [(pla, 30)],
      extras: [(schachtel, 1)],
    );
  }

  test('Produkt wird mit Kosten und Preisvorschlag geladen', () async {
    final id = await flexiDragon();
    final p = (await d.produktLaden(id))!;
    // 60 + 5 + 12 + 23 = 100 ct, +200 % = 3,00 €
    expect(p.kostenCent, 100);
    expect(p.preisCent, 300);
    expect(p.gewinnCent, 200);
    expect(p.filamente, hasLength(1));
    expect(p.extras, hasLength(1));
  });

  test(
    'erneutes Speichern ersetzt Filamente statt sie zu verdoppeln',
    () async {
      final id = await flexiDragon();
      final p = (await d.produktLaden(id))!;
      await d.produktSpeichern(
        p.produkt.toCompanion(true).copyWith(name: const Value('Drache')),
        filamente: [(p.filamente.first.$2.id, 40)],
        extras: const [],
      );
      final neu = (await d.produktLaden(id))!;
      expect(neu.produkt.name, 'Drache');
      expect(neu.filamente.single.$1.gramm, 40);
      expect(neu.extras, isEmpty);
      expect(await d.anzahlAktiverProdukte(), 1);
    },
  );

  test('Verkauf merkt sich Preis und Kosten, Gebühr bei Karte', () async {
    final id = await flexiDragon();
    final p = (await d.produktLaden(id))!;
    final vid = await d.verkaufen(p, menge: 2, zahlungsart: Zahlungsart.karte);

    // Später wird Filament teurer – alter Verkauf bleibt gleich.
    final f = p.filamente.first.$2;
    await d.filamentSpeichern(
      f.toCompanion(true).copyWith(preisProKgCent: const Value(9000)),
    );

    final alle = await d.verkaeufeLaden(DateTime(2000), DateTime(2100));
    expect(alle.single.id, vid);
    expect(alle.single.einzelkostenCent, 100);
    expect(alle.single.einzelpreisCent, 300);
    expect(alle.single.gebuehrCent, 12); // 2 % von 6 €

    final a = auswerten(alle.map((v) => v.zeile));
    expect(a.gewinnCent, 600 - 200 - 12);

    await d.verkaufLoeschen(vid);
    expect(await d.anzahlVerkaeufe(), 0);
  });

  test('Auftrag bezahlt erzeugt Verkäufe, zurücknehmen löscht sie', () async {
    final pid = await flexiDragon();
    final aid = await d.auftragSpeichern(
      AuftragTabelleCompanion.insert(kunde: 'Lena', erstelltAm: DateTime.now()),
      [
        AuftragPositionTabelleCompanion.insert(
          auftragId: 0,
          produktId: pid,
          menge: 3,
          einzelpreisCent: 250,
        ),
      ],
    );
    var auftraege = await d.auftraegeLaden();
    expect(auftraege.single.summeCent, 750);
    expect(auftraege.single.bezahlt, isFalse);
    expect(await d.anzahlVerkaeufe(), 0);

    await d.auftragBezahltSetzen(aid, true);
    final verkaeufe = await d.verkaeufeLaden(DateTime(2000), DateTime(2100));
    expect(verkaeufe.single.menge, 3);
    expect(verkaeufe.single.auftragId, aid);

    // Positionen ändern, während bezahlt → Verkäufe passen sich an.
    await d.auftragSpeichern(
      (await d.auftraegeLaden()).single.auftrag.toCompanion(true),
      [
        AuftragPositionTabelleCompanion.insert(
          auftragId: aid,
          produktId: pid,
          menge: 5,
          einzelpreisCent: 250,
        ),
      ],
    );
    expect(
      (await d.verkaeufeLaden(DateTime(2000), DateTime(2100))).single.menge,
      5,
    );

    await d.auftragBezahltSetzen(aid, false);
    expect(await d.anzahlVerkaeufe(), 0);

    await d.auftragStatusSetzen(aid, AuftragStatus.abgeholt);
    auftraege = await d.auftraegeLaden();
    expect(auftraege.single.status, AuftragStatus.abgeholt);

    await d.auftragLoeschen(aid);
    expect(await d.auftraegeLaden(), isEmpty);
  });

  test('allesLoeschen leert alles außer den Einstellungen', () async {
    await flexiDragon();
    await d.allesLoeschen();
    expect(await d.anzahlAktiverProdukte(), 0);
    expect((await d.einstellungenLesen()).standardAufschlagProzent, 200);
  });
}
