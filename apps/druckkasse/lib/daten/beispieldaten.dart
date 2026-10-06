import 'dart:math';

import 'package:drift/drift.dart';

import 'datenbank.dart';

/// Füllt die App mit Beispielen zum Ausprobieren: zwei Drucker, Filamente,
/// typische Produkte, Verkäufe der letzten Wochen, ein Auftrag, ein Sparziel.
Future<void> beispieldatenLaden(AppDatenbank d) => d.transaction(() async {
  final a1 = await d.druckerSpeichern(
    DruckerTabelleCompanion.insert(
      name: 'Bambu Lab A1',
      leistungWatt: 95,
      anschaffungCent: 29900,
      lebensdauerStunden: 5000,
    ),
  );
  final ender = await d.druckerSpeichern(
    DruckerTabelleCompanion.insert(
      name: 'Ender 3 V3 SE',
      leistungWatt: 110,
      anschaffungCent: 18900,
      lebensdauerStunden: 4000,
    ),
  );

  Future<int> filament(String name, String mat, int farbe, int preis) =>
      d.filamentSpeichern(
        FilamentTabelleCompanion.insert(
          name: name,
          material: mat,
          farbe: farbe,
          preisProKgCent: preis,
        ),
      );
  final rot = await filament('Bambu PLA Basic Rot', 'PLA', 0xFFE53935, 1999);
  final blau = await filament('Bambu PLA Basic Blau', 'PLA', 0xFF1E88E5, 1999);
  final silk = await filament(
    'PLA Silk Regenbogen',
    'PLA Silk',
    0xFFAB47BC,
    2499,
  );
  final schwarz = await filament('PETG Schwarz', 'PETG', 0xFF212121, 1799);
  final orange = await filament(
    'PLA Matt Orange',
    'PLA Matt',
    0xFFFB8C00,
    2199,
  );

  final tuete = await d.extraSpeichern(
    ExtraTabelleCompanion.insert(name: 'Tütchen', kostenCent: 5),
  );
  final schachtel = await d.extraSpeichern(
    ExtraTabelleCompanion.insert(name: 'Geschenkschachtel', kostenCent: 35),
  );
  final ring = await d.extraSpeichern(
    ExtraTabelleCompanion.insert(name: 'Schlüsselring', kostenCent: 8),
  );

  Future<int> produkt(
    String name,
    String symbol,
    int farbe,
    int drucker,
    int minuten,
    int stueck,
    List<(int, double)> filamente,
    List<(int, int)> extras, {
    double spuel = 0,
    int sortierung = 0,
    int? preis,
  }) => d.produktSpeichern(
    ProduktTabelleCompanion.insert(
      name: name,
      symbol: Value(symbol),
      farbe: farbe,
      druckerId: Value(drucker),
      druckzeitMinuten: minuten,
      stueckProDruck: Value(stueck),
      spuelabfallGramm: Value(spuel),
      sortierung: Value(sortierung),
      preisManuellCent: Value(preis),
    ),
    filamente: filamente,
    extras: extras,
  );

  final drache = await produkt(
    'Flexi Dragon',
    '🐉',
    0xFFAB47BC,
    a1,
    210,
    1,
    [(silk, 38)],
    [(tuete, 1)],
    sortierung: 0,
    preis: 800,
  );
  final klicker = await produkt(
    'Klicker',
    '🖱️',
    0xFFE53935,
    a1,
    95,
    6,
    [(rot, 30), (blau, 30)],
    [(ring, 1)],
    spuel: 25,
    sortierung: 1,
    preis: 300,
  );
  final wuerfel = await produkt(
    'Infinity Cube',
    '🧊',
    0xFF1E88E5,
    a1,
    160,
    2,
    [(blau, 44)],
    [(tuete, 1)],
    sortierung: 2,
  );
  final stern = await produkt(
    'Fidget Star',
    '⭐',
    0xFFFB8C00,
    ender,
    75,
    3,
    [(orange, 36)],
    [(tuete, 1)],
    sortierung: 3,
    preis: 400,
  );
  final kuerbis = await produkt(
    'Halloween-Kürbis',
    '🎃',
    0xFFFB8C00,
    a1,
    130,
    1,
    [(orange, 25), (schwarz, 3)],
    [(schachtel, 1)],
    spuel: 12,
    sortierung: 4,
    preis: 600,
  );

  // Verkäufe der letzten 60 Tage, zufällig aber reproduzierbar.
  final zufall = Random(42);
  final produkte = {for (final p in await d.produkteLaden()) p.produkt.id: p};
  final heute = DateTime.now();
  final gewichte = {drache: 5, klicker: 8, wuerfel: 3, stern: 4, kuerbis: 2};
  for (var tag = 60; tag >= 0; tag--) {
    if (zufall.nextInt(3) == 0) continue; // nicht jeden Tag
    final anzahl = 1 + zufall.nextInt(4);
    for (var i = 0; i < anzahl; i++) {
      final id = _gewichtet(gewichte, zufall);
      await d.verkaufen(
        produkte[id]!,
        menge: 1 + (zufall.nextInt(5) == 0 ? 1 : 0),
        zeitpunkt: DateTime(
          heute.year,
          heute.month,
          heute.day - tag,
          10 + zufall.nextInt(8),
          zufall.nextInt(60),
        ),
      );
    }
  }

  await d.auftragSpeichern(
    AuftragTabelleCompanion.insert(
      kunde: 'Lena (Nachbarin)',
      kontakt: const Value('0660 1234567'),
      notiz: const Value('Geburtstagsgeschenk für ihren Sohn'),
      erstelltAm: heute.subtract(const Duration(days: 2)),
      faelligAm: Value(heute.add(const Duration(days: 3))),
    ),
    [
      AuftragPositionTabelleCompanion.insert(
        auftragId: 0,
        produktId: drache,
        menge: 2,
        einzelpreisCent: 750,
        notiz: const Value('1× grün, 1× blau'),
      ),
      AuftragPositionTabelleCompanion.insert(
        auftragId: 0,
        produktId: klicker,
        menge: 3,
        einzelpreisCent: 300,
      ),
    ],
  );

  await d.sparzielSpeichern(
    SparzielTabelleCompanion.insert(
      name: 'Bambu Lab P1S',
      symbol: const Value('🖨️'),
      zielCent: 54900,
      startDatum: heute.subtract(const Duration(days: 30)),
    ),
  );
});

int _gewichtet(Map<int, int> gewichte, Random zufall) {
  final summe = gewichte.values.fold(0, (a, b) => a + b);
  var wurf = zufall.nextInt(summe);
  for (final e in gewichte.entries) {
    if (wurf < e.value) return e.key;
    wurf -= e.value;
  }
  return gewichte.keys.first;
}
