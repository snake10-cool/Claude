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

/// Wetter zu einem bestimmten Zeitpunkt (für das Fangbuch).
///
/// Bis 90 Tage zurück kommt es aus der Vorhersage-API, ältere Tage aus dem
/// Archiv von Open-Meteo.
Future<Map<String, num>?> wetterZurZeit(LatLng p, DateTime zeit) async {
  final tag = '${zeit.year.toString().padLeft(4, '0')}-'
      '${zeit.month.toString().padLeft(2, '0')}-'
      '${zeit.day.toString().padLeft(2, '0')}';
  final alt = DateTime.now().difference(zeit).inDays > 85;
  final uri = Uri.https(
    alt ? 'archive-api.open-meteo.com' : 'api.open-meteo.com',
    alt ? '/v1/archive' : '/v1/forecast',
    {
      'latitude': p.latitude.toStringAsFixed(3),
      'longitude': p.longitude.toStringAsFixed(3),
      'hourly': 'temperature_2m,surface_pressure,wind_speed_10m,weather_code',
      'timezone': 'Europe/Vienna',
      'start_date': tag,
      'end_date': tag,
    },
  );
  try {
    final antwort = await http.get(uri).timeout(const Duration(seconds: 5));
    if (antwort.statusCode != 200) return null;
    final h = (jsonDecode(antwort.body) as Map<String, dynamic>)['hourly']
        as Map<String, dynamic>;
    final i = zeit.hour.clamp(0, (h['time'] as List).length - 1);
    num? wert(String key) => (h[key] as List?)?[i] as num?;
    final temp = wert('temperature_2m');
    if (temp == null) return null;
    return {
      'temp': temp,
      'druck': wert('surface_pressure') ?? 0,
      'wind': wert('wind_speed_10m') ?? 0,
      'code': wert('weather_code') ?? 0,
    };
  } catch (_) {
    return null;
  }
}

String wetterKurz(Map<String, num> w) {
  final (icon, text) = Wetter(
    temperatur: 0,
    wind: 0,
    luftdruck: 0,
    code: w['code']?.toInt() ?? 0,
    sonnenaufgang: null,
    sonnenuntergang: null,
  ).beschreibung;
  return '$icon $text, ${w['temp']?.toStringAsFixed(0)} °C, '
      '${w['druck']?.toStringAsFixed(0)} hPa, Wind ${w['wind']?.toStringAsFixed(0)} km/h';
}

class Stunde {
  const Stunde(this.zeit, this.druck, this.temp, this.wolken, this.wind);

  final DateTime zeit;
  final double druck;
  final double temp;
  final double wolken;
  final double wind;
}

/// Stündliches Wetter von gestern bis in 3 Tagen (für die Beißzeit).
Future<List<Stunde>> stundenWetter(LatLng p) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': p.latitude.toStringAsFixed(3),
    'longitude': p.longitude.toStringAsFixed(3),
    'hourly': 'surface_pressure,temperature_2m,cloud_cover,wind_speed_10m',
    'timezone': 'Europe/Vienna',
    'past_days': '1',
    'forecast_days': '4',
  });
  final antwort = await http.get(uri).timeout(const Duration(seconds: 10));
  if (antwort.statusCode != 200) throw Exception('Wetter nicht verfügbar');
  final h = (jsonDecode(antwort.body) as Map<String, dynamic>)['hourly']
      as Map<String, dynamic>;
  final zeiten = (h['time'] as List).cast<String>();
  double d(String key, int i) => ((h[key] as List)[i] as num?)?.toDouble() ?? 0;
  return [
    for (var i = 0; i < zeiten.length; i++)
      Stunde(DateTime.parse(zeiten[i]), d('surface_pressure', i),
          d('temperature_2m', i), d('cloud_cover', i), d('wind_speed_10m', i)),
  ];
}

/// Abfluss eines Flusses in m³/s (Open-Meteo Flood API, Modelldaten).
class Abfluss {
  const Abfluss(this.tage, this.werte, this.mittel);

  final List<DateTime> tage;
  final List<double> werte;
  final double? mittel;
}

Future<Abfluss> abflussLaden(LatLng p) async {
  final uri = Uri.https('flood-api.open-meteo.com', '/v1/flood', {
    'latitude': p.latitude.toStringAsFixed(3),
    'longitude': p.longitude.toStringAsFixed(3),
    'daily': 'river_discharge,river_discharge_mean',
    'past_days': '7',
    'forecast_days': '7',
  });
  final antwort = await http.get(uri).timeout(const Duration(seconds: 10));
  if (antwort.statusCode != 200) throw Exception('Abfluss nicht verfügbar');
  final d = (jsonDecode(antwort.body) as Map<String, dynamic>)['daily']
      as Map<String, dynamic>;
  final werte = [
    for (final w in d['river_discharge'] as List) (w as num?)?.toDouble() ?? 0,
  ];
  final mittel = (d['river_discharge_mean'] as List?)
      ?.whereType<num>()
      .map((e) => e.toDouble())
      .toList();
  return Abfluss(
    [for (final t in d['time'] as List) DateTime.parse(t as String)],
    werte,
    mittel == null || mittel.isEmpty
        ? null
        : mittel.reduce((a, b) => a + b) / mittel.length,
  );
}


