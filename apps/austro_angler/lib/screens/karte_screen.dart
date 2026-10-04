import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/kachel_cache.dart';

import '../data/gewaesser.dart';
import '../main.dart';
import '../models/fang.dart';
import '../models/gewaesser.dart';
import '../data/fische.dart';
import '../services/alle_gewaesser.dart';
import '../services/fang_dienst.dart';
import 'geschaefte_screen.dart';
import 'gewaesser_screen.dart';
import 'widgets.dart';

class KarteScreen extends StatelessWidget {
  const KarteScreen({super.key});

  static const _start = LatLng(48.12, 13.10); // Bezirk Braunau

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
              initialZoom: 9.5,
              onLongPress: (_, punkt) => _spotAnlegen(context, punkt),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snake10.austroangler',
                tileProvider: kachelProvider,
              ),
              const _AlleGewaesserLayer(),
              ListenableBuilder(
                listenable: alleGewaesser,
                builder: (context, _) => MarkerLayer(
                  markers: [
                    for (final l in alleGewaesser.geschaefte)
                      Marker(
                        point: l.position,
                        width: 34,
                        height: 34,
                        child: _Pin(
                          icon: Icons.storefront,
                          farbe: Colors.deepPurple,
                          onTap: () => geschaeftZeigen(context, l),
                        ),
                      ),
                  ],
                ),
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
                          MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
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
              const _MeineFaenge(),
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
                  'Grün: geprüfte Gewässer. Hineinzoomen zeigt alle anderen '
                  '(grau). Lila: Angelgeschäfte. Lange drücken: eigenen Angelplatz speichern. Rote '
                  'Punkte: deine Fänge mit Fangort (nur du siehst sie).',
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

/// Gewässer aus OpenStreetMap: erst beim Hineinzoomen, damit die Karte
/// flüssig bleibt.
class _AlleGewaesserLayer extends StatelessWidget {
  const _AlleGewaesserLayer();

  @override
  Widget build(BuildContext context) {
    final kamera = MapCamera.of(context);
    if (kamera.zoom < 11) return const SizedBox.shrink();
    final grenzen = kamera.visibleBounds;
    return ListenableBuilder(
      listenable: alleGewaesser,
      builder: (context, _) => MarkerLayer(
        markers: [
          for (final g
              in alleGewaesser.liste
                  .where((g) => g.ausOsm && grenzen.contains(g.position))
                  .take(300))
            Marker(
              point: g.position,
              width: 30,
              height: 30,
              child: Tooltip(
                message: g.name,
                child: _Pin(
                  icon: g.typ.fliesst ? Icons.waves : Icons.water,
                  farbe: Colors.blueGrey,
                  onTap: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => GewaesserDetail(g))),
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

/// Eigene Fänge mit gewähltem Fangort (nur für einen selbst sichtbar).
class _MeineFaenge extends StatefulWidget {
  const _MeineFaenge();

  @override
  State<_MeineFaenge> createState() => _MeineFaengeState();
}

class _MeineFaengeState extends State<_MeineFaenge> {
  String? _uid;
  Stream<Map<String, LatLng>>? _orte;
  Stream<List<Fang>>? _faenge;

  @override
  Widget build(BuildContext context) {
    final uid = KontoScope.of(context)?.uid;
    if (uid == null) return const SizedBox.shrink();
    if (uid != _uid) {
      _uid = uid;
      _orte = fangDienst.fangorte(uid);
      _faenge = fangDienst.meineFaenge(uid);
    }
    return StreamBuilder<Map<String, LatLng>>(
      stream: _orte,
      builder: (context, orteSnap) => StreamBuilder<List<Fang>>(
        stream: _faenge,
        builder: (context, faengeSnap) {
          final orte = orteSnap.data ?? const {};
          final faenge = {for (final f in faengeSnap.data ?? <Fang>[]) f.id: f};
          return MarkerLayer(
            markers: [
              for (final e in orte.entries)
                if (faenge[e.key] case final f?)
                  Marker(
                    point: e.value,
                    width: 36,
                    height: 36,
                    child: GestureDetector(
                      onTap: () => meldung(
                        context,
                        '${fischById(f.fischId)?.name ?? f.fischId}'
                        '${f.laengeCm == null ? '' : ', ${f.laengeCm!.toStringAsFixed(0)} cm'}'
                        ' · ${datumText(f.datum)}',
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.set_meal,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}
