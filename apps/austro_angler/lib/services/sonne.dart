import 'dart:math';

/// Sonnenzeiten für einen Tag, berechnet mit der Sonnenaufgangs-Gleichung
/// (genau auf etwa 1–2 Minuten).
class SonnenZeiten {
  const SonnenZeiten({
    required this.morgendaemmerung,
    required this.aufgang,
    required this.goldeneStundeMorgenEnde,
    required this.goldeneStundeAbendBeginn,
    required this.untergang,
    required this.abenddaemmerung,
  });

  /// Beginn der bürgerlichen Dämmerung (Sonne 6° unter dem Horizont).
  final DateTime? morgendaemmerung;
  final DateTime? aufgang;

  /// Ende der goldenen Stunde am Morgen (Sonne 6° über dem Horizont).
  final DateTime? goldeneStundeMorgenEnde;
  final DateTime? goldeneStundeAbendBeginn;
  final DateTime? untergang;
  final DateTime? abenddaemmerung;
}

double _rad(double grad) => grad * pi / 180;
double _grad(double rad) => rad * 180 / pi;

DateTime _ausJulian(double j) =>
    DateTime.fromMillisecondsSinceEpoch(((j - 2440587.5) * 86400000).round(),
            isUtc: true)
        .toLocal();

SonnenZeiten sonnenZeiten(DateTime tag, double breite, double laenge) {
  final mittagUtc = DateTime.utc(tag.year, tag.month, tag.day, 12);
  final jd = mittagUtc.millisecondsSinceEpoch / 86400000 + 2440587.5;
  final n = (jd - 2451545.0 + 0.0008).roundToDouble();
  final jStern = n - laenge / 360;
  final m = (357.5291 + 0.98560028 * jStern) % 360;
  final c = 1.9148 * sin(_rad(m)) +
      0.02 * sin(_rad(2 * m)) +
      0.0003 * sin(_rad(3 * m));
  final lambda = (m + c + 180 + 102.9372) % 360;
  final jTransit = 2451545.0 +
      jStern +
      0.0053 * sin(_rad(m)) -
      0.0069 * sin(_rad(2 * lambda));
  final sinDelta = sin(_rad(lambda)) * sin(_rad(23.4397));
  final cosDelta = cos(asin(sinDelta));

  (DateTime?, DateTime?) bei(double hoehe) {
    final cosOmega = (sin(_rad(hoehe)) - sin(_rad(breite)) * sinDelta) /
        (cos(_rad(breite)) * cosDelta);
    if (cosOmega < -1 || cosOmega > 1) return (null, null);
    final omega = _grad(acos(cosOmega));
    return (_ausJulian(jTransit - omega / 360), _ausJulian(jTransit + omega / 360));
  }

  final (aufgang, untergang) = bei(-0.833);
  final (daemmerungMorgen, daemmerungAbend) = bei(-6);
  final (goldMorgen, goldAbend) = bei(6);
  return SonnenZeiten(
    morgendaemmerung: daemmerungMorgen,
    aufgang: aufgang,
    goldeneStundeMorgenEnde: goldMorgen,
    goldeneStundeAbendBeginn: goldAbend,
    untergang: untergang,
    abenddaemmerung: daemmerungAbend,
  );
}
