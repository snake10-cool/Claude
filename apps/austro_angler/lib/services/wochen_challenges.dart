import '../models/fang.dart';

/// Eine persönliche Aufgabe für die aktuelle Woche.
class WochenChallenge {
  const WochenChallenge(this.id, this.symbol, this.titel, this.ziel, this.zaehlen);

  final String id;
  final String symbol;
  final String titel;
  final int ziel;

  /// Fortschritt aus den Fängen dieser Woche (und allen früheren).
  final int Function(List<Fang> woche, List<Fang> frueher) zaehlen;
}

final alleChallenges = <WochenChallenge>[
  WochenChallenge('arten', '🐟', 'Fang 3 verschiedene Fischarten', 3,
      (w, _) => w.map((f) => f.fischId).toSet().length),
  WochenChallenge('frueh', '🌅', 'Früher Vogel: ein Fang vor 7 Uhr', 1,
      (w, _) => w.where((f) => f.datum.hour < 7).length),
  WochenChallenge('abend', '🌙', 'Abendangler: ein Fang ab 19 Uhr', 1,
      (w, _) => w.where((f) => f.datum.hour >= 19).length),
  WochenChallenge('fuenf', '🎣', 'Fünf Fänge in einer Woche', 5,
      (w, _) => w.length),
  WochenChallenge('fair', '🤝', 'Fair Play: einen Fisch schonend zurücksetzen', 1,
      (w, _) => w.where((f) => f.zurueckgesetzt).length),
  WochenChallenge('neues_gewaesser', '🗺️', 'Fang an einem Gewässer, wo du noch nie gefangen hast', 1,
      (w, alt) {
    final bekannt = alt.map((f) => f.gewaesser).toSet();
    return w
        .where((f) => f.gewaesser.isNotEmpty && !bekannt.contains(f.gewaesser))
        .length;
  }),
  WochenChallenge('neuer_koeder', '🪱', 'Probier einen neuen Köder (mit Fang)', 1,
      (w, alt) {
    final bekannt = alt.map((f) => f.koeder.toLowerCase()).toSet();
    return w
        .where((f) =>
            f.koeder.isNotEmpty && !bekannt.contains(f.koeder.toLowerCase()))
        .length;
  }),
  WochenChallenge('vermessen', '📏', 'Miss 3 Fische und trag die Länge ein', 3,
      (w, _) => w.where((f) => f.laengeCm != null).length),
];

/// ISO-Kalenderwoche.
int kalenderwoche(DateTime d) {
  final tag = DateTime(d.year, d.month, d.day);
  final donnerstag = tag.add(Duration(days: 4 - tag.weekday));
  final jahresbeginn = DateTime(donnerstag.year);
  return 1 + donnerstag.difference(jahresbeginn).inDays ~/ 7;
}

DateTime wochenbeginn(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

/// Die zwei Challenges dieser Woche.
List<WochenChallenge> challengesDerWoche(DateTime jetzt) {
  final w = kalenderwoche(jetzt) + jetzt.year * 53;
  final n = alleChallenges.length;
  return [alleChallenges[(w * 2) % n], alleChallenges[(w * 2 + 1) % n]];
}

String challengeSchluessel(DateTime jetzt, WochenChallenge c) =>
    '${jetzt.year}-${kalenderwoche(jetzt)}-${c.id}';
