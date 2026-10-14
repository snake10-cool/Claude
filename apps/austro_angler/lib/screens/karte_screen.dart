import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/gewaesser.dart';
import '../services/alle_gewaesser.dart';
import 'gewaesser_screen.dart';

/// Öffnet einen Punkt in der Google-Maps-App (dort auch mit Route).
Future<void> inGoogleMapsOeffnen(double lat, double lon) => launchUrl(
      Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$lat,$lon',
      }),
      mode: LaunchMode.externalApplication,
    );

/// Google-Karte mit den Gewässern im sichtbaren Ausschnitt.
class KarteScreen extends StatefulWidget {
  const KarteScreen({super.key});

  @override
  State<KarteScreen> createState() => _KarteScreenState();
}

class _KarteScreenState extends State<KarteScreen> {
  static const _braunau = LatLng(48.258, 13.040);

  /// Mehr Punkte auf einmal machen die Karte langsam und unübersichtlich.
  static const _maxPunkte = 250;

  GoogleMapController? _karte;
  Set<Marker> _punkte = const {};
  bool _zuViele = false;

  @override
  void initState() {
    super.initState();
    alleGewaesser.laden();
    alleGewaesser.addListener(_neuZeichnen);
  }

  @override
  void dispose() {
    alleGewaesser.removeListener(_neuZeichnen);
    _karte?.dispose();
    super.dispose();
  }

  void _neuZeichnen() => _punkteFuerAusschnitt();

  Future<void> _punkteFuerAusschnitt() async {
    final karte = _karte;
    if (karte == null || !mounted) return;
    final b = await karte.getVisibleRegion();
    bool drin(Gewaesser g) =>
        g.position.latitude >= b.southwest.latitude &&
        g.position.latitude <= b.northeast.latitude &&
        g.position.longitude >= b.southwest.longitude &&
        g.position.longitude <= b.northeast.longitude;
    final sichtbar = alleGewaesser.liste.where(drin).toList()
      // Geprüfte zuerst, dann die größten.
      ..sort((a, c) {
        if (a.ausOsm != c.ausOsm) return a.ausOsm ? 1 : -1;
        return (c.groesse ?? 0).compareTo(a.groesse ?? 0);
      });
    final auswahl = sichtbar.take(_maxPunkte);
    if (!mounted) return;
    setState(() {
      _zuViele = sichtbar.length > _maxPunkte;
      _punkte = {
        for (final g in auswahl)
          Marker(
            markerId: MarkerId(g.id),
            position: LatLng(g.position.latitude, g.position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(g.ausOsm
                ? (g.typ.fliesst
                    ? BitmapDescriptor.hueAzure
                    : BitmapDescriptor.hueCyan)
                : BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: g.ausOsm ? g.anzeigeName : '✅ ${g.anzeigeName}',
              snippet: [
                g.typ.name,
                if (g.bezirk.isNotEmpty) 'Bezirk ${g.bezirk}',
                'Antippen für Details',
              ].join(' · '),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => GewaesserDetail(g))),
            ),
          ),
      };
    });
  }

  LatLng _start(BuildContext context) {
    final s = SpeicherScope.of(context);
    return s.heimatLat == null || s.heimatLon == null
        ? _braunau
        : LatLng(s.heimatLat!, s.heimatLon!);
  }

  @override
  Widget build(BuildContext context) {
    // Die Google-Karte gibt es nur in der Handy-App.
    // (In Tests gibt es keine echte Karte.)
    final handy = !kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST') &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    return Scaffold(
      appBar: AppBar(title: const Text('Karte')),
      body: !handy
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Die Karte gibt es in der Handy-App.',
                    textAlign: TextAlign.center),
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _start(context), zoom: 11),
                  markers: _punkte,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (c) {
                    _karte = c;
                    _punkteFuerAusschnitt();
                  },
                  onCameraIdle: _punkteFuerAusschnitt,
                ),
                if (_zuViele)
                  Positioned(
                    top: 8,
                    left: 8,
                    right: 8,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Viele Gewässer hier – hineinzoomen, um alle zu sehen.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: handy
          ? FloatingActionButton.small(
              tooltip: 'Zum Heimatort',
              onPressed: () => _karte?.animateCamera(
                  CameraUpdate.newLatLngZoom(_start(context), 11)),
              child: const Icon(Icons.home_outlined),
            )
          : null,
    );
  }
}
