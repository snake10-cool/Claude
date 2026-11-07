import 'wetter.dart';

/// Beißzeit-Prognose als Faustregel aus Luftdruck, Mond, Wolken und Wind.
///
/// Das ist keine Wissenschaft, sondern alte Angler-Erfahrung:
/// - leicht fallender Luftdruck vor einer Wetteränderung → Fische fressen
/// - stark steigender Druck nach einer Front → Fische sind träge
/// - Neumond und Vollmond → mehr Aktivität
/// - bedeckter Himmel und leichter Wind → Fische weniger scheu
class BeissTag {
  const BeissTag(this.tag, this.punkte, this.gruende);

  final DateTime tag;

  /// 1 bis 5.
  final int punkte;
  final List<String> gruende;

  String get fische => '🐟' * punkte;
}

List<BeissTag> beisszeit(List<Stunde> stunden) {
  final heute = DateTime.now();
  final tage = <BeissTag>[];
  for (var t = 0; t < 4; t++) {
    final tag = DateTime(heute.year, heute.month, heute.day + t);
    // Mittag des Tages und 6 Stunden davor.
    Stunde? bei(int stunde) {
      final ziel = DateTime(tag.year, tag.month, tag.day, stunde);
      for (final s in stunden) {
        if (s.zeit == ziel) return s;
      }
      return null;
    }

    final mittag = bei(12);
    final morgen = bei(6);
    if (mittag == null || morgen == null) continue;

    var wert = 2.5;
    final gruende = <String>[];

    final trend = mittag.druck - morgen.druck;
    if (trend <= -1 && trend >= -4) {
      wert += 1;
      gruende.add('Luftdruck fällt leicht (${trend.toStringAsFixed(1)} hPa)');
    } else if (trend < -4) {
      wert -= 0.5;
      gruende.add('Luftdruck fällt stark – Unwetter möglich');
    } else if (trend > 3) {
      wert -= 1;
      gruende.add('Luftdruck steigt stark – Fische oft träge');
    } else {
      wert += 0.3;
      gruende.add('Luftdruck stabil');
    }

    final phase = mondphase(DateTime(tag.year, tag.month, tag.day, 12));
    final abstand = [phase, (phase - 0.5).abs(), 1 - phase]
        .reduce((a, b) => a < b ? a : b);
    if (abstand < 0.07) {
      wert += 0.8;
      gruende.add('${mondText(phase).$2} – oft gute Beißphase');
    }

    if (mittag.wolken > 60) {
      wert += 0.4;
      gruende.add('Bewölkt – Fische weniger scheu');
    } else if (mittag.wolken < 15) {
      wert -= 0.3;
      gruende.add('Strahlend sonnig – mittags eher ruhig');
    }

    if (mittag.wind >= 5 && mittag.wind <= 20) {
      wert += 0.4;
      gruende.add('Leichter Wind kräuselt das Wasser');
    } else if (mittag.wind > 30) {
      wert -= 0.8;
      gruende.add('Starker Wind (${mittag.wind.toStringAsFixed(0)} km/h)');
    }

    tage.add(BeissTag(tag, wert.round().clamp(1, 5), gruende));
  }
  return tage;
}

/// Beißindex 0–100 für einen Tag, mit Stundenwerten und den besten
/// Zeitfenstern. Gleiche Faustregeln wie [beisszeit], dazu Morgen- und
/// Abenddämmerung (die klassischen Beißzeiten).
class Beissindex {
  const Beissindex({
    required this.wert,
    required this.gruende,
    required this.stunden,
    required this.fenster,
  });

  /// 0–100.
  final int wert;

  /// Kurze Gründe, z. B. „Luftdruck fällt leicht“.
  final List<String> gruende;

  /// Wert je Stunde (Stunde → 0–100), nur 4–22 Uhr.
  final Map<int, int> stunden;

  /// Beste Zeitfenster als (von, bis) in vollen Stunden, höchstens zwei.
  final List<(int, int)> fenster;

  String get wort => switch (wert) {
        >= 80 => 'TOP',
        >= 65 => 'SEHR GUT',
        >= 50 => 'GUT',
        >= 35 => 'MÄSSIG',
        _ => 'SCHWACH',
      };

