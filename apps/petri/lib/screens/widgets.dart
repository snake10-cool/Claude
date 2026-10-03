import 'package:flutter/material.dart';

import '../main.dart';
import '../models/bundesland.dart';

/// Umschalter OÖ / Salzburg, der die Auswahl dauerhaft speichert.
class BundeslandWahl extends StatelessWidget {
  const BundeslandWahl({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    return SegmentedButton<Bundesland>(
      showSelectedIcon: false,
      segments: [
        for (final b in Bundesland.values)
          ButtonSegment(value: b, label: Text(b.kurz)),
      ],
      selected: {speicher.bundesland},
      onSelectionChanged: (s) => speicher.bundeslandSetzen(s.first),
    );
  }
}

class HinweisKarte extends StatelessWidget {
  const HinweisKarte(this.text, {super.key, this.icon = Icons.info_outline});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      color: farben.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: farben.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: farben.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
