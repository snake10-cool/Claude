/// Eingebaute Packlisten-Vorlagen. Kategorie → Artikel.
class PackVorlage {
  const PackVorlage(this.id, this.symbol, this.artikel);
  final String id;
  final String symbol;
  final Map<String, List<String>> artikel;
}

const _basis = {
  'Dokumente': [
    'Ausweis / Reisepass',
    'E-Card / Versicherungskarte',
    'Bankkarte',
    'Bargeld',
    'Tickets',
  ],
  'Technik': ['Handy', 'Ladekabel', 'Powerbank', 'Kopfhörer'],
  'Hygiene': ['Zahnbürste', 'Zahnpasta', 'Deo', 'Duschgel', 'Medikamente'],
  'Kleidung': [
    'Unterwäsche',
    'Socken',
    'T-Shirts',
    'Hose',
    'Pullover',
    'Schlafsachen',
  ],
};

const packVorlagen = [
  PackVorlage('strand', '🏖️', {
    ..._basis,
    'Strand': [
      'Badesachen',
      'Handtuch',
      'Sonnencreme',
      'Sonnenbrille',
      'Kappe',
      'Flipflops',
      'Strandtasche',
      'Wasserflasche',
    ],
  }),
  PackVorlage('ski', '⛷️', {
    ..._basis,
    'Ski': [
      'Skijacke',
      'Skihose',
      'Handschuhe',
      'Haube',
      'Skibrille',
      'Helm',
      'Skisocken',
      'Funktionsunterwäsche',
      'Lippenpflege',
      'Sonnencreme',
    ],
  }),
  PackVorlage('festival', '🎪', {
    ..._basis,
    'Festival': [
      'Ticket / Bändchen',
      'Zelt',
      'Schlafsack',
      'Isomatte',
      'Regenjacke',
      'Gummistiefel',
      'Ohrstöpsel',
      'Taschenlampe',
      'Klopapier',
      'Feuchttücher',
      'Becher',
    ],
  }),
  PackVorlage('stadt', '🏙️', {
    ..._basis,
    'Städtetrip': [
      'Bequeme Schuhe',
      'Rucksack',
      'Regenschirm',
      'Stadtplan / Offline-Karte',
      'Adapter',
    ],
  }),
  PackVorlage('camping', '🏕️', {
    ..._basis,
    'Camping': [
      'Zelt',
      'Schlafsack',
      'Isomatte',
      'Gaskocher',
      'Geschirr',
      'Taschenmesser',
      'Stirnlampe',
      'Müllsäcke',
      'Insektenschutz',
    ],
  }),
  PackVorlage('business', '💼', {
    ..._basis,
    'Arbeit': [
      'Laptop',
      'Laptop-Ladegerät',
      'Notizbuch',
      'Visitenkarten',
      'Hemd / Bluse',
      'Schuhe',
    ],
  }),
];
