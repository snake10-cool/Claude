import '../models/bundesland.dart';
import '../models/fisch.dart';

/// Stand der Schonbestimmungen (Recherche Oktober 2026).
///
/// OÖ: Oö. Fischereiverordnung, Tabelle des Oö. Landesfischereiverbands
/// (gültig ab 1.10.2020). Salzburg: Salzburger Fischereiverband.
/// Einzelne Reviere können strengere Regeln haben.
const schonzeitenStand = 'Stand: Oktober 2026 – ohne Gewähr';

const _ooe = Bundesland.ooe;
const _sbg = Bundesland.sbg;

const fische = <Fisch>[
  Fisch(
    id: 'bachforelle',
    name: 'Bachforelle',
    familie: 'Lachsfische (Salmoniden)',
    merkmale: 'Rote Punkte mit hellem Rand, Fettflosse, kräftiges Maul.',
    lebensraum: 'Kühle, sauerstoffreiche Bäche und Flüsse.',
    koeder: 'Spinner, Wurm, Fliege, Bachflohkrebs.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 9), bis: Tag(15, 3), mindestmassCm: 22),
      _sbg: Regel(
        von: Tag(1, 10),
        bis: Tag(28, 2),
        mindestmassCm: 25,
        hinweis: 'Über 800 m Seehöhe gilt 22 cm.',
      ),
    },
  ),
  Fisch(
    id: 'regenbogenforelle',
    name: 'Regenbogenforelle',
    familie: 'Lachsfische (Salmoniden)',
    merkmale:
        'Rosa-violettes Band entlang der Seite, viele kleine schwarze Punkte '
        'auch auf der Schwanzflosse. Stammt aus Nordamerika.',
    lebensraum: 'Flüsse, Bäche und Teiche, oft besetzt.',
    koeder: 'Spinner, Teig, Bienenmade, Wurm.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(1, 12), bis: Tag(15, 3), mindestmassCm: 22),
      _sbg: Regel(),
    },
  ),
  Fisch(
    id: 'seeforelle',
    name: 'Seeforelle',
    familie: 'Lachsfische (Salmoniden)',
    merkmale: 'Silbrig mit schwarzen, x-förmigen Flecken, wird sehr groß.',
    lebensraum: 'Tiefe, klare Voralpenseen.',
    koeder: 'Schleppen mit Blinker oder Wobbler.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 9), bis: Tag(15, 3), mindestmassCm: 50),
      _sbg: Regel(von: Tag(1, 10), bis: Tag(31, 12), mindestmassCm: 50),
    },
  ),
  Fisch(
    id: 'bachsaibling',
    name: 'Bachsaibling',
    familie: 'Lachsfische (Salmoniden)',
    merkmale:
        'Wurmartiges Muster am Rücken, weiße Vorderkante an Bauch- und '
        'Afterflosse. Stammt aus Nordamerika.',
    lebensraum: 'Kalte Bäche und Bergseen.',
    koeder: 'Wurm, kleine Spinner, Fliege.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 9), bis: Tag(15, 3), mindestmassCm: 22),
      _sbg: Regel(),
    },
  ),
  Fisch(
    id: 'seesaibling',
    name: 'Seesaibling',
    familie: 'Lachsfische (Salmoniden)',
    merkmale: 'Rötlicher Bauch, weiße Vorderkante an den unteren Flossen.',
    lebensraum: 'Tiefe, kalte Seen.',
    koeder: 'Hegene, kleine Blinker.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 9), bis: Tag(15, 3), mindestmassCm: 22),
      _sbg: Regel(von: Tag(16, 10), bis: Tag(31, 12), mindestmassCm: 25),
    },
  ),
  Fisch(
    id: 'aesche',
    name: 'Äsche',
    familie: 'Lachsfische (Salmoniden)',
    merkmale:
        'Sehr große, fahnenartige Rückenflosse, kleines Maul. Riecht frisch '
        'gefangen nach Thymian.',
    lebensraum: 'Schnell fließende, kiesige Flüsse (Äschenregion).',
    koeder: 'Nymphe, Trockenfliege.',
    regeln: {
      _ooe: Regel(von: Tag(1, 3), bis: Tag(30, 4), mindestmassCm: 30),
      _sbg: Regel(von: Tag(1, 1), bis: Tag(31, 5), mindestmassCm: 33),
    },
  ),
  Fisch(
    id: 'huchen',
    name: 'Huchen',
    familie: 'Lachsfische (Salmoniden)',
    merkmale:
        'Langgestreckt, kupferfarben, wird über 1 m lang. Auch "Donaulachs" '
        'genannt, stark gefährdet.',
    lebensraum: 'Größere Flüsse im Donau-Einzugsgebiet.',
    koeder: 'Große Gummifische, Zopf (nur im Winter).',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 2), bis: Tag(31, 5), mindestmassCm: 85),
      _sbg: Regel(von: Tag(1, 2), bis: Tag(31, 5), mindestmassCm: 85),
    },
  ),
  Fisch(
    id: 'reinanke',
    name: 'Reinanke (Maräne)',
    familie: 'Lachsfische (Salmoniden)',
    merkmale: 'Silbrig, kleiner Kopf, Fettflosse, keine Punkte.',
    lebensraum: 'Große, klare Seen, im Freiwasser.',
    koeder: 'Hegene mit kleinen Nymphen.',
    regeln: {
      _ooe: Regel(von: Tag(16, 10), bis: Tag(31, 12), mindestmassCm: 30),
      _sbg: Regel.unbekannt(),
    },
  ),
  Fisch(
    id: 'hecht',
    name: 'Hecht',
    familie: 'Hechte',
    merkmale:
        'Entenschnabelartiges Maul voller Zähne, Rückenflosse weit hinten, '
        'grün-gelb marmoriert.',
    lebensraum: 'Pflanzenreiche Seen, Altarme und langsame Flüsse.',
    koeder: 'Köderfisch (tot), Gummifisch, Blinker, Wobbler.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(1, 2), bis: Tag(30, 4), mindestmassCm: 60),
      _sbg: Regel(von: Tag(1, 2), bis: Tag(30, 4), mindestmassCm: 50),
    },
  ),
  Fisch(
    id: 'zander',
    name: 'Zander',
    familie: 'Barsche',
    merkmale:
        'Glasige Augen, zwei Rückenflossen (die erste mit Stacheln), '
        'Fangzähne.',
    lebensraum: 'Trübe Seen und große Flüsse wie der Inn.',
    koeder: 'Gummifisch, toter Köderfisch, am besten in der Dämmerung.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(1, 3), bis: Tag(30, 4), mindestmassCm: 50),
      _sbg: Regel(von: Tag(16, 3), bis: Tag(31, 5), mindestmassCm: 40),
    },
  ),
  Fisch(
    id: 'flussbarsch',
    name: 'Flussbarsch',
    familie: 'Barsche',
    merkmale:
        'Dunkle Querstreifen, rote Bauchflossen, stachelige erste '
        'Rückenflosse mit schwarzem Fleck.',
    lebensraum: 'Seen und Flüsse, oft in Schwärmen.',
    koeder: 'Wurm, kleiner Spinner, Dropshot.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(1, 3), bis: Tag(30, 4), mindestmassCm: 10),
      _sbg: Regel.unbekannt(),
    },
  ),
  Fisch(
    id: 'wels',
    name: 'Wels (Waller)',
    familie: 'Welse',
    merkmale:
        'Größter Süßwasserfisch Europas, keine Schuppen, 6 Barteln '
        '(2 lange am Oberkiefer).',
    lebensraum: 'Warme, große Flüsse und Seen, z. B. der Inn.',
    koeder: 'Tauwurmbündel, Köderfisch (tot), Pellets, Wallerholz.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(1, 6), bis: Tag(30, 6), mindestmassCm: 80),
      _sbg: Regel(),
    },
  ),
  Fisch(
    id: 'aalrutte',
    name: 'Aalrutte (Quappe)',
    familie: 'Dorsche',
    merkmale:
        'Einziger Süßwasser-Dorsch, eine Bartel am Kinn, marmoriert, '
        'laicht im Winter.',
    lebensraum: 'Kühle Flüsse und tiefe Seen, nachtaktiv.',
    koeder: 'Wurm, Fischfetzen – nachts am Grund.',
    raubfisch: true,
    regeln: {
      _ooe: Regel(von: Tag(16, 11), bis: Tag(28, 2), mindestmassCm: 40),
      _sbg: Regel(von: Tag(1, 12), bis: Tag(31, 3), mindestmassCm: 35),
    },
  ),
  Fisch(
    id: 'karpfen',
    name: 'Karpfen',
    familie: 'Karpfenfische',
    merkmale:
        'Hochrückig, 4 Barteln am Maul. Schuppen-, Spiegel- und Lederkarpfen.',
    lebensraum: 'Warme, nährstoffreiche Seen und Teiche.',
    koeder: 'Boilies, Mais, Teig, Wurm.',
    regeln: {
      _ooe: Regel(von: Tag(1, 5), bis: Tag(31, 5), mindestmassCm: 35),
      _sbg: Regel(),
    },
  ),
  Fisch(
    id: 'schleie',
    name: 'Schleie',
    familie: 'Karpfenfische',
    merkmale:
        'Grün-goldene Farbe, sehr kleine Schuppen, viel Schleim, '
        '2 kurze Barteln, rote Augen.',
    lebensraum: 'Schlammige, pflanzenreiche Seen und Teiche.',
    koeder: 'Wurm, Mais, Made – am Grund.',
    regeln: {
      _ooe: Regel(von: Tag(1, 5), bis: Tag(30, 6), mindestmassCm: 25),
      _sbg: Regel(von: Tag(1, 6), bis: Tag(31, 7), mindestmassCm: 25),
    },
  ),
  Fisch(
    id: 'brachse',
    name: 'Brachse (Brasse)',
    familie: 'Karpfenfische',
    merkmale: 'Sehr hochrückig und seitlich flach, rüsselartiges Maul.',
    lebensraum: 'Seen und langsame Flüsse (Brachsenregion).',
    koeder: 'Made, Wurm, Mais mit Futterkorb.',
    regeln: {
      _ooe: Regel(von: Tag(1, 5), bis: Tag(31, 5), mindestmassCm: 25),
      _sbg: Regel.unbekannt(),
    },
  ),
  Fisch(
    id: 'barbe',
    name: 'Barbe',
    familie: 'Karpfenfische',
    merkmale: 'Langgestreckt, unterständiges Maul mit 4 Barteln.',
    lebensraum: 'Kiesige, strömende Flüsse (Barbenregion).',
    koeder: 'Wurm, Käse, Frühstücksfleisch am Grund.',
    regeln: {
      _ooe: Regel(von: Tag(16, 4), bis: Tag(31, 5), mindestmassCm: 35),
      _sbg: Regel(von: Tag(1, 5), bis: Tag(15, 6), mindestmassCm: 35),
    },
  ),
  Fisch(
    id: 'nase',
    name: 'Nase',
    familie: 'Karpfenfische',
    merkmale:
        'Vorstehende "Nase", unterständiges Maul mit harter Lippe zum '
        'Abweiden von Algen.',
    lebensraum: 'Strömende Flüsse, wandert in Schwärmen.',
    koeder: 'Kaum gezielt befischt.',
    regeln: {
      _ooe: Regel(von: Tag(16, 3), bis: Tag(31, 5), mindestmassCm: 35),
      _sbg: Regel.ganzjaehrig(),
    },
  ),
  Fisch(
    id: 'aitel',
    name: 'Aitel (Döbel)',
    familie: 'Karpfenfische',
    merkmale: 'Breiter Kopf, großes Maul, Schuppen dunkel umrandet.',
    lebensraum: 'Fast alle Flüsse, sehr anpassungsfähig.',
    koeder: 'Brot, Kirschen, Wurm, kleine Spinner.',
    regeln: {
      _ooe: Regel(von: Tag(16, 3), bis: Tag(31, 5), mindestmassCm: 25),
      _sbg: Regel(),
    },
  ),
];

Fisch? fischById(String id) {
  for (final f in fische) {
    if (f.id == id) return f;
  }
  return null;
}
