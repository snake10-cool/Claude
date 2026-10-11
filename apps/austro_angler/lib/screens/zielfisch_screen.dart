import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../data/koeder.dart';
import '../main.dart';
import '../models/fisch.dart';
import '../models/gewaesser.dart';
import '../services/alle_gewaesser.dart';
import '../services/beisszeit.dart';
import '../services/darf_ich.dart';
import '../services/wetter.dart';
import 'darf_ich_screen.dart';
import 'gewaesser_screen.dart';

/// „Ich will Hecht“ → wo, wann, womit.
class ZielfischScreen extends StatefulWidget {
  const ZielfischScreen({super.key, this.fischId});

  final String? fischId;

  @override
  State<ZielfischScreen> createState() => _ZielfischScreenState();
}

class _ZielfischScreenState extends State<ZielfischScreen> {
  Fisch? _fisch;
  Future<List<BeissTag>>? _beiss;
  Gewaesser? _beissOrt;

  @override
  void initState() {
    super.initState();
    alleGewaesser.laden();
    if (widget.fischId != null) {
      _fisch = fische.where((f) => f.id == widget.fischId).firstOrNull;
    }
  }

  void _waehlen(Fisch f) => setState(() {
        _fisch = f;
        _beiss = null;
        _beissOrt = null;
      });

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Zielfisch')),
      body: ListenableBuilder(
        listenable: alleGewaesser,
        builder: (context, _) {
          final f = _fisch;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Welchen Fisch willst du fangen?',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _Auswahl(
                gewaehlt: f,
                lieblinge: speicher.lieblingsfische,
                onWahl: _waehlen,
              ),
              if (f != null) ...[
                const SizedBox(height: 16),
                _Heute(f),
                const SizedBox(height: 8),
                _Koeder(f),
                const SizedBox(height: 8),
                ..._gewaesser(context, f),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Widget> _gewaesser(BuildContext context, Fisch f) {
    final speicher = SpeicherScope.of(context);
    final heimat = speicher.heimatLat == null
        ? null
        : LatLng(speicher.heimatLat!, speicher.heimatLon!);
    const distanz = Distance();
    double km(Gewaesser g) => heimat == null
        ? 0
        : distanz.as(LengthUnit.Kilometer, heimat, g.position);

    // Im eigenen Bundesland; geprüfte/bekannte Vorkommen vor „typisch“.
    final treffer = alleGewaesser.liste
        .where((g) =>
            g.land == speicher.bundesland && g.fischarten.contains(f.id))
        .toList()
      ..sort((a, b) {
        int rang(Gewaesser g) => switch (g.fischQuelle) {
              FischQuelle.geprueft => 0,
              FischQuelle.bekannt => 1,
              FischQuelle.typisch => 2,
            };
        final fa = speicher.istFavorit(a.id), fb = speicher.istFavorit(b.id);
        if (fa != fb) return fa ? -1 : 1;
        if (rang(a) != rang(b)) return rang(a).compareTo(rang(b));
        if (heimat != null) return km(a).compareTo(km(b));
        return (b.groesse ?? 0).compareTo(a.groesse ?? 0);
      });
    final top = treffer.take(25).toList();

    if (top.isNotEmpty && _beiss == null) {
      _beissOrt = top.first;
      _beiss = stundenWetter(top.first.position).then(beisszeit);
    }

    final name = f.name.split(' (').first;
    return [
      if (_beiss != null && _beissOrt != null)
        FutureBuilder<List<BeissTag>>(
          future: _beiss,
          builder: (context, snap) {
            final tage = snap.data;
            if (tage == null || tage.isEmpty) return const SizedBox.shrink();
            final bester = [...tage]..sort((a, b) => b.punkte.compareTo(a.punkte));
            final b = bester.first;
            const wt = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
            return Card(
              child: ListTile(
                leading: const Text('📅', style: TextStyle(fontSize: 26)),
                title: Text('Bester Tag: ${wt[b.tag.weekday - 1]} '
                    '${b.tag.day}.${b.tag.month}.  ${b.fische}'),
                subtitle: Text('${b.gruende.take(2).join(' · ')}\n'
                    'Beißzeit-Prognose für ${_beissOrt!.anzeigeName}'),
                isThreeLine: true,
              ),
            );
          },
        ),
      const SizedBox(height: 8),
      Text(
        top.isEmpty
            ? 'Keine Gewässer mit $name in ${speicher.bundesland.name} gefunden.'
            : '$name in ${speicher.bundesland.name}'
                '${heimat != null ? ' – nach Entfernung' : ''}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 4),
      for (final g in top)
        Card(
          child: ListTile(
            leading: Text(
                speicher.istFavorit(g.id) ? '⭐' : g.fischQuelle.zeichen,
                style: const TextStyle(fontSize: 22)),
            title: Text(g.anzeigeName),
            subtitle: Text([
              g.typ.name,
              if (g.bezirk.isNotEmpty) 'Bezirk ${g.bezirk}',
              if (heimat != null) '${km(g).round()} km',
              g.fischQuelle.text,
            ].join(' · ')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GewaesserDetail(g))),
          ),
        ),
      if (treffer.length > top.length)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text('… und ${treffer.length - top.length} weitere.',
              textAlign: TextAlign.center),
        ),
    ];
  }
}

class _Auswahl extends StatelessWidget {
  const _Auswahl(
      {required this.gewaehlt, required this.lieblinge, required this.onWahl});

