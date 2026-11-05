import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/gewaesser.dart';
import '../services/alle_gewaesser.dart';
import 'gewaesser_screen.dart';
import '../services/fern_konfig.dart';
import 'widgets.dart';

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

  /// Sichtbare Gruppen (Filter-Knöpfe).
  final _zeigen = <_Art>{..._Art.values};

  /// Per Suche gewähltes Gewässer – wird immer gezeigt.
  Gewaesser? _gewaehlt;

  static _Art _art(Gewaesser g) => !g.ausOsm
      ? _Art.geprueft
      : g.typ.fliesst
          ? _Art.fluss
          : _Art.see;

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
    final sichtbar = alleGewaesser.liste
        .where((g) => _zeigen.contains(_art(g)) && drin(g))
        .toList()
      // Geprüfte zuerst, dann die größten.
      ..sort((a, c) {
        if (a.ausOsm != c.ausOsm) return a.ausOsm ? 1 : -1;
        return (c.groesse ?? 0).compareTo(a.groesse ?? 0);
      });
    final auswahl = [
      ...sichtbar.take(_maxPunkte),
      if (_gewaehlt case final g? when !sichtbar.take(_maxPunkte).contains(g)) g,
    ];
    if (!mounted) return;
    setState(() {
      _zuViele = sichtbar.length > _maxPunkte;
      _punkte = {
        for (final g in auswahl)
          Marker(
            markerId: MarkerId(g.id),
            position: LatLng(g.position.latitude, g.position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(_art(g).farbton),
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

  /// Gewässer aus der Suche anfliegen und seine Sprechblase zeigen.
  Future<void> _hinfliegen(Gewaesser g) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _gewaehlt = g;
      _zeigen.add(_art(g));
    });
    final karte = _karte;
    if (karte == null) return;
    await karte.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(g.position.latitude, g.position.longitude), 13));
    await _punkteFuerAusschnitt();
    try {
      await karte.showMarkerInfoWindow(MarkerId(g.id));
    } catch (_) {}
  }

  /// Passende Gewässer für die Suche: Namensanfang zuerst, geprüfte und
  /// große vor kleinen.
  static Iterable<Gewaesser> _treffer(String text) {
    final t = text.trim().toLowerCase();
    if (t.length < 2) return const [];
    final liste = alleGewaesser.liste
        .where((g) => g.anzeigeName.toLowerCase().contains(t))
        .toList()
      ..sort((a, b) {
        final aa = a.anzeigeName.toLowerCase().startsWith(t);
        final bb = b.anzeigeName.toLowerCase().startsWith(t);
        if (aa != bb) return aa ? -1 : 1;
        if (a.ausOsm != b.ausOsm) return a.ausOsm ? 1 : -1;
        return (b.groesse ?? 0).compareTo(a.groesse ?? 0);
      });
    return liste.take(8);
  }

  LatLng _start(BuildContext context) {
    final s = SpeicherScope.of(context);
    return s.heimatLat == null || s.heimatLon == null
        ? _braunau
        : LatLng(s.heimatLat!, s.heimatLon!);
  }

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('karte')) {
      return Scaffold(
          appBar: AppBar(title: const Text('Karte')),
          body: const FunktionAus('Die Karte'));
    }
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
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Suche(treffer: _treffer, gewaehlt: _hinfliegen),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final a in _Art.values)
                            FilterChip(
                              avatar: CircleAvatar(
                                  radius: 6, backgroundColor: a.farbe),
                              label: Text(a.name),
                              selected: _zeigen.contains(a),
                              showCheckmark: false,
                              onSelected: (an) {
                                setState(() =>
                                    an ? _zeigen.add(a) : _zeigen.remove(a));
                                _punkteFuerAusschnitt();
                              },
                            ),
                        ],
                      ),
                      if (_zuViele)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Viele Gewässer hier – hineinzoomen, um alle zu sehen.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ),
                    ],
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

/// Gruppen auf der Karte mit Farbe (wie die Punkte).
enum _Art {
  geprueft('geprüft', Colors.green, BitmapDescriptor.hueGreen),
  fluss('Fluss / Bach', Colors.blue, BitmapDescriptor.hueAzure),
  see('See / Teich', Colors.cyan, BitmapDescriptor.hueCyan);

  const _Art(this.name, this.farbe, this.farbton);
  final String name;
  final Color farbe;
  final double farbton;
}

/// Suchfeld „Gewässer suchen“ mit Vorschlägen.
class _Suche extends StatelessWidget {
  const _Suche({required this.treffer, required this.gewaehlt});

  final Iterable<Gewaesser> Function(String) treffer;
  final void Function(Gewaesser) gewaehlt;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Gewaesser>(
      optionsBuilder: (v) => treffer(v.text),
      displayStringForOption: (g) => g.anzeigeName,
      onSelected: gewaehlt,
      fieldViewBuilder: (context, controller, fokus, abschicken) => Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(28),
        child: TextField(
          controller: controller,
          focusNode: fokus,
          textInputAction: TextInputAction.search,
          onSubmitted: (v) {
            final t = treffer(v);
            if (t.isNotEmpty) gewaehlt(t.first);
          },
          decoration: InputDecoration(
            hintText: 'Gewässer suchen',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
      optionsViewBuilder: (context, waehlen, optionen) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: 320,
                maxWidth: MediaQuery.sizeOf(context).width - 16),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final g in optionen)
                  ListTile(
                    dense: true,
                    leading: Text(g.ausOsm ? '📍' : '✅'),
                    title: Text(g.anzeigeName),
                    subtitle: Text([
                      g.typ.name,
                      if (g.bezirk.isNotEmpty) 'Bezirk ${g.bezirk}',
                    ].join(' · ')),
                    onTap: () => waehlen(g),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
