import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../main.dart';
import '../models/gewaesser.dart';
import '../services/fang_dienst.dart';
import '../services/wetter.dart';
import 'konto_screen.dart';
import 'melden.dart';
import 'widgets.dart';

class GewaesserScreen extends StatefulWidget {
  const GewaesserScreen({super.key});

  @override
  State<GewaesserScreen> createState() => _GewaesserScreenState();
}

/// Mittelpunkt der App: Braunau am Inn.
const braunau = LatLng(48.258, 13.040);

int kmVonBraunau(Gewaesser g) =>
    const Distance().as(LengthUnit.Kilometer, braunau, g.position).round();

class _GewaesserScreenState extends State<GewaesserScreen> {
  String _suche = '';

  @override
  Widget build(BuildContext context) {
    final land = SpeicherScope.of(context).bundesland;
    final suche = _suche.toLowerCase();
    final liste = gewaesserListe
        .where((g) =>
            suche.isEmpty ||
            g.name.toLowerCase().contains(suche) ||
            g.ort.toLowerCase().contains(suche) ||
            g.typ.name.toLowerCase().contains(suche))
        .toList()
      ..sort((a, b) => kmVonBraunau(a).compareTo(kmVonBraunau(b)));
    final karte = fischerkarten.firstWhere((k) => k.land == land);

    return Scaffold(
      appBar: AppBar(title: const Text('Wo darf ich fischen?')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const BundeslandWahl(),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Gewässer, Ort oder "Bach" suchen',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _suche = v.trim()),
          ),
          const SizedBox(height: 8),
          if (_suche.isEmpty)
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Was brauche ich zum Fischen?'),
                subtitle: Text(land.name),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                children: [
                  for (final p in karte.punkte)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('•  '),
                          Expanded(child: Text(p)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          if (liste.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Nichts gefunden.', textAlign: TextAlign.center),
            ),
          for (final g in liste) _GewaesserKachel(g),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => meldenDialog(
              context,
              typ: 'neues-gewaesser',
              bezug: land.name,
              titel: 'Gewässer vorschlagen',
              hinweis: 'Name, Ort, Preise der Tageskarte und wo man sie '
                  'bekommt.',
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Gewässer fehlt? Vorschlagen'),
          ),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Alle Preise und Regeln ohne Gewähr. Vor dem Fischen immer die '
            'Lizenzbedingungen des Reviers lesen.',
          ),
        ],
      ),
    );
  }
}

class _GewaesserKachel extends StatelessWidget {
  const _GewaesserKachel(this.g);

  final Gewaesser g;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final tag = g.preise.isEmpty ? null : g.preise.first;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: farben.primaryContainer,
          child: Icon(
            switch (g.typ) {
              GewaesserTyp.fluss || GewaesserTyp.bach => Icons.waves,
              GewaesserTyp.teich => Icons.water_drop,
              _ => Icons.water,
            },
            color: farben.onPrimaryContainer,
          ),
        ),
        title: Text(g.name),
        subtitle: Text('${g.typ.name} · ${g.ort} · ${kmVonBraunau(g)} km'),
        trailing: Text(
          tag?.euroText ?? '?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
        ),
      ),
    );
  }
}

class GewaesserDetail extends StatelessWidget {
  const GewaesserDetail(this.g, {super.key});

  final Gewaesser g;

  Future<void> _navigation() async {
    final p = g.position;
    final uri = Uri.parse('geo:${p.latitude},${p.longitude}?q='
        '${p.latitude},${p.longitude}(${Uri.encodeComponent(g.name)})');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final heute = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(g.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('${g.typ.name} · ${g.ort} · ${g.land.name}',
              style: text.labelLarge),
          const SizedBox(height: 8),
          Text(g.beschreibung),
          if (g.hinweis != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(g.hinweis!, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 12),
          WetterKarte(g),
          const SizedBox(height: 16),
          Text('Preise', style: text.titleMedium),
          if (g.preise.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Noch nicht bekannt – bitte beim Revier erfragen.'),
            )
          else
            for (final p in g.preise)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(p.art),
                trailing: Text(p.euroText, style: text.titleMedium),
              ),
          if (KontoScope.of(context) != null) _CommunityPreise(g),
          TextButton.icon(
            onPressed: () => preisErgaenzen(context, g),
            icon: const Icon(Icons.add_card),
            label: const Text('Preis ergänzen'),
          ),
          const SizedBox(height: 8),
          Text('Karten bekommst du hier', style: text.titleMedium),
          const SizedBox(height: 4),
          Text(g.kartenverkauf),
          const SizedBox(height: 16),
          Text('Fischarten (${g.land.name})', style: text.titleMedium),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final id in g.fischarten)
                if (fischById(id) case final f?)
                  Chip(
                    avatar: f.regel(g.land).istGeschont(heute) == true
                        ? const Icon(Icons.block, size: 18)
                        : null,
                    label: Text(f.name),
                  ),
            ],
          ),
          const SizedBox(height: 4),
          Text('⛔ = heute Schonzeit', style: text.bodySmall),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _navigation,
            icon: const Icon(Icons.directions),
            label: const Text('Hinfahren'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => meldenDialog(
              context,
              typ: 'gewaesser-korrektur',
              bezug: g.id,
              titel: 'Info zu ${g.name} melden',
              hinweis: 'Was stimmt nicht oder fehlt? Z. B. neuer Preis.',
            ),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Falsche oder fehlende Info melden'),
          ),
          const SizedBox(height: 16),
          Text('Quelle: ${g.quelle} · Stand: ${g.stand}', style: text.bodySmall),
        ],
      ),
    );
  }
}

