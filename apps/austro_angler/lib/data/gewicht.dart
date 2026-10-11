import 'dart:math';

/// Längen-Gewichts-Beziehung W = a · L^b (W in g, L = Totallänge in cm).
/// Mittlere Werte für Mitteleuropa nach FishBase; Einzelfische streuen ±20 %.
const _lw = <String, (double, double)>{
  'bachforelle': (0.0105, 3.0),
  'regenbogenforelle': (0.0110, 3.0),
  'seeforelle': (0.0095, 3.03),
  'bachsaibling': (0.0102, 3.0),
  'seesaibling': (0.0083, 3.05),
  'namaycush': (0.0080, 3.08),
  'aesche': (0.0072, 3.08),
  'huchen': (0.0062, 3.08),
  'reinanke': (0.0068, 3.1),
  'sandfelchen': (0.0068, 3.1),
  'kleine_maraene': (0.0060, 3.15),
  'hecht': (0.0048, 3.08),
  'zander': (0.0069, 3.07),
  'wolgazander': (0.0075, 3.07),
  'flussbarsch': (0.0115, 3.1),
  'kaulbarsch': (0.0110, 3.1),
  'wels': (0.0045, 3.1),
  'zwergwels': (0.0110, 3.05),
  'aalrutte': (0.0050, 3.1),
  'aal': (0.0010, 3.2),
  'karpfen': (0.0150, 3.05),
  'graskarpfen': (0.0110, 3.05),
  'silberkarpfen': (0.0095, 3.08),
  'marmorkarpfen': (0.0110, 3.05),
  'schleie': (0.0120, 3.1),
  'brachse': (0.0098, 3.1),
  'guester': (0.0110, 3.1),
  'zope': (0.0080, 3.1),
  'zobel': (0.0085, 3.1),
  'barbe': (0.0083, 3.05),
  'nase': (0.0080, 3.08),
  'aitel': (0.0105, 3.05),
  'hasel': (0.0090, 3.05),
  'nerfling': (0.0110, 3.1),
  'perlfisch': (0.0075, 3.1),
  'rapfen': (0.0075, 3.07),
  'rotauge': (0.0110, 3.1),
  'rotfeder': (0.0120, 3.1),
  'laube': (0.0060, 3.1),
  'giebel': (0.0160, 3.0),
  'karausche': (0.0200, 3.0),
  'goldfisch': (0.0160, 3.0),
  'sonnenbarsch': (0.0160, 3.1),
  'forellenbarsch': (0.0125, 3.1),
  'sterlet': (0.0030, 3.15),
  'hausen': (0.0040, 3.1),
};

/// Ob für die Art eigene Werte vorliegen (sonst nur grobe Schätzung).
bool gewichtGenau(String fischId) => _lw.containsKey(fischId);

/// Geschätztes Gewicht in Gramm, `null` bei unsinniger Länge.
int? gewichtSchaetzen(String fischId, double laengeCm) {
  if (laengeCm < 3 || laengeCm > 300) return null;
  final (a, b) = _lw[fischId] ?? (0.0100, 3.0);
  return (a * pow(laengeCm, b)).round();
}
