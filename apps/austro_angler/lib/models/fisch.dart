import 'bundesland.dart';

/// Ein Tag im Jahr (ohne Jahreszahl), z. B. 16.9.
class Tag {
  const Tag(this.tag, this.monat);

  final int tag;
  final int monat;

  int get _wert => monat * 100 + tag;

  @override
  String toString() => '$tag.$monat.';
}

/// Schonzeit und Brittelmaß einer Fischart in einem Bundesland.
class Regel {
  const Regel({
    this.von,
    this.bis,
    this.mindestmassCm,
    this.ganzjaehrigGeschont = false,
    this.unbekannt = false,
    this.hinweis,
  });

  /// Keine Daten vorhanden: in der App als "bitte prüfen" angezeigt.
  const Regel.unbekannt() : this(unbekannt: true);

  const Regel.ganzjaehrig() : this(ganzjaehrigGeschont: true);

  final Tag? von;
  final Tag? bis;
  final int? mindestmassCm;
  final bool ganzjaehrigGeschont;
  final bool unbekannt;
  final String? hinweis;

  String get schonzeitText {
    if (unbekannt) return 'unbekannt – bitte prüfen';
    if (ganzjaehrigGeschont) return 'ganzjährig geschont';
    if (von == null || bis == null) return 'keine';
    return '$von – $bis';
  }

  String get mindestmassText {
    if (unbekannt) return 'unbekannt – bitte prüfen';
    if (ganzjaehrigGeschont) return '–';
    if (mindestmassCm == null) return 'keines';
    return '$mindestmassCm cm';
  }

  /// Ob [datum] in der Schonzeit liegt. `null`, wenn es keine Daten gibt.
  bool? istGeschont(DateTime datum) {
    if (unbekannt) return null;
    if (ganzjaehrigGeschont) return true;
    if (von == null || bis == null) return false;
    final heute = datum.month * 100 + datum.day;
    if (von!._wert <= bis!._wert) {
      return heute >= von!._wert && heute <= bis!._wert;
    }
    // Schonzeit über den Jahreswechsel, z. B. 16.9. – 15.3.
    return heute >= von!._wert || heute <= bis!._wert;
  }
}

class Fisch {
  const Fisch({
    required this.id,
    required this.name,
    required this.familie,
    required this.merkmale,
    required this.lebensraum,
    required this.koeder,
    required this.regeln,
    this.raubfisch = false,
  });

  final String id;
  final String name;
  final String familie;
  final String merkmale;
  final String lebensraum;
  final String koeder;
  final bool raubfisch;
  final Map<Bundesland, Regel> regeln;

  Regel regel(Bundesland land) => regeln[land] ?? const Regel.unbekannt();
}
