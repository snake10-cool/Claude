import 'package:druckkasse/logik/kalkulation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('berechneKosten', () {
    test('Material, Strom und Abnutzung für einen Flexi Dragon', () {
      // 30 g PLA zu 20 €/kg, 2 h, Bambu A1 mit 100 W, 300 € auf 5000 h,
      // Strom 25 ct/kWh, ohne Fehldruck-Zuschlag.
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 120,
          filamente: [FilamentAnteil(gramm: 30, preisProKgCent: 2000)],
          drucker: DruckerWerte(
            leistungWatt: 100,
            anschaffungCent: 30000,
            lebensdauerStunden: 5000,
          ),
          strompreisCentProKwh: 25,
        ),
      );
      expect(k.material, closeTo(60, 0.0001)); // 30 g × 2 ct
      expect(k.strom, closeTo(5, 0.0001)); // 0,1 kW × 2 h × 25 ct
      expect(k.abnutzung, closeTo(12, 0.0001)); // 6 ct/h × 2 h
      expect(k.gesamtCent, 77);
    });

    test('mehrere Stück pro Druck teilen die Druckkosten', () {
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 60,
          stueckProDruck: 4,
          filamente: [FilamentAnteil(gramm: 40, preisProKgCent: 2000)],
          extrasCent: 10,
        ),
      );
      expect(k.material, closeTo(20, 0.0001)); // 80 ct / 4
      expect(k.extras, 10); // Extras gelten pro Stück, nicht geteilt
      expect(k.gesamtCent, 30);
    });

    test('Spülabfall kostet den Durchschnittspreis der Filamente', () {
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 0,
          filamente: [
            FilamentAnteil(gramm: 10, preisProKgCent: 2000), // 20 ct
            FilamentAnteil(gramm: 10, preisProKgCent: 4000), // 40 ct
          ],
          spuelabfallGramm: 20, // Schnitt 3 ct/g → 60 ct
        ),
      );
      expect(k.material, closeTo(120, 0.0001));
    });

    test('Fehldruck-Zuschlag nur auf Material, Strom und Abnutzung', () {
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 0,
          filamente: [FilamentAnteil(gramm: 50, preisProKgCent: 2000)],
          extrasCent: 50,
          fehldruckProzent: 10,
        ),
      );
      expect(k.fehldruck, closeTo(10, 0.0001));
      expect(k.gesamtCent, 160);
    });

    test('Arbeitszeit mit Stundenlohn', () {
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 0,
          arbeitMinuten: 6,
          stundenlohnCent: 1500,
        ),
      );
      expect(k.arbeit, closeTo(150, 0.0001));
    });

    test('ohne Drucker und mit 0 Stück kein Absturz', () {
      final k = berechneKosten(
        const KalkulationsEingabe(
          druckzeitMinuten: 90,
          stueckProDruck: 0,
          drucker: DruckerWerte(
            leistungWatt: 100,
            anschaffungCent: 100,
            lebensdauerStunden: 0,
          ),
        ),
      );
      expect(k.abnutzung, 0);
      expect(k.gesamtCent, 0);
    });
  });

  group('preisVorschlag', () {
    test('Aufschlag und Aufrunden auf 0,50 €', () {
      // 77 ct + 200 % = 2,31 € → 2,50 €
      expect(
        preisVorschlag(kostenCent: 77, aufschlagProzent: 200, rundungCent: 50),
        250,
      );
    });

    test('genau auf der Rundungsgrenze bleibt der Preis', () {
      expect(
        preisVorschlag(kostenCent: 100, aufschlagProzent: 100, rundungCent: 50),
        200,
      );
    });

    test('ohne Rundung auf ganze Cent aufgerundet', () {
      expect(
        preisVorschlag(kostenCent: 33, aufschlagProzent: 50, rundungCent: 0),
        50, // 49,5 → 50
      );
    });

    test('Kosten 0 ergibt Preis 0', () {
      expect(
        preisVorschlag(kostenCent: 0, aufschlagProzent: 200, rundungCent: 50),
        0,
      );
    });
  });

  test('Marge vom Verkaufspreis', () {
    expect(margeVomPreis(preisCent: 400, kostenCent: 100), 75);
    expect(margeVomPreis(preisCent: 0, kostenCent: 100), 0);
  });

  test('Gebühr wird kaufmännisch gerundet', () {
    expect(gebuehrCent(1000, 1.39), 14);
    expect(gebuehrCent(1000, 0), 0);
  });
}
