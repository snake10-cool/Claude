import 'package:flutter/material.dart';

import '../main.dart';
import '../models/lehrplan.dart';

class KlasseScreen extends StatelessWidget {
  const KlasseScreen({super.key, this.wechseln = false});

  /// `true`, wenn die Klasse später in den Einstellungen geändert wird.
  final bool wechseln;

  @override
  Widget build(BuildContext context) {
    final fortschritt = FortschrittScope.of(context);
    final text = Theme.of(context).textTheme;

    Widget gruppe(String titel, Iterable<Stufe> stufen) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titel, style: text.titleMedium),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (final s in stufen)
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: fortschritt.stufe == s
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      foregroundColor: fortschritt.stufe == s
                          ? Theme.of(context).colorScheme.onPrimary
                          : null,
                    ),
                    onPressed: () async {
                      await fortschritt.stufeSetzen(s);
                      if (wechseln && context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      '${s.index % 4 + 1}',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );

    return Scaffold(
      appBar: wechseln ? AppBar(title: const Text('Klasse ändern')) : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!wechseln) ...[
              const SizedBox(height: 24),
              const Text('🦊', style: TextStyle(fontSize: 72),
                  textAlign: TextAlign.center),
              Text('Willkommen beim Lernfuchs!',
                  style: text.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('In welche Klasse gehst du?',
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),
            ],
            gruppe('Volksschule', Stufe.values.where((s) => s.volksschule)),
            gruppe('Mittelschule', Stufe.values.where((s) => !s.volksschule)),
          ],
        ),
      ),
    );
  }
}
