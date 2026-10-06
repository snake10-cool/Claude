import 'dart:math' as math;

import 'katalog.dart';

/// Der ganze Spielstand. Wird als JSON gespeichert.
class Spielstand {
  Spielstand({
    this.gold = 0,
    this.goldDieseRunde = 0,
    this.goldGesamt = 0,
    this.tipps = 0,
    Map<String, int>? helfer,
    Set<String>? gekauft,
    this.glitzer = 0,
    this.prestige = 0,
    DateTime? letzterBesuch,
    this.bonusTag,
    this.bonusSerie = 0,
    Set<String>? erfolge,
    this.boostBis,
    this.wurmRekord = 0,
  }) : helfer = helfer ?? {},
       gekauft = gekauft ?? {},
       erfolge = erfolge ?? {},
       letzterBesuch = letzterBesuch ?? DateTime.now();

  double gold;
  double goldDieseRunde;
  double goldGesamt;
  int tipps;
  Map<String, int> helfer;
  Set<String> gekauft;
  int glitzer;
  int prestige;
  DateTime letzterBesuch;

  /// Tag (yyyy-mm-dd) des zuletzt abgeholten Tagesbonus.
  String? bonusTag;
  int bonusSerie;
  Set<String> erfolge;

  /// Doppelte Produktion bis zu diesem Zeitpunkt.
  DateTime? boostBis;
  int wurmRekord;

  Map<String, dynamic> toJson() => {
    'gold': gold,
    'goldDieseRunde': goldDieseRunde,
    'goldGesamt': goldGesamt,
    'tipps': tipps,
    'helfer': helfer,
    'gekauft': gekauft.toList(),
    'glitzer': glitzer,
    'prestige': prestige,
    'letzterBesuch': letzterBesuch.millisecondsSinceEpoch,
    'bonusTag': bonusTag,
    'bonusSerie': bonusSerie,
    'erfolge': erfolge.toList(),
    'boostBis': boostBis?.millisecondsSinceEpoch,
    'wurmRekord': wurmRekord,
  };