  final Fisch? gewaehlt;
  final List<String> lieblinge;
  final void Function(Fisch) onWahl;

  @override
  Widget build(BuildContext context) {
    final schnell = [
      for (final id in [...lieblinge, 'hecht', 'zander', 'karpfen',
        'bachforelle', 'flussbarsch', 'wels', 'aesche', 'huchen'])
        fische.where((f) => f.id == id).firstOrNull,
    ].whereType<Fisch>().toSet().take(10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final f in schnell)
              ChoiceChip(
                label: Text(f.name.split(' (').first),
                selected: gewaehlt?.id == f.id,
                onSelected: (_) => onWahl(f),
              ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey(gewaehlt?.id),
          initialValue: gewaehlt?.id,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Andere Fischart',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final f in fische.where((f) => !f.ausgestorben))
              DropdownMenuItem(value: f.id, child: Text(f.name)),
          ],
          onChanged: (id) {
            final f = fische.where((x) => x.id == id).firstOrNull;
            if (f != null) onWahl(f);
          },
        ),
      ],
    );
  }
}

/// Darf ich heute? – kurze Ampel mit Sprung in den Darf-ich-Check.
class _Heute extends StatelessWidget {
  const _Heute(this.f);

  final Fisch f;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final name = f.name.split(' (').first;
    final a = darfIch.fragen(
        'Darf ich heute $name fangen', DateTime.now(), speicher.bundesland);
    final symbol = switch (a.ampel) {
      Ampel.ja => '✅',
      Ampel.achtung => '⚠️',
      Ampel.nein => '⛔',
      Ampel.info => '💡',
    };
    final bild = fischBilder[f.id];
    return Card(
      child: Column(
        children: [
          if (bild != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.asset(bild.pfad,
                  height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
          ListTile(
            leading: Text(symbol, style: const TextStyle(fontSize: 28)),
            title: Text(a.titel),
            subtitle: Text(a.punkte.isEmpty ? '' : a.punkte.first),
            trailing: const Icon(Icons.chat_bubble_outline),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => DarfIchScreen(
                    frage: 'Darf ich heute $name fangen?'))),
          ),
        ],
      ),
    );
  }
}

class _Koeder extends StatelessWidget {
  const _Koeder(this.f);

  final Fisch f;

  @override
  Widget build(BuildContext context) {
    final jz = jahreszeit(DateTime.now());
    final tipp = koederTipps[f.id]?[jz];
    return Card(
      child: ListTile(
        leading: const Text('🪝', style: TextStyle(fontSize: 26)),
        title: Text('Köder jetzt (${jahreszeitNamen[jz]})'),
        subtitle: Text(tipp ?? f.koeder),
      ),
    );
  }
}
