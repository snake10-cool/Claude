import 'dart:math';

import '../models/lehrplan.dart';

int _zahl(Random z, int min, int max) => min + z.nextInt(max - min + 1);

/// Drei falsche, aber plausible Zahlen in der Nähe von [richtig].
List<String> _daneben(Random z, num richtig,
    {int abstand = 3, bool negativErlaubt = false, String einheit = ''}) {
  final ergebnis = <num>{};
  var versuche = 0;
  while (ergebnis.length < 3 && versuche < 100) {
    versuche++;
    final d = _zahl(z, 1, abstand) * (z.nextBool() ? 1 : -1);
    final kandidat = richtig + d;
    if (kandidat == richtig) continue;
    if (!negativErlaubt && kandidat < 0) continue;
    ergebnis.add(kandidat);
  }
  // Notfalls nach oben auffüllen.
  var plus = abstand + 1;
  while (ergebnis.length < 3) {
    ergebnis.add(richtig + plus++);
  }
  return [for (final e in ergebnis) '${_text(e)}$einheit'];
}

String _text(num n) {
  if (n is double && n == n.roundToDouble()) return n.toInt().toString();
  if (n is double) return n.toStringAsFixed(2).replaceAll('.', ',');
  return n.toString();
}

Aufgabe _rechnung(Random z, String frage, num richtig,
    {int abstand = 3, bool negativErlaubt = false, String einheit = ''}) {
  return Aufgabe(
    frage,
    '${_text(richtig)}$einheit',
    _daneben(z, richtig,
        abstand: abstand, negativErlaubt: negativErlaubt, einheit: einheit),
  );
}

Aufgabe _plusMinus(Random z, int max) {
  final a = _zahl(z, 0, max);
  if (z.nextBool()) {
    final b = _zahl(z, 0, max - a);
    return _rechnung(z, '$a + $b = ?', a + b, abstand: max ~/ 20 + 2);
  }
  final b = _zahl(z, 0, a);
  return _rechnung(z, '$a − $b = ?', a - b, abstand: max ~/ 20 + 2);
}

int _ggt(int a, int b) => b == 0 ? a : _ggt(b, a % b);

