import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../services/alle_gewaesser.dart';
import 'melden.dart';
import 'widgets.dart';

/// Angelgeschäfte aus OpenStreetMap.
class GeschaefteScreen extends StatelessWidget {
  const GeschaefteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final heimat = speicher.heimatLat == null
        ? null
        : LatLng(speicher.heimatLat!, speicher.heimatLon!);
    return Scaffold(
      appBar: AppBar(title: const Text('Angelgeschäfte')),
      body: ListenableBuilder(
        listenable: alleGewaesser,
        builder: (context, _) {
          int km(Angelgeschaeft l) => heimat == null
              ? 0
              : const Distance()
                  .as(LengthUnit.Kilometer, heimat, l.position)
                  .round();
          final liste = alleGewaesser.geschaefte
              .where((l) => heimat != null || l.land == speicher.bundesland)
              .toList();
          if (heimat != null) liste.sort((a, b) => km(a).compareTo(km(b)));
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (heimat == null) const BundeslandWahl(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  heimat == null
                      ? '${liste.length} Geschäfte in ${speicher.bundesland.name}'
                      : 'Nächste zuerst (von ${speicher.heimatName})',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              if (!alleGewaesser.geladen)
                const Center(child: CircularProgressIndicator())
              else if (liste.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Hier ist noch kein Angelgeschäft eingetragen.'),
                ),
              for (final l in liste)
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.storefront)),
                    title: Text(l.name),
                    subtitle: Text([
                      if (l.adresse.isNotEmpty) l.adresse else l.ort,
                      if (heimat != null) '${km(l)} km',
                    ].join(' · ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => geschaeftZeigen(context, l),
                  ),
                ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => meldenDialog(
                  context,
                  typ: 'neues-geschaeft',
                  bezug: speicher.bundesland.name,
                  titel: 'Geschäft oder Verkaufsstelle vorschlagen',
                  hinweis: 'Name, Adresse, was es dort gibt (z. B. Tageskarten '
                      'für die Mattig).',
                ),
                icon: const Icon(Icons.add_business_outlined),
                label: const Text('Geschäft fehlt? Vorschlagen'),
              ),
              const SizedBox(height: 8),
              Text(
                'Daten © OpenStreetMap-Mitwirkende (ODbL). Öffnungszeiten ohne '
                'Gewähr.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

Future<void> geschaeftZeigen(BuildContext context, Angelgeschaeft l) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.name, style: Theme.of(context).textTheme.titleLarge),
              Text([l.ort, 'Bezirk ${l.bezirk}']
                  .where((t) => t.isNotEmpty)
                  .join(' · ')),
              const SizedBox(height: 8),
              if (l.adresse.isNotEmpty) Text('📍 ${l.adresse}'),
              if (l.oeffnungszeiten.isNotEmpty)
                Text('🕐 ${oeffnungszeitenText(l.oeffnungszeiten)}'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => launchUrl(
                      Uri.https('www.google.com', '/maps/search/', {
                        'api': '1',
                        'query':
                            '${l.position.latitude},${l.position.longitude}',
                      }),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.directions),
                    label: const Text('Hinfahren'),
                  ),
                  if (l.telefon.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(
                          Uri.parse('tel:${l.telefon.replaceAll(' ', '')}')),
                      icon: const Icon(Icons.phone),
                      label: const Text('Anrufen'),
                    ),
                  if (l.website.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(l.website),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Website'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

/// "Tu-Fr 09:00-18:00; Sa 09:00-14:00" -> "Di–Fr 09:00–18:00, Sa 09:00–14:00".
String oeffnungszeitenText(String osm) {
  const tage = {
    'Mo': 'Mo', 'Tu': 'Di', 'We': 'Mi', 'Th': 'Do', 'Fr': 'Fr', 'Sa': 'Sa',
    'Su': 'So', 'PH': 'Feiertag', 'off': 'zu',
  };
  var t = osm;
  tage.forEach((en, de) => t = t.replaceAll(en, de));
  return t.replaceAll(';', ',').replaceAll('-', '–');
}
