/// Gründe, aus denen man eine Quizfrage melden kann.
const meldeGruende = <String, String>{
  'keine': 'Keine der Antworten ist richtig',
  'falsch': 'Die als richtig gewertete Antwort stimmt nicht',
  'mehrere': 'Mehrere Antworten könnten stimmen',
  'unklar': 'Die Frage ist unklar oder missverständlich',
  'spoiler': 'Verrät zu viel oder passt nicht zu diesem Buch',
  'tippfehler': 'Tipp- oder Rechtschreibfehler',
  'sonstiges': 'Sonstiges',
};

/// Eine Meldung zu einer Quizfrage („an dieser Frage stimmt etwas nicht“).
class FrageMeldung {
  const FrageMeldung({
    this.id = '',
    required this.buchId,
    required this.buchTitel,
    required this.frage,
    required this.richtig,
    required this.gewaehlt,
    required this.grund,
    this.text = '',
    this.name = '',
  });

  final String id;
  final String buchId;
  final String buchTitel;
  final String frage;

  /// Die Antwort, die die App als richtig wertet.
  final String richtig;

  /// Was der Leser angeklickt hat (leer, wenn die Zeit ablief).
  final String gewaehlt;

  /// Schlüssel aus [meldeGruende].
  final String grund;
  final String text;
  final String name;

  String get grundText => meldeGruende[grund] ?? grund;

  Map<String, dynamic> toJson() => {
        'buchId': buchId,
        'buchTitel': buchTitel,
        'frage': frage,
        'richtig': richtig,
        'gewaehlt': gewaehlt,
        'grund': grund,
        'text': text,
      };

  factory FrageMeldung.fromJson(Map<String, dynamic> j, {String id = ''}) => FrageMeldung(
        id: id,
        buchId: j['buchId'] as String? ?? '',
        buchTitel: j['buchTitel'] as String? ?? '',
        frage: j['frage'] as String? ?? '',
        richtig: j['richtig'] as String? ?? '',
        gewaehlt: j['gewaehlt'] as String? ?? '',
        grund: j['grund'] as String? ?? 'sonstiges',
        text: j['text'] as String? ?? '',
        name: j['name'] as String? ?? '',
      );
}
