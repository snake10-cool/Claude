import 'package:latlong2/latlong.dart';

import '../models/bundesland.dart';
import '../models/gewaesser.dart';

/// Gewässer mit Schwerpunkt Bezirk Braunau und Salzburger Seengebiet.
///
/// Preise stammen aus öffentlichen Angaben der Vereine/Verbände und können
/// sich jedes Jahr ändern. Positionen sind ungefähr.
const gewaesserListe = <Gewaesser>[
  Gewaesser(
    id: 'inn-braunau',
    name: 'Inn bei Braunau',
    typ: GewaesserTyp.fluss,
    land: Bundesland.ooe,
    ort: 'Braunau am Inn',
    position: LatLng(48.258, 13.040),
    beschreibung:
        'Revier Inn-Braunau von der Salzachmündung bis Obernberg. Großer '
        'Fluss mit Stauräumen, bekannt für Zander, Hecht und Waller.',
    fischarten: ['zander', 'hecht', 'wels', 'karpfen', 'brachse', 'aitel',
      'flussbarsch', 'barbe'],
    preise: [Preis('Tageskarte', 22), Preis('Wochenkarte', 44)],
    kartenverkauf:
        'Fa. Hauser, Salzburgerstraße 5, Braunau – oder online über hejfish.',
    quelle: 'Oö. Landesfischereiverband (lfvooe.at)',
    stand: '2026',
  ),
  Gewaesser(
    id: 'salzach-ooe',
    name: 'Salzach (OÖ-Ufer)',
    typ: GewaesserTyp.fluss,
    land: Bundesland.ooe,
    ort: 'Ostermiething – Hochburg-Ach',
    position: LatLng(48.090, 12.860),
    beschreibung:
        'Grenzfluss zu Bayern, kräftige Strömung, kühles Gletscherwasser.',
    fischarten: ['aesche', 'bachforelle', 'regenbogenforelle', 'huchen',
      'aitel', 'barbe', 'aalrutte'],
    preise: [Preis('Tageskarte', 16)],
    kartenverkauf: 'Angelsport Kinzl',
    quelle: 'angelsport-kinzl.at',
    stand: '2026',
  ),
  Gewaesser(
    id: 'hoellerersee',
    name: 'Höllerersee',
    typ: GewaesserTyp.see,
    land: Bundesland.ooe,
    ort: 'Ibmer Seengebiet',
    position: LatLng(48.070, 12.905),
    beschreibung: 'Kleiner Moorsee im Ibmer Seengebiet, auch Nachtfischen.',
    fischarten: ['hecht', 'karpfen', 'schleie', 'zander', 'flussbarsch',
      'brachse'],
    preise: [
      Preis('Tageskarte', 20),
      Preis('Nachtkarte', 25),
      Preis('Wochenkarte', 45),
      Preis('Monatskarte', 60),
      Preis('Jahreskarte', 120),
      Preis('Jahreskarte Kinder', 50),
    ],
    kartenverkauf: 'Oö. Landesfischereiverband / hejfish',
    quelle: 'Oö. Landesfischereiverband (lfvooe.at)',
    stand: '2026',
  ),
  Gewaesser(
    id: 'ibmer-moor',
    name: 'Ibmer Moor / Heratinger See',
    typ: GewaesserTyp.moor,
    land: Bundesland.ooe,
    ort: 'Eggelsberg – Franking',
    position: LatLng(48.075, 12.930),
    beschreibung:
        'Größtes Moorgebiet Österreichs mit mehreren Seen. Teilweise '
        'Naturschutzgebiet – Regeln vor Ort beachten!',
    fischarten: ['hecht', 'karpfen', 'schleie', 'flussbarsch'],
    preise: [],
    kartenverkauf: 'Bitte prüfen',
    quelle: '–',
    stand: '–',
    hinweis: 'Preise und Kartenverkauf fehlen noch.',
  ),
  Gewaesser(
    id: 'mattig',
    name: 'Mattig',
    typ: GewaesserTyp.fluss,
    land: Bundesland.ooe,
    ort: 'Mattighofen – Braunau',
    position: LatLng(48.105, 13.150),
    beschreibung:
        'Kleinerer Fluss durch das Mattigtal, mündet bei Braunau in den Inn.',
    fischarten: ['bachforelle', 'regenbogenforelle', 'aitel', 'aesche'],
    preise: [],
    kartenverkauf: 'Bitte prüfen (z. B. Sportanglerclub Mattig)',
    quelle: '–',
    stand: '–',
    hinweis: 'Preise und Kartenverkauf fehlen noch.',
  ),
  Gewaesser(
    id: 'obertrumer-see',
    name: 'Obertrumer See',
    typ: GewaesserTyp.see,
    land: Bundesland.sbg,
    ort: 'Obertrum am See',
    position: LatLng(47.955, 13.075),
    beschreibung: 'Einer der drei Trumer Seen im Salzburger Flachgau.',
    fischarten: ['hecht', 'zander', 'reinanke', 'karpfen', 'schleie',
      'flussbarsch', 'wels'],
    preise: [Preis('Tageskarte', 20)],
    kartenverkauf: 'Siehe fischen.fischereiverband.at',
    quelle: 'Salzburger Fischereiverband',
    stand: 'Saison 1.5. – 31.10.2026',
    hinweis:
        'Zusätzlich nötig: Salzburger Jahresfischerkarte oder Gastfischerkarte.',
  ),
  Gewaesser(
    id: 'mattsee',
    name: 'Mattsee',
    typ: GewaesserTyp.see,
    land: Bundesland.sbg,
    ort: 'Mattsee',
    position: LatLng(47.975, 13.100),
    beschreibung: 'Größter der Trumer Seen, an der Grenze zu Oberösterreich.',
    fischarten: ['hecht', 'zander', 'reinanke', 'karpfen', 'schleie',
      'flussbarsch', 'wels'],
    preise: [Preis('Tageskarte', 20)],
    kartenverkauf: 'Fischerinnung Mattsee',
    quelle: 'fischerinnung-mattsee.at',
    stand: 'Saison 1.5. – 31.10.2026',
    hinweis:
        'Zusätzlich nötig: Salzburger Jahresfischerkarte oder Gastfischerkarte.',
  ),
  Gewaesser(
    id: 'grabensee',
    name: 'Grabensee',
    typ: GewaesserTyp.see,
    land: Bundesland.sbg,
    ort: 'Perwang am Grabensee',
    position: LatLng(47.995, 13.085),
    beschreibung: 'Kleinster Trumer See, Uferfischen mit privater Erlaubnis.',
    fischarten: ['hecht', 'karpfen', 'schleie', 'flussbarsch'],
    preise: [],
    kartenverkauf:
        'Saison-, Monats- und 2-Wochen-Karten bei Manfred Kainz (Bartlbauer), '
        'Edt 8, 5166 Perwang – ab Ende April.',
    quelle: 'Salzburger Fischereiverband',
    stand: '2026',
    hinweis: 'Keine Tageskarten, Preise bitte direkt erfragen.',
  ),
  Gewaesser(
    id: 'wallersee',
    name: 'Wallersee',
    typ: GewaesserTyp.see,
    land: Bundesland.sbg,
    ort: 'Seekirchen am Wallersee',
    position: LatLng(47.910, 13.170),
    beschreibung: 'Großer Flachgauer See mit Fischach als Abfluss.',
    fischarten: ['hecht', 'zander', 'reinanke', 'karpfen', 'schleie',
      'flussbarsch', 'wels', 'brachse'],
    preise: [Preis('Tageskarte', 25)],
    kartenverkauf: 'Siehe o-fischer.at',
    quelle: 'o-fischer.at',
    stand: '2026',
  ),
  Gewaesser(
    id: 'fuschlsee',
    name: 'Fuschlsee',
    typ: GewaesserTyp.see,
    land: Bundesland.sbg,
    ort: 'Fuschl am See',
    position: LatLng(47.800, 13.280),
    beschreibung: 'Sehr klarer See im Salzkammergut, gut für Salmoniden.',
    fischarten: ['seeforelle', 'seesaibling', 'reinanke', 'hecht',
      'flussbarsch'],
    preise: [Preis('Tageskarte', 23)],
    kartenverkauf: 'Siehe fischen.fischereiverband.at',
    quelle: 'Salzburger Fischereiverband',
    stand: 'Saison 2023 (5:00 – 21:00 Uhr)',
    hinweis: 'Preis von 2023 – kann sich geändert haben.',
  ),
];