  String get fensterText => fenster
      .map((f) => '${_zwei(f.$1)}:00 – ${_zwei(f.$2)}:00')
      .join(' und ');

  static String _zwei(int h) => h.toString().padLeft(2, '0');
}

/// Berechnet den Beißindex für [tag]. [aufgang]/[untergang] aus der
/// Sonnenberechnung; ohne sie zählt nur das Wetter.
Beissindex? beissindex(List<Stunde> stunden, DateTime tag,
    {DateTime? aufgang, DateTime? untergang}) {
  Stunde? bei(int h) {
    final ziel = DateTime(tag.year, tag.month, tag.day, h);
    for (final s in stunden) {
      if (s.zeit == ziel) return s;
    }
    return null;
  }

  final mittag = bei(12), morgen = bei(6);
  if (mittag == null || morgen == null) return null;

  var basis = 50.0;
  final gruende = <String>[];
  final trend = mittag.druck - morgen.druck;
  if (trend <= -1 && trend >= -4) {
    basis += 14;
    gruende.add('Luftdruck fällt leicht');
  } else if (trend < -4) {
    basis -= 6;
    gruende.add('Luftdruck fällt stark');
  } else if (trend > 3) {
    basis -= 14;
    gruende.add('Luftdruck steigt stark');
  } else if (trend > 0.5) {
    basis += 2;
    gruende.add('Luftdruck steigt leicht');
  } else {
    basis += 5;
    gruende.add('Luftdruck stabil');
  }

  final phase = mondphase(DateTime(tag.year, tag.month, tag.day, 12));
  final abstand =
      [phase, (phase - 0.5).abs(), 1 - phase].reduce((a, b) => a < b ? a : b);
  if (abstand < 0.07) {
    basis += 10;
    gruende.add(mondText(phase).$2);
  }

  if (mittag.wolken > 60) {
    basis += 6;
    gruende.add('bewölkt');
  } else if (mittag.wolken < 15) {
    basis -= 4;
    gruende.add('sonnig');
  }

  if (mittag.wind >= 5 && mittag.wind <= 20) {
    basis += 6;
    gruende.add('leichter Wind');
  } else if (mittag.wind < 5) {
    gruende.add('wenig Wind');
  } else if (mittag.wind > 30) {
    basis -= 12;
    gruende.add('starker Wind');
  }

  double stundeNahe(DateTime? t, int h) =>
      t == null ? 99 : (t.hour + t.minute / 60 - (h + 0.5)).abs();

  final werte = <int, int>{};
  for (var h = 4; h <= 22; h++) {
    var w = basis - 12;
    // Dämmerung: die zwei Stunden rund um Sonnenauf- und -untergang.
    final d = [stundeNahe(aufgang, h), stundeNahe(untergang, h)]
        .reduce((a, b) => a < b ? a : b);
    if (d <= 1.5) {
      w += 30 - d * 8;
    }
    final s = bei(h);
    if (s != null) {
      // Pralle Mittagssonne: Fische stehen tief.
      if (h >= 11 && h <= 15 && s.wolken < 30) w -= 10;
      if (s.wind > 30) w -= 8;
    }
    werte[h] = w.round().clamp(0, 100);
  }

  // Tageswert: Wetter-Basis plus die beste Stunde des Tages.
  final beste = werte.values.reduce((a, b) => a > b ? a : b);
  final wert = ((basis * 0.6) + (beste * 0.4)).round().clamp(0, 100);

  // Zusammenhängende Stunden nahe am Bestwert → Zeitfenster.
  final grenze = beste - 8;
  final fenster = <(int, int, int)>[]; // von, bis, summe
  int? start;
  var summe = 0;
  for (var h = 4; h <= 23; h++) {
    final gut = h <= 22 && werte[h]! >= grenze;
    if (gut) {
      start ??= h;
      summe += werte[h]!;
    } else if (start != null) {
      fenster.add((start, h, summe));
      start = null;
      summe = 0;
    }
  }
  fenster.sort((a, b) => b.$3.compareTo(a.$3));
  final zwei = fenster.take(2).toList()..sort((a, b) => a.$1.compareTo(b.$1));

  return Beissindex(
    wert: wert,
    gruende: gruende.take(3).toList(),
    stunden: werte,
    fenster: [for (final f in zwei) (f.$1, f.$2)],
  );
}
