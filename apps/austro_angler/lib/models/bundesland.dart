/// Schwerpunkt: Bezirk Braunau und Umgebung (Innviertel und Flachgau).
enum Bundesland {
  ooe('Oberösterreich', 'OÖ'),
  sbg('Salzburg', 'Sbg');

  const Bundesland(this.name, this.kurz);

  final String name;
  final String kurz;

  static Bundesland? ausName(String? name) {
    for (final b in values) {
      if (b.name == name) return b;
    }
    return null;
  }
}
