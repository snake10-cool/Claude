import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/fische.dart';
import '../data/gewaesser.dart';
import '../main.dart';
import '../models/fang.dart';
import '../models/gewaesser.dart';
import '../services/alle_gewaesser.dart';
import '../services/fang_dienst.dart';
import '../services/speicher.dart';
import '../services/beisszeit.dart';
import '../services/sonne.dart';
import '../services/wetter.dart';
import 'heimat_screen.dart';
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

enum _Sortierung { groesse, name, entfernung, heimat }

class _GewaesserScreenState extends State<GewaesserScreen> {
  String _suche = '';
  GewaesserTyp? _typ;
  _Sortierung? _sortierung;

  @override
  void initState() {
    super.initState();
    alleGewaesser.addListener(_neu);
  }

  @override
  void dispose() {
    alleGewaesser.removeListener(_neu);
    super.dispose();
  }

  void _neu() => setState(() {});

  List<Gewaesser> _gefiltert(Speicher speicher) {
    final suche = _suche.toLowerCase();
    final liste = alleGewaesser.liste.where((g) {
      if (g.land != speicher.bundesland) return false;
      if (speicher.bezirk.isNotEmpty && g.bezirk != speicher.bezirk) {
        return false;
      }
      if (speicher.gemeinde.isNotEmpty && !g.liegtIn(speicher.gemeinde)) {
        return false;
      }
      if (_typ != null &&
          g.typ != _typ &&
          !(_typ == GewaesserTyp.teich && g.typ == GewaesserTyp.moor)) {
        return false;
      }
      return suche.isEmpty ||
          g.name.toLowerCase().contains(suche) ||
          g.ort.toLowerCase().contains(suche);
    }).toList();
    final sortierung = _sortierungVon(speicher);
    final heimat = speicher.heimatLat == null
        ? null
        : LatLng(speicher.heimatLat!, speicher.heimatLon!);
    const distanz = Distance();
    double km(Gewaesser g) =>
        heimat == null ? 0 : distanz.as(LengthUnit.Meter, heimat, g.position);
    int vergleich(Gewaesser a, Gewaesser b) => switch (sortierung) {
          _Sortierung.heimat => km(a).compareTo(km(b)),
          _Sortierung.name => deutschSortieren(a.name, b.name),
          _Sortierung.entfernung => kmVonBraunau(a).compareTo(kmVonBraunau(b)),
          _Sortierung.groesse => _gewicht(b).compareTo(_gewicht(a)),
        };
    // Geprüfte Gewässer mit Lizenzinfos immer zuerst.
    liste.sort((a, b) => a.ausOsm == b.ausOsm
        ? vergleich(a, b)
        : (a.ausOsm ? 1 : -1));
    return liste;
  }

  _Sortierung _sortierungVon(Speicher speicher) =>
      _sortierung ??
      (speicher.heimat.isNotEmpty ? _Sortierung.heimat : _Sortierung.groesse);

