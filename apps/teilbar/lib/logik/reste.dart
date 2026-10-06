/// Resteküche: Welche Rezepte passen zu den Zutaten, die ich habe?
class Zutat {
  const Zutat({required this.name, required this.menge, this.grund = false});

  factory Zutat.ausJson(Map<String, dynamic> j) => Zutat(
    name: j['name'] as String,
    menge: j['menge'] as String? ?? '',
    grund: j['grund'] as bool? ?? false,
  );

  final String name;
  final String menge;

  /// Grundzutaten (Salz, Öl, Mehl …) hat man meist zu Hause.
  final bool grund;
}

class Rezept {
  const Rezept({
    required this.id,
    required this.name,
    required this.minuten,
    required this.portionen,
    required this.tags,
    required this.zutaten,
    required this.schritte,
  });

  factory Rezept.ausJson(Map<String, dynamic> j) => Rezept(
    id: j['id'] as String,
    name: j['name'] as String,
    minuten: j['minuten'] as int,
    portionen: j['portionen'] as int,
    tags: (j['tags'] as List).cast<String>(),
    zutaten: [
      for (final z in j['zutaten'] as List)
        Zutat.ausJson(Map<String, dynamic>.from(z as Map)),
    ],
    schritte: (j['schritte'] as List).cast<String>(),
  );

  final String id;
  final String name;
  final int minuten;
  final int portionen;
  final List<String> tags;
  final List<Zutat> zutaten;
  final List<String> schritte;
}

/// Vergleichsform: klein, ohne Umlaut-Unterschiede, ohne Plural-Endungen.
String zutatSchluessel(String name) {
  var s = name
      .toLowerCase()
      .trim()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss');
  // Unregelmäßige Mehrzahl.
  s = const {'eier': 'ei', 'nuesse': 'nuss', 'aepfel': 'apfel'}[s] ?? s;
  for (final endung in ['n', 'en', 'e', 's']) {
    if (s.length > 4 && s.endsWith(endung)) {
      s = s.substring(0, s.length - endung.length);
      break;
    }
  }
  return s;
}

/// Hat jemand diese Zutat? „Tomaten“ passt zu „Tomate“, „Dosentomaten“
/// aber nicht zu „Tomaten“ (anderes Produkt).
bool zutatVorhanden(String zutat, Set<String> vorhanden) =>
    vorhanden.contains(zutatSchluessel(zutat));

class RezeptTreffer {
  const RezeptTreffer(this.rezept, this.fehlend, this.vorhanden);
  final Rezept rezept;

  /// Fehlende Zutaten (ohne Grundzutaten).
  final List<Zutat> fehlend;

  /// Wie viele der Hauptzutaten vorhanden sind.
  final int vorhanden;

  int get haupt => fehlend.length + vorhanden;
  double get anteil => haupt == 0 ? 1 : vorhanden / haupt;
}

/// Sortiert Rezepte: am wenigsten fehlend zuerst, dann die mit den
/// meisten verwendeten Zutaten. Rezepte ohne jede passende Zutat fallen
/// weg (außer [alle] ist gesetzt).
List<RezeptTreffer> rezepteFinden(
  Iterable<Rezept> rezepte,
  Iterable<String> meineZutaten, {
  bool alle = false,
}) {
  final vorhanden = {for (final z in meineZutaten) zutatSchluessel(z)};
  final treffer = <RezeptTreffer>[];
  for (final r in rezepte) {
    final fehlend = <Zutat>[];
    var da = 0;
    for (final z in r.zutaten.where((z) => !z.grund)) {
      if (zutatVorhanden(z.name, vorhanden)) {
        da++;
      } else {
        fehlend.add(z);
      }
    }
    if (da == 0 && !alle) continue;
    treffer.add(RezeptTreffer(r, fehlend, da));
  }
  treffer.sort((a, b) {
    final f = a.fehlend.length.compareTo(b.fehlend.length);
    if (f != 0) return f;
    final v = b.vorhanden.compareTo(a.vorhanden);
    return v != 0 ? v : a.rezept.name.compareTo(b.rezept.name);
  });
  return treffer;
}

/// Alle Zutatennamen aus den Rezepten, für Vorschläge beim Eintippen.
List<String> alleZutaten(Iterable<Rezept> rezepte) {
  final namen = <String, String>{};
  for (final r in rezepte) {
    for (final z in r.zutaten.where((z) => !z.grund)) {
      namen.putIfAbsent(zutatSchluessel(z.name), () => z.name);
    }
  }
  return namen.values.toList()..sort();
}

/// Rezept des Tages – jeden Tag ein anderes.
Rezept rezeptDesTages(List<Rezept> rezepte, DateTime tag) {
  final n = DateTime.utc(
    tag.year,
    tag.month,
    tag.day,
  ).difference(DateTime.utc(2000)).inDays;
  return rezepte[n % rezepte.length];
}
