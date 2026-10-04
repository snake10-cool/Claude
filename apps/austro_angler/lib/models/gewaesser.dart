import 'package:latlong2/latlong.dart';

import 'bundesland.dart';

enum GewaesserTyp {
  fluss('Fluss'),
  bach('Bach'),
  see('See'),
  teich('Teich'),
  kanal('Kanal'),
  moor('Moorgebiet');

  bool get fliesst => this == fluss || this == bach || this == kanal;

  const GewaesserTyp(this.name);

  final String name;
}

class Preis {
  const Preis(this.art, this.euro);

  /// z. B. "Tageskarte", "Wochenkarte".
  final String art;
  final double euro;

  String get euroText =>
      '€ ${euro.toStringAsFixed(euro % 1 == 0 ? 0 : 2).replaceAll('.', ',')}';
}

class Gewaesser {
  const Gewaesser({
    required this.id,
    required this.name,
    required this.typ,
    required this.land,
    required this.ort,
    required this.position,
    required this.beschreibung,
    required this.fischarten,
    required this.preise,
    required this.kartenverkauf,
    required this.quelle,
    required this.stand,
    this.hinweis,
    this.lizenzUrl,
    this.bezirk = '',
    this.gemeinden = const [],
    this.groesse,
    this.ausOsm = false,
  });

  /// Automatisch aus OpenStreetMap: ohne geprüfte Lizenz- und Preisinfos.
  Gewaesser.osm({
    required this.id,
    required this.name,
    required this.typ,
    required this.land,
    required this.bezirk,
    required this.gemeinden,
    required this.position,
    required double this.groesse,
    required this.stand,
  })  : ort = gemeinden.isEmpty ? bezirk : gemeinden.join(', '),
        beschreibung = _osmText(name, typ, bezirk, gemeinden, groesse),
        fischarten = typischeFische[typ] ?? const [],
        preise = const [],
        kartenverkauf = 'Die Lizenz vergibt der Fischereiberechtigte – oft '
            'ein Verein, eine Gemeinde oder ein Grundbesitzer. Frag im '
            'Angelgeschäft, beim Gemeindeamt oder beim Landesfischereiverband. '
            'Viele Lizenzen gibt es auch online, z. B. bei hejfish.',
        quelle = 'OpenStreetMap-Mitwirkende (ODbL)',
        hinweis = 'Automatisch aus OpenStreetMap: Lizenz und Preise sind '
            'noch nicht geprüft. Kennst du sie? Tipp unten auf '
            '"Preis ergänzen" oder melde die Infos.',
        lizenzUrl = null,
        ausOsm = true;

  static String _osmText(String name, GewaesserTyp typ, String bezirk,
      List<String> gemeinden, double groesse) {
    final wo = gemeinden.isEmpty
        ? 'im Bezirk $bezirk'
        : gemeinden.length == 1
            ? 'in ${gemeinden.first} (Bezirk $bezirk)'
            : 'durch ${gemeinden.length} Gemeinden im Bezirk $bezirk';
    final mass = typ.fliesst
        ? 'Rund ${_zahl(groesse)} km Lauf in diesem Bezirk.'
        : 'Fläche rund ${_zahl(groesse)} ha.';
    return '${typ.name} $wo. $mass';
  }

  static String _zahl(double z) =>
      (z >= 10 ? z.toStringAsFixed(0) : z.toStringAsFixed(1))
          .replaceAll('.', ',');

  /// Kopie mit Bezirk und Gemeinden (für die geprüften Gewässer).
  Gewaesser mitOrt({required String bezirk, required List<String> gemeinden}) =>
      Gewaesser(
        id: id,
        name: name,
        typ: typ,
        land: land,
        ort: ort,
        position: position,
        beschreibung: beschreibung,
        fischarten: fischarten,
        preise: preise,
        kartenverkauf: kartenverkauf,
        quelle: quelle,
        stand: stand,
        hinweis: hinweis,
        lizenzUrl: lizenzUrl,
        bezirk: bezirk,
        gemeinden: gemeinden,
        groesse: groesse,
      );

  final String id;
  final String name;
  final GewaesserTyp typ;
  final Bundesland land;
  final String ort;

  /// Ungefähre Lage, für die Karte.
  final LatLng position;
  final String beschreibung;

  /// IDs aus `fische.dart`.
  final List<String> fischarten;

  /// Leer, wenn die Preise noch nicht bekannt sind.
  final List<Preis> preise;
  final String kartenverkauf;
  final String quelle;
  final String stand;
  final String? hinweis;

  /// Seite, auf der man die Lizenz kaufen oder Infos bekommt.
  final String? lizenzUrl;

  /// Politischer Bezirk, z. B. "Braunau am Inn".
  final String bezirk;

  /// Gemeinden, durch die das Gewässer fließt bzw. in denen es liegt.
  final List<String> gemeinden;

  /// km Länge im Bezirk (Fließgewässer) oder ha Fläche.
  final double? groesse;

  /// Aus OpenStreetMap, ohne geprüfte Infos.
  final bool ausOsm;

  /// Eindeutiger Name für Fangbuch und Angeltage, z. B. "Mühlbach (Lochen)".
  String get anzeigeName {
    if (!ausOsm) return name;
    if (gemeinden.isEmpty) return '$name (Bezirk $bezirk)';
    return '$name (${gemeinden.first})';
  }

  bool liegtIn(String gemeinde) => gemeinden.contains(gemeinde);

  String get preisKurz {
    if (preise.isEmpty) return ausOsm ? 'Lizenz ungeprüft' : 'Preis unbekannt';
    final tag = preise.where((p) => p.art == 'Tageskarte');
    final p = tag.isNotEmpty ? tag.first : preise.first;
    return '${p.art} ${p.euroText}';
  }
}

/// Typische Fischarten je Gewässertyp – nur ein Anhaltspunkt für Gewässer
/// ohne geprüfte Infos.
const typischeFische = <GewaesserTyp, List<String>>{
  GewaesserTyp.bach: ['bachforelle', 'regenbogenforelle', 'aitel', 'koppe',
    'elritze', 'aesche'],
  GewaesserTyp.fluss: ['barbe', 'nase', 'aitel', 'aesche', 'huchen', 'hecht',
    'zander', 'wels', 'brachse', 'rotauge', 'flussbarsch'],
  GewaesserTyp.kanal: ['aitel', 'rotauge', 'flussbarsch', 'hecht', 'karpfen'],
  GewaesserTyp.see: ['hecht', 'flussbarsch', 'reinanke', 'karpfen', 'schleie',
    'rotauge', 'rotfeder', 'brachse', 'zander'],
  GewaesserTyp.teich: ['karpfen', 'schleie', 'rotauge', 'rotfeder', 'hecht',
    'flussbarsch', 'karausche'],
};