  /// Seen zählen pro Hektar mehr als Bäche pro Kilometer.
  static double _gewicht(Gewaesser g) {
    final z = g.groesse ?? 0;
    return switch (g.typ) {
      GewaesserTyp.see || GewaesserTyp.teich || GewaesserTyp.moor => z * 2,
      GewaesserTyp.fluss => z * 3,
      _ => z,
    };
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final land = speicher.bundesland;
    final liste = _gefiltert(speicher);
    final karte = fischerkarten.firstWhere((k) => k.land == land);
    final bezirke = alleGewaesser.bezirke[land] ?? const <String>[];
    final gemeinden = speicher.bezirk.isEmpty
        ? const <String>[]
        : alleGewaesser.gemeindenVon(land, speicher.bezirk);
    final text = Theme.of(context).textTheme;

    final kopf = <Widget>[
      const BundeslandWahl(),
      const SizedBox(height: 8),
      if (bezirke.isNotEmpty)
        LayoutBuilder(
          builder: (context, c) {
            final breite = (c.maxWidth - 8) / 2;
            return Row(
              children: [
                DropdownMenu<String>(
                  key: ValueKey('bezirk-${land.name}-${speicher.bezirk}'),
                  width: breite,
                  initialSelection: speicher.bezirk,
                  label: const Text('Bezirk'),
                  enableFilter: true,
                  requestFocusOnTap: true,
                  menuHeight: 360,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'Alle Bezirke'),
                    for (final b in bezirke)
                      DropdownMenuEntry(value: b, label: b),
                  ],
                  onSelected: (b) {
                    if (b != null) speicher.ortSetzen(bezirk: b);
                  },
                ),
                const SizedBox(width: 8),
                DropdownMenu<String>(
                  key: ValueKey('ort-${speicher.bezirk}-${speicher.gemeinde}'),
                  width: breite,
                  enabled: gemeinden.isNotEmpty,
                  initialSelection: speicher.gemeinde,
                  label: const Text('Ort'),
                  enableFilter: true,
                  requestFocusOnTap: true,
                  menuHeight: 360,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: '', label: 'Alle Orte'),
                    for (final g in gemeinden)
                      DropdownMenuEntry(value: g, label: g),
                  ],
                  onSelected: (g) {
                    if (g != null) {
                      speicher.ortSetzen(bezirk: speicher.bezirk, gemeinde: g);
                    }
                  },
                ),
              ],
            );
          },
        ),
      const SizedBox(height: 8),
      TextField(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Gewässer suchen',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (v) => setState(() => _suche = v.trim()),
      ),
      const SizedBox(height: 4),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final t in [
              null,
              GewaesserTyp.fluss,
              GewaesserTyp.bach,
              GewaesserTyp.see,
              GewaesserTyp.teich,
              GewaesserTyp.kanal,
            ])
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(t?.name ?? 'Alle'),
                  selected: _typ == t,
                  onSelected: (_) => setState(() => _typ = t),
                ),
              ),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Text(
              alleGewaesser.geladen
                  ? '${liste.length} Gewässer'
                  : 'Lade alle Gewässer …',
              style: text.labelLarge,
            ),
          ),
          PopupMenuButton<_Sortierung>(
            tooltip: 'Sortieren',
            initialValue: _sortierungVon(speicher),
            onSelected: (s) async {
              if (s == _Sortierung.heimat && speicher.heimat.isEmpty) {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const HeimatScreen()));
              }
              setState(() => _sortierung = s);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: _Sortierung.heimat,
                  child: Text(speicher.heimat.isEmpty
                      ? 'Nähe zu meinem Ort …'
                      : 'Nähe zu ${speicher.heimatName}')),
              const PopupMenuItem(
                  value: _Sortierung.groesse, child: Text('Größte zuerst')),
              const PopupMenuItem(
                  value: _Sortierung.name, child: Text('Name A–Z')),
              const PopupMenuItem(
                  value: _Sortierung.entfernung,
                  child: Text('Nähe zu Braunau')),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.sort),
            ),
          ),
        ],
      ),
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
      if (!alleGewaesser.geladen)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        )
      else if (liste.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text('Nichts gefunden.', textAlign: TextAlign.center),
        ),
    ];

    final fuss = <Widget>[
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => meldenDialog(
          context,
          typ: 'neues-gewaesser',
          bezug: '${land.name} ${speicher.bezirk} ${speicher.gemeinde}',
          titel: 'Gewässer vorschlagen',
          hinweis: 'Name, Ort, Preise der Tageskarte und wo man sie '
              'bekommt.',
        ),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Gewässer fehlt? Vorschlagen'),
      ),
      const SizedBox(height: 8),
      const HinweisKarte(
        '✅ = geprüft mit Lizenz- und Preisinfos. Alle anderen Gewässer '
        'stammen aus OpenStreetMap – dort fehlen Lizenz und Preis noch. '
        'Alles ohne Gewähr: Vor dem Fischen immer die Lizenzbedingungen '
        'des Reviers lesen.',
      ),
      if (alleGewaesser.stand.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Gewässerdaten © OpenStreetMap-Mitwirkende (ODbL), Stand '
            '${alleGewaesser.stand}',
            style: text.bodySmall,
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Wo darf ich fischen?')),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            sliver: SliverList.list(children: kopf),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList.builder(
              itemCount: liste.length,
              itemBuilder: (_, i) => _GewaesserKachel(liste[i],
                  heimat: speicher.heimatLat == null
                      ? null
                      : LatLng(speicher.heimatLat!, speicher.heimatLon!)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            sliver: SliverList.list(children: fuss),
          ),
        ],
      ),
    );
  }
}

