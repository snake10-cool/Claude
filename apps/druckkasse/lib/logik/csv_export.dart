import 'statistik.dart';

/// Verkäufe als CSV für Excel/LibreOffice im deutschen Format:
/// Semikolon als Trenner, Komma bei Beträgen.
String verkaeufeAlsCsv(
  Iterable<VerkaufZeile> verkaeufe, {
  required List<String> kopfzeile,
  required String Function(VerkaufZeile) zahlungsart,
}) {
  final zeilen = <List<String>>[kopfzeile];
  for (final v in verkaeufe) {
    final z = v.zeitpunkt;
    zeilen.add([
      '${_zwei(z.day)}.${_zwei(z.month)}.${z.year} ${_zwei(z.hour)}:${_zwei(z.minute)}',
      v.produktName,
      '${v.menge}',
      betragCsv(v.einzelpreisCent),
      betragCsv(v.umsatzCent),
      betragCsv(v.kostenCent),
      betragCsv(v.gebuehrCent),
      betragCsv(v.gewinnCent),
      zahlungsart(v),
    ]);
  }
  return '${zeilen.map((z) => z.map(_feld).join(';')).join('\r\n')}\r\n';
}

String betragCsv(int cent) {
  final vorzeichen = cent < 0 ? '-' : '';
  final b = cent.abs();
  return '$vorzeichen${b ~/ 100},${_zwei(b % 100)}';
}

String _zwei(int n) => n.toString().padLeft(2, '0');

String _feld(String s) {
  if (s.contains(RegExp('[;"\r\n]'))) {
    return '"${s.replaceAll('"', '""')}"';
  }
  return s;
}
