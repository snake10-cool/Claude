/// Für wen ein Buch gedacht ist.
enum Zielgruppe { kinder, jugend, erwachsene }

/// Wie schwer ein Quiz ist – angezeigt als „leicht“, „mittel“ oder „schwierig“.
enum Schwierigkeit {
  leicht('leicht'),
  mittel('mittel'),
  schwierig('schwierig');

  const Schwierigkeit(this.text);
  final String text;
}

/// Eine Quizfrage. Die erste Antwort in [antworten] ist die richtige,
/// angezeigt werden sie gemischt.
class Frage {
  const Frage(this.text, this.antworten);

  final String text;
  final List<String> antworten;

  String get richtig => antworten.first;
}

class Buch {
  const Buch({
    required this.id,
    required this.titel,
    required this.autor,
    required this.jahr,
    required this.seiten,
    required this.zielgruppe,
    required this.tags,
    required this.beschreibung,
    this.minAlter = 0,
    this.quiz = const [],
    this.eigenes = false,
    this.coverUrl,
    this.isbn,
    this.schwierigkeit,
  });

  final String id;
  final String titel;
  final String autor;
  final int jahr;
  final int seiten;
  final Zielgruppe zielgruppe;

  /// Merkmale für die Empfehlungen, siehe [Tags].
  final Set<String> tags;
  final String beschreibung;
  final int minAlter;
  final List<Frage> quiz;

  /// Vom Nutzer selbst angelegt (nicht im Katalog, ohne Quiz).
  final bool eigenes;

  /// Cover aus der Online-Suche, sonst null (dann Platzhalter).
  final String? coverUrl;
  final String? isbn;

  /// Nur setzen, wenn das Quiz deutlich leichter oder schwerer ist als für
  /// die Altersgruppe üblich – sonst gilt [stufe] nach der Zielgruppe.
  final Schwierigkeit? schwierigkeit;

  Schwierigkeit get stufe =>
      schwierigkeit ??
      switch (zielgruppe) {
        Zielgruppe.kinder => Schwierigkeit.leicht,
        Zielgruppe.jugend => Schwierigkeit.mittel,
        Zielgruppe.erwachsene => Schwierigkeit.schwierig,
      };

  bool get hatQuiz => quiz.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titel': titel,
        'autor': autor,
        'jahr': jahr,
        'seiten': seiten,
        'zielgruppe': zielgruppe.name,
        'tags': tags.toList(),
        'beschreibung': beschreibung,
        'coverUrl': ?coverUrl,
        'isbn': ?isbn,
      };

  factory Buch.eigenesAusJson(Map<String, dynamic> j) => Buch(
        id: j['id'] as String,
        titel: j['titel'] as String,
        autor: j['autor'] as String,
        jahr: j['jahr'] as int? ?? 0,
        seiten: j['seiten'] as int? ?? 0,
        zielgruppe: Zielgruppe.values.asNameMap()[j['zielgruppe']] ?? Zielgruppe.erwachsene,
        tags: {...?(j['tags'] as List?)?.cast<String>()},
        beschreibung: j['beschreibung'] as String? ?? 'Selbst hinzugefügt.',
        eigenes: true,
        coverUrl: j['coverUrl'] as String?,
        isbn: j['isbn'] as String?,
      );
}

/// Alle Merkmale, die Bücher und Fragebogen-Antworten verbinden.
class Tags {
  static const fantasy = 'fantasy';
  static const scifi = 'scifi';
  static const krimi = 'krimi';
  static const thriller = 'thriller';
  static const horror = 'horror';
  static const liebe = 'liebe';
  static const klassiker = 'klassiker';
  static const humor = 'humor';
  static const abenteuer = 'abenteuer';
  static const historisch = 'historisch';
  static const sachbuch = 'sachbuch';
  static const dystopie = 'dystopie';
  static const drama = 'drama';
  static const nachdenklich = 'nachdenklich';
  static const gegenwart = 'gegenwart';
  static const freundschaft = 'freundschaft';
  static const spannend = 'spannend';
  static const gefuehl = 'gefuehl';
  static const action = 'action';
  static const jungeHelden = 'jungeHelden';
  static const tiere = 'tiere';
  static const traurig = 'traurig';
  static const happyend = 'happyend';
  static const serie = 'serie';
  static const selbsthilfe = 'selbsthilfe';

