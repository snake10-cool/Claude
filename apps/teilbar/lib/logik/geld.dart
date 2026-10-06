// Geldlogik für Gruppen: Wer hat wie viel bezahlt, wer schuldet wem.
// Alle Beträge in Cent.

/// Eine Ausgabe: [zahler] hat [betragCent] bezahlt, aufgeteilt nach
/// [anteile] (Person → Gewicht, z. B. alle 1 = gleichmäßig).
///
/// Eine Rückzahlung „A zahlt B 10 €“ ist einfach eine Ausgabe mit
/// zahler A und anteile {B: 1}.
class Buchung {
  const Buchung({
    required this.zahler,
    required this.betragCent,
    required this.anteile,
  });

  final String zahler;
  final int betragCent;
  final Map<String, int> anteile;
}

/// Teilt [betragCent] nach Gewichten auf, sodass die Summe exakt stimmt.
/// Restcent gehen an die größten Nachkommaanteile (bei Gleichstand in der
/// Reihenfolge der Schlüssel).
Map<String, int> aufteilen(int betragCent, Map<String, int> gewichte) {
  final aktiv = {
    for (final e in gewichte.entries)
      if (e.value > 0) e.key: e.value,
  };
  if (aktiv.isEmpty) return const {};
  final summe = aktiv.values.fold(0, (a, b) => a + b);
  final ergebnis = <String, int>{};
  final reste = <(String, int)>[];
  var verteilt = 0;
  for (final e in aktiv.entries) {
    final zaehler = betragCent * e.value;
    final teil = zaehler ~/ summe;
    ergebnis[e.key] = teil;
    reste.add((e.key, zaehler % summe));
    verteilt += teil;
  }
  // Bei negativen Beträgen (Gutschrift) funktioniert ~/ anders – hier
  // kommen nur positive Beträge vor.
  reste.sort((a, b) => b.$2.compareTo(a.$2));
  var rest = betragCent - verteilt;
  for (final (person, _) in reste) {
    if (rest <= 0) break;
    ergebnis[person] = ergebnis[person]! + 1;
    rest--;
  }
  return ergebnis;
}

/// Saldo pro Person: positiv = bekommt Geld zurück, negativ = schuldet.
/// Die Summe aller Salden ist immer 0.
Map<String, int> salden(
  Iterable<Buchung> buchungen,
  Iterable<String> personen,
) {
  final s = {for (final p in personen) p: 0};
  for (final b in buchungen) {
    final teile = aufteilen(b.betragCent, b.anteile);
    if (teile.isEmpty) continue;
    s[b.zahler] = (s[b.zahler] ?? 0) + b.betragCent;
    for (final e in teile.entries) {
      s[e.key] = (s[e.key] ?? 0) - e.value;
    }
  }
  return s;
}

/// Eine Überweisung zum Ausgleichen.
class Ueberweisung {
  const Ueberweisung(this.von, this.an, this.betragCent);
  final String von;
  final String an;
  final int betragCent;

  @override
  bool operator ==(Object other) =>
      other is Ueberweisung &&
      other.von == von &&
      other.an == an &&
      other.betragCent == betragCent;

  @override
  int get hashCode => Object.hash(von, an, betragCent);

  @override
  String toString() => '$von → $an: $betragCent';
}

/// Möglichst wenige Überweisungen, damit alle Salden 0 werden: Wer am
/// meisten schuldet, zahlt dem, der am meisten bekommt.
List<Ueberweisung> ausgleichen(Map<String, int> salden) {
  final schuldner = [
    for (final e in salden.entries)
      if (e.value < 0) [e.key, -e.value],
  ];
  final glaeubiger = [
    for (final e in salden.entries)
      if (e.value > 0) [e.key, e.value],
  ];
  final ergebnis = <Ueberweisung>[];
  while (schuldner.isNotEmpty && glaeubiger.isNotEmpty) {
    schuldner.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
    glaeubiger.sort((a, b) => (b[1] as int).compareTo(a[1] as int));
    final s = schuldner.first;
    final g = glaeubiger.first;
    final betrag = (s[1] as int) < (g[1] as int) ? s[1] as int : g[1] as int;
    ergebnis.add(Ueberweisung(s[0] as String, g[0] as String, betrag));
    s[1] = (s[1] as int) - betrag;
    g[1] = (g[1] as int) - betrag;
    if (s[1] == 0) schuldner.removeAt(0);
    if (g[1] == 0) glaeubiger.removeAt(0);
  }
  return ergebnis;
}

/// Ergebnis des Rechnungs- und Trinkgeldrechners.
class Rechnung {
  const Rechnung({
    required this.trinkgeldCent,
    required this.gesamtCent,
    required this.proPersonCent,
  });

  final int trinkgeldCent;
  final int gesamtCent;

  /// Was jede Person zahlt (bei Rundung kann die Summe etwas über
  /// [gesamtCent] liegen – das ist dann zusätzliches Trinkgeld).
  final int proPersonCent;
}

/// Rechnungsbetrag + Trinkgeld, geteilt durch [personen]. Mit
/// [aufrundenAufCent] (z. B. 50) wird der Betrag pro Person aufgerundet.
Rechnung rechnungTeilen({
  required int betragCent,
  required double trinkgeldProzent,
  required int personen,
  int aufrundenAufCent = 0,
}) {
  final p = personen < 1 ? 1 : personen;
  final trinkgeld = (betragCent * trinkgeldProzent / 100).round();
  final gesamt = betragCent + trinkgeld;
  var proPerson = (gesamt + p - 1) ~/ p; // nie zu wenig
  if (aufrundenAufCent > 1) {
    proPerson =
        ((proPerson + aufrundenAufCent - 1) ~/ aufrundenAufCent) *
        aufrundenAufCent;
  }
  return Rechnung(
    trinkgeldCent: proPerson * p - betragCent,
    gesamtCent: proPerson * p,
    proPersonCent: proPerson,
  );
}
