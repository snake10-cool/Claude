import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../models/fisch.dart';
import '../models/gewaesser.dart';
import '../services/alle_gewaesser.dart';
import '../services/beisszeit.dart';
import '../services/fang_dienst.dart';
import '../services/live_angeln.dart';
import '../services/wetter.dart';
import 'aktivitaeten_screen.dart';
import 'darf_ich_screen.dart';
import 'fangbuch_screen.dart';
import 'fischerkarte_screen.dart';
import 'live_angeln_screen.dart';
import 'petri_screen.dart';
import 'regeln_screen.dart';
import 'gewaesser_screen.dart';
import 'heimat_screen.dart';
import 'lexikon_screen.dart';
import 'widgets.dart';
import 'zielfisch_screen.dart';
import '../services/fern_konfig.dart';
import 'beissindex_karte.dart';

/// Startseite: was heute am Wasser zählt – auf einen Blick.
class HeuteScreen extends StatefulWidget {
  const HeuteScreen({super.key});

  @override
  State<HeuteScreen> createState() => _HeuteScreenState();
}

class _HeuteScreenState extends State<HeuteScreen> {
  String? _uid;
  Stream<List<Fang>>? _stream;

  @override
  void initState() {
    super.initState();
    alleGewaesser.laden();
  }

  Stream<List<Fang>> _streamFuer(String uid) {
    if (uid != _uid || _stream == null) {
      _uid = uid;
      _stream = fangDienst.meineFaenge(uid);
    }
    return _stream!;
  }

  static String _gruss(DateTime jetzt) => switch (jetzt.hour) {
        < 5 => 'Gute Nacht',
        < 11 => 'Guten Morgen',
        < 14 => 'Mahlzeit',
        < 18 => 'Servus',
        _ => 'Guten Abend',
      };

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final konto = KontoScope.of(context);
    final name = konto?.angemeldet == true ? konto?.name : null;
    final jetzt = DateTime.now();
    const wt = [
      'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag',
      'Sonntag'
    ];

    Widget challenges(List<Fang> f) => WochenChallengeKarte(f);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Heute'),
        actions: const [NeuigkeitenGlocke()],
      ),
      body: ListenableBuilder(
        listenable: alleGewaesser,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
                '${_gruss(jetzt)}${name == null || name.isEmpty ? '' : ', $name'}!',
                style: Theme.of(context).textTheme.headlineSmall),
            Text('${wt[jetzt.weekday - 1]}, ${jetzt.day}.${jetzt.month}.'
                '${speicher.heimatName.isEmpty ? '' : ' · ${speicher.heimatName}'}'),
            const SizedBox(height: 12),
            if (funktionAn('darf_ich')) const DarfIchFeld(),
            const SizedBox(height: 4),
            const _Schnellzugriff(),
            const SizedBox(height: 4),
            if (funktionAn('ki')) const _PetriKarte(),
            if (funktionAn('wetter')) const _WetterKarte(),
            const SizedBox(height: 4),
            const _MeineGewaesser(),
            const SizedBox(height: 4),
            const _Lieblingsfische(),
            const SizedBox(height: 4),
            if (konto?.angemeldet == true && konto?.uid != null)
              StreamBuilder<List<Fang>>(
                stream: _streamFuer(konto!.uid!),
                builder: (context, snap) =>
                    challenges(snap.data ?? const []),
              )
            else
              challenges(speicher.faenge),
          ],
        ),
      ),
    );
  }
}

/// Einstieg zur Petri-KI.
class _PetriKarte extends StatelessWidget {
  const _PetriKarte();

  @override
  Widget build(BuildContext context) {
    void oeffnen(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        leading: const Text('🎣', style: TextStyle(fontSize: 30)),
        title: const Text('Frag Petri – dein KI-Angelguide'),
        subtitle: const Text('Köder, Regeln, Taktik – oder Fisch per Foto bestimmen'),
        trailing: IconButton(
          tooltip: 'Fisch per Foto bestimmen',
          icon: const Icon(Icons.photo_camera_outlined),
          onPressed: () => oeffnen(const PetriFotoScreen()),
        ),
        onTap: () => oeffnen(const PetriScreen()),
      ),
    );
  }
}

/// Drei große Knöpfe: Live-Angeln, Regeln heute, Fischerkarte.
class _Schnellzugriff extends StatelessWidget {
  const _Schnellzugriff();