/// Was man in den Bundesländern zum Fischen braucht.
class Fischerkarte {
  const Fischerkarte(this.land, this.punkte);

  final Bundesland land;
  final List<String> punkte;
}

const fischerkarten = <Fischerkarte>[
  Fischerkarte(Bundesland.ooe, [
    'Immer zwei Dinge: eine amtliche Fischerkarte UND eine Erlaubnis '
        '(Lizenz/Tageskarte) für das Gewässer.',
    'Jahresfischerkarte: ab 12 Jahren, Fischerkurs (mind. 10 Stunden, auch '
        'online) und Prüfung. Kurs inkl. Prüfung ca. € 135.',
    'Jahresfischerkarten-Abgabe: € 32 pro Jahr.',
    'Ohne Prüfung: Gastfischerkarte € 20, gültig 3 Wochen, höchstens 2× pro '
        'Jahr.',
  ]),
  Fischerkarte(Bundesland.sbg, [
    'Immer zwei Dinge: eine Fischerkarte UND eine Erlaubnis '
        '(Lizenz/Tageskarte) für das Gewässer.',
    'Mit Prüfung: Salzburger Jahresfischerkarte.',
    'Ohne Prüfung: Gastfischerkarte – € 10 (1 Tag), € 25 (7 Tage), '
        '€ 34 (14 Tage).',
  ]),
];
