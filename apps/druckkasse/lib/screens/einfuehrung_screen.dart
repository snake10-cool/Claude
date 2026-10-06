import 'package:flutter/material.dart';

import '../daten/beispieldaten.dart';
import '../daten/datenbank.dart';
import '../l10n/l.dart';

/// Erster Start: kurz erklären, dann selbst einrichten oder mit
/// Beispieldaten loslegen.
class EinfuehrungScreen extends StatelessWidget {
  const EinfuehrungScreen({super.key, required this.fertig});

  final VoidCallback fertig;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    Widget punkt(IconData symbol, String titel, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: t.colorScheme.primaryContainer,
            child: Icon(symbol, color: t.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titel,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(text, style: t.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: t.colorScheme.primary,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Center(
                  child: Text('🖨️', style: TextStyle(fontSize: 52)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.willkommen,
              textAlign: TextAlign.center,
              style: t.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.willkommenText,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),
            punkt(Icons.calculate, l.einfuehrung1Titel, l.einfuehrung1Text),
            punkt(Icons.touch_app, l.einfuehrung2Titel, l.einfuehrung2Text),
            punkt(Icons.flag, l.einfuehrung3Titel, l.einfuehrung3Text),
            const SizedBox(height: 16),
            FilledButton(onPressed: fertig, child: Text(l.selbstEinrichten)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await beispieldatenLaden(db);
                fertig();
              },
              child: Text(l.mitBeispielenStarten),
            ),
            const SizedBox(height: 8),
            Text(
              l.beispieleSpaeterLoeschen,
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
