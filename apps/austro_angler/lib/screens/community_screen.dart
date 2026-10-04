import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import '../services/konto.dart';
import 'fangbuch_screen.dart';
import 'melden.dart';
import 'profil_screen.dart';
import 'aktivitaeten_screen.dart';
import 'challenge_screen.dart';
import 'kommentare_screen.dart';
import 'story_screen.dart';
import 'treffen_screen.dart';
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
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          actions: [
            if (konto.angemeldet)
              IconButton(
                tooltip: 'Neuigkeiten',
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AktivitaetenScreen())),
              ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: [
              Tab(icon: Icon(Icons.dynamic_feed), text: 'Neu'),
              Tab(icon: Icon(Icons.people), text: 'Freunde'),
              Tab(icon: Icon(Icons.event), text: 'Angeltage'),
              Tab(icon: Icon(Icons.flag_circle), text: 'Challenge'),
              Tab(icon: Icon(Icons.leaderboard), text: 'Rangliste'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Rekorde'),
            ],
          ),
        ),
        body: const TabBarView(
            children: [_Feed(), _FreundeFeed(), TreffenListe(), ChallengeListe(),
              _Rangliste(), _Rekorde()]),
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
              if (!konto.istBlockiert(f.uid)) _FeedKarte(f),
          ],
        );
      },
    );
  }
}

/// Offene Freundschaftsanfragen an mich.
class _Anfragen extends StatelessWidget {
  const _Anfragen(this.stream);

