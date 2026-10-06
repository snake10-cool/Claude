import 'dart:math' as math;

/// Große Zahlen lesbar: 1234 → „1.234“, 1,5 Mio, 2,3 Mrd …
String grosseZahl(double wert) {
  if (wert.isNaN || wert.isInfinite) return '∞';
  final negativ = wert < 0;
  final w = wert.abs();
  String text;
  if (w < 1000) {
    text = w < 10 && w != w.floorToDouble()
        ? w.toStringAsFixed(1).replaceAll('.', ',')
        : w.floor().toString();
  } else if (w < 1e6) {
    final s = w.floor().toString();
    final teile = <String>[];
    for (var i = s.length; i > 0; i -= 3) {
      teile.insert(0, s.substring(math.max(0, i - 3), i));
    }
    text = teile.join('.');
  } else {
    const namen = ['Mio', 'Mrd', 'Bio', 'Brd', 'Trio', 'Trd', 'Qua', 'Qud'];
    // Kleine Toleranz: log10(1e15) ist sonst 14,999…
    var stufe = ((math.log(w) / math.ln10 + 1e-9) / 3).floor() - 2; // 0 = Mio
    stufe = stufe.clamp(0, namen.length - 1);
    final teil = w / math.pow(10, 6 + stufe * 3);
    final stellen = teil >= 100 ? 0 : (teil >= 10 ? 1 : 2);
    text =
        '${teil.toStringAsFixed(stellen).replaceAll('.', ',')} ${namen[stufe]}';
  }
  return negativ ? '-$text' : text;
}

/// Sekunden → „2 h 5 min“ / „45 s“.
String dauerText(Duration d) {
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  if (d.inMinutes > 0) return '${d.inMinutes} min ${d.inSeconds % 60} s';
  return '${d.inSeconds} s';
}