final mathe = <Stufe, List<Thema>>{
  Stufe.vs1: [
    Thema('m1-plus', 'Plus und Minus bis 20', (z) => _plusMinus(z, 20)),
    Thema('m1-vergleich', 'Größer, kleiner, gleich', (z) {
      final a = _zahl(z, 0, 20), b = _zahl(z, 0, 20);
      final richtig = a > b ? '>' : a < b ? '<' : '=';
      return Aufgabe('$a  ?  $b', richtig,
          ['>', '<', '='].where((s) => s != richtig).toList());
    }),
    Thema('m1-nachbar', 'Nachbarzahlen', (z) {
      final a = _zahl(z, 1, 19);
      return z.nextBool()
          ? _rechnung(z, 'Welche Zahl kommt nach $a?', a + 1, abstand: 2)
          : _rechnung(z, 'Welche Zahl kommt vor $a?', a - 1, abstand: 2);
    }),
  ],
  Stufe.vs2: [
    Thema('m2-plus', 'Plus und Minus bis 100', (z) => _plusMinus(z, 100)),
    Thema('m2-einmaleins', 'Kleines Einmaleins', (z) {
      final a = _zahl(z, 1, 10), b = _zahl(z, 1, 10);
      return _rechnung(z, '$a · $b = ?', a * b, abstand: 6);
    }),
    Thema('m2-doppelt', 'Verdoppeln und Halbieren', (z) {
      final a = _zahl(z, 1, 50);
      return z.nextBool()
          ? _rechnung(z, 'Das Doppelte von $a ist?', a * 2, abstand: 4)
          : _rechnung(z, 'Die Hälfte von ${a * 2} ist?', a, abstand: 4);
    }),
  ],
  Stufe.vs3: [
    Thema('m3-plus', 'Plus und Minus bis 1000', (z) => _plusMinus(z, 1000)),
    Thema('m3-teilen', 'Teilen (auch mit Rest)', (z) {
      final b = _zahl(z, 2, 10), q = _zahl(z, 1, 10), r = _zahl(z, 0, b - 1);
      final a = b * q + r;
      final richtig = r == 0 ? '$q' : '$q Rest $r';
      final falsch = <String>{
        r == 0 ? '${q + 1}' : '$q Rest ${(r + 1) % b}',
        r == 0 ? '${q - 1 < 0 ? q + 2 : q - 1}' : '${q + 1} Rest $r',
        r == 0 ? '$q Rest 1' : '${q - 1} Rest $r',
      }..remove(richtig);
      return Aufgabe('$a : $b = ?', richtig, falsch.toList());
    }),
    Thema('m3-laengen', 'Längen umrechnen', (z) {
      switch (z.nextInt(3)) {
        case 0:
          final m = _zahl(z, 1, 9);
          return _rechnung(z, '$m m = ? cm', m * 100,
              abstand: 3, einheit: ' cm');
        case 1:
          final cm = _zahl(z, 1, 9) * 10;
          return _rechnung(z, '${cm ~/ 10} cm = ? mm', cm,
              abstand: 3, einheit: ' mm');
        default:
          final km = _zahl(z, 1, 9);
          return _rechnung(z, '$km km = ? m', km * 1000,
              abstand: 3, einheit: ' m');
      }
    }),
  ],
  Stufe.vs4: [
    Thema('m4-runden', 'Runden auf Hunderter', (z) {
      final a = _zahl(z, 1000, 99999);
      final richtig = ((a + 50) ~/ 100) * 100;
      return Aufgabe('$a auf Hunderter gerundet?', '$richtig',
          {'${richtig + 100}', '${richtig - 100}', '${(a ~/ 10) * 10}'}
              .where((s) => s != '$richtig')
              .toList());
    }),
    Thema('m4-mal', 'Mal mit großen Zahlen', (z) {
      final a = _zahl(z, 11, 99), b = _zahl(z, 2, 9);
      return _rechnung(z, '$a · $b = ?', a * b, abstand: 12);
    }),
    Thema('m4-brueche', 'Erste Brüche', (z) {
      const teile = {2: 'die Hälfte', 4: 'ein Viertel', 10: 'ein Zehntel'};
      final n = teile.keys.elementAt(z.nextInt(teile.length));
      final ganz = n * _zahl(z, 1, 12);
      return _rechnung(z, 'Was ist ${teile[n]} von $ganz?', ganz ~/ n,
          abstand: 3);
    }),
  ],
  Stufe.ms1: [
    Thema('m5-punkt', 'Punkt vor Strich', (z) {
      final a = _zahl(z, 1, 20), b = _zahl(z, 2, 9), c = _zahl(z, 2, 9);
      return Aufgabe('$a + $b · $c = ?', '${a + b * c}', [
        '${(a + b) * c}',
        '${a + b * c + 1}',
        '${a + b + c}',
      ]..remove('${a + b * c}'));
    }),
    Thema('m5-dezimal', 'Dezimalzahlen addieren', (z) {
      final a = _zahl(z, 10, 999) / 10, b = _zahl(z, 10, 999) / 10;
      final summe = ((a + b) * 10).round() / 10;
      String t(double x) => x.toStringAsFixed(1).replaceAll('.', ',');
      return Aufgabe('${t(a)} + ${t(b)} = ?', t(summe),
          [t(summe + 1), t(summe - 0.1), t(summe + 0.1)]);
    }),
    Thema('m5-rechteck', 'Umfang und Fläche Rechteck', (z) {
      final a = _zahl(z, 2, 15), b = _zahl(z, 2, 15);
      return z.nextBool()
          ? _rechnung(z, 'Rechteck $a cm × $b cm: Umfang?', 2 * (a + b),
              abstand: 4, einheit: ' cm')
          : _rechnung(z, 'Rechteck $a cm × $b cm: Fläche?', a * b,
              abstand: 5, einheit: ' cm²');
    }),
  ],
  Stufe.ms2: [
    Thema('m6-kuerzen', 'Brüche kürzen', (z) {
      int p = _zahl(z, 1, 9), q = _zahl(z, 2, 10);
      while (_ggt(p, q) != 1 || p >= q) {
        p = _zahl(z, 1, 9);
        q = _zahl(z, 2, 10);
      }
      final k = _zahl(z, 2, 6);
      return Aufgabe('Kürze ${p * k}/${q * k} so weit wie möglich', '$p/$q', {
        '${p + 1}/$q',
        '$p/${q + 1}',
        '${p * k}/$q',
        '$q/$p',
      }.where((s) => s != '$p/$q').take(3).toList());
    }),
    Thema('m6-prozent', 'Prozent einfach', (z) {
      const prozente = [10, 20, 25, 50, 75];
      final p = prozente[z.nextInt(prozente.length)];
      final g = _zahl(z, 1, 20) * 20;
      return _rechnung(z, '$p % von $g = ?', g * p ~/ 100, abstand: 5);
    }),
    Thema('m6-schluss', 'Schlussrechnung', (z) {
      final stueck = _zahl(z, 2, 6), preis = _zahl(z, 1, 9);
      final neu = _zahl(z, 2, 12);
      return _rechnung(
        z,
        '$stueck Hefte kosten € ${stueck * preis}. Was kosten $neu Hefte?',
        neu * preis,
        abstand: 4,
        einheit: ' €',
      );
    }),
    Thema('m6-winkel', 'Winkelsumme im Dreieck', (z) {
      final a = _zahl(z, 20, 100), b = _zahl(z, 20, 160 - a);
      return _rechnung(z, 'Dreieck: α = $a°, β = $b°. Wie groß ist γ?',
          180 - a - b, abstand: 10, einheit: '°');
    }),
  ],
  Stufe.ms3: [
    Thema('m7-negativ', 'Rechnen mit negativen Zahlen', (z) {
      final a = _zahl(z, -20, 20), b = _zahl(z, -20, 20);
      final klammer = b < 0 ? '($b)' : '$b';
      return z.nextBool()
          ? _rechnung(z, '$a + $klammer = ?', a + b, negativErlaubt: true)
          : _rechnung(z, '$a − $klammer = ?', a - b, negativErlaubt: true);
    }),
    Thema('m7-potenzen', 'Potenzen', (z) {
      final basis = _zahl(z, 2, 10), exp = basis <= 5 ? _zahl(z, 2, 4) : 2;
      return Aufgabe('$basis hoch $exp = ?', '${pow(basis, exp)}', [
        '${basis * exp}',
        '${pow(basis, exp) + basis}',
        '${pow(basis, exp + 1)}',
      ]);
    }),
    Thema('m7-gleichung', 'Gleichungen lösen', (z) {
      final x = _zahl(z, -10, 10), a = _zahl(z, 2, 9), b = _zahl(z, -20, 20);
      final c = a * x + b;
      final bText = b < 0 ? '− ${-b}' : '+ $b';
      return _rechnung(z, '${a}x $bText = $c   →   x = ?', x,
          negativErlaubt: true);
    }),
    Thema('m7-rabatt', 'Rabatt und Preis', (z) {
      const rabatte = [10, 20, 25, 30, 50];
      final r = rabatte[z.nextInt(rabatte.length)];
      final preis = _zahl(z, 2, 20) * 10;
      return _rechnung(
        z,
        'Eine Jacke kostet € $preis. Mit $r % Rabatt kostet sie?',
        preis - preis * r ~/ 100,
        abstand: 6,
        einheit: ' €',
      );
    }),
  ],
  Stufe.ms4: [
    Thema('m8-pythagoras', 'Satz des Pythagoras', (z) {
      const tripel = [[3, 4, 5], [6, 8, 10], [5, 12, 13], [8, 15, 17],
        [9, 12, 15], [7, 24, 25], [12, 16, 20]];
      final t = tripel[z.nextInt(tripel.length)];
      return _rechnung(z,
          'Rechtwinkliges Dreieck: a = ${t[0]} cm, b = ${t[1]} cm. c = ?',
          t[2], abstand: 3, einheit: ' cm');
    }),
    Thema('m8-wurzel', 'Quadratwurzeln', (z) {
      final w = _zahl(z, 2, 20);
      return _rechnung(z, '√${w * w} = ?', w, abstand: 3);
    }),
    Thema('m8-funktion', 'Lineare Funktionen', (z) {
      final k = _zahl(z, 1, 5) * (z.nextBool() ? 1 : -1);
      final d = _zahl(z, 1, 10) * (z.nextBool() ? 1 : -1);
      final x = _zahl(z, -5, 5);
      final kText = switch (k) { 1 => '', -1 => '−', _ => '$k' };
      final dText = d < 0 ? '− ${-d}' : '+ $d';
      return _rechnung(z, 'y = ${kText}x $dText. Wie groß ist y bei x = $x?',
          k * x + d, abstand: 4, negativErlaubt: true);
    }),
    Thema('m8-klammer', 'Gleichungen mit Klammern', (z) {
      final x = _zahl(z, -8, 8), a = _zahl(z, 2, 6), b = _zahl(z, 1, 9);
      final c = a * (x + b);
      return _rechnung(z, '$a · (x + $b) = $c   →   x = ?', x,
          negativErlaubt: true);
    }),
  ],
};
