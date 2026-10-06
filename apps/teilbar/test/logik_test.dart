import 'package:flutter_test/flutter_test.dart';
import 'package:teilbar/logik/artikel_text.dart';
import 'package:teilbar/logik/geld.dart';
import 'package:teilbar/logik/reste.dart';

void main() {
  group('aufteilen', () {
    test('gleichmäßig mit Restcent', () {
      final t = aufteilen(1000, {'a': 1, 'b': 1, 'c': 1});
      expect(t.values.fold(0, (x, y) => x + y), 1000);
      expect(t.values.toList()..sort(), [333, 333, 334]);
    });

    test('nach Gewicht', () {
      expect(aufteilen(900, {'a': 2, 'b': 1}), {'a': 600, 'b': 300});
    });

    test('Gewicht 0 bekommt nichts, leer bleibt leer', () {
      expect(aufteilen(500, {'a': 1, 'b': 0}), {'a': 500});
      expect(aufteilen(500, {'a': 0}), isEmpty);
    });
  });

  group('Salden und Ausgleich', () {
    test('WG-Einkauf: Anna zahlt 30 € für drei', () {
      final s = salden(
        [
          const Buchung(
            zahler: 'anna',
            betragCent: 3000,
            anteile: {'anna': 1, 'ben': 1, 'cem': 1},
          ),
        ],
        ['anna', 'ben', 'cem'],
      );
      expect(s, {'anna': 2000, 'ben': -1000, 'cem': -1000});
      expect(s.values.fold(0, (a, b) => a + b), 0);
      expect(ausgleichen(s).toSet(), {
        const Ueberweisung('ben', 'anna', 1000),
        const Ueberweisung('cem', 'anna', 1000),
      });
    });

    test('Rückzahlung gleicht aus', () {
      final s = salden(
        [
          const Buchung(
            zahler: 'anna',
            betragCent: 2000,
            anteile: {'anna': 1, 'ben': 1},
          ),
          const Buchung(zahler: 'ben', betragCent: 1000, anteile: {'anna': 1}),
        ],
        ['anna', 'ben'],
      );
      expect(s, {'anna': 0, 'ben': 0});
      expect(ausgleichen(s), isEmpty);
    });

    test('mehrere Ausgaben: wenige Überweisungen, alles geht auf', () {
      final s = salden(
        [
          const Buchung(
            zahler: 'a',
            betragCent: 6000,
            anteile: {'a': 1, 'b': 1, 'c': 1, 'd': 1},
          ),
          const Buchung(
            zahler: 'b',
            betragCent: 2000,
            anteile: {'a': 1, 'b': 1, 'c': 1, 'd': 1},
          ),
          const Buchung(
            zahler: 'c',
            betragCent: 1001,
            anteile: {'c': 1, 'd': 1},
          ),
        ],
        ['a', 'b', 'c', 'd'],
      );
      expect(s.values.fold(0, (x, y) => x + y), 0);
      final u = ausgleichen(s);
      expect(u.length, lessThanOrEqualTo(3));
      final nachher = Map.of(s);
      for (final x in u) {
        nachher[x.von] = nachher[x.von]! + x.betragCent;
        nachher[x.an] = nachher[x.an]! - x.betragCent;
      }
      expect(nachher.values.every((v) => v == 0), isTrue);
    });
  });

  group('Rechnung teilen', () {
    test('10 % Trinkgeld auf 4 Personen', () {
      final r = rechnungTeilen(
        betragCent: 8000,
        trinkgeldProzent: 10,
        personen: 4,
      );
      expect(r.proPersonCent, 2200);
      expect(r.gesamtCent, 8800);
      expect(r.trinkgeldCent, 800);
    });

    test('nie zu wenig: aufrunden auf den Cent', () {
      final r = rechnungTeilen(
        betragCent: 1000,
        trinkgeldProzent: 0,
        personen: 3,
      );
      expect(r.proPersonCent, 334);
      expect(r.gesamtCent, 1002);
    });

    test('aufrunden auf 50 Cent', () {
      final r = rechnungTeilen(
        betragCent: 4730,
        trinkgeldProzent: 5,
        personen: 2,
        aufrundenAufCent: 50,
      );
      // 47,30 + 2,37 = 49,67 → 24,84 → 25,00
      expect(r.proPersonCent, 2500);
      expect(r.trinkgeldCent, 5000 - 4730);
    });
  });

  group('Artikel eintippen', () {
    test('Mengen vorne und hinten', () {
      expect(artikelLesen('2 Milch'), ('2', 'Milch'));
      expect(artikelLesen('500g mehl'), ('500 g', 'Mehl'));
      expect(artikelLesen('2 Pkg. Butter'), ('2 Pkg.', 'Butter'));
      expect(artikelLesen('1,5 l Saft'), ('1,5 l', 'Saft'));
      expect(artikelLesen('Brot x3'), ('3', 'Brot'));
      expect(artikelLesen('Eier 10x'), ('10', 'Eier'));
      expect(artikelLesen('  Klopapier '), ('', 'Klopapier'));
      expect(artikelLesen('3 Dosen Mais'), ('3 Dosen', 'Mais'));
    });
  });

  group('Resteküche', () {
    const rezepte = [
      Rezept(
        id: 'a',
        name: 'Eierspeis',
        minuten: 10,
        portionen: 1,
        tags: [],
        schritte: [],
        zutaten: [
          Zutat(name: 'Eier', menge: '3'),
          Zutat(name: 'Schnittlauch', menge: ''),
          Zutat(name: 'Salz', menge: '', grund: true),
        ],
      ),
      Rezept(
        id: 'b',
        name: 'Tomatensalat',
        minuten: 5,
        portionen: 1,
        tags: [],
        schritte: [],
        zutaten: [
          Zutat(name: 'Tomaten', menge: '3'),
          Zutat(name: 'Zwiebel', menge: '1'),
        ],
      ),
      Rezept(
        id: 'c',
        name: 'Kuchen',
        minuten: 60,
        portionen: 8,
        tags: [],
        schritte: [],
        zutaten: [Zutat(name: 'Butter', menge: '')],
      ),
    ];

    test('Plural und Groß/klein egal, Grundzutaten zählen nicht', () {
      final t = rezepteFinden(rezepte, [
        'ei',
        'Tomate',
        'Zwiebeln',
        'schnittlauch',
      ]);
      expect(t.map((x) => x.rezept.id).toList(), ['a', 'b']);
      expect(t.first.fehlend, isEmpty);
    });

    test('fehlende Zutaten werden genannt, ohne Treffer fällt weg', () {
      final t = rezepteFinden(rezepte, ['Eier']);
      expect(t.single.rezept.id, 'a');
      expect(t.single.fehlend.single.name, 'Schnittlauch');
      expect(rezepteFinden(rezepte, ['Eier'], alle: true).length, 3);
    });

    test('Dosentomaten sind keine Tomaten', () {
      expect(
        zutatVorhanden('Tomaten', {zutatSchluessel('Dosentomaten')}),
        isFalse,
      );
    });
  });
}
