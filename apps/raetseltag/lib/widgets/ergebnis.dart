import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../dienste.dart';
import '../l10n/l.dart';

/// Gemeinsamer Abschluss-Dialog: Ergebnis, Teilen, Weiter.
/// Danach (nicht währenddessen!) ggf. eine Zwischenwerbung.
Future<void> ergebnisZeigen(
  BuildContext context, {
  required bool geloest,
  required String titel,
  required String text,
  String? teilen,
}) async {
  final l = context.l;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Text(geloest ? '🎉' : '🤔', style: const TextStyle(fontSize: 48)),
      title: Text(titel),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(
            l.serieTage(fortschritt.aktuelleSerie),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      actions: [
        if (teilen != null)
          TextButton.icon(
            onPressed: () => SharePlus.instance.share(
              ShareParams(text: '$teilen\n$storeLink'),
            ),
            icon: const Icon(Icons.share),
            label: Text(l.teilen),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.weiter),
        ),
      ],
    ),
  );
  if (geloest) BewertungsBitte.vielleichtFragen();
  await werbung.zwischenwerbung();
}
