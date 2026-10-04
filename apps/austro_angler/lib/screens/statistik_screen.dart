import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/abzeichen.dart';
import '../services/fang_dienst.dart';
import '../services/pdf_export.dart';
import 'angeljahr_screen.dart';
import 'widgets.dart';
import 'zuruecksetzen_screen.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  Future<List<Fang>>? _faenge;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    _faenge ??= konto?.uid == null
        ? Future.value(SpeicherScope.of(context).faenge)
        : fangDienst.meineFaenge(konto!.uid!).first;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik & Abzeichen')),
      body: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Laden fehlgeschlagen.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final f = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  leading: const Text('🎁', style: TextStyle(fontSize: 28)),
                  title: const Text('Dein Angeljahr ⭐'),
                  subtitle: const Text('Jahresrückblick zum Teilen'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AngeljahrScreen(f))),
                ),
              ),
              _Abzeichen(f),
              _CatchRelease(f),
              _Rekorde(f),
              _Balken('📅 Fänge pro Monat (${DateTime.now().year})',
                  _proMonat(f), premium: true),
              _Balken('🪱 Beste Köder', _top(f.map((x) => x.koeder)),
                  premium: true),
              _Balken('📍 Beste Gewässer', _top(f.map((x) => x.gewaesser)),
                  premium: true),
              _Balken('🕐 Beste Uhrzeit', _uhrzeiten(f), premium: true),
              _Balken('🌤️ Wetter bei deinen Fängen', _wetter(f), premium: true),
              _Export(f, konto?.name ?? ''),
              _RevierStatistik(f, konto?.name ?? ''),
            ],
          );
        },
      ),
    );
  }

  static Map<String, int> _proMonat(List<Fang> f) {
    const monate = ['Jän', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug',
      'Sep', 'Okt', 'Nov', 'Dez'];
    final jahr = DateTime.now().year;
    return {
      for (var m = 1; m <= 12; m++)
        monate[m - 1]: f
            .where((x) => x.datum.year == jahr && x.datum.month == m)
            .length,
    };
  }

  static Map<String, int> _top(Iterable<String> werte) {
    final z = <String, int>{};
    for (final w in werte.where((w) => w.trim().isNotEmpty)) {
      z[w] = (z[w] ?? 0) + 1;
    }
    final liste = z.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(liste.take(6));
  }

  static Map<String, int> _uhrzeiten(List<Fang> f) {
    final z = <String, int>{};
    for (var s = 0; s < 24; s += 3) {
      z['${s.toString().padLeft(2, '0')}–${(s + 3).toString().padLeft(2, '0')}'] =
          f.where((x) => x.datum.hour >= s && x.datum.hour < s + 3).length;
    }
    return z;
  }

  static Map<String, int> _wetter(List<Fang> f) {
    String gruppe(int code) => switch (code) {
          0 || 1 => '☀️ sonnig',
          2 || 3 => '☁️ bewölkt',
          45 || 48 => '🌫️ Nebel',
          >= 51 && <= 67 || >= 80 && <= 82 => '🌧️ Regen',
          >= 71 && <= 77 || 85 || 86 => '🌨️ Schnee',
          >= 95 => '⛈️ Gewitter',
          _ => 'sonstiges',
        };
    return _top(f
        .where((x) => x.wetter != null)
        .map((x) => gruppe(x.wetter!['code']?.toInt() ?? 0)));
  }
}

