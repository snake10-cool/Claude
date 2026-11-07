import '../data/fische.dart';
import '../models/fang.dart';
import '../screens/album_screen.dart' show Seltenheit, seltenheit;
import 'abzeichen.dart';

/// Ein Rang der Angel-Karriere.
typedef Rang = ({int abLevel, String titel, String symbol});

const raenge = <Rang>[
  (abLevel: 1, titel: 'Grünschnabel', symbol: '🐣'),
  (abLevel: 3, titel: 'Jungfischer', symbol: '🎣'),
  (abLevel: 6, titel: 'Petrijünger', symbol: '🐟'),
  (abLevel: 10, titel: 'Uferkenner', symbol: '🌿'),
  (abLevel: 15, titel: 'Hechtflüsterer', symbol: '🌊'),
  (abLevel: 20, titel: 'Revierkenner', symbol: '🧭'),
  (abLevel: 30, titel: 'Alter Hecht', symbol: '🦉'),
  (abLevel: 40, titel: 'Donau-Legende', symbol: '🏆'),
  (abLevel: 50, titel: 'Huchen-König', symbol: '👑'),
];

/// Punkte pro Aktion.
abstract final class Xp {
  static const fang = 10;
  static const laenge = 5;
  static const zurueckgesetzt = 5;
  static const neueArt = 30;
  static const challenge = 25;
  static const abzeichen = 50;
  static const liveTag = 20;
  static const pruefung = 100;
  static const quizPunkt = 5;

  /// Bonus für den Erstfang einer Art nach Seltenheit.
  static int selten(Seltenheit s) => switch (s) {
        Seltenheit.haeufig => 0,
        Seltenheit.selten => 10,
        Seltenheit.sehrSelten => 25,
        Seltenheit.legendaer => 50,
      };
}

/// Woher die Punkte kommen (für die Aufschlüsselung).
typedef XpQuelle = ({
  String symbol,
  String titel,
  int anzahl,
  int xp,
  String wie,
});

/// Punkte, die man für Level [n] insgesamt braucht (Level 1 = 0).
int xpFuerLevel(int n) => 50 * n * (n - 1);

int levelFuer(int xp) {
  var n = 1;
  while (xpFuerLevel(n + 1) <= xp) {
    n++;
  }
  return n;
}

Rang rangFuer(int level) =>
    raenge.lastWhere((r) => level >= r.abLevel, orElse: () => raenge.first);

class Karriere {
  Karriere(this.quellen);

  final List<XpQuelle> quellen;

  late final int xp = quellen.fold(0, (s, q) => s + q.xp);
  late final int level = levelFuer(xp);
  Rang get rang => rangFuer(level);

  Rang? get naechsterRang {
    for (final r in raenge) {
      if (r.abLevel > level) return r;
    }
    return null;
  }

  int get xpLevelStart => xpFuerLevel(level);
  int get xpNaechstesLevel => xpFuerLevel(level + 1);
  int get xpBisNaechstes => xpNaechstesLevel - xp;

  /// Fortschritt im aktuellen Level (0–1).
  double get fortschritt =>
      (xp - xpLevelStart) / (xpNaechstesLevel - xpLevelStart);
}

/// Berechnet die Karriere aus dem, was schon in der App steht – ohne eigenes
/// Protokoll. So bekommen auch bestehende Nutzer gleich ihr Level.
Karriere karriereBerechnen({
  required List<Fang> faenge,
  int challenges = 0,
  int liveTage = 0,
  bool pruefungBestanden = false,
  int quizRekord = 0,
}) {
  final arten = {for (final f in faenge) f.fischId};
  var seltenBonus = 0;
  var selteneArten = 0;
  for (final id in arten) {
    final fisch = fischById(id);
    if (fisch == null) continue;
    final bonus = Xp.selten(seltenheit(fisch));
    if (bonus > 0) {
      seltenBonus += bonus;
      selteneArten++;
    }
  }
  final gemessen = faenge.where((f) => f.laengeCm != null).length;
  final zurueck = faenge.where((f) => f.zurueckgesetzt).length;
  final abzeichen = alleAbzeichen.where((a) => a.erreicht(faenge)).length;

  return Karriere([
    (
      symbol: '🎣',
      titel: 'Fänge eingetragen',
      anzahl: faenge.length,
      xp: faenge.length * Xp.fang,
      wie: '+${Xp.fang} je Fang',
    ),
    (
      symbol: '📏',
      titel: 'Mit Länge gemessen',
      anzahl: gemessen,
      xp: gemessen * Xp.laenge,
      wie: '+${Xp.laenge} je Fang mit Länge',
    ),
    (
      symbol: '🤲',
      titel: 'Schonend zurückgesetzt',
      anzahl: zurueck,
      xp: zurueck * Xp.zurueckgesetzt,
      wie: '+${Xp.zurueckgesetzt} je zurückgesetztem Fisch',
    ),
    (
      symbol: '📒',
      titel: 'Arten im Sammelalbum',
      anzahl: arten.length,
      xp: arten.length * Xp.neueArt,
      wie: '+${Xp.neueArt} je neuer Art',
    ),
    (
      symbol: '💎',
      titel: 'Seltene Arten',
      anzahl: selteneArten,
      xp: seltenBonus,
      wie: 'selten +10 · sehr selten +25 · legendär +50',
    ),
    (
      symbol: '✅',
      titel: 'Wochen-Challenges',
      anzahl: challenges,
      xp: challenges * Xp.challenge,
      wie: '+${Xp.challenge} je geschaffter Challenge',
    ),
    (
      symbol: '🏅',
      titel: 'Abzeichen',
      anzahl: abzeichen,
      xp: abzeichen * Xp.abzeichen,
      wie: '+${Xp.abzeichen} je Abzeichen',
    ),
    (
      symbol: '⏱️',
      titel: 'Live-Angeltage',
      anzahl: liveTage,
      xp: liveTage * Xp.liveTag,
      wie: '+${Xp.liveTag} je Live-Angeln ab 30 Minuten',
    ),
    (
      symbol: '🎓',
      titel: 'Prüfungsmodus bestanden',
      anzahl: pruefungBestanden ? 1 : 0,
      xp: pruefungBestanden ? Xp.pruefung : 0,
      wie: '+${Xp.pruefung} einmalig',
    ),
    (
      symbol: '🧠',
      titel: 'Quiz-Rekord (Punkte)',
      anzahl: quizRekord,
      xp: quizRekord * Xp.quizPunkt,
      wie: '+${Xp.quizPunkt} je Punkt im besten Übungsdurchgang',
    ),
  ]);
}

/// 1240 → „1.240“
String xpText(int xp) {
  final s = xp.abs().toString();
  final b = StringBuffer(xp < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}
