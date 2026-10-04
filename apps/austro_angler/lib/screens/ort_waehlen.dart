import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/kachel_cache.dart';

import 'gewaesser_screen.dart';

/// Karte zum Antippen eines Ortes. Gibt den gewählten Punkt zurück.
/// Es wird nichts automatisch ermittelt – man wählt den Ort selbst.
class OrtWaehlen extends StatefulWidget {
  const OrtWaehlen({super.key, this.start});

  final LatLng? start;

  @override
  State<OrtWaehlen> createState() => _OrtWaehlenState();
}

class _OrtWaehlenState extends State<OrtWaehlen> {
  late LatLng? _punkt = widget.start;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fangort wählen'),
        actions: [
          TextButton(
            onPressed: _punkt == null
                ? null
                : () => Navigator.pop(context, _punkt),
            child: const Text('Übernehmen'),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: widget.start ?? braunau,
              initialZoom: widget.start == null ? 10 : 14,
              onTap: (_, p) => setState(() => _punkt = p),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.snake10.austroangler',
                tileProvider: kachelProvider,
              ),
              if (_punkt != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _punkt!,
                      width: 44,
                      height: 44,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on,
                        size: 44,
                        color: Colors.red.shade700,
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
          const Positioned(
            left: 12,
            right: 12,
            top: 12,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Tippe auf die Stelle, wo du gefangen hast. Der '
                  'Ort bleibt privat – nur du siehst ihn.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
