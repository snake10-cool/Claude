import 'package:druckkasse/logik/csv_export.dart';
import 'package:druckkasse/logik/grenzen.dart';
import 'package:druckkasse/logik/sparziel_rechner.dart';
import 'package:druckkasse/logik/statistik.dart';
import 'package:druckkasse/logik/typen.dart';
import 'package:flutter_test/flutter_test.dart';

VerkaufZeile v(
  int? id,
  String name,
  int menge,
  int preis,
  int kosten, {
  DateTime? am,
  int gebuehr = 0,
}) => VerkaufZeile(
  zeitpunkt: am ?? DateTime(2026, 10, 5),
  produktId: id,
  produktName: name,
  menge: menge,
  einzelpreisCent: preis,
  einzelkostenCent: kosten,
  gebuehrCent: gebuehr,
);

void main() {
  group('auswerten', () {
    test('Summen und Gewinn', () {
      final a = auswerten([
        v(1, 'Flexi Dragon', 2, 500, 100),
        v(2, 'Klicker', 3, 200, 30, gebuehr: 10),
      ]);
      expect(a.umsatzCent, 1600);
      expect(a.kostenCent, 290);
      expect(a.gebuehrenCent, 10);
      expect(a.gewinnCent, 1300);
      expect(a.stueck, 5);
      expect(a.anzahlVerkaeufe, 2);
    });

    test('Bestseller nach Stück, bei Gleichstand nach Umsatz', () {
      final a = auswerten([
        v(1, 'Flexi Dragon', 2, 500, 100),
        v(2, 'Klicker', 3, 200, 30),
        v(1, 'Flexi Dragon', 1, 500, 100),
        v(3, 'Stern', 3, 100, 10),
      ]);
      expect(a.bestseller.map((b) => b.name).toList(), [
        'Flexi Dragon',
        'Klicker',
        'Stern',
      ]);
      expect(a.bestseller.first.stueck, 3);
      expect(a.bestseller.first.gewinnCent, 1200);
    });

    test('leer ergibt Nullen', () {
      final a = auswerten([]);
      expect(a.gewinnCent, 0);
      expect(a.bestseller, isEmpty);
    });
  });

  test(
    'Monatsverlauf füllt leere Monate mit 0 und geht über Jahresgrenzen',
    () {
      final verlauf = monatsVerlauf(
        [
          v(1, 'A', 1, 500, 100, am: DateTime(2025, 12, 24)),
          v(1, 'A', 2, 500, 100, am: DateTime(2026, 2, 1)),
          v(1, 'A', 1, 500, 100, am: DateTime(2025, 1, 1)), // zu alt
        ],
        bisMonat: DateTime(2026, 2),
        anzahl: 3,
      );
      expect(verlauf.map((m) => m.monat).toList(), [
        DateTime(2025, 12),
        DateTime(2026, 1),
        DateTime(2026, 2),
      ]);
      expect(verlauf.map((m) => m.umsatzCent).toList(), [500, 0, 1000]);
      expect(verlauf.last.gewinnCent, 800);
    },
  );

  group('Sparziel', () {
    final a = auswerten([v(1, 'A', 4, 500, 100)]); // Umsatz 20 €, Gewinn 16 €

    test('Stand nach Basis', () {
      expect(sparStand(SparBasis.gewinn, a), 1600);
      expect(sparStand(SparBasis.umsatz, a), 2000);
    });

    test('Fortschritt begrenzt auf 0 bis 1', () {
      expect(sparFortschritt(standCent: 1600, zielCent: 3200), 0.5);
      expect(sparFortschritt(standCent: 5000, zielCent: 3200), 1);
      expect(sparFortschritt(standCent: -100, zielCent: 3200), 0);
    });

    test('fehlende Stück werden aufgerundet', () {
      expect(stueckFehlend(restCent: 1000, proStueckCent: 300), 4);
      expect(stueckFehlend(restCent: 900, proStueckCent: 300), 3);
      expect(stueckFehlend(restCent: 0, proStueckCent: 300), 0);
      expect(stueckFehlend(restCent: 100, proStueckCent: 0), isNull);
    });
  });

  group('CSV', () {
    test('deutsches Format mit Semikolon und Komma', () {
      final csv = verkaeufeAlsCsv(
        [
          v(
            1,
            'Flexi; "Dragon"',
            2,
            550,
            120,
            am: DateTime(2026, 3, 7, 9, 5),
            gebuehr: 15,
          ),
        ],
        kopfzeile: const [
          'Datum',
          'Produkt',
          'Menge',
          'Einzelpreis',
          'Umsatz',
          'Kosten',
          'Gebühr',
          'Gewinn',
          'Zahlung',
        ],
        zahlungsart: (_) => 'Bar',
      );
      final zeilen = csv.split('\r\n');
      expect(
        zeilen[1],
        '07.03.2026 09:05;"Flexi; ""Dragon""";2;5,50;11,00;2,40;0,15;8,45;Bar',
      );
    });

    test('negative Beträge', () {
      expect(betragCsv(-205), '-2,05');
      expect(betragCsv(7), '0,07');
    });
  });

  test('Gratis-Grenzen', () {
    expect(darfAnlegen(vorhanden: 14, grenze: 15, istPro: false), isTrue);
    expect(darfAnlegen(vorhanden: 15, grenze: 15, istPro: false), isFalse);
    expect(darfAnlegen(vorhanden: 99, grenze: 15, istPro: true), isTrue);
  });
}
