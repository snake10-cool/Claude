import 'dart:math' as math;

/// Ein Filament in einem Produkt: Gramm pro Druck und Kilopreis.
class FilamentAnteil {
  const FilamentAnteil({required this.gramm, required this.preisProKgCent});
  final double gramm;
  final int preisProKgCent;
}

/// Werte des Druckers für Strom und Abnutzung.
class DruckerWerte {
  const DruckerWerte({
    required this.leistungWatt,
    required this.anschaffungCent,
    required this.lebensdauerStunden,
  });
  final int leistungWatt;
  final int anschaffungCent;
  final int lebensdauerStunden;
}

/// Alles, was man braucht, um die Kosten eines Stücks zu berechnen.
class KalkulationsEingabe {
  const KalkulationsEingabe({
    required this.druckzeitMinuten,
    this.stueckProDruck = 1,
    this.filamente = const [],
    this.spuelabfallGramm = 0,
    this.drucker,
    this.strompreisCentProKwh = 0,
    this.extrasCent = 0,
    this.arbeitMinuten = 0,
    this.stundenlohnCent = 0,
    this.fehldruckProzent = 0,
  });

  /// Pro Druck (ganze Platte).
  final int druckzeitMinuten;
  final int stueckProDruck;

  /// Pro Druck (ganze Platte).
  final List<FilamentAnteil> filamente;
  final double spuelabfallGramm;
  final DruckerWerte? drucker;
  final double strompreisCentProKwh;

  /// Pro Stück.
  final int extrasCent;
  final int arbeitMinuten;
  final int stundenlohnCent;

  /// Zuschlag auf Material, Strom und Abnutzung für misslungene Drucke.
  final int fehldruckProzent;
}

/// Kosten eines Stücks, aufgeschlüsselt. Intern mit Kommastellen gerechnet,
/// gerundet wird nur am Ende ([gesamtCent]).
class Kostenaufstellung {
  const Kostenaufstellung({
    required this.material,
    required this.strom,
    required this.abnutzung,
    required this.fehldruck,
    required this.extras,
    required this.arbeit,
  });

  final double material;
  final double strom;
  final double abnutzung;
  final double fehldruck;
  final double extras;
  final double arbeit;

  double get summe =>
      material + strom + abnutzung + fehldruck + extras + arbeit;
  int get gesamtCent => summe.round();
}

Kostenaufstellung berechneKosten(KalkulationsEingabe e) {
  final stueck = math.max(1, e.stueckProDruck);
  final stunden = e.druckzeitMinuten / 60;

  var materialProDruck = 0.0;
  var grammGesamt = 0.0;
  for (final f in e.filamente) {
    materialProDruck += f.gramm * f.preisProKgCent / 1000;
    grammGesamt += f.gramm;
  }
  // Spülabfall kostet so viel wie das Filament im Schnitt (nach Gewicht).
  if (grammGesamt > 0 && e.spuelabfallGramm > 0) {
    materialProDruck += e.spuelabfallGramm * (materialProDruck / grammGesamt);
  }

  var stromProDruck = 0.0;
  var abnutzungProDruck = 0.0;
  final d = e.drucker;
  if (d != null) {
    stromProDruck = d.leistungWatt / 1000 * stunden * e.strompreisCentProKwh;
    if (d.lebensdauerStunden > 0) {
      abnutzungProDruck = d.anschaffungCent / d.lebensdauerStunden * stunden;
    }
  }

  final material = materialProDruck / stueck;
  final strom = stromProDruck / stueck;
  final abnutzung = abnutzungProDruck / stueck;
  final fehldruck = (material + strom + abnutzung) * e.fehldruckProzent / 100;
  final arbeit = e.arbeitMinuten / 60 * e.stundenlohnCent;

  return Kostenaufstellung(
    material: material,
    strom: strom,
    abnutzung: abnutzung,
    fehldruck: fehldruck,
    extras: e.extrasCent.toDouble(),
    arbeit: arbeit,
  );
}

/// Preisvorschlag: Kosten plus Aufschlag, aufgerundet auf [rundungCent]
/// (50 = auf 0,50 €). Es wird immer aufgerundet, damit der Gewinn nie
/// kleiner wird als gewünscht.
int preisVorschlag({
  required int kostenCent,
  required int aufschlagProzent,
  required int rundungCent,
}) {
  if (kostenCent <= 0) return 0;
  final zaehler = kostenCent * (100 + aufschlagProzent);
  final roh = (zaehler + 99) ~/ 100; // auf ganze Cent aufrunden
  if (rundungCent <= 1) return roh;
  return ((roh + rundungCent - 1) ~/ rundungCent) * rundungCent;
}

/// Anteil des Gewinns am Verkaufspreis in Prozent (die „echte“ Marge).
double margeVomPreis({required int preisCent, required int kostenCent}) {
  if (preisCent <= 0) return 0;
  return (preisCent - kostenCent) / preisCent * 100;
}

/// Gebühr eines Zahlungsanbieters in Cent.
int gebuehrCent(int betragCent, double prozent) =>
    (betragCent * prozent / 100).round();
