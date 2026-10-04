import '../models/bundesland.dart';

/// Fischarten der großen, bekannten Gewässer Österreichs – zusammengetragen
/// aus allgemeinen Fachquellen (Fischereiverbände, Gewässerberichte,
/// Fachliteratur). Ohne Gewähr; einzelne Abschnitte können abweichen.
///
/// Schlüssel: Name wie in OpenStreetMap. Gilt für alle Abschnitte mit diesem
/// Namen, außer es ist ein Bundesland angegeben.
typedef BekannteFische = ({Bundesland? land, List<String> fische});

const _donau = [
  'barbe', 'nase', 'aitel', 'brachse', 'zander', 'wels', 'hecht',
  'flussbarsch', 'rapfen', 'karpfen', 'aalrutte', 'huchen', 'sterlet',
  'nerfling', 'zobel', 'zope', 'guester', 'rotauge', 'laube', 'russnase',
  'sichling', 'wolgazander', 'streber', 'zingel', 'schraetzer',
  'donaukaulbarsch', 'kaulbarsch', 'gruendling', 'weissflossengruendling',
  'kesslergruendling', 'schwarzmundgrundel', 'kesslergrundel',
  'marmorgrundel', 'flussgrundel', 'aal',
];

const _voralpenfluss = [
  'aesche', 'bachforelle', 'regenbogenforelle', 'huchen', 'barbe', 'nase',
  'aitel', 'hecht', 'aalrutte', 'koppe', 'schmerle', 'gruendling',
];

const _forellenfluss = [
  'bachforelle', 'regenbogenforelle', 'aesche', 'koppe', 'aitel', 'schmerle',
  'elritze',
];

const _tieflandfluss = [
  'hecht', 'zander', 'wels', 'karpfen', 'brachse', 'rotauge', 'aitel',
  'rapfen', 'schleie', 'flussbarsch', 'guester', 'laube', 'nerfling',
  'karausche', 'bitterling', 'schlammpeitzger', 'aal', 'barbe', 'nase',
];

const _alpensee = [
  'reinanke', 'seeforelle', 'seesaibling', 'hecht', 'flussbarsch',
  'aalrutte', 'rotauge', 'brachse', 'elritze', 'koppe',
];

const _salzkammergutsee = [
  'reinanke', 'seeforelle', 'seesaibling', 'hecht', 'flussbarsch',
  'aalrutte', 'rotauge', 'brachse', 'seelaube', 'perlfisch', 'karpfen',
  'schleie', 'aitel',
];

const _kaerntnersee = [
  'hecht', 'zander', 'karpfen', 'wels', 'reinanke', 'flussbarsch',
  'schleie', 'brachse', 'rotauge', 'rotfeder', 'aal', 'aalrutte',
];

