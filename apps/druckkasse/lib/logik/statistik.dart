/// Ein Verkauf, so wie ihn die Auswertung braucht (unabhängig von der
/// Datenbank, damit sich alles testen lässt).
class VerkaufZeile {
  const VerkaufZeile({
    required this.zeitpunkt,
    required this.produktId,
    required this.produktName,
    required this.menge,
    required this.einzelpreisCent,
    required this.einzelkostenCent,
    this.gebuehrCent = 0,
    this.zahlungsart = 0,
  });

  final DateTime zeitpunkt;
  final int? produktId;
  final String produktName;
  final int menge;
  final int einzelpreisCent;
  final int einzelkostenCent;
  final int gebuehrCent;

  /// Index von `Zahlungsart`.
  final int zahlungsart;

  int get umsatzCent => menge * einzelpreisCent;
  int get kostenCent => menge * einzelkostenCent;
  int get gewinnCent => umsatzCent - kostenCent - gebuehrCent;
}

class BestsellerEintrag {
  const BestsellerEintrag({
    required this.produktId,
    required this.name,
    required this.stueck,
    required this.umsatzCent,
    required this.gewinnCent,
  });

  final int? produktId;
  final String name;
  final int stueck;
  final int umsatzCent;
  final int gewinnCent;
}

class Auswertung {
  const Auswertung({
    required this.umsatzCent,
    required this.kostenCent,
    required this.gebuehrenCent,
    required this.stueck,
    required this.anzahlVerkaeufe,
    required this.bestseller,
  });

  static const leer = Auswertung(
    umsatzCent: 0,
    kostenCent: 0,
    gebuehrenCent: 0,
    stueck: 0,
    anzahlVerkaeufe: 0,
    bestseller: [],
  );

  final int umsatzCent;
  final int kostenCent;
  final int gebuehrenCent;
  final int stueck;
  final int anzahlVerkaeufe;

  /// Sortiert nach Stückzahl, bei Gleichstand nach Umsatz.
  final List<BestsellerEintrag> bestseller;

  int get gewinnCent => umsatzCent - kostenCent - gebuehrenCent;
}

Auswertung auswerten(Iterable<VerkaufZeile> verkaeufe) {
  var umsatz = 0, kosten = 0, gebuehren = 0, stueck = 0, anzahl = 0;
  final proProdukt = <Object, _Summe>{};
  for (final v in verkaeufe) {
    umsatz += v.umsatzCent;
    kosten += v.kostenCent;
    gebuehren += v.gebuehrCent;
    stueck += v.menge;
    anzahl++;
    final schluessel = v.produktId ?? v.produktName;
    final s = proProdukt.putIfAbsent(
      schluessel,
      () => _Summe(v.produktId, v.produktName),
    );
    s.stueck += v.menge;
    s.umsatz += v.umsatzCent;
    s.gewinn += v.gewinnCent;
  }
  final bestseller =
      [
        for (final s in proProdukt.values)
          BestsellerEintrag(
            produktId: s.id,
            name: s.name,
            stueck: s.stueck,
            umsatzCent: s.umsatz,
            gewinnCent: s.gewinn,
          ),
      ]..sort((a, b) {
        final c = b.stueck.compareTo(a.stueck);
        return c != 0 ? c : b.umsatzCent.compareTo(a.umsatzCent);
      });
  return Auswertung(
    umsatzCent: umsatz,
    kostenCent: kosten,
    gebuehrenCent: gebuehren,
    stueck: stueck,
    anzahlVerkaeufe: anzahl,
    bestseller: bestseller,
  );
}

class _Summe {
  _Summe(this.id, this.name);
  final int? id;
  final String name;
  int stueck = 0, umsatz = 0, gewinn = 0;
}

/// Umsatz und Gewinn eines Monats für das Verlaufs-Diagramm.
class MonatsWert {
  const MonatsWert(this.monat, this.umsatzCent, this.gewinnCent);
  final DateTime monat;
  final int umsatzCent;
  final int gewinnCent;
}

/// Die letzten [anzahl] Monate bis einschließlich [bisMonat], älteste zuerst.
/// Monate ohne Verkäufe sind mit 0 dabei.
List<MonatsWert> monatsVerlauf(
  Iterable<VerkaufZeile> verkaeufe, {
  required DateTime bisMonat,
  int anzahl = 6,
}) {
  final monate = [
    for (var i = anzahl - 1; i >= 0; i--)
      DateTime(bisMonat.year, bisMonat.month - i),
  ];
  final umsatz = {for (final m in monate) m: 0};
  final gewinn = {for (final m in monate) m: 0};
  for (final v in verkaeufe) {
    final m = DateTime(v.zeitpunkt.year, v.zeitpunkt.month);
    if (!umsatz.containsKey(m)) continue;
    umsatz[m] = umsatz[m]! + v.umsatzCent;
    gewinn[m] = gewinn[m]! + v.gewinnCent;
  }
  return [for (final m in monate) MonatsWert(m, umsatz[m]!, gewinn[m]!)];
}

/// Erster Tag des Monats und erster Tag des Folgemonats.
(DateTime, DateTime) monatsGrenzen(DateTime monat) =>
    (DateTime(monat.year, monat.month), DateTime(monat.year, monat.month + 1));
