import 'package:flutter/material.dart';

import 'l10n/basis_localizations.dart';

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
            Text(titel,
                style: t.textTheme.titleLarge, textAlign: TextAlign.center),
            if (text != null) ...[
              const SizedBox(height: 8),
              Text(text!,
                  style: t.textTheme.bodyMedium, textAlign: TextAlign.center),
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

/// Frage „Wirklich …?“. Gibt `true` zurück, wenn bestätigt.
Future<bool> bestaetigen(
  BuildContext context, {
  required String titel,
  required String text,
  String? ja,
}) async {
  final l = BasisLocalizations.of(context);
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
