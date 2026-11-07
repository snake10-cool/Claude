import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../design.dart';
import '../main.dart';
import '../services/alle_gewaesser.dart';
import '../services/angelplaner.dart';
import '../services/fern_konfig.dart';
import '../services/wecker.dart';
import 'beissindex_karte.dart';
import 'widgets.dart';

const _wt = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _wtLang = [
  'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag',
  'Sonntag', //
];

/// Angelplaner: Beißindex der nächsten 7 Tage für Heimatort und
/// Lieblingsgewässer – mit dem besten Termin der Woche.
class AngelplanerScreen extends StatefulWidget {
  const AngelplanerScreen({super.key});

  @override
  State<AngelplanerScreen> createState() => _AngelplanerScreenState();
}

class _AngelplanerScreenState extends State<AngelplanerScreen> {
  Future<List<PlanOrt>>? _plan;

  List<(String, LatLng)> _orte() {
    final s = SpeicherScope.of(context);
    final orte = <(String, LatLng)>[];
    if (s.heimatLat != null && s.heimatLon != null) {
      orte.add((
        s.heimatName.isEmpty ? 'Heimatort' : s.heimatName,
        LatLng(s.heimatLat!, s.heimatLon!),
      ));
    }
    for (final id in s.favoriten) {
      for (final g in alleGewaesser.liste) {
        if (g.id == id) {
          orte.add((g.name, g.position));
          break;
        }
      }
      if (orte.length >= 6) break;
    }
    return orte;
  }

  void _laden() => _plan = planen(_orte());

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('planer')) return const FunktionAusSeite('Angelplaner');
    final orte = _orte();
    if (_plan == null && orte.isNotEmpty) _laden();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Angelplaner'),
        actions: [
          IconButton(
            tooltip: 'Neu laden',
            icon: const Icon(Icons.refresh),
            onPressed: orte.isEmpty ? null : () => setState(_laden),
          ),
        ],
      ),
      body: orte.isEmpty
          ? const _Leer()
          : FutureBuilder<List<PlanOrt>>(
              future: _plan,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final plan = snap.data ?? const [];
                if (plan.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: const [
                      HinweisKarte(
                        'Gerade gibt es keine Wetterdaten – ohne Internet '
                        'kann der Planer nicht rechnen.',
                        icon: Icons.cloud_off,
                      ),
                    ],
                  );
                }
                final bester = besterTermin(plan);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                  children: [
                    if (bester != null) _BesterTag(bester),
                    const SizedBox(height: 8),
                    _Woche(plan, bester: bester),
                    const SizedBox(height: 10),
                    Text(
                      'Schätzung aus Wettervorhersage, Mond und Dämmerung. Je '
                      'weiter weg der Tag, desto unsicherer. Tippe auf einen '
                      'Tag für die besten Zeiten.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _Leer extends StatelessWidget {
  const _Leer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        HinweisKarte(
          'Wähle unter Mehr → Mein Heimatort deinen Ort oder folge Gewässern '
          'mit dem ⭐ – dann rechnet der Planer für jeden Ort die nächsten '
          '7 Tage.',
          icon: Icons.star_outline,
        ),
      ],
    );
  }
}

String _fenster(PlanTag t) =>
    t.index.fenster.isEmpty ? '' : '${t.index.fenster.first.$1}–${t.index.fenster.first.$2} Uhr';

class _BesterTag extends StatelessWidget {
  const _BesterTag(this.t);

  final Termin t;

