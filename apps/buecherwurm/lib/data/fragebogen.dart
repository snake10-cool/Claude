/// Eine Antwortmöglichkeit. [gewichte] verschiebt das Leseprofil
/// (Schlüssel aus Tags), [wert] wird für Alter, Länge und Format genutzt.
class Option {
  const Option(this.id, this.text, {this.gewichte = const {}, this.wert});

  final String id;
  final String text;
  final Map<String, double> gewichte;
  final int? wert;
}

class FragebogenFrage {
  const FragebogenFrage(
    this.id,
    this.text,
    this.optionen, {
    this.mehrfach = false,
    this.hinweis,
  });

  final String id;
  final String text;
  final List<Option> optionen;

  /// Mehrere Antworten erlaubt.
  final bool mehrfach;
  final String? hinweis;
}

const fragebogen = <FragebogenFrage>[
  FragebogenFrage('alter', 'Wie alt bist du?', [
    Option('u10', 'Unter 10', wert: 8, gewichte: {'jungeHelden': 1, 'tiere': 0.5, 'humor': 0.5}),
    Option('10', '10–13', wert: 11, gewichte: {'jungeHelden': 1, 'abenteuer': 0.5}),
    Option('14', '14–17', wert: 15, gewichte: {'jungeHelden': 0.5}),
    Option('18', '18–29', wert: 20),
    Option('30', '30 oder älter', wert: 35),
  ]),
  FragebogenFrage(
    'genres',
    'Welche Genres magst du?',
    [
      Option('fantasy', 'Fantasy & Magie', gewichte: {'fantasy': 3}),
      Option('scifi', 'Science-Fiction & Weltall', gewichte: {'scifi': 3}),
      Option('krimi', 'Krimi & Detektiv', gewichte: {'krimi': 3}),
      Option('thriller', 'Thriller', gewichte: {'thriller': 3, 'spannend': 1}),
      Option('horror', 'Grusel & Horror', gewichte: {'horror': 3}),
      Option('liebe', 'Liebesgeschichten', gewichte: {'liebe': 3}),
      Option('humor', 'Lustige Bücher', gewichte: {'humor': 3}),
      Option('abenteuer', 'Abenteuer', gewichte: {'abenteuer': 3}),
      Option('historisch', 'Historische Romane', gewichte: {'historisch': 3}),
      Option('dystopie', 'Dystopien (düstere Zukunft)', gewichte: {'dystopie': 3}),
      Option('sachbuch', 'Sachbücher', gewichte: {'sachbuch': 3}),
      Option('klassiker', 'Klassiker', gewichte: {'klassiker': 3}),
    ],
    mehrfach: true,
    hinweis: 'Wähle so viele, wie du willst.',
  ),
  FragebogenFrage('format', 'Liest du lieber oder hörst du lieber?', [
    Option('lesen', 'Lesen (Buch oder E-Book)', wert: 0),
    Option('hoeren', 'Hören (Hörbuch)', wert: 1),
    Option('beides', 'Beides', wert: 2),
  ]),
  FragebogenFrage('laenge', 'Wie lang darf ein Buch sein?', [
    Option('kurz', 'Kurz – unter 250 Seiten', wert: 0),
    Option('mittel', 'Mittel – bis etwa 500 Seiten', wert: 1),
    Option('lang', 'Je dicker, desto besser', wert: 2),
    Option('egal', 'Ist mir egal', wert: 3),
  ]),
  FragebogenFrage(
    'stimmung',
    'Wie soll sich ein Buch anfühlen?',
    [
      Option('spannend', 'Spannend – ich will nicht aufhören', gewichte: {'spannend': 2, 'thriller': 0.5}),
      Option('lustig', 'Lustig – ich will lachen', gewichte: {'humor': 2}),
      Option('gefuehl', 'Gefühlvoll – ich will mitfühlen', gewichte: {'gefuehl': 2, 'liebe': 0.5}),
      Option('nachdenklich', 'Nachdenklich – ich will grübeln', gewichte: {'nachdenklich': 2}),
      Option('gruselig', 'Gruselig – ich will Gänsehaut', gewichte: {'horror': 2}),
    ],
    mehrfach: true,
  ),
  FragebogenFrage('welt', 'In welcher Welt fühlst du dich am wohlsten?', [
    Option('heute', 'In unserer Welt, heute', gewichte: {'gegenwart': 2}),
    Option('frueher', 'In der Vergangenheit', gewichte: {'historisch': 2}),
    Option('zukunft', 'In der Zukunft oder im Weltall', gewichte: {'scifi': 2, 'dystopie': 1}),
    Option('magie', 'In einer Welt voller Magie', gewichte: {'fantasy': 2}),
    Option('egal', 'Überall, Hauptsache gut', gewichte: {}),
  ]),
  FragebogenFrage('held', 'Wer soll die Hauptfigur sein?', [
    Option('jung', 'Kinder oder Jugendliche', gewichte: {'jungeHelden': 2}),
    Option('erwachsen', 'Erwachsene', gewichte: {'jungeHelden': -1}),
    Option('tiere', 'Tiere oder Fabelwesen', gewichte: {'tiere': 2, 'fantasy': 0.5}),
    Option('egal', 'Egal', gewichte: {}),
  ]),
  FragebogenFrage(
    'wichtig',
    'Was ist dir in einer Geschichte wichtig?',
    [
      Option('action', 'Action und Kämpfe', gewichte: {'action': 2}),
      Option('liebe', 'Liebe und Beziehungen', gewichte: {'liebe': 2}),
      Option('raetsel', 'Rätsel und Geheimnisse', gewichte: {'krimi': 2}),
      Option('freundschaft', 'Freundschaft und Zusammenhalt', gewichte: {'freundschaft': 2}),
      Option('wissen', 'Etwas lernen', gewichte: {'sachbuch': 2, 'historisch': 0.5}),
      Option('reise', 'Reisen und Entdecken', gewichte: {'abenteuer': 2}),
    ],
    mehrfach: true,
  ),
  FragebogenFrage('ende', 'Wie soll ein Buch enden?', [
    Option('happy', 'Mit einem Happy End', gewichte: {'happyend': 2, 'traurig': -1.5}),
    Option('offen', 'Gern auch offen', gewichte: {'nachdenklich': 0.5}),
    Option('traurig', 'Traurig ist okay – Hauptsache echt', gewichte: {'traurig': 1, 'drama': 1}),
    Option('egal', 'Egal', gewichte: {}),
  ]),
  FragebogenFrage('reihe', 'Reihen oder Einzelbände?', [
    Option('reihe', 'Reihen – ich will mehr davon', gewichte: {'serie': 1.5}),
    Option('einzel', 'Lieber abgeschlossene Bücher', gewichte: {'serie': -1}),
    Option('egal', 'Egal', gewichte: {}),
  ]),
  FragebogenFrage('alt', 'Alte Klassiker oder neue Bücher?', [
    Option('klassiker', 'Klassiker', gewichte: {'klassiker': 2}),
    Option('neu', 'Neue Bücher', gewichte: {'klassiker': -1.5, 'gegenwart': 0.5}),
    Option('beides', 'Beides', gewichte: {}),
  ]),
  FragebogenFrage('grusel', 'Wie viel Grusel verträgst du?', [
    Option('kein', 'Gar keinen', gewichte: {'horror': -3}),
    Option('bisschen', 'Ein bisschen', gewichte: {'horror': -0.5}),
    Option('viel', 'Je mehr, desto besser', gewichte: {'horror': 2}),
  ]),
  FragebogenFrage('sach', 'Wie stehst du zu Sachbüchern und Ratgebern?', [
    Option('nie', 'Nur Romane bitte', gewichte: {'sachbuch': -3, 'selbsthilfe': -3}),
    Option('manchmal', 'Manchmal', gewichte: {}),
    Option('gern', 'Sehr gern', gewichte: {'sachbuch': 2, 'selbsthilfe': 1.5}),
  ]),
  FragebogenFrage('oft', 'Wie oft liest oder hörst du?', [
    Option('selten', 'Selten', gewichte: {'humor': 0.5}),
    Option('monat', 'Ein paar Mal im Monat'),
    Option('woche', 'Mehrmals pro Woche'),
    Option('taeglich', 'Jeden Tag'),
  ]),
  FragebogenFrage('ernst', 'Wie ernst darf es werden?', [
    Option('leicht', 'Lieber locker und leicht', gewichte: {'humor': 1, 'drama': -1.5}),
    Option('mittel', 'Mal so, mal so'),
    Option('ernst', 'Ruhig schwer und tiefgründig', gewichte: {'drama': 1.5, 'nachdenklich': 1}),
  ]),
];

FragebogenFrage? frageMitId(String id) {
  for (final f in fragebogen) {
    if (f.id == id) return f;
  }
  return null;
}
