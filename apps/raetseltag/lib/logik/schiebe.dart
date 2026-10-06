import 'dart:math';

/// Schiebepuzzle n×n. 0 ist die Lücke.
class Schiebe {
  Schiebe(this.n, this.felder);

  /// Gelöster Zustand: 1, 2, …, n²−1, Lücke unten rechts.
  factory Schiebe.geloest(int n) =>
      Schiebe(n, [for (var i = 1; i < n * n; i++) i, 0]);

  /// Mischt mit zufälligen erlaubten Zügen – so ist es immer lösbar.
  factory Schiebe.gemischt(int n, int seed, {int zuege = 200}) {
    final s = Schiebe.geloest(n);
    final zufall = Random(seed);
    var vorher = -1;
    var gemacht = 0;
    while (gemacht < zuege || s.istGeloest) {
      final nachbarn = s
          ._nachbarnDerLuecke()
          .where((i) => i != vorher)
          .toList();
      final wahl = nachbarn[zufall.nextInt(nachbarn.length)];
      vorher = s.luecke;
      s._tauschen(wahl);
      gemacht++;
    }
    return s;
  }

  final int n;
  final List<int> felder;
  int zuege = 0;

  int get luecke => felder.indexOf(0);

  bool get istGeloest {
    for (var i = 0; i < felder.length - 1; i++) {
      if (felder[i] != i + 1) return false;
    }
    return true;
  }

  List<int> _nachbarnDerLuecke() {
    final l = luecke;
    final z = l ~/ n, s = l % n;
    return [
      if (z > 0) l - n,
      if (z < n - 1) l + n,
      if (s > 0) l - 1,
      if (s < n - 1) l + 1,
    ];
  }

  void _tauschen(int i) {
    final l = luecke;
    felder[l] = felder[i];
    felder[i] = 0;
  }

  /// Tippt auf Feld [i]. Liegt es in derselben Zeile oder Spalte wie die
  /// Lücke, rutschen alle Steine dazwischen nach. Gibt zurück, wie viele
  /// Steine bewegt wurden (0 = nichts passiert).
  int tippen(int i) {
    final l = luecke;
    if (i == l) return 0;
    final zi = i ~/ n, si = i % n, zl = l ~/ n, sl = l % n;
    final int schritt;
    if (zi == zl) {
      schritt = i < l ? -1 : 1;
    } else if (si == sl) {
      schritt = i < l ? -n : n;
    } else {
      return 0;
    }
    var bewegt = 0;
    var pos = l;
    while (pos != i) {
      final naechste = pos + schritt;
      felder[pos] = felder[naechste];
      felder[naechste] = 0;
      pos = naechste;
      bewegt++;
    }
    zuege += bewegt;
    return bewegt;
  }
}

int schiebeSeed(int nummer) => nummer * 7 + 1234;
