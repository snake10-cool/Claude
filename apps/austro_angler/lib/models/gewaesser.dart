import 'package:latlong2/latlong.dart';

import 'bundesland.dart';

enum GewaesserTyp {
  fluss('Fluss'),
  bach('Bach'),
  see('See'),
  teich('Teich'),
  moor('Moorgebiet');

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
  });

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

  String get preisKurz {
    if (preise.isEmpty) return 'Preis unbekannt';
    final tag = preise.where((p) => p.art == 'Tageskarte');
    final p = tag.isNotEmpty ? tag.first : preise.first;
    return '${p.art} ${p.euroText}';
  }
}
