/// Köder-Tipps nach Jahreszeit (Frühling, Sommer, Herbst, Winter).
/// Allgemeine Angler-Erfahrung – Schonzeiten gehen immer vor!
const koederTipps = <String, List<String>>{
  'hecht': [
    'Nach der Schonzeit (ab Mai): flach laufende Wobbler und Spinner im '
        'Flachwasser, wo sich das Wasser zuerst erwärmt.',
    'Morgens und abends an Krautkanten: Gummifisch, Spinnerbait, '
        'Oberflächenköder.',
    'Beste Hechtzeit: große Gummifische und tote Köderfische, tiefer '
        'geführt.',
    'Langsam! Toter Köderfisch am Grund oder große, langsam geführte '
        'Gummifische.',
  ],
  'zander': [
    'Nach der Schonzeit: Gummifisch in der Dämmerung, an Steinpackungen.',
    'Nachts und in der Dämmerung, kleine Gummifische oder Köderfischfetzen.',
    'Sehr gute Zeit: Gummifisch am Jigkopf in Faulenzer-Technik, tiefe '
        'Stellen.',
    'Langsam am Grund, toter Köderfisch; tagsüber in tiefen Rinnen.',
  ],
  'flussbarsch': [
    'Nach der Schonzeit: kleine Spinner und Gummis an Stegen und Kanten.',
    'Schwärme jagen an der Oberfläche – kleine Wobbler, Spinner, Wurm.',
    'Dropshot mit kleinen Gummis, große Barsche fressen jetzt viel.',
    'Tief und langsam: Dropshot, Wurm oder Made am Grund.',
  ],
  'karpfen': [
    'Wenn das Wasser wärmer wird: Mais, kleine Boilies im Flachen.',
    'Beste Zeit (nach der Schonzeit): Boilies, Mais, Teig – nachts und am '
        'Morgen, mit Futter.',
    'Fressen sich Reserven an: Boilies und Partikel, ruhig mehr füttern.',
    'Wenig füttern, kleine Happen (Maden, Mais) an tiefen, ruhigen Stellen.',
  ],
  'schleie': [
    'Ab warmem Wasser: Wurm oder Made am Grund, früh morgens.',
    'Nach der Schonzeit: Mais, Wurm, Made nahe am Kraut – sehr früh am Tag.',
    'Noch aktiv bei mildem Wetter: Wurm am Grund.',
    'Kaum aktiv – liegt im Schlamm.',
  ],
  'wels': [
    'Wird ab 15 °C Wassertemperatur aktiv: Tauwurmbündel, Köderfisch.',
    'Nach der Schonzeit beste Zeit: Wallerholz, Köderfisch, Pellets – '
        'nachts.',
    'Bis Oktober gut: Köderfisch, Tauwurmbündel in Rinnen.',
    'Kaum aktiv – Winterruhe in tiefen Löchern.',
  ],
  'bachforelle': [
    'Ab Saisonstart (Mitte März): Wurm und Spinner, später Nymphen.',
    'Trockenfliege am Abend, kleine Spinner in schnellem Wasser.',
    'Bis zur Schonzeit (Mitte Sept.): Wobbler und Streamer für große '
        'Forellen.',
    'Schonzeit (OÖ: 16.9. – 15.3.).',
  ],
  'regenbogenforelle': [
    'Nach der Schonzeit: Spinner, Bienenmade, Forellenteig.',
    'Morgens und abends: Spinner, Wurm, Trockenfliege.',
    'Sehr beißfreudig: Spinner, Teig, Bienenmade.',
    'In OÖ Schonzeit ab Dezember – davor langsam geführte Köder.',
  ],
  'aesche': [
    'Schonzeit (OÖ: März – April).',
    'Trockenfliege und kleine Nymphen.',
    'Beste Äschenzeit: Nymphe und Trockenfliege, auch an kalten Tagen.',
    'Nymphe am Grund an milden Wintertagen.',
  ],
  'aitel': [
    'Nach der Schonzeit (ab Juni in OÖ): Brot, Wurm.',
    'Kirschen und Beeren unter Bäumen, kleine Wobbler, Insekten.',
    'Wurm, Käse, kleine Spinner.',
    'Wurm und Made, langsam.',
  ],
  'barbe': [
    'Nach der Schonzeit: Wurm oder Made am Grund in der Strömung.',
    'Käse, Frühstücksfleisch, Wurm – mit Futterkorb, abends.',
    'Wurm und Käse in tieferen Rinnen.',
    'Kaum aktiv.',
  ],
  'brachse': [
    'Made und Wurm mit Futterkorb.',
    'Mais, Made, Wurm – viel Futter, abends und nachts.',
    'Made und Wurm an tiefen Stellen.',
    'Kleine Köder, wenig Futter, tief.',
  ],
  'aalrutte': [
    'Kaum aktiv.',
    'Kaum aktiv – zu warm.',
    'Ab Spätherbst: Wurm oder Fischfetzen nachts am Grund.',
    'Schonzeit (OÖ: 16.11. – 28.2.).',
  ],
  'rotauge': [
    'Nach der Schonzeit: Made, Teig an der Stippe.',
    'Made, Mais, Brot mit etwas Futter.',
    'Made und Wurm, in tieferem Wasser.',
    'Feine Montage, Made, wenig füttern.',
  ],
  'rapfen': [
    'Nach der Schonzeit (ab Juni in OÖ): schlanke Blinker.',
    'Raubt an der Oberfläche: schnell geführte Blinker und Wobbler.',
    'Blinker und Wobbler, schnell geführt.',
    'Wenig aktiv.',
  ],
};

/// 0 = Frühling, 1 = Sommer, 2 = Herbst, 3 = Winter.
int jahreszeit(DateTime d) => switch (d.month) {
      3 || 4 || 5 => 0,
      6 || 7 || 8 => 1,
      9 || 10 || 11 => 2,
      _ => 3,
    };

const jahreszeitNamen = ['🌱 Frühling', '☀️ Sommer', '🍂 Herbst', '❄️ Winter'];
