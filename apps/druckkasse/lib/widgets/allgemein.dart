import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import 'format.dart';

/// Freundlicher Hinweis, wenn eine Liste leer ist.
class LeerHinweis extends StatelessWidget {
  const LeerHinweis({
    super.key,
    required this.symbol,
    required this.titel,
    this.text,
    this.knopf,
    this.aktion,
  });

  final IconData symbol;
  final String titel;
  final String? text;
  final String? knopf;
  final VoidCallback? aktion;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(symbol, size: 56, color: t.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              titel,
              style: t.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (text != null) ...[
              const SizedBox(height: 8),
              Text(
                text!,
                style: t.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (knopf != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: aktion,
                icon: const Icon(Icons.add),
                label: Text(knopf!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Überschrift über einem Abschnitt in Formularen und Listen.
class Abschnitt extends StatelessWidget {
  const Abschnitt(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

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

/// Frage „Wirklich löschen?“.
Future<bool> bestaetigen(
  BuildContext context, {
  required String titel,
  required String text,
  String? ja,
}) async {
  final l = context.l;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titel),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.abbrechen),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(ja ?? l.loeschen),
        ),
      ],
    ),
  );
  return ok ?? false;
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
