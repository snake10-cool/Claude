import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'fangbuch_screen.dart';
import 'melden.dart';
import 'widgets.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Community')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: HinweisKarte(
            'Die Community kommt bald! Hier siehst du dann die Fänge aller '
            'Austro Angler, Rekorde pro Fischart und kannst "Petri Heil!" '
            'sagen.',
            icon: Icons.groups,
          ),
        ),
      );
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dynamic_feed), text: 'Neu'),
              Tab(icon: Icon(Icons.leaderboard), text: 'Rangliste'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Rekorde'),
            ],
          ),
        ),
        body: const TabBarView(children: [_Feed(), _Rangliste(), _Rekorde()]),
      ),
    );
  }
}

class _Feed extends StatefulWidget {
  const _Feed();

  @override
  State<_Feed> createState() => _FeedState();
}

class _FeedState extends State<_Feed> with AutomaticKeepAliveClientMixin {
  final _stream = fangDienst.feed();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final konto = KontoScope.of(context)!;
    return StreamBuilder<List<Fang>>(
      stream: _stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Feed konnte nicht laden.'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final faenge = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (!konto.angemeldet)
              const AnmeldenKarte(
                'Melde dich an, um deine eigenen Fänge zu teilen und '
                '"Petri Heil!" zu sagen.',
              ),
            if (faenge.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Noch keine Fänge geteilt.\nSei der oder die Erste! 🎣',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final f in faenge)
              FangKarte(f, unten: _Aktionen(f)),
          ],
        );
      },
    );
  }
}

class _Aktionen extends StatelessWidget {
  const _Aktionen(this.fang);

  final Fang fang;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    final uid = konto.uid;
    final gegeben = uid != null && fang.petriHeil.contains(uid);
    final eigener = uid != null && fang.uid == uid;

    return Row(
      children: [
        TextButton.icon(
          onPressed: uid == null || eigener
              ? null
              : () => fangDienst.petriHeil(fang, uid, an: !gegeben),
          icon: Icon(gegeben ? Icons.thumb_up : Icons.thumb_up_outlined),
          label: Text('Petri Heil! ${fang.petriHeil.length}'),
        ),
        const Spacer(),
        if (konto.istAdmin && !eigener)
          IconButton(
            tooltip: 'Als Admin entfernen',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Fang entfernen?'),
                  content: Text('Fang von ${fang.nutzerName} löschen.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Abbrechen'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Löschen'),
                    ),
                  ],
                ),
              );
              if (ok == true) await fangDienst.loeschen(fang);
            },
          ),
        if (!eigener)
          IconButton(
            tooltip: 'Melden',
            icon: const Icon(Icons.flag_outlined, size: 20),
            onPressed: () => meldenDialog(
              context,
              typ: 'fang',
              bezug: fang.id,
              titel: 'Fang melden',
              hinweis: 'Was ist das Problem? (z. B. beleidigend, fremdes '
                  'Foto, geschonter Fisch entnommen)',
            ),
          ),
      ],
    );
  }
}

enum _Wertung { faenge, petriHeil, groesster }

class _Platz {
  _Platz(this.name);

  final String name;
  int faenge = 0;
  int petriHeil = 0;
  double groesster = 0;
}

class _Rangliste extends StatefulWidget {
  const _Rangliste();

  @override
  State<_Rangliste> createState() => _RanglisteState();
}

