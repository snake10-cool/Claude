import 'dart:math';

/// Sudoku als Liste von 81 Zahlen (0 = leer), zeilenweise.
typedef Raster = List<int>;

enum Stufe { leicht, mittel, schwer }

/// So viele Felder bleiben vorgegeben.
int vorgaben(Stufe s) => switch (s) {
  Stufe.leicht => 40,
  Stufe.mittel => 32,
  Stufe.schwer => 27,
};

bool _passt(Raster r, int i, int z) {
  final zeile = i ~/ 9, spalte = i % 9;
  for (var k = 0; k < 9; k++) {
    if (r[zeile * 9 + k] == z || r[k * 9 + spalte] == z) return false;
  }
  final bz = zeile ~/ 3 * 3, bs = spalte ~/ 3 * 3;
  for (var a = 0; a < 3; a++) {
    for (var b = 0; b < 3; b++) {
      if (r[(bz + a) * 9 + bs + b] == z) return false;
    }
  }
  return true;
}

/// Zählt Lösungen bis [grenze] (für die Eindeutigkeitsprüfung).
int loesungenZaehlen(Raster start, {int grenze = 2}) {
  final r = List.of(start);
  var anzahl = 0;
  bool suche() {
    // Feld mit den wenigsten Möglichkeiten zuerst – viel schneller.
    var bestes = -1;
    var besteOptionen = 10;
    for (var i = 0; i < 81; i++) {
      if (r[i] != 0) continue;
      var n = 0;
      for (var z = 1; z <= 9; z++) {
        if (_passt(r, i, z)) n++;
      }
      if (n < besteOptionen) {
        besteOptionen = n;
        bestes = i;
        if (n == 0) return false;
      }
    }
    if (bestes == -1) {
      anzahl++;
      return anzahl >= grenze;
    }
    for (var z = 1; z <= 9; z++) {
      if (_passt(r, bestes, z)) {
        r[bestes] = z;
        if (suche()) return true;
        r[bestes] = 0;
      }
    }
    return false;
  }

  suche();
  return anzahl;
}

Raster? loesen(Raster start) {
  final r = List.of(start);
  bool suche(int i) {
    if (i == 81) return true;
    if (r[i] != 0) return suche(i + 1);
    for (var z = 1; z <= 9; z++) {
      if (_passt(r, i, z)) {
        r[i] = z;
        if (suche(i + 1)) return true;
        r[i] = 0;
      }
    }
    return false;
  }

  return suche(0) ? r : null;
}

/// Erzeugt ein Sudoku mit genau einer Lösung. Gleicher [seed] → gleiches
/// Rätsel (wichtig für das Tagesrätsel).
(Raster raetsel, Raster loesung) sudokuErzeugen(int seed, Stufe stufe) {
  final zufall = Random(seed);
  // 1. Volles Raster mit zufälliger Reihenfolge der Ziffern füllen.
  final voll = List.filled(81, 0);
  bool fuellen(int i) {
    if (i == 81) return true;
    final ziffern = List.generate(9, (k) => k + 1)..shuffle(zufall);
    for (final z in ziffern) {
      if (_passt(voll, i, z)) {
        voll[i] = z;
        if (fuellen(i + 1)) return true;
        voll[i] = 0;
      }
    }
    return false;
  }

  fuellen(0);
  // 2. Felder entfernen (symmetrisch), solange die Lösung eindeutig bleibt.
  final raetsel = List.of(voll);
  final reihenfolge = List.generate(41, (i) => i)..shuffle(zufall);
  var uebrig = 81;
  final ziel = vorgaben(stufe);
  for (final i in reihenfolge) {
    if (uebrig <= ziel) break;
    final j = 80 - i;
    final a = raetsel[i], b = raetsel[j];
    raetsel[i] = 0;
    raetsel[j] = 0;
    if (loesungenZaehlen(raetsel) != 1) {
      raetsel[i] = a;
      raetsel[j] = b;
    } else {
      uebrig -= i == j ? 1 : 2;
    }
  }
  return (raetsel, voll);
}

/// Felder, die gegen eine Regel verstoßen (doppelt in Zeile/Spalte/Block).
Set<int> konflikte(Raster r) {
  final ergebnis = <int>{};
  for (var i = 0; i < 81; i++) {
    final z = r[i];
    if (z == 0) continue;
    r[i] = 0;
    if (!_passt(r, i, z)) ergebnis.add(i);
    r[i] = z;
  }
  return ergebnis;
}

bool geloest(Raster r, Raster loesung) {
  for (var i = 0; i < 81; i++) {
    if (r[i] != loesung[i]) return false;
  }
  return true;
}

/// Seed für das Tagesrätsel einer Stufe.
int sudokuSeed(int nummer, Stufe s) => nummer * 31 + s.index * 7919 + 17;
