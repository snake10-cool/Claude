import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l.dart';

final _euro = NumberFormat.currency(locale: 'de_AT', symbol: '€');

String euro(int cent) => _euro.format(cent / 100);

String euroFeld(int cent) =>
    '${cent ~/ 100},${(cent.abs() % 100).toString().padLeft(2, '0')}';

int? parseEuro(String text) {
  var t = text.trim().replaceAll('€', '').replaceAll(' ', '');
  if (t.isEmpty) return null;
  if (t.contains(',')) t = t.replaceAll('.', '').replaceAll(',', '.');
  final w = double.tryParse(t);
  if (w == null || w.isNaN || w.isInfinite) return null;
  return (w * 100).round();
}

String datum(DateTime d) => DateFormat('d. MMM yyyy', 'de').format(d);
String datumKurz(DateTime d) => DateFormat('d. MMM', 'de').format(d);

/// Eingabefeld für Geldbeträge.
class EuroFeld extends StatelessWidget {
  const EuroFeld({
    super.key,
    required this.controller,
    required this.label,
    this.pflicht = false,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool pflicht;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    autofocus: autofocus,
    decoration: InputDecoration(labelText: label, suffixText: '€'),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    onChanged: onChanged,
    validator: (t) {
      if ((t ?? '').trim().isEmpty) {
        return pflicht ? context.l.pflichtfeld : null;
      }
      final c = parseEuro(t!);
      return c == null || c <= 0 ? context.l.ungueltigerBetrag : null;
    },
  );
}

/// Runder Kreis mit Anfangsbuchstaben einer Person.
class PersonKreis extends StatelessWidget {
  const PersonKreis({
    super.key,
    required this.name,
    required this.farbe,
    this.groesse = 36,
  });
  final String name;
  final int farbe;
  final double groesse;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: groesse / 2,
    backgroundColor: Color(farbe),
    child: Text(
      name.isEmpty ? '?' : name.characters.first.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: groesse * 0.45,
      ),
    ),
  );
}