const bekannteFische = <String, BekannteFische>{
  // Große Flüsse
  'donau': (land: null, fische: _donau),
  'inn': (land: null, fische: [..._voralpenfluss, 'zander', 'brachse',
    'rotauge', 'wels', 'karpfen', 'rapfen']),
  'salzach': (land: null, fische: _voralpenfluss),
  'traun': (land: null, fische: [..._voralpenfluss, 'seeforelle']),
  'enns': (land: null, fische: [..._voralpenfluss, 'zander', 'brachse']),
  'mur': (land: null, fische: _voralpenfluss),
  'drau': (land: null, fische: [..._voralpenfluss, 'zander', 'wels',
    'karpfen', 'brachse', 'flussbarsch', 'rotauge']),
  'march': (land: null, fische: _tieflandfluss),
  'thaya': (land: null, fische: _tieflandfluss),
  'leitha': (land: null, fische: ['aitel', 'barbe', 'nase', 'hecht',
    'karpfen', 'rotauge', 'flussbarsch', 'gruendling', 'schmerle',
    'bachforelle']),
  'raab': (land: null, fische: ['aitel', 'barbe', 'nase', 'hecht', 'karpfen',
    'rotauge', 'flussbarsch', 'gruendling', 'schmerle', 'bachforelle',
    'zander', 'wels']),
  'lafnitz': (land: null, fische: ['aitel', 'barbe', 'nase', 'hecht',
    'bachforelle', 'aesche', 'gruendling', 'schmerle', 'koppe']),
  'ybbs': (land: null, fische: _voralpenfluss),
  'erlauf': (land: null, fische: _voralpenfluss),
  'traisen': (land: null, fische: _voralpenfluss),
  'kamp': (land: null, fische: ['bachforelle', 'regenbogenforelle', 'aesche',
    'aitel', 'barbe', 'hecht', 'flussbarsch', 'rotauge', 'gruendling',
    'koppe', 'schmerle']),
  'gail': (land: null, fische: _voralpenfluss),
  'gurk': (land: null, fische: _voralpenfluss),
  'lavant': (land: null, fische: _forellenfluss),
  'möll': (land: null, fische: _forellenfluss),
  'isel': (land: null, fische: _forellenfluss),
  'ziller': (land: null, fische: _forellenfluss),
  'lech': (land: null, fische: _forellenfluss),
  'ill': (land: null, fische: [..._forellenfluss, 'seeforelle']),
  'rhein': (land: null, fische: ['seeforelle', 'aesche', 'bachforelle',
    'regenbogenforelle', 'aitel', 'barbe', 'aalrutte', 'koppe']),
  'steyr': (land: null, fische: _voralpenfluss),
  'alm': (land: null, fische: _forellenfluss),
  'ager': (land: null, fische: [..._forellenfluss, 'barbe', 'nase', 'hecht']),
  'saalach': (land: null, fische: _forellenfluss),
  'lammer': (land: null, fische: _forellenfluss),

  // Große Seen
  'neusiedler see': (land: null, fische: ['zander', 'hecht', 'karpfen',
    'wels', 'brachse', 'rotauge', 'rotfeder', 'laube', 'giebel',
    'flussbarsch', 'aal', 'schleie', 'guester', 'sichling']),
  'bodensee': (land: null, fische: ['reinanke', 'sandfelchen', 'seeforelle',
    'seesaibling', 'hecht', 'flussbarsch', 'zander', 'aalrutte', 'brachse',
    'rotauge', 'karpfen', 'schleie', 'aal', 'wels', 'kaulbarsch']),
  'traunsee': (land: null, fische: _salzkammergutsee),
  'wolfgangsee': (land: null, fische: _salzkammergutsee),
  'hallstätter see': (land: null, fische: _salzkammergutsee),
  'irrsee': (land: null, fische: ['hecht', 'zander', 'karpfen', 'schleie',
    'reinanke', 'flussbarsch', 'rotauge', 'aalrutte', 'brachse']),
  'grundlsee': (land: null, fische: _alpensee),
  'altausseer see': (land: null, fische: _alpensee),
  'wörthersee': (land: null, fische: _kaerntnersee),
  'millstätter see': (land: null, fische: [..._kaerntnersee, 'seeforelle']),
  'ossiacher see': (land: Bundesland.ktn, fische: _kaerntnersee),
  'weißensee': (land: Bundesland.ktn, fische: ['reinanke', 'seesaibling',
    'hecht', 'flussbarsch', 'karpfen', 'schleie', 'seeforelle', 'rotauge',
    'aalrutte']),
  'faaker see': (land: null, fische: _kaerntnersee),
  'klopeiner see': (land: null, fische: _kaerntnersee),
  'achensee': (land: null, fische: _alpensee),
  'plansee': (land: null, fische: _alpensee),
  'zeller see': (land: Bundesland.sbg, fische: ['hecht', 'reinanke',
    'seeforelle', 'karpfen', 'schleie', 'flussbarsch', 'rotauge',
    'aalrutte']),
  'erlaufsee': (land: null, fische: _alpensee),
  'lunzer see': (land: null, fische: _alpensee),
};