  static const namen = {
    fantasy: 'Fantasy',
    scifi: 'Science-Fiction',
    krimi: 'Krimi',
    thriller: 'Thriller',
    horror: 'Grusel',
    liebe: 'Liebe',
    klassiker: 'Klassiker',
    humor: 'Lustig',
    abenteuer: 'Abenteuer',
    historisch: 'Geschichte',
    sachbuch: 'Sachbuch',
    dystopie: 'Dystopie',
    drama: 'Drama',
    nachdenklich: 'Nachdenklich',
    gegenwart: 'Heute',
    freundschaft: 'Freundschaft',
    spannend: 'Spannend',
    gefuehl: 'Gefühlvoll',
    action: 'Action',
    jungeHelden: 'Junge Helden',
    tiere: 'Tiere',
    traurig: 'Traurig',
    happyend: 'Happy End',
    serie: 'Reihe',
    selbsthilfe: 'Selbsthilfe',
  };
}

enum Status {
  wunschliste('Wunschliste'),
  lese('Lese ich gerade'),
  gelesen('Gelesen'),
  abgebrochen('Abgebrochen');

  const Status(this.text);
  final String text;
}

enum Format {
  gelesen('gelesen'),
  gehoert('gehört');

  const Format(this.wort);
  final String wort;
}

/// Ein Buch in der eigenen Bibliothek.
class Eintrag {
  Eintrag({
    required this.status,
    this.sterne = 0,
    this.format = Format.gelesen,
    this.notiz = '',
    this.seite = 0,
    DateTime? datum,
  }) : datum = datum ?? DateTime.now();

  Status status;

  /// 0 = nicht bewertet, sonst 1–5.
  int sterne;
  Format format;
  String notiz;

  /// Aktuelle Seite beim Lesen (0 = nicht erfasst).
  int seite;
  DateTime datum;

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'sterne': sterne,
        'format': format.name,
        'notiz': notiz,
        'seite': seite,
        'datum': datum.toIso8601String(),
      };

  factory Eintrag.ausJson(Map<String, dynamic> j) => Eintrag(
        status: Status.values.byName(j['status'] as String),
        sterne: j['sterne'] as int? ?? 0,
        format: Format.values.byName(j['format'] as String? ?? 'gelesen'),
        notiz: j['notiz'] as String? ?? '',
        seite: j['seite'] as int? ?? 0,
        datum: DateTime.tryParse(j['datum'] as String? ?? ''),
      );
}

/// Ergebnis des ersten Quiz-Versuchs zu einem Buch (nur der zählt).
class QuizErgebnis {
  const QuizErgebnis({
    required this.richtig,
    required this.gesamt,
    required this.punkte,
    required this.datum,
  });

  final int richtig;
  final int gesamt;
  final int punkte;
  final DateTime datum;

  /// Mindestens zwei Drittel richtig: Das Buch zählt als „bewiesen gelesen".
  bool get bestanden => richtig * 3 >= gesamt * 2;

  Map<String, dynamic> toJson() => {
        'richtig': richtig,
        'gesamt': gesamt,
        'punkte': punkte,
        'datum': datum.toIso8601String(),
      };

  factory QuizErgebnis.ausJson(Map<String, dynamic> j) => QuizErgebnis(
        richtig: j['richtig'] as int,
        gesamt: j['gesamt'] as int,
        punkte: j['punkte'] as int,
        datum: DateTime.parse(j['datum'] as String),
      );
}
