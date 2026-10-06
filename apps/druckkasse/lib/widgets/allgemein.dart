import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import 'format.dart';

/// Eingabefeld für Geldbeträge („12,50“).
class EuroFeld extends StatelessWidget {
  const EuroFeld({
    super.key,
    required this.controller,
    required this.label,
    this.pflicht = false,
    this.hilfe,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final bool pflicht;
  final String? hilfe;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixText: '€',
      helperText: hilfe,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
    onChanged: onChanged,
    validator: (t) {
      if ((t ?? '').trim().isEmpty) {
        return pflicht ? context.l.pflichtfeld : null;
      }
      return parseEuro(t!) == null ? context.l.ungueltigerBetrag : null;
    },
  );
}

/// Eingabefeld für ganze Zahlen.
class ZahlFeld extends StatelessWidget {
  const ZahlFeld({
    super.key,
    required this.controller,
    required this.label,
    this.suffix,
    this.hilfe,
    this.komma = false,
    this.pflicht = true,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final String? hilfe;
  final bool komma;
  final bool pflicht;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      suffixText: suffix,
      helperText: hilfe,
      helperMaxLines: 3,
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: komma),
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(komma ? r'[0-9.,]' : r'[0-9]')),
    ],
    onChanged: onChanged,
    validator: (t) {
      if ((t ?? '').trim().isEmpty) {
        return pflicht ? context.l.pflichtfeld : null;
      }
      return parseKomma(t!) == null ? context.l.ungueltigeZahl : null;
    },
  );
}

/// Zeigt, dass die Gratis-Grenze erreicht ist, und bietet Pro an.
Future<void> proGrenzeZeigen(BuildContext context, String text) async {
  final l = context.l;
  final holen = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.workspace_premium),
      title: Text(l.grenzeErreicht),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.abbrechen),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l.proAnsehen),
        ),
      ],
    ),
  );
  if (holen == true && context.mounted) proSeiteOeffnen(context);
}

void proSeiteOeffnen(BuildContext context) {
  final l = context.l;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProSeite(
        dienst: kauf,
        titel: l.proTitel,
        vorteile: [
          ProVorteil(Icons.all_inclusive, l.proVorteilUnbegrenzt),
          ProVorteil(Icons.table_view, l.proVorteilExport),
          ProVorteil(Icons.bar_chart, l.proVorteilVerlauf),
          ProVorteil(Icons.flag, l.proVorteilSparziele),
          ProVorteil(Icons.favorite, l.proVorteilUnterstuetzen),
        ],
      ),
    ),
  );
}

/// Kleiner farbiger Kreis mit Emoji, z. B. für Produkte.
class SymbolKreis extends StatelessWidget {
  const SymbolKreis({
    super.key,
    required this.symbol,
    required this.farbe,
    this.groesse = 40,
  });

  final String symbol;
  final Color farbe;
  final double groesse;

  @override
  Widget build(BuildContext context) => Container(
    width: groesse,
    height: groesse,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: farbe.withValues(alpha: 0.25),
      shape: BoxShape.circle,
      border: Border.all(color: farbe, width: 2),
    ),
    child: Text(symbol, style: TextStyle(fontSize: groesse * 0.5)),
  );
}
