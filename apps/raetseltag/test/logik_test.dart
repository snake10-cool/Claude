import 'package:flutter_test/flutter_test.dart';
import 'package:raetseltag/logik/schiebe.dart';
import 'package:raetseltag/logik/serie.dart';
import 'package:raetseltag/logik/sudoku.dart';
import 'package:raetseltag/logik/tag.dart';
import 'package:raetseltag/logik/wortraetsel.dart';

const r = Feld.richtig, e = Feld.enthalten, f = Feld.falsch;

void main() {
  group('Worträtsel', () {
    test('richtig, enthalten, falsch', () {
      // B richtig; A, U fehlen; E und R kommen in „beere“ vor.
      expect(bewerten('BAUER', 'beere'), [r, f, f, e, e]);
      expect(bewerten('apfel', 'apfel'), [r, r, r, r, r]);
    });

    test('doppelte Buchstaben: nur so oft gelb wie vorhanden', () {
      // Lösung hat ein E an Stelle 2 → das zweite E im Versuch ist grau.
      expect(bewerten('eeeee', 'liebe'), [f, f, r, f, r]);
      // „leben“ hat zwei E → beide E im Versuch sind gelb.
      expect(bewerten('ernte', 'leben'), [e, f, e, f, e]);
      // Grün hat Vorrang vor gelb.
      expect(bewerten('essen', 'nesse'), [e, e, r, e, e]);
    });

    test('Umlaute zählen als eigene Buchstaben', () {
      expect(bewerten('bäche', 'bache'), [r, f, r, r, r]);
    });

    test('Tastatur merkt sich den besten Zustand', () {
      final s = tastaturStatus(['erbse', 'leben'], 'leben');
      expect(s['e'], Feld.richtig);
      expect(s['r'], Feld.falsch);
      expect(s['b'], Feld.richtig);
    });

    test('Emoji-Raster', () {
      // „bauer“ hat nur ein E → nur das erste E von „beere“ ist gelb.
      expect(emojiRaster(['beere', 'bauer'], 'bauer'), '🟩🟨⬛🟨⬛\n🟩🟩🟩🟩🟩');
    });
  });

  group('Sudoku', () {
    for (final s in Stufe.values) {
      test('${s.name}: eindeutig lösbar, richtige Anzahl Vorgaben', () {
        final (raetsel, loesung) = sudokuErzeugen(sudokuSeed(5, s), s);
        expect(
          raetsel.where((z) => z != 0).length,
          lessThanOrEqualTo(vorgaben(s) + 1),
        );
        expect(loesungenZaehlen(raetsel), 1);
        expect(loesen(raetsel), loesung);
        expect(konflikte(loesung), isEmpty);
        for (var i = 0; i < 81; i++) {
          if (raetsel[i] != 0) expect(raetsel[i], loesung[i]);
        }
      });
    }

    test('gleicher Tag → gleiches Sudoku', () {
      final a = sudokuErzeugen(sudokuSeed(9, Stufe.mittel), Stufe.mittel);
      final b = sudokuErzeugen(sudokuSeed(9, Stufe.mittel), Stufe.mittel);
      expect(a.$1, b.$1);
    });

    test('Konflikte werden erkannt', () {
      final (_, loesung) = sudokuErzeugen(1, Stufe.leicht);
      final kaputt = List.of(loesung);
      kaputt[0] = kaputt[1];
      expect(konflikte(kaputt), containsAll([0, 1]));
      expect(geloest(kaputt, loesung), isFalse);
      expect(geloest(loesung, loesung), isTrue);
    });
  });

  group('Schiebepuzzle', () {
    test('gemischt ist nicht gelöst und immer gleich für einen Tag', () {
      final a = Schiebe.gemischt(4, schiebeSeed(3));
      final b = Schiebe.gemischt(4, schiebeSeed(3));
      expect(a.istGeloest, isFalse);
      expect(a.felder, b.felder);
      expect(a.felder.toSet().length, 16);
    });

    test('Reihe rutscht nach, ungültige Tipps bewegen nichts', () {
      final s = Schiebe.geloest(4); // Lücke an 15
      expect(s.tippen(12), 3); // ganze untere Reihe rutscht
      expect(s.felder.sublist(12), [0, 13, 14, 15]);
      expect(s.zuege, 3);
      expect(s.tippen(1), 0); // nicht in Zeile/Spalte der Lücke
      expect(s.tippen(15), 3); // zurück
      expect(s.istGeloest, isTrue);
    });
  });

  group('Tage und Serie', () {
    test('Rätselnummern', () {
      expect(raetselNummer(DateTime(2026, 10, 1, 23)), 1);
      expect(raetselNummer(DateTime(2026, 10, 31)), 31);
      expect(tagVonNummer(31), DateTime(2026, 10, 31));
      // Zeitumstellung Ende Oktober verschiebt nichts.
      expect(raetselNummer(DateTime(2026, 11, 1)), 32);
    });

    test('Serie mit und ohne heute', () {
      final heute = DateTime(2026, 10, 10);
      expect(serie({8, 9, 10}, heute), 3);
      expect(serie({7, 8, 9}, heute), 3);
      expect(serie({7, 8}, heute), 0);
      expect(laengsteSerie({1, 2, 3, 7, 8}), 3);
    });
  });
}
