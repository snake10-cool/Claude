import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../services/kachel_cache.dart';
import 'glossar_screen.dart';
import 'heimat_screen.dart';
import 'widgets.dart';

class EinstellungenScreen extends StatefulWidget {
  const EinstellungenScreen({super.key});

  @override
  State<EinstellungenScreen> createState() => _EinstellungenScreenState();
}

class _EinstellungenScreenState extends State<EinstellungenScreen> {
  Future<(int, int)>? _cache;

  @override
  void initState() {
    super.initState();
    _cache = KachelCache.groesse();
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Mein Heimatort'),
              subtitle: Text(speicher.heimat.isEmpty
                  ? 'Nicht gewählt'
                  : speicher.heimatName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HeimatScreen())),
            ),
          ),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.child_care),
              title: const Text('Jungangler-Modus'),
              subtitle: const Text('Einfache Erklärungen, größere Schrift, '
                  'Begriffe zum Antippen'),
              value: speicher.jungangler,
              onChanged: speicher.junganglerSetzen,
            ),
          ),
          if (speicher.jungangler)
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Angel-Wörterbuch'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GlossarScreen())),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Titel('⏳ Schonzeit-Countdown'),
                  Text('Für diese Fische zeigt der Gewässer-Tab oben, wie '
                      'lange die Schonzeit noch dauert.',
                      style: text.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (final f in fische.where((f) =>
                          !f.ausgestorben && !f.geschuetzt))
                        FilterChip(
                          label: Text(f.name),
                          selected: speicher.lieblingsfische.contains(f.id),
                          onSelected: (_) =>
                              speicher.lieblingsfischUmschalten(f.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Titel('🗺️ Offline-Karte', premium: true),
                  const Text(
                    'Jeder Kartenausschnitt, den du dir ansiehst, wird auf dem '
                    'Gerät gespeichert. Am Bach ohne Netz siehst du ihn dann '
                    'trotzdem. Tipp: Vor dem Losfahren die Gegend auf der '
                    'Karte einmal anschauen und hineinzoomen.',
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<(int, int)>(
                    future: _cache,
                    builder: (context, snap) {
                      final (bytes, anzahl) = snap.data ?? (0, 0);
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              snap.hasData
                                  ? '$anzahl Kacheln · '
                                      '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB'
                                  : 'Wird berechnet …',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              await KachelCache.leeren();
                              if (!mounted) return;
                              setState(() => _cache = KachelCache.groesse());
                            },
                            child: const Text('Löschen'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
