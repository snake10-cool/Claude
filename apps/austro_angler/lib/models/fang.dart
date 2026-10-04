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
    this.geschichte = '',
    this.ausruestung = '',
    this.verein = '',
    this.uid = '',
    this.nutzerName = '',
    this.oeffentlich = true,
    this.hatFoto = false,
    this.hatVideo = false,
    this.petriHeil = const [],
    this.wetter,
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

  /// Längere Erzählung zum Fang (optional).
  final String geschichte;

  /// Womit gefangen, z. B. "Spinnrute 2,40 m".
  final String ausruestung;

  /// Verein des Anglers beim Speichern (für die Vereins-Rangliste).
  final String verein;

  // Nur für online gespeicherte Fänge:
  final String uid;
  final String nutzerName;
  final bool oeffentlich;
  final bool hatFoto;
  final bool hatVideo;

  /// UIDs der Nutzer, die "Petri Heil!" gesagt haben.
  final List<String> petriHeil;

  /// Wetter zur Fangzeit (automatisch geholt), z. B.
  /// {temp: 14.2, druck: 1018, wind: 9, code: 3}.
  final Map<String, num>? wetter;

  Fang kopie({
    String? id,
    String? uid,
    String? nutzerName,
    bool? oeffentlich,
    bool? hatFoto,
    bool? hatVideo,
    Map<String, num>? wetter,
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
        geschichte: geschichte,
        ausruestung: ausruestung,
        verein: verein,
        uid: uid ?? this.uid,
        nutzerName: nutzerName ?? this.nutzerName,
        oeffentlich: oeffentlich ?? this.oeffentlich,
        hatFoto: hatFoto ?? this.hatFoto,
        hatVideo: hatVideo ?? this.hatVideo,
        petriHeil: petriHeil,
        wetter: wetter ?? this.wetter,
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
        'wetter': wetter,
        if (geschichte.isNotEmpty) 'geschichte': geschichte,
        if (ausruestung.isNotEmpty) 'ausruestung': ausruestung,
        if (verein.isNotEmpty) 'verein': verein,
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
        geschichte: j['geschichte'] as String? ?? '',
        ausruestung: j['ausruestung'] as String? ?? '',
        wetter: _wetter(j['wetter']),
      );

  static Map<String, num>? _wetter(Object? roh) => roh is Map
      ? {for (final e in roh.entries) e.key as String: e.value as num}
      : null;

  /// Für Firestore. `petriHeil` und `erstellt` setzt der Dienst.
  Map<String, dynamic> toFirestore() => {
        ..._basis(),
        'datum': Timestamp.fromDate(datum),
        'uid': uid,
        'nutzerName': nutzerName,
        'hatFoto': hatFoto,
        if (hatVideo) 'hatVideo': true,
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
      geschichte: j['geschichte'] as String? ?? '',
      ausruestung: j['ausruestung'] as String? ?? '',
      verein: j['verein'] as String? ?? '',
      uid: j['uid'] as String? ?? '',
      nutzerName: j['nutzerName'] as String? ?? '',
      oeffentlich: oeffentlich,
      hatFoto: j['hatFoto'] as bool? ?? false,
      hatVideo: j['hatVideo'] as bool? ?? false,
      petriHeil: (j['petriHeil'] as List?)?.cast<String>() ?? const [],
      wetter: _wetter(j['wetter']),
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
