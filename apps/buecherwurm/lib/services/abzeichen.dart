import '../models/buch.dart';
import 'speicher.dart';

class Abzeichen {
  const Abzeichen(this.emoji, this.name, this.beschreibung, this.erreicht);

  final String emoji;
  final String name;
  final String beschreibung;
  final bool Function(Speicher s) erreicht;
}

int _gelesen(Speicher s) => s.gelesen;
int _gehoert(Speicher s) =>
    s.eintraege.values.where((e) => e.status == Status.gelesen && e.format == Format.gehoert).length;
int _genres(Speicher s) => {
      for (final MapEntry(:key, :value) in s.eintraege.entries)
        if (value.status == Status.gelesen) ...?s.buch(key)?.tags.where(_genreTags.contains),
    }.length;
const _genreTags = {
  'fantasy', 'scifi', 'krimi', 'thriller', 'horror', 'liebe', 'klassiker', 'humor',
  'abenteuer', 'historisch', 'sachbuch', 'dystopie',
};
int _seiten(Speicher s) => s.eintraege.entries
    .where((e) => e.value.status == Status.gelesen)
    .fold(0, (sum, e) => sum + (s.buch(e.key)?.seiten ?? 0));

int _serie(Speicher s) {
  final tage = s.leseTage;
  var n = 0;
  var tag = DateTime.now();
  // Heute zählt noch nicht als verpasst, wenn noch nicht gelesen wurde.
  if (!tage.contains(Speicher.tagSchluessel(tag))) tag = tag.subtract(const Duration(days: 1));
  while (tage.contains(Speicher.tagSchluessel(tag))) {
    n++;
    tag = tag.subtract(const Duration(days: 1));
  }
  return n;
}

/// Aktuelle Lese-Serie in Tagen.
int leseSerie(Speicher s) => _serie(s);
int gesamtSeiten(Speicher s) => _seiten(s);

final alleAbzeichen = <Abzeichen>[
  Abzeichen('📖', 'Erstes Buch', 'Ein Buch als gelesen eingetragen', (s) => _gelesen(s) >= 1),
  Abzeichen('📚', 'Leseratte', '10 Bücher gelesen', (s) => _gelesen(s) >= 10),
  Abzeichen('🐛', 'Bücherwurm', '25 Bücher gelesen', (s) => _gelesen(s) >= 25),
  Abzeichen('🏛️', 'Bibliothek', '100 Bücher gelesen', (s) => _gelesen(s) >= 100),
  Abzeichen('🎧', 'Ohrenleser', '5 Hörbücher gehört', (s) => _gehoert(s) >= 5),
  Abzeichen('🧭', 'Entdecker', 'Bücher aus 6 verschiedenen Genres', (s) => _genres(s) >= 6),
  Abzeichen('🏔️', '10.000 Seiten', 'Zusammen über 10.000 Seiten gelesen', (s) => _seiten(s) >= 10000),
  Abzeichen('✅', 'Bewiesen', 'Das erste Quiz bestanden', (s) => s.bewiesen >= 1),
  Abzeichen('🎓', 'Quiz-Profi', '10 Quizze bestanden', (s) => s.bewiesen >= 10),
  Abzeichen('💯', 'Fehlerfrei', 'Ein Quiz ohne Fehler', (s) => s.quiz.values.any((q) => q.richtig == q.gesamt)),
  Abzeichen('⚖️', 'Kritiker', 'Bücher gegeneinander verglichen', (s) => s.vergleiche >= 1),
  Abzeichen('🔥', 'Dranbleiber', '7 Tage in Folge gelesen', (s) => _serie(s) >= 7),
  Abzeichen('🎯', 'Ziel erreicht', 'Jahres-Leseziel geschafft',
      (s) => s.jahresziel > 0 && s.gelesenImJahr(DateTime.now().year) >= s.jahresziel),
];
