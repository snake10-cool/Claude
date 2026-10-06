import 'package:intl/intl.dart';

final _euro = NumberFormat.currency(locale: 'de_AT', symbol: '€');
final _zahl = NumberFormat.decimalPattern('de_AT');

/// 1250 → „€ 12,50“ (österreichische Schreibweise).
String euro(int cent) => _euro.format(cent / 100);

/// Betrag ohne Währungszeichen für Eingabefelder: 1250 → „12,50“.
String euroFeld(int cent) {
  final vorzeichen = cent < 0 ? '-' : '';
  final b = cent.abs();
  return '$vorzeichen${b ~/ 100},${(b % 100).toString().padLeft(2, '0')}';
}

/// „12,5“, „12.50“, „12“ → Cent. `null` bei ungültiger Eingabe.
int? parseEuro(String text) {
  var t = text.trim().replaceAll('€', '').replaceAll(' ', '');
  if (t.isEmpty) return null;
  // „1.234,50“ → Punkt ist Tausendertrenner.
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  final wert = double.tryParse(t);
  if (wert == null || wert.isNaN || wert.isInfinite) return null;
  return (wert * 100).round();
}

/// „12,5“ → 12.5. `null` bei ungültiger Eingabe.
double? parseKomma(String text) {
  final t = text.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

String zahl(num wert) => _zahl.format(wert);

/// 125 → „2 h 5 min“, 45 → „45 min“.
String dauer(int minuten) {
  final h = minuten ~/ 60;
  final m = minuten % 60;
  if (h == 0) return '$m min';
  if (m == 0) return '$h h';
  return '$h h $m min';
}

String datum(DateTime d) => DateFormat('d. MMM yyyy', 'de').format(d);
String datumKurz(DateTime d) => DateFormat('d.M.', 'de').format(d);
String uhrzeit(DateTime d) => DateFormat('HH:mm', 'de').format(d);
String monatJahr(DateTime d) => DateFormat('MMMM yyyy', 'de').format(d);
String monatKurz(DateTime d) => DateFormat('MMM', 'de').format(d);