class _GewaesserKachel extends StatelessWidget {
  const _GewaesserKachel(this.g, {this.heimat});

  final Gewaesser g;
  final LatLng? heimat;

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final tag = g.preise.isEmpty ? null : g.preise.first;
    final groesse = g.groesse == null
        ? ''
        : g.typ.fliesst
            ? ' · ${_zahl(g.groesse!)} km'
            : ' · ${_zahl(g.groesse!)} ha';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              g.ausOsm ? farben.surfaceContainerHighest : farben.primaryContainer,
          child: Icon(
            switch (g.typ) {
              GewaesserTyp.fluss ||
              GewaesserTyp.bach ||
              GewaesserTyp.kanal =>
                Icons.waves,
              GewaesserTyp.teich => Icons.water_drop,
              _ => Icons.water,
            },
            color: g.ausOsm
                ? farben.onSurfaceVariant
                : farben.onPrimaryContainer,
          ),
        ),
        title: Text(g.ausOsm ? g.name : '✅ ${g.name}'),
        subtitle: Text(
          '${g.typ.name}$groesse · ${g.ort}'
          '${heimat == null ? '' : ' · ${const Distance().as(LengthUnit.Kilometer, heimat!, g.position).round()} km'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: g.ausOsm
            ? null
            : Text(
                tag?.euroText ?? '?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GewaesserDetail(g)),
        ),
      ),
    );
  }

  static String _zahl(double z) =>
      (z >= 10 ? z.toStringAsFixed(0) : z.toStringAsFixed(1))
          .replaceAll('.', ',');
}

class GewaesserDetail extends StatelessWidget {
  const GewaesserDetail(this.g, {super.key});

  final Gewaesser g;