  Future<void> _erinnern(BuildContext context) async {
    final tag = t.tag.tag;
    final start = t.tag.index.fenster.isEmpty ? 7 : t.tag.index.fenster.first.$1;
    var wann = DateTime(tag.year, tag.month, tag.day, start)
        .subtract(const Duration(hours: 1));
    if (wann.isBefore(DateTime.now())) {
      wann = DateTime.now().add(const Duration(minutes: 1));
    }
    final ok = await Wecker.instanz.planerErinnern(
      wann,
      '🎣 Top-Beißzeit: ${t.ort.name}',
      '${_wtLang[tag.weekday - 1]} ${_fenster(t.tag)} – Beißindex '
          '${t.tag.index.wert}. Petri Heil!',
    );
    if (!context.mounted) return;
    meldung(
        context,
        ok
            ? 'Erinnerung gestellt: ${_wtLang[wann.weekday - 1]} um '
                '${wann.hour}:${wann.minute.toString().padLeft(2, '0')} Uhr.'
            : 'Erinnerungen gibt es nur in der Android-App.');
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    final tag = t.tag.tag;
    final heute = DateTime.now();
    final morgen = heute.add(const Duration(days: 1));
    bool gleich(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    final wann = gleich(tag, heute)
        ? 'Heute'
        : gleich(tag, morgen)
            ? 'Morgen'
            : _wtLang[tag.weekday - 1];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DEIN BESTER ANGELTAG',
                style: text.labelMedium
                    ?.copyWith(color: akzent, letterSpacing: 1.3)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$wann, ${tag.day}.${tag.month}.',
                          style: text.headlineMedium),
                      Text(_fenster(t.tag), style: text.titleLarge),
                      const SizedBox(height: 2),
                      Text(t.ort.name, style: text.bodyLarge),
                    ],
                  ),
                ),
                _Zahl(t.tag.index.wert, gross: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(t.tag.index.gruende.join(' · '), style: text.bodySmall),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _erinnern(context),
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Erinnere mich'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Beißindex als runde Zahl mit Farbe.
class _Zahl extends StatelessWidget {
  const _Zahl(this.wert, {this.gross = false, this.bester = false});

  final int wert;
  final bool gross;

  /// Bester Termin der Woche – mit Ring.
  final bool bester;

  @override
  Widget build(BuildContext context) {
    final akzent = DesignInfo.von(context).akzent;
    final schema = Theme.of(context).colorScheme;
    final groesse = gross ? 64.0 : 38.0;
    // Gespreizt: unter 45 kaum Farbe, ab 90 volle Farbe.
    final staerke = ((wert - 45) / 45).clamp(0.0, 1.0);
    final stark = staerke > 0.55;
    return Container(
      width: groesse,
      height: groesse,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: akzent.withValues(alpha: 0.10 + staerke * 0.88),
        border: bester ? Border.all(color: schema.onSurface, width: 2.5) : null,
      ),
      child: Text(
        '$wert',
        style: (gross
                ? Theme.of(context).textTheme.headlineMedium
                : Theme.of(context).textTheme.titleSmall)
            ?.copyWith(
                fontWeight: FontWeight.w800,
                color: stark ? schema.surface : schema.onSurface),
      ),
    );
  }
}

class _Woche extends StatelessWidget {
  const _Woche(this.plan, {this.bester});

  final List<PlanOrt> plan;
  final Termin? bester;

  void _details(BuildContext context, PlanOrt o, PlanTag t) {
    final text = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_wtLang[t.tag.weekday - 1]}, ${t.tag.day}.${t.tag.month}.',
                style: text.headlineSmall),
            Text(o.name, style: text.bodyLarge),
            const SizedBox(height: 10),
            Row(
              children: [
                _Zahl(t.index.wert),
                const SizedBox(width: 10),
                Expanded(
                    child: Text('${t.index.wort} · ${t.index.fensterText}',
                        style: text.titleSmall)),
              ],
            ),
            const SizedBox(height: 12),
            BeissZeitleiste(t.index),
            const SizedBox(height: 10),
            Text(t.index.gruende.join(' · '), style: text.bodySmall),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tage = plan.first.tage.map((t) => t.tag).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('DIE NÄCHSTEN 7 TAGE', style: text.labelMedium),
            ),
            Row(
              children: [
                const SizedBox(width: 92),
                for (final t in tage)
                  Expanded(
                    child: Text(_wt[t.weekday - 1],
                        textAlign: TextAlign.center, style: text.labelMedium),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            for (final o in plan)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(o.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.labelLarge),
                    ),
                    for (final t in o.tage)
                      Expanded(
                        child: Center(
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _details(context, o, t),
                            child: _Zahl(t.index.wert,
                                bester: bester != null &&
                                    bester!.ort == o &&
                                    bester!.tag == t),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
