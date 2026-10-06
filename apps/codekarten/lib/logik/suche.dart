/// Tags aus „Java, Basics ,schleifen“ → {java, basics, schleifen}.
List<String> tagsLesen(String text) => {
  for (final t in text.split(','))
    if (t.trim().isNotEmpty) t.trim().toLowerCase(),
}.toList();

/// Passt ein Snippet zur Suche? Alle Wörter müssen in Titel, Code, Notiz
/// oder Tags vorkommen (Groß/klein egal).
bool passtZurSuche({
  required String suche,
  required String titel,
  required String code,
  required String notiz,
  required String tags,
}) {
  final woerter = suche
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty);
  final heu = '$titel\n$code\n$notiz\n$tags'.toLowerCase();
  return woerter.every(heu.contains);
}