  Future<void> _navigation() async {
    final p = g.position;
    // Öffnet am Handy die Karten-App, am PC den Browser.
    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '${p.latitude},${p.longitude}',
    });
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
          Text(
              [
                g.typ.name,
                g.ort,
                if (g.bezirk.isNotEmpty && g.bezirk != g.ort) 'Bezirk ${g.bezirk}',
                g.land.name,
              ].join(' · '),
              style: text.labelLarge),
          const SizedBox(height: 8),
          Text(g.beschreibung),
          if (g.hinweis != null) ...[
            const SizedBox(height: 12),
            HinweisKarte(g.hinweis!, icon: Icons.warning_amber),
          ],
          const SizedBox(height: 12),
          WetterKarte(g),
          BeisszeitKarte(g),
          DaemmerungKarte(g),
          if (KontoScope.of(context) != null) WasBeisstKarte(g),
          if (g.typ.fliesst) AbflussKarte(g),
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
          if (g.lizenzUrl == null && landesverbaende[g.land] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonalIcon(
                onPressed: () => launchUrl(
                    Uri.parse(landesverbaende[g.land]!.$2),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.open_in_new),
                label: Text(landesverbaende[g.land]!.$1),
              ),
            ),
          if (g.lizenzUrl != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: FilledButton.tonalIcon(
                onPressed: () => launchUrl(Uri.parse(g.lizenzUrl!),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('Lizenz kaufen / Infos (Website)'),
              ),
            ),
          const SizedBox(height: 16),
          Text('Fischarten (${g.land.name})', style: text.titleMedium),
          Text('${g.fischQuelle.zeichen} ${g.fischQuelle.text}'
              '${g.fischQuelle == FischQuelle.typisch ? ' – nicht sicher' : ''}',
              style: text.bodySmall),
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
          if (KontoScope.of(context) != null) ...[
            const SizedBox(height: 12),
            GepruefteInfosKarte(g),
            InfoKnoepfe(g),
          ],
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
          if (KontoScope.of(context) != null) BewertungenKarte(g),
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

class BeisszeitKarte extends StatefulWidget {
  const BeisszeitKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<BeisszeitKarte> createState() => _BeisszeitKarteState();
}

class _BeisszeitKarteState extends State<BeisszeitKarte> {
  late final Future<List<BeissTag>> _tage =
      stundenWetter(widget.g.position).then(beisszeit);

  static const _wochentage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<BeissTag>>(
          future: _tage,
          builder: (context, snap) {
            if (snap.hasError) {
              return const Text('Beißzeit gerade nicht verfügbar.');
            }
            if (!snap.hasData) {
              return const SizedBox(
                  height: 40, child: Center(child: CircularProgressIndicator()));
            }
            final tage = snap.data!;
            if (tage.isEmpty) return const Text('Keine Daten.');
            final heute = tage.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Titel('🎯 Beißzeit-Prognose'),
                const SizedBox(height: 6),
                Text('Heute: ${heute.fische}  (${heute.punkte}/5)',
                    style: Theme.of(context).textTheme.titleLarge),
                for (final g in heute.gruende) Text('• $g'),
                const Text('• Beste Zeiten: Morgen- und Abenddämmerung'),
                const SizedBox(height: 8),
                const Row(children: [
                  Text('Nächste Tage  '),
                  PremiumMarke(),
                ]),
                const SizedBox(height: 4),
                Row(
                  children: [
                    for (final t in tage.skip(1))
                      Expanded(
                        child: Column(
                          children: [
                            Text(_wochentage[t.tag.weekday - 1]),
                            Text(t.fische, style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Faustregel aus Luftdruck, Mond, Wolken und Wind – '
                    'keine Garantie 😉',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AbflussKarte extends StatefulWidget {
  const AbflussKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<AbflussKarte> createState() => _AbflussKarteState();
}

class _AbflussKarteState extends State<AbflussKarte> {
  late final Future<Abfluss> _abfluss = abflussLaden(widget.g.position);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<Abfluss>(
          future: _abfluss,
          builder: (context, snap) {
            final a = snap.data;
            final link = TextButton.icon(
              onPressed: () => launchUrl(Uri.parse('https://ehyd.gv.at'),
                  mode: LaunchMode.externalApplication),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Offizielle Pegel (eHYD)'),
            );
            if (snap.hasError || (a != null && a.werte.isEmpty)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('💧 Abfluss gerade nicht verfügbar.'), link],
              );
            }
            if (a == null) {
              return const SizedBox(
                  height: 40, child: Center(child: CircularProgressIndicator()));
            }
            // Index von heute: 7 Tage Vergangenheit, dann heute.
            final heuteIdx = a.werte.length > 7 ? 7 : a.werte.length - 1;
            final heute = a.werte[heuteIdx];
            final gestern = heuteIdx > 0 ? a.werte[heuteIdx - 1] : heute;
            final trend = heute > gestern * 1.05
                ? '↗ steigend'
                : heute < gestern * 0.95
                    ? '↘ fallend'
                    : '→ gleichbleibend';
            final verhaeltnis = a.mittel == null || a.mittel == 0
                ? null
                : heute / a.mittel!;
            final hoch = a.werte.reduce((x, y) => x > y ? x : y);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Titel('💧 Wasserführung'),
                const SizedBox(height: 6),
                Text('Heute ca. ${heute.toStringAsFixed(heute < 10 ? 1 : 0)} m³/s  $trend',
                    style: text.titleMedium),
                if (verhaeltnis != null)
                  Text(verhaeltnis > 1.5
                      ? 'Deutlich mehr Wasser als üblich – Vorsicht, oft trüb.'
                      : verhaeltnis < 0.6
                          ? 'Weniger Wasser als üblich.'
                          : 'Etwa normale Wasserführung.'),
                const SizedBox(height: 8),
                const Row(children: [Text('Verlauf 14 Tage  '), PremiumMarke()]),
                const SizedBox(height: 4),
                SizedBox(
                  height: 50,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < a.werte.length; i++)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            height: hoch == 0 ? 2 : 4 + 46 * a.werte[i] / hoch,
                            color: i == heuteIdx
                                ? Theme.of(context).colorScheme.primary
                                : i > heuteIdx
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.35)
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.6),
                          ),
                        ),
                    ],
                  ),
                ),
                Text('Links vergangene Woche, rechts Vorhersage. Modelldaten '
                    '(Open-Meteo/GloFAS), bei kleinen Bächen ungenau.',
                    style: text.bodySmall),
                link,
              ],
            );
          },
        ),
      ),
    );
  }
}

