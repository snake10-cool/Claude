import '../logik/kalkulation.dart';
import 'datenbank.dart';

/// Ein Produkt mit allem, was dazugehört, und den fertig berechneten Kosten.
class ProduktDetails {
  ProduktDetails({
    required this.produkt,
    required this.drucker,
    required this.filamente,
    required this.extras,
    required this.einstellungen,
  });

  final Produkt produkt;
  final Drucker? drucker;
  final List<(ProduktFilament, Filament)> filamente;
  final List<(ProduktExtra, Extra)> extras;
  final Einstellungen einstellungen;

  late final Kostenaufstellung kosten = berechneKosten(eingabe);

  KalkulationsEingabe get eingabe => KalkulationsEingabe(
    druckzeitMinuten: produkt.druckzeitMinuten,
    stueckProDruck: produkt.stueckProDruck,
    filamente: [
      for (final (pf, f) in filamente)
        FilamentAnteil(gramm: pf.gramm, preisProKgCent: f.preisProKgCent),
    ],
    spuelabfallGramm: produkt.spuelabfallGramm,
    drucker: drucker == null
        ? null
        : DruckerWerte(
            leistungWatt: drucker!.leistungWatt,
            anschaffungCent: drucker!.anschaffungCent,
            lebensdauerStunden: drucker!.lebensdauerStunden,
          ),
    strompreisCentProKwh: einstellungen.strompreisCentProKwh,
    extrasCent: extras.fold(0, (s, e) => s + e.$1.menge * e.$2.kostenCent),
    arbeitMinuten: produkt.arbeitMinuten,
    stundenlohnCent: einstellungen.stundenlohnCent,
    fehldruckProzent: einstellungen.fehldruckProzent,
  );

  int get kostenCent => kosten.gesamtCent;

  int get aufschlagProzent =>
      produkt.aufschlagProzent ?? einstellungen.standardAufschlagProzent;

  int get vorschlagCent => preisVorschlag(
    kostenCent: kostenCent,
    aufschlagProzent: aufschlagProzent,
    rundungCent: einstellungen.rundungCent,
  );

  /// Der Preis, zu dem verkauft wird.
  int get preisCent => produkt.preisManuellCent ?? vorschlagCent;

  int get gewinnCent => preisCent - kostenCent;

  /// Hauptfarbe des Produkts für Knöpfe (erstes Filament oder eigene Farbe).
  int get anzeigeFarbe =>
      filamente.isNotEmpty ? filamente.first.$2.farbe : produkt.farbe;
}