  final Stream<Map<String, String>>? stream;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    return StreamBuilder<Map<String, String>>(
      stream: stream,
      builder: (context, snap) {
        final anfragen = (snap.data ?? const <String, String>{})
          ..removeWhere((uid, _) => konto.istBlockiert(uid));
        if (anfragen.isEmpty) return const SizedBox.shrink();
        return Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Titel('👋 Freundschaftsanfragen (${anfragen.length})'),
                for (final e in anfragen.entries)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(at(e.value)),
                    onTap: () => profilOeffnen(context, e.key, e.value),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Ablehnen',
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              fangDienst.anfrageAblehnen(konto.uid!, e.key),
                        ),
                        IconButton.filled(
                          tooltip: 'Annehmen',
                          icon: const Icon(Icons.check),
                          onPressed: () async {
                            try {
                              await fangDienst.anfrageAnnehmen(konto.uid!,
                                  konto.name ?? '', e.key, e.value);
                              if (context.mounted) {
                                meldung(context,
                                    '${at(e.value)} ist jetzt dein Freund. 🎣');
                              }
                            } catch (_) {
                              if (context.mounted) {
                                meldung(context, 'Hat nicht geklappt.');
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Fang im Feed: Antippen öffnet das Profil des Fängers.
class _FeedKarte extends StatelessWidget {
  const _FeedKarte(this.fang);

  final Fang fang;

  @override
  Widget build(BuildContext context) => FangKarte(
        fang,
        unten: _Aktionen(fang),
        onTap: fang.nutzerName.isEmpty
            ? null
            : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ProfilScreen(uid: fang.uid, name: fang.nutzerName),
                )),
      );
}

class _FreundeFeed extends StatefulWidget {
  const _FreundeFeed();

  @override
  State<_FreundeFeed> createState() => _FreundeFeedState();
}

class _FreundeFeedState extends State<_FreundeFeed>
    with AutomaticKeepAliveClientMixin {
  final _eingabe = TextEditingController();
  Stream<Map<String, String>>? _freunde;
  String? _uid;
  Future<List<Fang>>? _feed;
  Set<String> _feedFuer = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _eingabe.dispose();
    super.dispose();
  }

  Stream<Map<String, String>>? _anfragen;

  Future<void> _hinzufuegen() async {
    final handle = Konto.handle(_eingabe.text);
    if (handle.isEmpty) return;
    final konto = KontoScope.of(context)!;
    try {
      await fangDienst.anfrageAnHandle(_uid!, konto.name ?? '', handle);
      _eingabe.clear();
      if (mounted) {
        meldung(context, 'Freundschaftsanfrage an ${at(handle)} geschickt. 🎣');
      }
    } catch (e) {
      if (mounted) meldung(context, '$e'.replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final konto = KontoScope.of(context)!;
    if (!konto.angemeldet) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: const [
          AnmeldenKarte('Melde dich an, um Freunde über ihren @Namen '
              'hinzuzufügen und ihre Fänge zu sehen.'),
        ],
      );
    }
    if (_uid != konto.uid) {
      _uid = konto.uid;
      _freunde = fangDienst.freunde(_uid!);
      _anfragen = fangDienst.anfragenAnMich(_uid!);
    }
    return StreamBuilder<Map<String, String>>(
      stream: _freunde,
      builder: (context, snap) {
        final freunde = snap.data ?? const <String, String>{};
        // Feed neu laden, wenn sich die Freundesliste ändert.
        if (!setEquals(_feedFuer, freunde.keys.toSet())) {
          _feedFuer = freunde.keys.toSet();
          _feed = fangDienst.freundeFeed(_feedFuer);
        }
        return RefreshIndicator(
          onRefresh: () async {
            setState(() => _feed = fangDienst.freundeFeed(_feedFuer));
            await _feed;
          },
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _eingabe,
                      decoration: const InputDecoration(
                        prefixText: '@',
                        hintText: 'Freundschaftsanfrage an @Namen',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _hinzufuegen(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _hinzufuegen,
                    icon: const Icon(Icons.person_add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Dein Name zum Teilen: ${at(konto.name ?? '')}',
                  style: Theme.of(context).textTheme.bodySmall),
              _Anfragen(_anfragen),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in freunde.entries)
                    ActionChip(
                      avatar: const Icon(Icons.person, size: 18),
                      label: Text(at(e.value)),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfilScreen(uid: e.key, name: e.value),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (freunde.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Noch keine Freunde. Frag deine Angel-Kollegen nach '
                    'ihrem @Namen!',
                    textAlign: TextAlign.center,
                  ),
                )
              else
                FutureBuilder<List<Fang>>(
                  future: _feed,
                  builder: (context, f) {
                    if (f.hasError) {
                      return const Text('Laden fehlgeschlagen.');
                    }
                    if (!f.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (f.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Deine Freunde haben noch nichts geteilt.',
                            textAlign: TextAlign.center),
                      );
                    }
                    return Column(
                      children: [
                        for (final fang in f.data!.take(100))
                          if (!konto.istBlockiert(fang.uid)) _FeedKarte(fang),
                      ],
                    );
                  },
                ),
            ],
          ),
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
              : () => fangDienst.petriHeil(fang, uid,
                  an: !gegeben, name: konto.name ?? ''),
          icon: Icon(gegeben ? Icons.thumb_up : Icons.thumb_up_outlined),
          label: Text('Petri Heil! ${fang.petriHeil.length}'),
        ),
        IconButton(
          tooltip: 'Als Bild teilen',
          icon: const Icon(Icons.share_outlined, size: 20),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => StoryScreen(fang))),
        ),
        IconButton(
          tooltip: 'Kommentare',
          icon: const Icon(Icons.chat_bubble_outline, size: 20),
          onPressed: uid == null
              ? null
              : () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => KommentareScreen(fang))),
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
                  content: Text('Fang von ${at(fang.nutzerName)} löschen.'),
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
        if (!eigener && uid != null)
          PopupMenuButton<String>(
            tooltip: 'Mehr',
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (wahl) async {
              if (wahl == 'melden') {
                await meldenDialog(
                  context,
                  typ: 'fang',
                  bezug: fang.id,
                  titel: 'Beitrag melden',
                  hinweis: 'Was ist das Problem? (z. B. beleidigend, fremdes '
                      'Foto, geschonter Fisch entnommen)',
                );
              } else if (wahl == 'nutzer') {
                await meldenDialog(
                  context,
                  typ: 'nutzer',
                  bezug: '${fang.uid} (${at(fang.nutzerName)})',
                  titel: '${at(fang.nutzerName)} melden',
                  hinweis: 'Was ist das Problem? (z. B. Beleidigungen, Spam, '
                      'Fake-Fänge)',
                );
              } else if (wahl == 'profil') {
                profilOeffnen(context, fang.uid, fang.nutzerName);
              } else if (wahl == 'blockieren') {
                await blockierenDialog(context, fang.uid, fang.nutzerName);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'profil', child: Text('👤 Profil ansehen')),
              PopupMenuItem(value: 'melden', child: Text('🚩 Beitrag melden')),
              PopupMenuItem(value: 'nutzer', child: Text('🙋 Nutzer melden')),
              PopupMenuItem(
                  value: 'blockieren', child: Text('🚫 Nutzer blockieren')),
            ],
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
  final mitglieder = <String>{};
}

class _Rangliste extends StatefulWidget {
  const _Rangliste();

  @override
  State<_Rangliste> createState() => _RanglisteState();
}

class _RanglisteState extends State<_Rangliste> {
  _Wertung _wertung = _Wertung.faenge;
  bool _vereine = false;
  bool _gesamt = false;
  final _cache = <String, Future<Map<String, RangEintrag>>>{};

  String get _zeitraum =>
      _gesamt ? 'gesamt' : FangDienst.monatsSchluessel(DateTime.now());

  Future<Map<String, RangEintrag>> _laden({bool neu = false}) {
    if (neu) _cache.remove(_zeitraum);
    return _cache[_zeitraum] ??= fangDienst.rangliste(_zeitraum);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final konto = KontoScope.of(context);
    final eigeneUid = konto?.uid;
    final future = _laden();
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await _laden(neu: true);
        if (mounted) setState(() {});
      },
      child: FutureBuilder<Map<String, RangEintrag>>(
        future: future,
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
          for (final e in snap.data!.values) {
            if (e.faenge == 0 || (konto?.istBlockiert(e.uid) ?? false)) continue;
            if (_vereine && e.verein.isEmpty) continue;
            final p = _vereine
                ? plaetze.putIfAbsent(e.verein.toLowerCase(), () => _Platz(e.verein))
                : plaetze.putIfAbsent(e.uid, () => _Platz(at(e.name)));
            p.mitglieder.add(e.uid);
            p.faenge += e.faenge;
            p.petriHeil += e.petri;
            if (e.groesster > p.groesster) p.groesster = e.groesster;
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: false, label: Text('Dieser Monat')),
                      ButtonSegment(value: true, label: Text('Gesamt')),
                    ],
                    selected: {_gesamt},
                    onSelectionChanged: (s) => setState(() => _gesamt = s.first),
                  ),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: false,
                          icon: Icon(Icons.person),
                          label: Text('Angler')),
                      ButtonSegment(
                          value: true,
                          icon: Icon(Icons.groups_2),
                          label: Text('Vereine')),
                    ],
                    selected: {_vereine},
                    onSelectionChanged: (s) =>
                        setState(() => _vereine = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
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
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_vereine
                      ? 'Noch kein Verein dabei. Trag unter Mehr → Mein '
                          'Konto deinen Verein ein!'
                      : 'Noch niemand in der Rangliste.'),
                ),
              for (var i = 0; i < top.length; i++)
                Card(
                  color: !_vereine && top[i].key == eigeneUid
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                  child: ListTile(
                    onTap: _vereine
                        ? null
                        : () => profilOeffnen(context, top[i].key,
                            top[i].value.name.replaceFirst('@', '')),
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
                        '${top[i].value.petriHeil} × Petri Heil'
                        '${_vereine ? ' · ${top[i].value.mitglieder.length} Angler' : ''}'),
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
              Text(
                'Aus allen öffentlich geteilten Fängen. Jeder Eintrag wird '
                'aktualisiert, wenn die Person ihr Fangbuch öffnet.',
                style: text.bodySmall,
              ),
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
        setState(() => _faenge = fangDienst.laengsteFaenge(neu: true));
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
                      at(rekorde[fisch.id]!.nutzerName),
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