class _RanglisteState extends State<_Rangliste> {
  late Future<List<Fang>> _faenge = fangDienst.neuesteFaenge();
  _Wertung _wertung = _Wertung.faenge;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final eigeneUid = KontoScope.of(context)?.uid;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _faenge = fangDienst.neuesteFaenge());
        await _faenge;
      },
      child: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          if (snap.hasError) {
            return ListView(children: const [
              Padding(
                padding: EdgeInsets.all(32),
                child: Text('Rangliste konnte nicht laden.'),
              ),
            ]);
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final plaetze = <String, _Platz>{};
          for (final f in snap.data!) {
            final p = plaetze.putIfAbsent(f.uid, () => _Platz(f.nutzerName));
            p.faenge++;
            p.petriHeil += f.petriHeil.length;
            if ((f.laengeCm ?? 0) > p.groesster) p.groesster = f.laengeCm!;
          }
          num wert(_Platz p) => switch (_wertung) {
                _Wertung.faenge => p.faenge,
                _Wertung.petriHeil => p.petriHeil,
                _Wertung.groesster => p.groesster,
              };
          final liste = plaetze.entries.toList()
            ..sort((a, b) => wert(b.value).compareTo(wert(a.value)));
          final top = liste.take(50).toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SegmentedButton<_Wertung>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: _Wertung.faenge, label: Text('Fänge')),
                  ButtonSegment(
                      value: _Wertung.petriHeil, label: Text('Petri Heil')),
                  ButtonSegment(
                      value: _Wertung.groesster, label: Text('Größter')),
                ],
                selected: {_wertung},
                onSelectionChanged: (s) => setState(() => _wertung = s.first),
              ),
              const SizedBox(height: 12),
              if (top.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Noch niemand in der Rangliste.'),
                ),
              for (var i = 0; i < top.length; i++)
                Card(
                  color: top[i].key == eigeneUid
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    leading: SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          switch (i) {
                            0 => '🥇',
                            1 => '🥈',
                            2 => '🥉',
                            _ => '${i + 1}.',
                          },
                          style: i < 3
                              ? const TextStyle(fontSize: 26)
                              : text.titleMedium,
                        ),
                      ),
                    ),
                    title: Text(top[i].value.name),
                    subtitle: Text('${top[i].value.faenge} Fänge · '
                        '${top[i].value.petriHeil} × Petri Heil'),
                    trailing: Text(
                      switch (_wertung) {
                        _Wertung.faenge => '${top[i].value.faenge}',
                        _Wertung.petriHeil => '${top[i].value.petriHeil}',
                        _Wertung.groesster =>
                          '${top[i].value.groesster.toStringAsFixed(0)} cm',
                      },
                      style: text.titleLarge,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Aus den letzten 500 geteilten Fängen.',
                  style: text.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _Rekorde extends StatefulWidget {
  const _Rekorde();

  @override
  State<_Rekorde> createState() => _RekordeState();
}

class _RekordeState extends State<_Rekorde> {
  late Future<List<Fang>> _faenge = fangDienst.laengsteFaenge();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return RefreshIndicator(
      onRefresh: () async {
        setState(() => _faenge = fangDienst.laengsteFaenge());
        await _faenge;
      },
      child: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          if (snap.hasError) {
            return ListView(children: const [
              Padding(
                padding: EdgeInsets.all(32),
                child: Text('Rekorde konnten nicht laden.'),
              ),
            ]);
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Die Liste ist nach Länge sortiert: der erste pro Art ist der Rekord.
          final rekorde = <String, Fang>{};
          for (final f in snap.data!) {
            rekorde.putIfAbsent(f.fischId, () => f);
          }
          final liste = fische.where((f) => rekorde.containsKey(f.id));
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Größte geteilte Fänge pro Fischart', style: text.titleMedium),
              const SizedBox(height: 8),
              if (liste.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Noch keine Rekorde.'),
                ),
              for (final fisch in liste)
                Card(
                  child: ListTile(
                    leading: const Text('🏆', style: TextStyle(fontSize: 28)),
                    title: Text(fisch.name),
                    subtitle: Text([
                      rekorde[fisch.id]!.nutzerName,
                      if (rekorde[fisch.id]!.gewaesser.isNotEmpty)
                        rekorde[fisch.id]!.gewaesser,
                      datumText(rekorde[fisch.id]!.datum),
                    ].join(' · ')),
                    trailing: Text(
                      '${rekorde[fisch.id]!.laengeCm!.toStringAsFixed(0)} cm',
                      style: text.titleLarge,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
