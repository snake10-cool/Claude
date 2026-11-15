import '../models/buch.dart';
import 'speicher.dart';

/// Eine Monats-Challenge. [geschafft] prüft die Bücher des Monats.
class Challenge {
  const Challenge(this.id, this.emoji, this.text, this.geschafft);

  final String id;
  final String emoji;
  final String text;
  final bool Function(Speicher s, int jahr, int monat) geschafft;
}

Iterable<Buch> _gelesenIm(Speicher s, int jahr, int monat) => [
      for (final MapEntry(:key, :value) in s.eintraege.entries)
        if (value.status == Status.gelesen && value.datum.year == jahr && value.datum.month == monat) ?s.buch(key),
    ];

Challenge _genre(String tag, String emoji, String text) =>
    Challenge('genre_$tag', emoji, text, (s, j, m) => _gelesenIm(s, j, m).any((b) => b.tags.contains(tag)));

final challengePool = <Challenge>[
  Challenge('dick', '🧱', 'Lies ein Buch mit über 400 Seiten',
      (s, j, m) => _gelesenIm(s, j, m).any((b) => b.seiten > 400)),
  Challenge('drei', '📚', 'Lies 3 Bücher in diesem Monat', (s, j, m) => _gelesenIm(s, j, m).length >= 3),
  Challenge('hoeren', '🎧', 'Hör ein Hörbuch', (s, j, m) => s.eintraege.values.any((e) =>
      e.status == Status.gelesen && e.format == Format.gehoert && e.datum.year == j && e.datum.month == m)),
  Challenge('quiz', '✅', 'Bestehe 2 Quizze', (s, j, m) =>
      s.quiz.values.where((q) => q.bestanden && q.datum.year == j && q.datum.month == m).length >= 2),
  Challenge('tage', '📅', 'Lies an 10 verschiedenen Tagen', (s, j, m) =>
      s.leseTage.where((t) => t.startsWith('$j-${m.toString().padLeft(2, '0')}')).length >= 10),
  Challenge('alt', '🏛️', 'Lies ein Buch, das vor 1950 erschienen ist',
      (s, j, m) => _gelesenIm(s, j, m).any((b) => b.jahr != 0 && b.jahr < 1950)),
  Challenge('reihe', '🔗', 'Lies einen Band aus einer Buchreihe',
      (s, j, m) => _gelesenIm(s, j, m).any((b) => b.tags.contains('serie'))),
  Challenge('kurz', '⚡', 'Lies ein Buch mit unter 150 Seiten',
      (s, j, m) => _gelesenIm(s, j, m).any((b) => b.seiten > 0 && b.seiten < 150)),
  _genre('fantasy', '🐉', 'Lies ein Fantasy-Buch'),
  _genre('krimi', '🔍', 'Lies einen Krimi'),
  _genre('scifi', '🚀', 'Lies ein Science-Fiction-Buch'),
  _genre('klassiker', '🎩', 'Lies einen Klassiker'),
  _genre('sachbuch', '🧠', 'Lies ein Sachbuch'),
  _genre('humor', '😂', 'Lies ein lustiges Buch'),
  _genre('historisch', '⏳', 'Lies ein Buch, das in der Vergangenheit spielt'),
];

/// Die drei Challenges eines Monats – für alle gleich, damit man sich
/// mit Freunden vergleichen kann.
List<Challenge> challengesFuer(int jahr, int monat) {
  final start = (jahr * 12 + monat) * 7;
  final liste = <Challenge>[];
  for (var i = 0; liste.length < 3; i++) {
    final c = challengePool[(start + i * 5) % challengePool.length];
    if (!liste.contains(c)) liste.add(c);
  }
  return liste;
}

/// Lesesommer: Juli und August doppelte Punkte.
bool istLesesommer(int monat) => monat == 7 || monat == 8;
int challengePunkte(int monat) => istLesesommer(monat) ? 50 : 25;
