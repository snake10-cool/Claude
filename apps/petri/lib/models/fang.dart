import 'package:latlong2/latlong.dart';

class Fang {
  Fang({
    required this.id,
    required this.fischId,
    required this.datum,
    this.laengeCm,
    this.gewichtG,
    this.gewaesser = '',
    this.koeder = '',
    this.notiz = '',
    this.zurueckgesetzt = false,
  });

  final String id;
  final String fischId;
  final DateTime datum;
  final double? laengeCm;
  final int? gewichtG;
  final String gewaesser;
  final String koeder;
  final String notiz;
  final bool zurueckgesetzt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'fischId': fischId,
        'datum': datum.toIso8601String(),
        'laengeCm': laengeCm,
        'gewichtG': gewichtG,
        'gewaesser': gewaesser,
        'koeder': koeder,
        'notiz': notiz,
        'zurueckgesetzt': zurueckgesetzt,
      };

  factory Fang.fromJson(Map<String, dynamic> j) => Fang(
        id: j['id'] as String,
        fischId: j['fischId'] as String,
        datum: DateTime.parse(j['datum'] as String),
        laengeCm: (j['laengeCm'] as num?)?.toDouble(),
        gewichtG: j['gewichtG'] as int?,
        gewaesser: j['gewaesser'] as String? ?? '',
        koeder: j['koeder'] as String? ?? '',
        notiz: j['notiz'] as String? ?? '',
        zurueckgesetzt: j['zurueckgesetzt'] as bool? ?? false,
      );
}

/// Ein eigener Angelplatz auf der Karte.
class Spot {
  Spot({required this.id, required this.name, required this.position});

  final String id;
  final String name;
  final LatLng position;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'lat': position.latitude,
        'lng': position.longitude,
      };

  factory Spot.fromJson(Map<String, dynamic> j) => Spot(
        id: j['id'] as String,
        name: j['name'] as String,
        position: LatLng(
          (j['lat'] as num).toDouble(),
          (j['lng'] as num).toDouble(),
        ),
      );
}
