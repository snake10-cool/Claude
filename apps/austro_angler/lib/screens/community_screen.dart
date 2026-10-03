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
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dynamic_feed), text: 'Neueste Fänge'),
              Tab(icon: Icon(Icons.emoji_events), text: 'Rekorde'),
            ],
          ),
        ),
        body: const TabBarView(children: [_Feed(), _Rekorde()]),
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
