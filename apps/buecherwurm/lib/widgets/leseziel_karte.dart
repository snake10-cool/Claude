import 'package:flutter/material.dart';

import '../main.dart';

/// Jahres-Leseziel: „5 von 12 Büchern 2026". Antippen zum Ändern.
class LesezielKarte extends StatelessWidget {
  const LesezielKarte({super.key});

  Future<void> _aendern(BuildContext context) async {
    final speicher = SpeicherScope.of(context);
    var ziel = speicher.jahresziel == 0 ? 12 : speicher.jahresziel;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Leseziel ${DateTime.now().year}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$ziel Bücher', style: Theme.of(context).textTheme.headlineMedium),
              Slider(
                value: ziel.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (v) => setState(() => ziel = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok == true) await speicher.jahreszielSetzen(ziel);
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final jahr = DateTime.now().year;
    final ziel = speicher.jahresziel;
    final gelesen = speicher.gelesenImJahr(jahr);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _aendern(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: ziel == 0
              ? const Row(
                  children: [
                    Text('🎯', style: TextStyle(fontSize: 26)),
                    SizedBox(width: 12),
                    Expanded(child: Text('Setz dir ein Leseziel für dieses Jahr')),
                    Icon(Icons.chevron_right),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gelesen >= ziel
                          ? '🎯 Leseziel $jahr geschafft: $gelesen von $ziel Büchern!'
                          : '🎯 Leseziel $jahr: $gelesen von $ziel Büchern',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (gelesen / ziel).clamp(0, 1).toDouble(),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
