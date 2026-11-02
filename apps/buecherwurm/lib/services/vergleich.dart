import '../models/buch.dart';

/// Ein Thema, nach dem Bücher gegeneinander bewertet werden.
class Aspekt {
  const Aspekt(this.id, this.frage, this.tags, {this.immer = false});

  final String id;
  final String frage;

  /// Ein Buch gehört dazu, wenn es eines dieser Merkmale hat. Die Bewertung
  /// verschiebt genau diese Merkmale im Leseprofil.
  final Set<String> tags;

  /// Gilt für jedes Buch (z. B. „Wie gefällt dir das Ende?").
  final bool immer;
}

const aspekte = <Aspekt>[
  Aspekt('gesamt', 'Wie gefällt dir das Buch insgesamt?', {}, immer: true),
  Aspekt('liebe', 'Wie gefällt dir die Liebesgeschichte?', {'liebe'}),
  Aspekt('spannung', 'Wie spannend findest du es?', {'spannend', 'thriller'}),
  Aspekt('humor', 'Wie lustig findest du es?', {'humor'}),
  Aspekt('magie', 'Wie gefällt dir die magische Welt?', {'fantasy'}),
  Aspekt('zukunft', 'Wie gefällt dir die Zukunftswelt?', {'scifi', 'dystopie'}),
  Aspekt('raetsel', 'Wie gefällt dir der Kriminalfall?', {'krimi'}),
  Aspekt('grusel', 'Wie gut ist der Grusel?', {'horror'}),
  Aspekt('freundschaft', 'Wie gefällt dir die Freundschaft der Figuren?', {'freundschaft'}),
  Aspekt('action', 'Wie gefallen dir Kämpfe und Action?', {'action'}),
  Aspekt('abenteuer', 'Wie gefällt dir das Abenteuer?', {'abenteuer'}),
  Aspekt('gefuehl', 'Wie sehr berührt dich die Geschichte?', {'gefuehl', 'drama', 'traurig'}),
  Aspekt('geschichte', 'Wie gefällt dir die Zeit, in der es spielt?', {'historisch'}),
  Aspekt('tiere', 'Wie gefallen dir die Tiere in der Geschichte?', {'tiere'}),
  Aspekt('nachdenken', 'Wie sehr regt es dich zum Nachdenken an?', {'nachdenklich'}),
  Aspekt('figur', 'Wie gefällt dir die Hauptfigur?', {}, immer: true),
  Aspekt('ende', 'Wie gefällt dir das Ende?', {}, immer: true),
];

/// Antwortmöglichkeiten: Wert 3 (super) bis 0 (gar nicht), null = weiß nicht.
const bewertungen = <(String, String, int?)>[
  ('😍', 'Super', 3),
  ('🙂', 'Gut', 2),
  ('😐', 'Geht so', 1),
  ('👎', 'Gar nicht', 0),
  ('🤷', 'Weiß nicht', null),
];

/// Die Themen, die für diese Bücher passen: allgemeine Themen immer,
/// besondere nur, wenn mindestens zwei der Bücher sie haben – und dann nur
/// mit diesen Büchern.
List<(Aspekt, List<Buch>)> runden(List<Buch> buecher) => [
      for (final a in aspekte)
        if (a.immer)
          (a, buecher)
        else if (buecher.where((b) => b.tags.intersection(a.tags).isNotEmpty).toList()
            case final passend when passend.length >= 2)
          (a, passend),
    ];

class VergleichsErgebnis {
  const VergleichsErgebnis(this.rangliste, this.sieger, this.vorlieben, this.sterne);

  /// Bücher nach Durchschnittswert, bestes zuerst.
  final List<(Buch, double)> rangliste;

  /// Thema → bestes Buch (nur bei eindeutigem Sieger).
  final Map<Aspekt, Buch> sieger;

  /// Merkmal → Vorliebe von -1 (mag ich nicht) bis +1 (liebe ich).
  final Map<String, double> vorlieben;

  /// Vorgeschlagene Sterne aus der Gesamtbewertung (Buch-ID → 1–5).
  final Map<String, int> sterne;
}

/// [antworten]: Aspekt-ID → (Buch-ID → Wert 0–3 oder null).
VergleichsErgebnis auswerten(List<Buch> buecher, Map<String, Map<String, int?>> antworten) {
  final summe = <String, int>{};
  final anzahl = <String, int>{};
  final sieger = <Aspekt, Buch>{};
  final tagWerte = <String, List<double>>{};

  for (final (a, teil) in runden(buecher)) {
    final werte = antworten[a.id] ?? const {};
    int? bester;
    Buch? besterBuch;
    var eindeutig = false;
    for (final b in teil) {
      final w = werte[b.id];
      if (w == null) continue;
      summe[b.id] = (summe[b.id] ?? 0) + w;
      anzahl[b.id] = (anzahl[b.id] ?? 0) + 1;
      if (bester == null || w > bester) {
        bester = w;
        besterBuch = b;
        eindeutig = true;
      } else if (w == bester) {
        eindeutig = false;
      }
      // -1 … +1, nur für die Merkmale, um die es in diesem Thema geht.
      for (final t in a.tags.intersection(b.tags)) {
        tagWerte.putIfAbsent(t, () => []).add((w - 1.5) / 1.5);
      }
    }
    if (besterBuch != null && eindeutig && teil.length >= 2) sieger[a] = besterBuch;
  }

  final rangliste = [
    for (final b in buecher)
      if ((anzahl[b.id] ?? 0) > 0) (b, summe[b.id]! / anzahl[b.id]!),
  ]..sort((x, y) => y.$2.compareTo(x.$2));

  final gesamt = antworten['gesamt'] ?? const {};
  return VergleichsErgebnis(
    rangliste,
    sieger,
    {for (final MapEntry(:key, :value) in tagWerte.entries) key: value.reduce((x, y) => x + y) / value.length},
    {
      for (final MapEntry(:key, :value) in gesamt.entries)
        if (value != null) key: const [1, 3, 4, 5][value],
    },
  );
}
