import 'bundesland.dart';

/// Ein Tag im Jahr (ohne Jahreszahl), z. B. 16.9.
class Tag {
  const Tag(this.tag, this.monat);

  final int tag;
  final int monat;

  int get _wert => monat * 100 + tag;

  /// Nächstes Datum ab [ab] (heute zählt mit).
  DateTime naechstes(DateTime ab) {
    final heute = DateTime(ab.year, ab.month, ab.day);
    final d = DateTime(ab.year, monat, tag);
    return d.isBefore(heute) ? DateTime(ab.year + 1, monat, tag) : d;
  }

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

  /// Tage bis zum Ende der Schonzeit (wenn gerade geschont), sonst null.
  int? tageBisOffen(DateTime heute) {
    if (istGeschont(heute) != true || ganzjaehrigGeschont) return null;
    return _tageZwischen(heute, bis!.naechstes(heute)) + 1;
  }

  /// Tage bis zum Beginn der Schonzeit (wenn gerade offen), sonst null.
  int? tageBisSchonzeit(DateTime heute) {
    if (istGeschont(heute) != false || von == null) return null;
    return _tageZwischen(heute, von!.naechstes(heute));
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
    this.geschuetzt = false,
    this.eingeschleppt = false,
    this.ausgestorben = false,
  });

  final String id;
  final String name;
  final String familie;
  final String merkmale;
  final String lebensraum;
  final String koeder;
  final bool raubfisch;

  /// FFH-Art, darf nicht entnommen werden.
  final bool geschuetzt;

  /// Nicht heimisch (eingesetzt oder eingeschleppt).
  final bool eingeschleppt;

  /// In Österreich ausgestorben oder verschollen.
  final bool ausgestorben;
  final Map<Bundesland, Regel> regeln;

  Regel regel(Bundesland land) => regeln[land] ?? const Regel.unbekannt();
}

/// Ganze Kalendertage von [a] bis [b] – in UTC gerechnet, sonst fehlt über
/// die Sommerzeit-Umstellung eine Stunde und es wird ein Tag zu wenig.
int _tageZwischen(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;