  @override
  Widget build(BuildContext context) {
    void oeffnen(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    return ListenableBuilder(
      listenable: liveAngeln,
      builder: (context, _) {
        final laeuft = liveAngeln.sitzung != null;
        final knoepfe = [
          if (funktionAn('live_angeln'))
            (laeuft ? '🔴' : '🎣', laeuft ? 'Live läuft' : 'Live-Angeln',
                () => oeffnen(const LiveAngelnScreen())),
          if (funktionAn('regeln'))
            ('📋', 'Regeln heute', () => oeffnen(const RegelnScreen())),
          if (funktionAn('fischerkarte'))
            ('🎫', 'Fischerkarte', () => oeffnen(const FischerkarteScreen())),
        ];
        if (knoepfe.isEmpty) return const SizedBox.shrink();
        return Row(
          children: [
            for (final (symbol, titel, tap) in knoepfe)
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 4, 6, 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: tap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Text(symbol, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 4),
                          Text(titel,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Wetter und Beißzeit am Heimatort.
class _WetterKarte extends StatefulWidget {
  const _WetterKarte();

  @override
  State<_WetterKarte> createState() => _WetterKarteState();
}

class _WetterKarteState extends State<_WetterKarte> {
  LatLng? _ort;
  Future<Wetter>? _wetter;
  Future<List<BeissTag>>? _beiss;

  void _laden(LatLng ort) {
    if (_ort == ort) return;
    _ort = ort;
    _wetter = wetterLaden(ort);
    _beiss = stundenWetter(ort).then(beisszeit);
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    if (speicher.heimatLat == null || speicher.heimatLon == null) {
      return Card(
        child: ListTile(
          leading: const Text('🌤️', style: TextStyle(fontSize: 26)),
          title: const Text('Wetter & Beißzeit'),
          subtitle: const Text('Heimatort wählen, dann siehst du hier '
              'Wetter und die besten Angeltage.'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HeimatScreen())),
        ),
      );
    }
    if (funktionAn('beissindex')) {
      return BeissindexKarte(
          LatLng(speicher.heimatLat!, speicher.heimatLon!),
          ortName: speicher.heimatName);
    }
    _laden(LatLng(speicher.heimatLat!, speicher.heimatLon!));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Wetter>(
              future: _wetter,
              builder: (context, snap) {
                final w = snap.data;
                if (w == null) {
                  return Text(snap.hasError
                      ? '🌡️ Wetter gerade nicht verfügbar'
                      : '🌡️ Wetter wird geladen …');
                }
                final (symbol, text) = w.beschreibung;
                String uhr(DateTime? d) => d == null
                    ? '–'
                    : '${d.hour}:${d.minute.toString().padLeft(2, '0')}';
                return Row(
                  children: [
                    Text(symbol, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${w.temperatur.round()} °C · $text',
                              style: Theme.of(context).textTheme.titleMedium),
                          Text('Wind ${w.wind.round()} km/h · '
                              '${w.luftdruck.round()} hPa · '
                              '🌅 ${uhr(w.sonnenaufgang)} – '
                              '${uhr(w.sonnenuntergang)}'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            FutureBuilder<List<BeissTag>>(
              future: _beiss,
              builder: (context, snap) {
                final tage = snap.data;
                if (tage == null || tage.isEmpty) {
                  return const SizedBox.shrink();
                }
                const wt = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                final heute = tage.first;
                final bester = [...tage]
                  ..sort((a, b) => b.punkte.compareTo(a.punkte));
                final b = bester.first;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Beißzeit heute: ${heute.fische}'
                    '${heute.gruende.isEmpty ? '' : ' – ${heute.gruende.first}'}\n'
                    'Bester Tag: ${wt[b.tag.weekday - 1]} '
                    '${b.tag.day}.${b.tag.month}. ${b.fische}',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Gefolgte Gewässer – schnell öffnen.
class _MeineGewaesser extends StatelessWidget {
  const _MeineGewaesser();

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final liste = [
      for (final id in speicher.favoriten)
        alleGewaesser.liste.where((g) => g.id == id).firstOrNull,
    ].whereType<Gewaesser>().toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('⭐ Meine Gewässer'),
            const SizedBox(height: 4),
            if (liste.isEmpty)
              const Text('Tippe bei einem Gewässer auf den Stern, dann '
                  'erscheint es hier.')
            else
              for (final g in liste)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Text(g.fischQuelle.zeichen,
                      style: const TextStyle(fontSize: 20)),
                  title: Text(g.anzeigeName),
                  subtitle: Text([
                    g.typ.name,
                    if (g.bezirk.isNotEmpty) 'Bezirk ${g.bezirk}',
                  ].join(' · ')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => GewaesserDetail(g))),
                ),
          ],
        ),
      ),
    );
  }
}

/// Lieblingsfische: offen oder geschont – mit Sprung in den Zielfisch-Modus.
class _Lieblingsfische extends StatelessWidget {
  const _Lieblingsfische();

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final heute = DateTime.now();
    final liste = [
      for (final id in speicher.lieblingsfische)
        fische.where((f) => f.id == id).firstOrNull,
    ].whereType<Fisch>().take(6).toList();
    String status(Fisch f) {
      if (f.geschuetzt) return '🛡️ geschützt';
      final r = f.regel(speicher.bundesland);
      final geschont = r.istGeschont(heute);
      if (geschont == null) return '❔ bitte prüfen';
      if (geschont) {
        final tage = r.tageBisOffen(heute);
        return tage == null ? '⛔ geschont' : '⛔ geschont, noch $tage Tage';
      }
      final bis = r.tageBisSchonzeit(heute);
      return bis != null && bis <= 14
          ? '⚠️ offen, Schonzeit in $bis Tagen'
          : '✅ offen';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                    child: Titel('🐟 Lieblingsfische in '
                        '${speicher.bundesland.name}')),
                if (funktionAn('zielfisch'))
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ZielfischScreen())),
                  child: const Text('Zielfisch'),
                ),
              ],
            ),
            for (final f in liste)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(f.name.split(' (').first),
                subtitle: Text(status(f)),
                trailing: !funktionAn('zielfisch')
                    ? null
                    : IconButton(
                  tooltip: 'Wo und womit?',
                  icon: const Icon(Icons.my_location),
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => ZielfischScreen(fischId: f.id))),
                ),
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FischDetail(f))),
              ),
          ],
        ),
      ),
    );
  }
}
