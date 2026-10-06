/// Art einer Lernkarte. Der Name wird in der Datenbank und in den
/// Stapel-Dateien verwendet – nicht umbenennen.
enum KartenTyp {
  /// Frage → umdrehen → Antwort, selbst bewerten.
  begriff,

  /// „Was gibt dieser Code aus?“ mit Auswahl.
  ausgabe,

  /// Code mit Lücke „___“, richtige Ergänzung auswählen.
  luecke,
}

const sprachen = ['java', 'python', 'dart', 'javascript', 'andere'];

String spracheName(String sprache) => switch (sprache) {
  'java' => 'Java',
  'python' => 'Python',
  'dart' => 'Dart',
  'javascript' => 'JavaScript',
  _ => 'Code',
};
