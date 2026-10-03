import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class Wetter {
  const Wetter({
    required this.temperatur,
    required this.wind,
    required this.luftdruck,
    required this.code,
    required this.sonnenaufgang,
    required this.sonnenuntergang,
  });

  final double temperatur;
  final double wind;
  final double luftdruck;
  final int code;
  final DateTime? sonnenaufgang;
  final DateTime? sonnenuntergang;

  /// Beschreibung zum WMO-Wettercode.
  (String, String) get beschreibung => switch (code) {
        0 => ('☀️', 'Klar'),
        1 || 2 => ('🌤️', 'Leicht bewölkt'),
        3 => ('☁️', 'Bedeckt'),
        45 || 48 => ('🌫️', 'Nebel'),
        51 || 53 || 55 || 56 || 57 => ('🌦️', 'Nieselregen'),
        61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => ('🌧️', 'Regen'),
        71 || 73 || 75 || 77 || 85 || 86 => ('🌨️', 'Schnee'),
        95 || 96 || 99 => ('⛈️', 'Gewitter'),
        _ => ('🌡️', 'Wetter'),
      };
}

/// Holt das aktuelle Wetter von Open-Meteo (kostenlos, ohne Schlüssel).
Future<Wetter> wetterLaden(LatLng p) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': p.latitude.toStringAsFixed(3),
    'longitude': p.longitude.toStringAsFixed(3),
    'current': 'temperature_2m,weather_code,wind_speed_10m,surface_pressure',
    'daily': 'sunrise,sunset',
    'timezone': 'Europe/Vienna',
    'forecast_days': '1',
  });
  final antwort = await http.get(uri).timeout(const Duration(seconds: 10));
  if (antwort.statusCode != 200) {
    throw Exception('Wetter nicht verfügbar (${antwort.statusCode})');
  }
  final j = jsonDecode(antwort.body) as Map<String, dynamic>;
  final c = j['current'] as Map<String, dynamic>;
  final d = j['daily'] as Map<String, dynamic>?;
  DateTime? zeit(String key) {
    final liste = d?[key] as List?;
    return liste == null || liste.isEmpty
        ? null
        : DateTime.tryParse(liste.first as String);
  }

  return Wetter(
    temperatur: (c['temperature_2m'] as num).toDouble(),
    wind: (c['wind_speed_10m'] as num).toDouble(),
    luftdruck: (c['surface_pressure'] as num).toDouble(),
    code: (c['weather_code'] as num).toInt(),
    sonnenaufgang: zeit('sunrise'),
    sonnenuntergang: zeit('sunset'),
  );
}

/// Mondphase: 0 = Neumond, 0,5 = Vollmond.
double mondphase(DateTime zeit) {
  const synodischerMonat = 29.530588853;
  final neumond = DateTime.utc(2000, 1, 6, 18, 14);
  final tage = zeit.toUtc().difference(neumond).inMinutes / 1440;
  final phase = (tage / synodischerMonat) % 1;
  return phase < 0 ? phase + 1 : phase;
}

(String, String) mondText(double phase) {
  const namen = [
    ('🌑', 'Neumond'),
    ('🌒', 'Zunehmende Sichel'),
    ('🌓', 'Erstes Viertel'),
    ('🌔', 'Zunehmender Mond'),
    ('🌕', 'Vollmond'),
    ('🌖', 'Abnehmender Mond'),
    ('🌗', 'Letztes Viertel'),
    ('🌘', 'Abnehmende Sichel'),
  ];
  return namen[(phase * 8).round() % 8];
}

/// Beleuchteter Anteil des Mondes in Prozent.
int mondBeleuchtung(double phase) =>
    ((1 - cos(2 * pi * phase)) / 2 * 100).round();