class DaemmerungKarte extends StatelessWidget {
  const DaemmerungKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  Widget build(BuildContext context) {
    final z = sonnenZeiten(DateTime.now(), g.position.latitude,
        g.position.longitude);
    String u(DateTime? t) => t == null ? '–' : uhrText(t);
    Widget zeile(String icon, String text, String zeit) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            SizedBox(width: 28, child: Text(icon)),
            Expanded(child: Text(text)),
            Text(zeit, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('🌅 Dämmerung & Sonne heute', premium: true),
            const SizedBox(height: 6),
            zeile('🌌', 'Morgendämmerung beginnt', u(z.morgendaemmerung)),
            zeile('🌅', 'Sonnenaufgang', u(z.aufgang)),
            zeile('📸', 'Goldene Stunde bis', u(z.goldeneStundeMorgenEnde)),
            zeile('📸', 'Goldene Stunde ab', u(z.goldeneStundeAbendBeginn)),
            zeile('🌇', 'Sonnenuntergang', u(z.untergang)),
            zeile('🌌', 'Abenddämmerung endet', u(z.abenddaemmerung)),
            const SizedBox(height: 4),
            Text('Die Dämmerung ist meist die beste Beißzeit – vor allem für '
                'Zander, Hecht und Forelle.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class WasBeisstKarte extends StatefulWidget {
  const WasBeisstKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<WasBeisstKarte> createState() => _WasBeisstKarteState();
}

class _WasBeisstKarteState extends State<WasBeisstKarte> {
  late final _faenge = fangDienst.faengeAn(widget.g.anzeigeName);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FutureBuilder<List<Fang>>(
          future: _faenge,
          builder: (context, snap) {
            if (snap.hasError) return const Text('🎣 Fänge gerade nicht verfügbar.');
            if (!snap.hasData) {
              return const SizedBox(
                  height: 40, child: Center(child: CircularProgressIndicator()));
            }
            final grenze = DateTime.now().subtract(const Duration(days: 14));
            final neu = snap.data!.where((f) => f.datum.isAfter(grenze)).toList();
            final proArt = <String, int>{};
            final koeder = <String, int>{};
            for (final f in neu) {
              proArt[f.fischId] = (proArt[f.fischId] ?? 0) + 1;
              if (f.koeder.isNotEmpty) {
                koeder[f.koeder] = (koeder[f.koeder] ?? 0) + 1;
              }
            }
            String top(Map<String, int> m, String Function(String) name) =>
                (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
                    .take(3)
                    .map((e) => '${name(e.key)} (${e.value})')
                    .join(', ');
            final letzter = snap.data!.isEmpty ? null : snap.data!.first;
            final alleArten = <String, int>{};
            for (final f in snap.data!) {
              alleArten[f.fischId] = (alleArten[f.fischId] ?? 0) + 1;
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Titel('🎣 Was beißt gerade?'),
                const SizedBox(height: 6),
                if (letzter == null)
                  const Text('Hier wurde noch nichts geteilt – sei die oder '
                      'der Erste!')
                else
                  Text('Letzter Fang: ${fischById(letzter.fischId)?.name ?? ''}'
                      '${letzter.laengeCm == null ? '' : ', ${letzter.laengeCm!.toStringAsFixed(0)} cm'}'
                      ' am ${datumText(letzter.datum)} von ${at(letzter.nutzerName)}'),
                if (neu.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Row(children: [
                    Text('Letzte 14 Tage  '),
                    PremiumMarke(),
                  ]),
                  Text('${neu.length} Fänge · Fische: '
                      '${top(proArt, (id) => fischById(id)?.name ?? id)}'),
                  if (koeder.isNotEmpty) Text('Köder: ${top(koeder, (k) => k)}'),
                ],
                if (alleArten.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Hier schon gefangen:'),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final e in alleArten.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value)))
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                              '🎣 ${fischById(e.key)?.name ?? e.key} (${e.value})'),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text('Aus öffentlich geteilten Fängen der Community.',
                    style: text.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

class BewertungenKarte extends StatefulWidget {
  const BewertungenKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<BewertungenKarte> createState() => _BewertungenKarteState();
}

class _BewertungenKarteState extends State<BewertungenKarte> {
  late final _stream = fangDienst.bewertungen(widget.g.id);

  Future<void> _bewerten(Bewertung? alt) async {
    final konto = KontoScope.of(context)!;
    if (!konto.angemeldet) return;
    var sterne = alt?.sterne ?? 5;
    final tipp = TextEditingController(text: alt?.tipp ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('${widget.g.name} bewerten'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      onPressed: () => setState(() => sterne = i),
                      icon: Icon(i <= sterne ? Icons.star : Icons.star_border,
                          color: Colors.amber.shade700, size: 32),
                    ),
                ],
              ),
              TextField(
                controller: tipp,
                maxLines: 3,
                maxLength: 300,
                decoration: const InputDecoration(
                  hintText: 'Tipp für andere, z. B. Parkplatz, beste Stelle, '
                      'Köder …',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await fangDienst.bewerten(
        widget.g.id, konto.uid!, konto.name ?? '', sterne, tipp.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final text = Theme.of(context).textTheme;
    return StreamBuilder<List<Bewertung>>(
      stream: _stream,
      builder: (context, snap) {
        final liste = snap.data ?? const <Bewertung>[];
        final eigene = liste.where((b) => b.uid == konto.uid).firstOrNull;
        final schnitt = liste.isEmpty
            ? 0.0
            : liste.map((b) => b.sterne).reduce((a, b) => a + b) / liste.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('⭐ Bewertungen', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(liste.isEmpty
                ? 'Noch keine Bewertungen.'
                : '${schnitt.toStringAsFixed(1).replaceAll('.', ',')} von 5 '
                    'Sternen (${liste.length})'),
            TextButton.icon(
              onPressed: () => _bewerten(eigene),
              icon: const Icon(Icons.rate_review_outlined),
              label: Text(eigene == null ? 'Bewerten' : 'Meine Bewertung ändern'),
            ),
            for (final b in liste.take(20))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${'★' * b.sterne}${'☆' * (5 - b.sterne)}  '
                    '${at(b.nutzerName)}'),
                subtitle: b.tipp.isEmpty ? null : Text(b.tipp),
                trailing: b.uid == konto.uid || konto.istAdmin
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () =>
                            fangDienst.bewertungLoeschen(widget.g.id, b.uid),
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }
}


/// Von Anglern ergänzte und vom Administrator geprüfte Infos.
class GepruefteInfosKarte extends StatefulWidget {
  const GepruefteInfosKarte(this.g, {super.key});

  final Gewaesser g;

  @override
  State<GepruefteInfosKarte> createState() => _GepruefteInfosKarteState();
}

class _GepruefteInfosKarteState extends State<GepruefteInfosKarte> {
  late final _infos = fangDienst.gepruefteInfos(widget.g.id);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final admin = KontoScope.of(context)?.istAdmin ?? false;
    return StreamBuilder<GepruefteInfos>(
      stream: _infos,
      builder: (context, snap) {
        final infos = snap.data;
        if (infos == null || infos.leer) return const SizedBox.shrink();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                        child: Titel('🙋 Von Anglern ergänzt (geprüft)')),
                    if (admin)
                      IconButton(
                        tooltip: 'Alle entfernen',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            fangDienst.gepruefteInfosLoeschen(widget.g.id),
                      ),
                  ],
                ),
                if (infos.fische.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final id in infos.fische)
                        Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text('✅ ${fischById(id)?.name ?? id}'),
                        ),
                    ],
                  ),
                ],
                for (final e in infos.eintraege) ...[
                  const Divider(),
                  if (e['verkauf'] case final String v) Text('🎫 $v'),
                  if (e['text'] case final String t) Text(t),
                  if (e['url'] case final String u)
                    TextButton.icon(
                      onPressed: () => launchUrl(Uri.parse(u),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: Text(u, overflow: TextOverflow.ellipsis),
                    ),
                  Text('von ${at(e['von'] as String? ?? '')}',
                      style: text.bodySmall),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "Mehr Infos wünschen" und "Infos ergänzen".
class InfoKnoepfe extends StatelessWidget {
  const InfoKnoepfe(this.g, {super.key});

  final Gewaesser g;

  Future<bool> _angemeldet(BuildContext context) async {
    final konto = KontoScope.of(context);
    if (konto?.angemeldet ?? false) return true;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const KontoScreen()));
    return false;
  }

  Future<void> _wuenschen(BuildContext context) async {
    if (!await _angemeldet(context) || !context.mounted) return;
    final konto = KontoScope.of(context)!;
    try {
      await fangDienst.infosWuenschen(
        uid: konto.uid!,
        nutzerName: konto.name ?? '',
        gewaesserId: g.id,
        gewaesserName: '${g.anzeigeName}, ${g.bezirk.isEmpty ? g.land.name : 'Bezirk ${g.bezirk}'}',
      );
      if (context.mounted) {
        meldung(context, 'Danke! Dein Wunsch ist beim Team angekommen.');
      }
    } catch (_) {
      if (context.mounted) meldung(context, 'Senden fehlgeschlagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (g.ausOsm)
            const HinweisKarte(
              'Zu diesem Gewässer fehlen noch sichere Infos. Weißt du mehr? '
              'Ergänze es – oder wünsch dir, dass wir nachforschen.',
              icon: Icons.help_outline,
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _wuenschen(context),
                  icon: const Icon(Icons.record_voice_over_outlined),
                  label: const Text('Mehr Infos wünschen'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    if (!await _angemeldet(context) || !context.mounted) return;
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => InfosErgaenzenScreen(g)));
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Infos ergänzen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formular: Fischarten, Kartenverkauf, Website und Notiz einreichen.
class InfosErgaenzenScreen extends StatefulWidget {
  const InfosErgaenzenScreen(this.g, {super.key});

  final Gewaesser g;

  @override
  State<InfosErgaenzenScreen> createState() => _InfosErgaenzenScreenState();
}

class _InfosErgaenzenScreenState extends State<InfosErgaenzenScreen> {
  final _fische = <String>{};
  final _verkauf = TextEditingController();
  final _url = TextEditingController();
  final _text = TextEditingController();
  String _suche = '';
  bool _sendet = false;

  @override
  void dispose() {
    _verkauf.dispose();
    _url.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _senden() async {
    final konto = KontoScope.of(context)!;
    var url = _url.text.trim();
    if (url.isNotEmpty && !url.startsWith('http')) url = 'https://$url';
    if (_fische.isEmpty &&
        _verkauf.text.trim().isEmpty &&
        url.isEmpty &&
        _text.text.trim().isEmpty) {
      meldung(context, 'Bitte mindestens eine Info eintragen.');
      return;
    }
    setState(() => _sendet = true);
    try {
      await fangDienst.infosVorschlagen(
        uid: konto.uid!,
        nutzerName: konto.name ?? '',
        gewaesserId: widget.g.id,
        gewaesserName: widget.g.anzeigeName,
        fische: _fische.toList(),
        verkauf: _verkauf.text.trim(),
        url: url,
        text: _text.text.trim(),
      );
      if (!mounted) return;
      meldung(context, 'Danke! Nach der Prüfung sehen es alle.');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) meldung(context, 'Senden fehlgeschlagen.');
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final suche = _suche.toLowerCase();
    final auswahl = fische
        .where((f) => !f.ausgestorben)
        .where((f) =>
            _fische.contains(f.id) || f.name.toLowerCase().contains(suche))
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text('Infos: ${widget.g.name}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Welche Fische gibt es hier?', style: text.titleMedium),
          const SizedBox(height: 6),
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Fisch suchen',
              isDense: true,
            ),
            onChanged: (v) => setState(() => _suche = v.trim()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final f in auswahl)
                FilterChip(
                  label: Text(f.name),
                  selected: _fische.contains(f.id),
                  onSelected: (an) => setState(
                      () => an ? _fische.add(f.id) : _fische.remove(f.id)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _verkauf,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Wo gibt es die Lizenz / Tageskarte?',
              hintText: 'z. B. Gasthaus Post, Verein XY, hejfish',
            ),
          ),
          TextField(
            controller: _url,
            maxLength: 300,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Website (optional)'),
          ),
          TextField(
            controller: _text,
            maxLength: 1000,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Sonstiges (Regeln, Tipps, Preise …)',
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _sendet ? null : _senden,
            icon: const Icon(Icons.send),
            label: const Text('Zur Prüfung schicken'),
          ),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Das Team prüft deine Angaben, bevor sie für alle sichtbar werden. '
            'Preise kannst du auch direkt beim Gewässer unter "Preis ergänzen" '
            'eintragen.',
          ),
        ],
      ),
    );
  }
}
