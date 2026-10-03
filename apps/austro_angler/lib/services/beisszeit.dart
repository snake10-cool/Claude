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
