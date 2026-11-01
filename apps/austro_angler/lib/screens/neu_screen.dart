import 'package:flutter/material.dart';

import 'album_screen.dart';

/// Stand der Neuigkeiten. Bei jedem Update mit neuem „Neu in Austro Angler“
/// erhöhen.
const neuigkeitenStand = 9;

/// „Neu in Austro Angler“ – nach einem Update einmal gezeigt, sonst unter Mehr.
class NeuScreen extends StatelessWidget {
  const NeuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final farben = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Neu in Austro Angler')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: farben.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text('Gewässern folgen', style: text.headlineSmall),
                  const SizedBox(height: 6),
                  const Text(
                      'Tippe beim Gewässer oben auf den Stern. Deine Gewässer '
                      'stehen dann in der Liste immer ganz oben – und mit '
                      '„⭐ Meine“ siehst du nur sie, egal in welchem Bundesland.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: farben.tertiaryContainer,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AlbumScreen())),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📒', style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 6),
                    Text('Arten-Sammelalbum', style: text.headlineSmall),
                    const SizedBox(height: 6),
                    const Text(
                        'Alle Fischarten Österreichs als Karten – von häufig bis '
                        'legendär. Jeder Fang im Fangbuch schaltet seine Art frei. '
                        'Wie viele schaffst du?'),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('Zum Album →',
                          style: text.labelLarge
                              ?.copyWith(color: farben.onTertiaryContainer)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Text('🗺️', style: TextStyle(fontSize: 26)),
              title: Text('Karte mit Google Maps'),
              subtitle: Text('Alle Gewässer auf einen Blick – mit einem Tipp in '
                  'Google Maps öffnen und hinfahren.'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Text('⬇️', style: TextStyle(fontSize: 26)),
              title: Text('Updates in der App'),
              subtitle: Text('Neue Versionen laden im Hintergrund – ein Tipp '
                  'zum Neustarten.'),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Los geht’s – Petri Heil!'),
          ),
        ],
      ),
    );
  }
}
