import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Fang {
  Fang({
    required this.id,
    required this.fischId,
    required this.datum,
    this.laengeCm,
    this.gewichtG,
    this.gewaesser = '',
    this.bundesland = '',
    this.koeder = '',
    this.notiz = '',
    this.zurueckgesetzt = false,
    this.uid = '',
    this.nutzerName = '',
    this.oeffentlich = true,
    this.hatFoto = false,
    this.petriHeil = const [],
  });

  final String id;
  final String fischId;
  final DateTime datum;
  final double? laengeCm;
  final int? gewichtG;
  final String gewaesser;

  /// Name des Bundeslands (siehe `Bundesland.name`).
  final String bundesland;
  final String koeder;
  final String notiz;
  final bool zurueckgesetzt;

  // Nur für online gespeicherte Fänge:
  final String uid;
  final String nutzerName;
  final bool oeffentlich;
  final bool hatFoto;

  /// UIDs der Nutzer, die "Petri Heil!" gesagt haben.
  final List<String> petriHeil;

  Fang kopie({
    String? id,
    String? uid,
    String? nutzerName,
    bool? oeffentlich,
    bool? hatFoto,
  }) =>
      Fang(
        id: id ?? this.id,
        fischId: fischId,
        datum: datum,
        laengeCm: laengeCm,
        gewichtG: gewichtG,
        gewaesser: gewaesser,
        bundesland: bundesland,
        koeder: koeder,
        notiz: notiz,
        zurueckgesetzt: zurueckgesetzt,
        uid: uid ?? this.uid,
        nutzerName: nutzerName ?? this.nutzerName,
        oeffentlich: oeffentlich ?? this.oeffentlich,
        hatFoto: hatFoto ?? this.hatFoto,
        petriHeil: petriHeil,
      );

  Map<String, dynamic> _basis() => {
        'fischId': fischId,
        'laengeCm': laengeCm,
        'gewichtG': gewichtG,
        'gewaesser': gewaesser,
        'bundesland': bundesland,
        'koeder': koeder,
        'notiz': notiz,
        'zurueckgesetzt': zurueckgesetzt,
      };

  /// Für die lokale Speicherung (ohne Konto).
  Map<String, dynamic> toJson() => {
        ..._basis(),
        'id': id,
        'datum': datum.toIso8601String(),
      };

  factory Fang.fromJson(Map<String, dynamic> j) => Fang(
        id: j['id'] as String,
        fischId: j['fischId'] as String,
        datum: DateTime.parse(j['datum'] as String),
        laengeCm: (j['laengeCm'] as num?)?.toDouble(),
        gewichtG: (j['gewichtG'] as num?)?.toInt(),
        gewaesser: j['gewaesser'] as String? ?? '',
        bundesland: j['bundesland'] as String? ?? '',
        koeder: j['koeder'] as String? ?? '',
        notiz: j['notiz'] as String? ?? '',
        zurueckgesetzt: j['zurueckgesetzt'] as bool? ?? false,
      );

  /// Für Firestore. `petriHeil` und `erstellt` setzt der Dienst.
  Map<String, dynamic> toFirestore() => {
        ..._basis(),
        'datum': Timestamp.fromDate(datum),
        'uid': uid,
        'nutzerName': nutzerName,
        'hatFoto': hatFoto,
      };

  factory Fang.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required bool oeffentlich,
  }) {
    final j = doc.data()!;
    return Fang(
      id: doc.id,
      fischId: j['fischId'] as String? ?? '',
      datum: (j['datum'] as Timestamp?)?.toDate() ?? DateTime.now(),
      laengeCm: (j['laengeCm'] as num?)?.toDouble(),
      gewichtG: (j['gewichtG'] as num?)?.toInt(),
      gewaesser: j['gewaesser'] as String? ?? '',
      bundesland: j['bundesland'] as String? ?? '',
      koeder: j['koeder'] as String? ?? '',
      notiz: j['notiz'] as String? ?? '',
      zurueckgesetzt: j['zurueckgesetzt'] as bool? ?? false,
      uid: j['uid'] as String? ?? '',
      nutzerName: j['nutzerName'] as String? ?? '',
      oeffentlich: oeffentlich,
      hatFoto: j['hatFoto'] as bool? ?? false,
      petriHeil: (j['petriHeil'] as List?)?.cast<String>() ?? const [],
    );
  }
}

/// Ein eigener Angelplatz auf der Karte (bleibt immer privat am Handy).
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