class WetterKarte extends StatefulWidget {
  const WetterKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<WetterKarte> createState() => _WetterKarteState();
}

class _WetterKarteState extends State<WetterKarte> {
  late final Future<Wetter> _wetter = wetterLaden(widget.g.position);

  String _uhr(DateTime? t) => t == null
      ? '–'
      : '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final phase = mondphase(DateTime.now());
    final (mondIcon, mondName) = mondText(phase);
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<Wetter>(
          future: _wetter,
          builder: (context, snap) {
            final w = snap.data;
            final mond = Text(
              '$mondIcon $mondName (${mondBeleuchtung(phase)} %)',
            );
            if (snap.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('Wetter gerade nicht verfügbar.'), mond],
              );
            }
            if (w == null) {
              return const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final (icon, beschreibung) = w.beschreibung;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${w.temperatur.toStringAsFixed(0)} °C · '
                            '$beschreibung',
                            style: text.titleMedium,
                          ),
                          Text(
                            'Wind ${w.wind.toStringAsFixed(0)} km/h · '
                            '${w.luftdruck.toStringAsFixed(0)} hPa',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('🌅 ${_uhr(w.sonnenaufgang)}   🌇 '
                    '${_uhr(w.sonnenuntergang)}'),
                mond,
                const SizedBox(height: 4),
                Text('Wetter: Open-Meteo', style: text.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Von Nutzern vorgeschlagene und vom Admin geprüfte Preise.
class _CommunityPreise extends StatefulWidget {
  const _CommunityPreise(this.g);

  final Gewaesser g;

  @override
  State<_CommunityPreise> createState() => _CommunityPreiseState();
}

class _CommunityPreiseState extends State<_CommunityPreise> {
  late final _stream = fangDienst.gepruefteCommunityPreise(widget.g.id);

  @override
  Widget build(BuildContext context) {
    final admin = KontoScope.of(context)?.istAdmin ?? false;
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<CommunityPreis>>(
      stream: _stream,
      builder: (context, snap) {
        final preise = snap.data ?? const <CommunityPreis>[];
        if (preise.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('✓ Von der Community ergänzt (geprüft)',
                style: text.labelLarge),
            for (final p in preise)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(p.art),
                subtitle: Text('${at(p.von)} · ${datumText(p.datum)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(Preis(p.art, p.euro).euroText,
                        style: text.titleMedium),
                    if (admin)
                      IconButton(
                        tooltip: 'Entfernen',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => fangDienst.gepruefterPreisEntfernen(
                            widget.g.id, p),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Dialog zum Vorschlagen eines Preises. Der Admin prüft ihn vor dem
/// Veröffentlichen.
Future<void> preisErgaenzen(BuildContext context, Gewaesser g) async {
  final konto = KontoScope.of(context);
  if (konto == null) {
    meldung(context, 'Geht erst, wenn die Online-Funktionen aktiv sind.');
    return;
  }
  if (!konto.angemeldet) {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const KontoScreen()));
    return;
  }
  const arten = ['Tageskarte', 'Wochenkarte', 'Monatskarte', 'Jahreskarte',
    'Nachtkarte', 'Tageskarte Jugend', 'Tageskarte Mitglieder'];
  var art = arten.first;
  final euro = TextEditingController();
  final notiz = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('Preis für ${g.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: art,
                decoration: const InputDecoration(labelText: 'Karte'),
                items: [
                  for (final a in arten)
                    DropdownMenuItem(value: a, child: Text(a)),
                ],
                onChanged: (v) => setState(() => art = v!),
              ),
              TextField(
                controller: euro,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Preis', suffixText: '€'),
              ),
              TextField(
                controller: notiz,
                maxLength: 300,
                decoration: const InputDecoration(
                  labelText: 'Woher weißt du das? (optional)',
                  hintText: 'z. B. Aushang am Gewässer, Website, Jahr',
                ),
              ),
              const Text('Ein Admin prüft den Preis, bevor er für alle '
                  'sichtbar wird.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Vorschlagen'),
          ),
        ],
      ),
    ),
  );
  final betrag = double.tryParse(euro.text.replaceAll(',', '.').trim());
  if (ok != true) return;
  if (betrag == null || betrag < 0 || betrag > 5000) {
    if (context.mounted) meldung(context, 'Bitte einen gültigen Preis eingeben.');
    return;
  }
  try {
    await fangDienst.preisVorschlagen(
      uid: konto.uid!,
      nutzerName: konto.name ?? '',
      gewaesserId: g.id,
      gewaesserName: g.name,
      art: art,
      euro: betrag,
      notiz: notiz.text.trim(),
    );
    if (context.mounted) {
      meldung(context, 'Danke! Der Preis wird geprüft und dann freigeschaltet.');
    }
  } catch (_) {
    if (context.mounted) meldung(context, 'Senden fehlgeschlagen.');
  }
}
