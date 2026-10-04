/// Alle neun Bundesländer. Schwerpunkt bleibt Braunau (OÖ) und Salzburg.
enum Bundesland {
  wien('Wien', 'W'),
  noe('Niederösterreich', 'NÖ'),
  bgld('Burgenland', 'Bgld'),
  ooe('Oberösterreich', 'OÖ'),
  sbg('Salzburg', 'Sbg'),
  stmk('Steiermark', 'Stmk'),
  ktn('Kärnten', 'Ktn'),
  tirol('Tirol', 'T'),
  vbg('Vorarlberg', 'Vbg');

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
