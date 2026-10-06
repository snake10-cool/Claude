/// Ergebnis für einen Buchstaben.
enum Feld { richtig, enthalten, falsch }

const wortLaenge = 5;
const maxVersuche = 6;

/// Bewertet einen Versuch wie Wordle: Erst die richtigen Stellen, dann
/// „enthalten“ nur so oft, wie der Buchstabe im Lösungswort noch übrig ist.
List<Feld> bewerten(String versuch, String loesung) {
  final v = versuch.toLowerCase();
  final l = loesung.toLowerCase();
  final ergebnis = List.filled(wortLaenge, Feld.falsch);
  final uebrig = <String, int>{};
  for (var i = 0; i < wortLaenge; i++) {
    if (v[i] == l[i]) {
      ergebnis[i] = Feld.richtig;
    } else {
      uebrig[l[i]] = (uebrig[l[i]] ?? 0) + 1;
    }
  }
  for (var i = 0; i < wortLaenge; i++) {
    if (ergebnis[i] == Feld.richtig) continue;
    final n = uebrig[v[i]] ?? 0;
    if (n > 0) {
      ergebnis[i] = Feld.enthalten;
      uebrig[v[i]] = n - 1;
    }
  }
  return ergebnis;
}

/// Bester bekannter Zustand pro Buchstabe für die Tastatur.
Map<String, Feld> tastaturStatus(List<String> versuche, String loesung) {
  final status = <String, Feld>{};
  for (final v in versuche) {
    final b = bewerten(v, loesung);
    for (var i = 0; i < wortLaenge; i++) {
      final c = v[i].toLowerCase();
      final alt = status[c];
      if (alt == null || b[i].index < alt.index) status[c] = b[i];
    }
  }
  return status;
}

/// Emoji-Raster zum Teilen (ohne die Buchstaben zu verraten).
String emojiRaster(List<String> versuche, String loesung) => [
  for (final v in versuche)
    bewerten(v, loesung)
        .map(
          (f) => switch (f) {
            Feld.richtig => '🟩',
            Feld.enthalten => '🟨',
            Feld.falsch => '⬛',
          },
        )
        .join(),
].join('\n');

/// Lösungswort für eine Rätselnummer (Liste ist schon gemischt).
String wortDesTages(List<String> loesungen, int nummer) =>
    loesungen[(nummer - 1) % loesungen.length];