class _Abzeichen extends StatelessWidget {
  const _Abzeichen(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final erreicht = alleAbzeichen.where((a) => a.erreicht(faenge)).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Titel('🏅 Abzeichen ($erreicht von ${alleAbzeichen.length})'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final a in alleAbzeichen)
                  Tooltip(
                    message: '${a.name}: ${a.beschreibung}'
                        '${a.premium ? ' (⭐ Premium)' : ''}',
                    triggerMode: TooltipTriggerMode.tap,
                    child: Opacity(
                      opacity: a.erreicht(faenge) ? 1 : 0.25,
                      child: SizedBox(
                        width: 72,
                        child: Column(
                          children: [
                            Text(a.icon, style: const TextStyle(fontSize: 30)),
                            Text(a.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Tippe auf ein Abzeichen, um zu sehen, wie man es bekommt.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Rekorde extends StatelessWidget {
  const _Rekorde(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final rekorde = <String, Fang>{};
    for (final f in faenge.where((f) => f.laengeCm != null)) {
      final alt = rekorde[f.fischId];
      if (alt == null || f.laengeCm! > alt.laengeCm!) rekorde[f.fischId] = f;
    }
    final liste = rekorde.values.toList()
      ..sort((a, b) => b.laengeCm!.compareTo(a.laengeCm!));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('🏆 Meine Rekorde'),
            if (liste.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Trag bei deinen Fängen die Länge ein!'),
              ),
            for (final f in liste)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(fischById(f.fischId)?.name ?? f.fischId),
                subtitle: Text([
                  datumText(f.datum),
                  if (f.gewaesser.isNotEmpty) f.gewaesser,
                ].join(' · ')),
                trailing: Text('${f.laengeCm!.toStringAsFixed(0)} cm',
                    style: Theme.of(context).textTheme.titleMedium),
              ),
          ],
        ),
      ),
    );
  }
}

class _Balken extends StatelessWidget {
  const _Balken(this.titel, this.werte, {this.premium = false});

  final String titel;
  final Map<String, int> werte;
  final bool premium;

  @override
  Widget build(BuildContext context) {
    final maximum = werte.values.fold(0, (a, b) => a > b ? a : b);
    final farbe = Theme.of(context).colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Titel(titel, premium: premium),
            const SizedBox(height: 8),
            if (maximum == 0)
              const Text('Noch keine Daten.')
            else
              for (final e in werte.entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(e.key,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) => Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 14,
                              width: c.maxWidth * e.value / maximum,
                              decoration: BoxDecoration(
                                color: farbe,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: 30,
                          child: Text(' ${e.value}', textAlign: TextAlign.end)),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _Export extends StatelessWidget {
  const _Export(this.faenge, this.name);

  final List<Fang> faenge;
  final String name;

  @override
  Widget build(BuildContext context) {
    final jahre = faenge.map((f) => f.datum.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (jahre.isEmpty) jahre.add(DateTime.now().year);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('📄 Fangbuch als PDF', premium: true),
            const SizedBox(height: 4),
            const Text('Zum Abgeben der Fangstatistik am Saisonende, zum '
                'Drucken oder Verschicken.'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final j in jahre)
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await fangbuchAlsPdf(faenge, j, name);
                      } catch (e) {
                        if (context.mounted) meldung(context, 'PDF-Fehler: $e');
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text('$j'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CatchRelease extends StatelessWidget {
  const _CatchRelease(this.faenge);

  final List<Fang> faenge;

  @override
  Widget build(BuildContext context) {
    final zurueck = faenge.where((f) => f.zurueckgesetzt).length;
    final quote = faenge.isEmpty ? 0 : (zurueck * 100 / faenge.length).round();
    final proArt = <String, (int, int)>{};
    for (final f in faenge) {
      final (z, g) = proArt[f.fischId] ?? (0, 0);
      proArt[f.fischId] = (z + (f.zurueckgesetzt ? 1 : 0), g + 1);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('🤝 Catch & Release'),
            const SizedBox(height: 6),
            Text('$zurueck von ${faenge.length} Fischen zurückgesetzt ($quote %)'),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: quote / 100, minHeight: 8),
            const SizedBox(height: 8),
            for (final e in proArt.entries.where((e) => e.value.$1 > 0))
              Text('${fischById(e.key)?.name ?? e.key}: '
                  '${e.value.$1} von ${e.value.$2} zurück'),
            TextButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ZuruecksetzenScreen())),
              icon: const Icon(Icons.tips_and_updates_outlined),
              label: const Text('Tipps: schonend zurücksetzen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevierStatistik extends StatefulWidget {
  const _RevierStatistik(this.faenge, this.name);

  final List<Fang> faenge;
  final String name;

  @override
  State<_RevierStatistik> createState() => _RevierStatistikState();
}

class _RevierStatistikState extends State<_RevierStatistik> {
  late int _jahr = DateTime.now().year;
  String? _gewaesser;

  @override
  Widget build(BuildContext context) {
    final jahre = {
      DateTime.now().year,
      ...widget.faenge.map((f) => f.datum.year),
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    final gewaesser = widget.faenge
        .where((f) => f.datum.year == _jahr && f.gewaesser.isNotEmpty)
        .map((f) => f.gewaesser)
        .toSet()
        .toList()
      ..sort();
    final gewaehlt = gewaesser.contains(_gewaesser) ? _gewaesser : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Titel('📝 Fangstatistik fürs Revier', premium: true),
            const SizedBox(height: 4),
            const Text('Viele Vereine wollen am Saisonende wissen, was du '
                'entnommen hast. Die App füllt das Formular aus deinem '
                'Fangbuch aus.'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [
                for (final j in jahre.take(4))
                  ChoiceChip(
                    label: Text('$j'),
                    selected: j == _jahr,
                    onSelected: (_) => setState(() => _jahr = j),
                  ),
              ],
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: gewaehlt,
              hint: Text(gewaesser.isEmpty
                  ? 'Keine Fänge mit Gewässer in $_jahr'
                  : 'Gewässer wählen'),
              items: [
                for (final g in gewaesser)
                  DropdownMenuItem(value: g, child: Text(g)),
              ],
              onChanged: (g) => setState(() => _gewaesser = g),
            ),
            FilledButton.tonalIcon(
              onPressed: gewaehlt == null
                  ? null
                  : () async {
                      try {
                        await revierStatistikPdf(
                            widget.faenge, _jahr, gewaehlt, widget.name);
                      } catch (e) {
                        if (context.mounted) meldung(context, 'PDF-Fehler: $e');
                      }
                    },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