/// Warnung vor Gewitter, Sturm oder Starkregen zwischen [von] und [bis]
/// (höchstens 7 Tage voraus). Null, wenn nichts Gefährliches angesagt ist.
Future<String?> unwetterWarnung(LatLng p, DateTime von, DateTime bis) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': p.latitude.toStringAsFixed(3),
    'longitude': p.longitude.toStringAsFixed(3),
    'hourly': 'weather_code,wind_gusts_10m,precipitation',
    'timezone': 'Europe/Vienna',
    'forecast_days': '8',
  });
  final antwort = await http.get(uri).timeout(const Duration(seconds: 10));
  if (antwort.statusCode != 200) return null;
  final h = (jsonDecode(antwort.body) as Map<String, dynamic>)['hourly']
      as Map<String, dynamic>;
  final zeiten = (h['time'] as List).cast<String>();
  var gewitter = false;
  var boeen = 0.0;
  var regen = 0.0;
  for (var i = 0; i < zeiten.length; i++) {
    final t = DateTime.parse(zeiten[i]);
    if (t.isBefore(von.subtract(const Duration(hours: 1))) || t.isAfter(bis)) {
      continue;
    }
    final code = ((h['weather_code'] as List)[i] as num?)?.toInt() ?? 0;
    if (code >= 95) gewitter = true;
    final b = ((h['wind_gusts_10m'] as List)[i] as num?)?.toDouble() ?? 0;
    if (b > boeen) boeen = b;
    final r = ((h['precipitation'] as List)[i] as num?)?.toDouble() ?? 0;
    if (r > regen) regen = r;
  }
  final teile = [
    if (gewitter) '⛈️ Gewitter',
    if (boeen >= 60) '💨 Sturmböen bis ${boeen.round()} km/h',
    if (regen >= 5) '🌧️ Starkregen',
  ];
  return teile.isEmpty ? null : teile.join(', ');
}

/// Grobe Schätzung der Wassertemperatur aus der Lufttemperatur der letzten
/// zwei Wochen. Seen reagieren langsam, Bäche werden vom Grundwasser gekühlt.
Future<double?> wassertemperaturSchaetzung(LatLng p,
    {required bool fliesst, required bool klein, required bool see}) async {
  final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
    'latitude': p.latitude.toStringAsFixed(3),
    'longitude': p.longitude.toStringAsFixed(3),
    'daily': 'temperature_2m_mean',
    'timezone': 'Europe/Vienna',
    'past_days': '21',
    'forecast_days': '1',
  });
  final antwort = await http.get(uri).timeout(const Duration(seconds: 10));
  if (antwort.statusCode != 200) return null;
  final werte = [
    for (final w in ((jsonDecode(antwort.body) as Map<String, dynamic>)['daily']
        as Map<String, dynamic>)['temperature_2m_mean'] as List)
      if (w != null) (w as num).toDouble(),
  ];
  if (werte.isEmpty) return null;
  // Gleitender Mittelwert: kleiner Faktor = träges Wasser.
  final faktor = see ? 0.12 : (fliesst ? (klein ? 0.4 : 0.3) : 0.25);
  var wasser = werte.first;
  for (final l in werte) {
    wasser += faktor * (l - wasser);
  }
  // Bäche bekommen viel Grundwasser (ca. 9 °C).
  if (fliesst && klein) wasser = 0.65 * wasser + 0.35 * 9;
  return wasser.clamp(0.5, 30).toDouble();
}

/// Was die Wassertemperatur für das Angeln bedeutet.
String wassertemperaturTipp(double grad) => switch (grad) {
      < 6 => 'Sehr kalt: Fische sind träge. Langsam und am Grund fischen – '
          'Hecht, Aalrutte und Saiblinge beißen noch am ehesten.',
      < 12 => 'Kühl: Forellen, Äschen und Hechte sind aktiv. Friedfische '
          'beißen noch zögerlich.',
      < 20 => 'Ideal: Fast alle Fische fressen gut, Karpfen, Schleien und '
          'Barsche werden richtig aktiv.',
      < 24 => 'Warm: Karpfen und Welse lieben es. Forellen leiden – lieber '
          'früh morgens oder abends fischen.',
      _ => 'Sehr warm: Wenig Sauerstoff im Wasser. Fische schonen, gefangene '
          'Fische besonders schnell zurücksetzen.',
    };