  factory Spielstand.ausJson(Map<String, dynamic> j) => Spielstand(
    gold: (j['gold'] as num?)?.toDouble() ?? 0,
    goldDieseRunde: (j['goldDieseRunde'] as num?)?.toDouble() ?? 0,
    goldGesamt: (j['goldGesamt'] as num?)?.toDouble() ?? 0,
    tipps: j['tipps'] as int? ?? 0,
    helfer: (j['helfer'] as Map?)?.map(
      (k, v) => MapEntry(k as String, v as int),
    ),
    gekauft: ((j['gekauft'] as List?) ?? const []).cast<String>().toSet(),
    glitzer: j['glitzer'] as int? ?? 0,
    prestige: j['prestige'] as int? ?? 0,
    letzterBesuch: j['letzterBesuch'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(j['letzterBesuch'] as int),
    bonusTag: j['bonusTag'] as String?,
    bonusSerie: j['bonusSerie'] as int? ?? 0,
    erfolge: ((j['erfolge'] as List?) ?? const []).cast<String>().toSet(),
    boostBis: j['boostBis'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(j['boostBis'] as int),
    wurmRekord: j['wurmRekord'] as int? ?? 0,
  );
}

/// Offline-Ertrag: Anteil der normalen Produktion und Höchstdauer.
const offlineAnteil = 0.5;
const offlineMaximum = Duration(hours: 8);

/// Prestige ab so viel Gold in einer Runde.
const prestigeAb = 1e6;

/// Alle Regeln des Spiels. Reine Logik, ohne Flutter.
class Spiel {
  Spiel(this.stand);
  final Spielstand stand;

  // ───────────────────────── Produktion ─────────────────────────

  /// Bonus durch Glitzersteine: +10 % pro Stein.
  double get glitzerFaktor => 1 + stand.glitzer * 0.1;

  bool boostAktiv(DateTime jetzt) =>
      stand.boostBis != null && jetzt.isBefore(stand.boostBis!);

  double _allesFaktor(DateTime jetzt) {
    var f = glitzerFaktor;
    for (final v in verbesserungen) {
      if (v.wirkung == Wirkung.alles && stand.gekauft.contains(v.id)) {
        f *= v.faktor;
      }
    }
    if (boostAktiv(jetzt)) f *= 2;
    return f;
  }

  double helferProduktion(HelferArt h) {
    var p = h.proSekunde * (stand.helfer[h.id] ?? 0);
    for (final v in verbesserungen) {
      if (v.wirkung == Wirkung.helfer &&
          v.ziel == h.id &&
          stand.gekauft.contains(v.id)) {
        p *= v.faktor;
      }
    }
    return p;
  }

  double proSekunde([DateTime? jetzt]) {
    final summe = helferArten.fold(0.0, (s, h) => s + helferProduktion(h));
    return summe * _allesFaktor(jetzt ?? DateTime.now());
  }

  double tippWert([DateTime? jetzt]) {
    final j = jetzt ?? DateTime.now();
    var w = 1.0;
    var anteil = 0.0;
    for (final v in verbesserungen) {
      if (!stand.gekauft.contains(v.id)) continue;
      if (v.wirkung == Wirkung.tippen) w *= v.faktor;
      if (v.wirkung == Wirkung.tippenAnteil) anteil += v.faktor;
    }
    return w * glitzerFaktor * (boostAktiv(j) ? 2 : 1) + anteil * proSekunde(j);
  }

  void _gutschreiben(double betrag) {
    stand.gold += betrag;
    stand.goldDieseRunde += betrag;
    stand.goldGesamt += betrag;
  }

  /// Ein Tipp auf Mo. Gibt den Ertrag zurück.
  double tippen([DateTime? jetzt]) {
    final w = tippWert(jetzt);
    stand.tipps++;
    _gutschreiben(w);
    return w;
  }

  /// Zeit vergeht (im Spiel, nicht offline).
  void tick(Duration dt, [DateTime? jetzt]) {
    _gutschreiben(proSekunde(jetzt) * dt.inMicroseconds / 1e6);
  }

  void bonusGutschreiben(double betrag) => _gutschreiben(betrag);

  // ───────────────────────── Kaufen ─────────────────────────

  double helferKosten(HelferArt h, [int anzahl = 1]) {
    final n = stand.helfer[h.id] ?? 0;
    // Geometrische Reihe: Summe der nächsten [anzahl] Preise.
    final start = h.grundkosten * math.pow(kostenFaktor, n);
    return start * (math.pow(kostenFaktor, anzahl) - 1) / (kostenFaktor - 1);
  }

  /// Wie viele Helfer man sich gerade leisten kann (für „Max“).
  int helferLeistbar(HelferArt h) {
    final n = stand.helfer[h.id] ?? 0;
    final start = h.grundkosten * math.pow(kostenFaktor, n);
    if (stand.gold < start) return 0;
    final k =
        math.log(stand.gold * (kostenFaktor - 1) / start + 1) /
        math.log(kostenFaktor);
    return k.floor();
  }

  bool helferKaufen(HelferArt h, [int anzahl = 1]) {
    if (anzahl < 1) return false;
    final k = helferKosten(h, anzahl);
    if (stand.gold < k) return false;
    stand.gold -= k;
    stand.helfer[h.id] = (stand.helfer[h.id] ?? 0) + anzahl;
    return true;
  }

  /// Helfer sind sichtbar, sobald man fast genug Gold für den ersten hat
  /// oder schon einen besitzt.
  bool helferSichtbar(HelferArt h) =>
      (stand.helfer[h.id] ?? 0) > 0 ||
      stand.goldDieseRunde >= h.grundkosten * 0.5;

  bool verbesserungSichtbar(Verbesserung v) {
    if (stand.gekauft.contains(v.id)) return false;
    if (v.ziel != null && (stand.helfer[v.ziel] ?? 0) < v.benoetigt) {
      return false;
    }
    return stand.goldDieseRunde >= v.kosten * 0.3;
  }

  bool verbesserungKaufen(Verbesserung v) {
    if (stand.gekauft.contains(v.id) || stand.gold < v.kosten) return false;
    stand.gold -= v.kosten;
    stand.gekauft.add(v.id);
    return true;
  }

  // ───────────────────────── Offline ─────────────────────────

  /// Ertrag für die Zeit seit dem letzten Besuch (ohne Boost).
  (double gold, Duration zeit) offlineErtrag(DateTime jetzt) {
    var weg = jetzt.difference(stand.letzterBesuch);
    if (weg.isNegative) weg = Duration.zero;
    if (weg > offlineMaximum) weg = offlineMaximum;
    final ohneBoost =
        proSekunde(stand.letzterBesuch) /
        (boostAktiv(stand.letzterBesuch) ? 2 : 1);
    return (ohneBoost * offlineAnteil * weg.inSeconds, weg);
  }

  // ───────────────────────── Prestige ─────────────────────────

  /// Glitzersteine, die ein neuer Hügel jetzt bringen würde.
  int glitzerFuerPrestige() => stand.goldDieseRunde < prestigeAb
      ? 0
      : math.sqrt(stand.goldDieseRunde / prestigeAb).floor();

  /// Neuer Hügel: Gold, Helfer und Verbesserungen weg, Glitzer dazu.
  bool prestigeMachen() {
    final neu = glitzerFuerPrestige();
    if (neu <= 0) return false;
    stand
      ..glitzer += neu
      ..prestige += 1
      ..gold = 0
      ..goldDieseRunde = 0
      ..helfer = {}
      ..gekauft = {};
    return true;
  }

  // ───────────────────────── Tagesbonus ─────────────────────────

  static String tagText(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  bool tagesbonusVerfuegbar(DateTime jetzt) => stand.bonusTag != tagText(jetzt);

  /// Tag 1–7 der Serie, die man heute bekommt.
  int bonusTagNummer(DateTime jetzt) {
    final gestern = tagText(DateTime(jetzt.year, jetzt.month, jetzt.day - 1));
    final serie = stand.bonusTag == gestern ? stand.bonusSerie : 0;
    return serie % 7 + 1;
  }

  /// Gold-Belohnung für einen Bonustag: mindestens 100, sonst
  /// Minuten der aktuellen Produktion (Tag 1: 5 min … Tag 7: 60 min).
  double bonusGold(int tag, DateTime jetzt) {
    const minuten = [5, 10, 15, 20, 30, 45, 60];
    return math.max(100.0 * tag, proSekunde(jetzt) * 60 * minuten[tag - 1]);
  }

  /// Holt den Tagesbonus ab. Gibt (Gold, Glitzer) zurück.
  (double, int)? tagesbonusAbholen(DateTime jetzt) {
    if (!tagesbonusVerfuegbar(jetzt)) return null;
    final tag = bonusTagNummer(jetzt);
    final gold = bonusGold(tag, jetzt);
    final glitzer = tag == 7 ? 1 : 0;
    _gutschreiben(gold);
    stand
      ..glitzer += glitzer
      ..bonusSerie = tag
      ..bonusTag = tagText(jetzt);
    return (gold, glitzer);
  }

  // ───────────────────────── Erfolge ─────────────────────────

  /// Prüft alle Erfolge und gibt die neu erreichten zurück.
  List<Erfolg> erfolgePruefen() {
    final neu = <Erfolg>[];
    for (final e in erfolge) {
      if (!stand.erfolge.contains(e.id) && e.erreicht(stand)) {
        stand.erfolge.add(e.id);
        neu.add(e);
      }
    }
    return neu;
  }
}

class Erfolg {
  const Erfolg(this.id, this.symbol, this.erreicht);
  final String id;
  final String symbol;
  final bool Function(Spielstand s) erreicht;
}

int _helferGesamt(Spielstand s) => s.helfer.values.fold(0, (a, b) => a + b);

final erfolge = <Erfolg>[
  Erfolg('tipp100', '👆', (s) => s.tipps >= 100),
  Erfolg('tipp1000', '✌️', (s) => s.tipps >= 1000),
  Erfolg('tipp10000', '🖐️', (s) => s.tipps >= 10000),
  Erfolg('gold1k', '🪙', (s) => s.goldGesamt >= 1e3),
  Erfolg('gold1m', '💰', (s) => s.goldGesamt >= 1e6),
  Erfolg('gold1b', '🏦', (s) => s.goldGesamt >= 1e9),
  Erfolg('gold1t', '👑', (s) => s.goldGesamt >= 1e12),
  Erfolg('helfer10', '🪱', (s) => _helferGesamt(s) >= 10),
  Erfolg('helfer100', '🦔', (s) => _helferGesamt(s) >= 100),
  Erfolg(
    'alleHelfer',
    '🔆',
    (s) => helferArten.every((h) => (s.helfer[h.id] ?? 0) > 0),
  ),
  Erfolg('prestige1', '⛰️', (s) => s.prestige >= 1),
  Erfolg('prestige5', '🏔️', (s) => s.prestige >= 5),
  Erfolg('wurm20', '🎯', (s) => s.wurmRekord >= 20),
  Erfolg('wurm50', '🏆', (s) => s.wurmRekord >= 50),
  Erfolg('serie7', '📅', (s) => s.bonusSerie >= 7),
];
