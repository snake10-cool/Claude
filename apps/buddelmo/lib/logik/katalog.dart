/// Ein Helfer, der automatisch Gold gräbt.
class HelferArt {
  const HelferArt(this.id, this.symbol, this.grundkosten, this.proSekunde);
  final String id;
  final String symbol;
  final double grundkosten;
  final double proSekunde;
}

/// Kosten steigen pro gekauftem Exemplar um 15 %.
const kostenFaktor = 1.15;

const helferArten = [
  HelferArt('wurm', '🪱', 15, 0.1),
  HelferArt('igel', '🦔', 100, 1),
  HelferArt('schaufel', '⛏️', 1100, 8),
  HelferArt('lore', '🛒', 12000, 47),
  HelferArt('bohrer', '🔩', 130000, 260),
  HelferArt('kristall', '💎', 1.4e6, 1400),
  HelferArt('magma', '🌋', 2e7, 7800),
  HelferArt('laser', '🔆', 3.3e8, 44000),
];

/// Was eine Verbesserung bewirkt.
enum Wirkung {
  /// Tippen bringt [faktor]-mal so viel.
  tippen,

  /// Ein Helfer [ziel] produziert [faktor]-mal so viel.
  helfer,

  /// Tippen bringt zusätzlich [faktor] × Produktion pro Sekunde.
  tippenAnteil,

  /// Alles produziert [faktor]-mal so viel.
  alles,
}

class Verbesserung {
  const Verbesserung(
    this.id,
    this.symbol,
    this.kosten,
    this.wirkung,
    this.faktor, {
    this.ziel,
    this.benoetigt = 0,
  });

  final String id;
  final String symbol;
  final double kosten;
  final Wirkung wirkung;
  final double faktor;

  /// Bei [Wirkung.helfer]: welcher Helfer.
  final String? ziel;

  /// Erst sichtbar, wenn man so viele vom [ziel]-Helfer hat.
  final int benoetigt;
}

const verbesserungen = [
  Verbesserung('krallen1', '🧤', 100, Wirkung.tippen, 2),
  Verbesserung('krallen2', '🧤', 5000, Wirkung.tippen, 2),
  Verbesserung('krallen3', '🧤', 5e5, Wirkung.tippen, 2),
  Verbesserung('lampe', '💡', 5e4, Wirkung.tippenAnteil, 0.01),
  Verbesserung('lampe2', '🔦', 5e7, Wirkung.tippenAnteil, 0.02),
  Verbesserung(
    'wurm2',
    '🪱',
    500,
    Wirkung.helfer,
    2,
    ziel: 'wurm',
    benoetigt: 10,
  ),
  Verbesserung(
    'wurm3',
    '🪱',
    5e4,
    Wirkung.helfer,
    3,
    ziel: 'wurm',
    benoetigt: 25,
  ),
  Verbesserung(
    'igel2',
    '🦔',
    3000,
    Wirkung.helfer,
    2,
    ziel: 'igel',
    benoetigt: 10,
  ),
  Verbesserung(
    'igel3',
    '🦔',
    3e5,
    Wirkung.helfer,
    3,
    ziel: 'igel',
    benoetigt: 25,
  ),
  Verbesserung(
    'schaufel2',
    '⛏️',
    3e4,
    Wirkung.helfer,
    2,
    ziel: 'schaufel',
    benoetigt: 10,
  ),
  Verbesserung(
    'schaufel3',
    '⛏️',
    3e6,
    Wirkung.helfer,
    3,
    ziel: 'schaufel',
    benoetigt: 25,
  ),
  Verbesserung(
    'lore2',
    '🛒',
    4e5,
    Wirkung.helfer,
    2,
    ziel: 'lore',
    benoetigt: 10,
  ),
  Verbesserung(
    'bohrer2',
    '🔩',
    4e6,
    Wirkung.helfer,
    2,
    ziel: 'bohrer',
    benoetigt: 10,
  ),
  Verbesserung(
    'kristall2',
    '💎',
    5e7,
    Wirkung.helfer,
    2,
    ziel: 'kristall',
    benoetigt: 10,
  ),
  Verbesserung(
    'magma2',
    '🌋',
    6e8,
    Wirkung.helfer,
    2,
    ziel: 'magma',
    benoetigt: 10,
  ),
  Verbesserung(
    'laser2',
    '🔆',
    1e10,
    Wirkung.helfer,
    2,
    ziel: 'laser',
    benoetigt: 10,
  ),
  Verbesserung('karte', '🗺️', 1e6, Wirkung.alles, 1.5),
  Verbesserung('kompass', '🧭', 1e9, Wirkung.alles, 2),
];

/// Erdschichten nach gesamt gegrabenem Gold (nur Optik und Motivation).
class Schicht {
  const Schicht(this.ab, this.oben, this.unten);
  final double ab;
  final int oben;
  final int unten;
}

const schichten = [
  Schicht(0, 0xFF8BC34A, 0xFF6D4C41), // Wiese
  Schicht(1e3, 0xFF795548, 0xFF5D4037), // Erde
  Schicht(1e5, 0xFFA1887F, 0xFF6D4C41), // Lehm
  Schicht(1e7, 0xFF78909C, 0xFF455A64), // Stein
  Schicht(1e9, 0xFF5C6BC0, 0xFF283593), // Kristallhöhle
  Schicht(1e11, 0xFFE64A19, 0xFF3E2723), // Lava
  Schicht(1e13, 0xFFFFC107, 0xFFBF360C), // Erdkern
];

int schichtIndex(double gesamt) {
  var i = 0;
  for (var j = 0; j < schichten.length; j++) {
    if (gesamt >= schichten[j].ab) i = j;
  }
  return i;
}
