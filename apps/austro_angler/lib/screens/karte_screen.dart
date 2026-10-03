import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/gewaesser.dart';
import '../main.dart';
import '../models/fang.dart';
import '../models/gewaesser.dart';
import 'gewaesser_screen.dart';

class KarteScreen extends StatelessWidget {
  const KarteScreen({super.key});

  static const _start = LatLng(47.60, 13.80); // Mitte Österreichs

  Future<void> _spotAnlegen(BuildContext context, LatLng punkt) async {
    final speicher = SpeicherScope.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Neuer Angelplatz'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'z. B. Hechtbucht'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await speicher.spotSpeichern(
      Spot(id: speicher.neueId(), name: name.trim(), position: punkt),
    );
  }

  void _spotZeigen(BuildContext context, Spot spot) {
    final speicher = SpeicherScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.place),
          title: Text(spot.name),
          subtitle: const Text('Dein Angelplatz (nur auf diesem Handy)'),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              speicher.spotLoeschen(spot.id);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final farben = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Karte')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _start,
              initialZoom: 7,
              onLongPress: (_, punkt) => _spotAnlegen(context, punkt),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snake10.austroangler',
              ),
              MarkerLayer(
                markers: [
                  for (final g in gewaesserListe)
                    Marker(
                      point: g.position,
                      width: 40,
                      height: 40,
                      child: _Pin(
                        icon: g.typ == GewaesserTyp.fluss
                            ? Icons.waves
                            : Icons.water,
                        farbe: farben.primary,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GewaesserDetail(g),
                          ),
                        ),
                      ),
                    ),
                  for (final s in speicher.spots)
                    Marker(
                      point: s.position,
                      width: 40,
                      height: 40,
                      child: _Pin(
                        icon: Icons.star,
                        farbe: Colors.orange.shade700,
                        onTap: () => _spotZeigen(context, s),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap-Mitwirkende'),
                ],
              ),
            ],
          ),
          Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  'Lange drücken, um einen eigenen Angelplatz zu speichern.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.icon, required this.farbe, required this.onTap});

  final IconData icon;
  final Color farbe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: farbe,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
