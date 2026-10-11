import 'package:flutter/material.dart';

import '../data/bilder.dart';
import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../models/fisch.dart';
import '../services/fang_dienst.dart';
import 'lexikon_screen.dart';

/// Stufen nach Fanghäufigkeit in Österreich – für Glanz im Album.
enum Seltenheit {
  haeufig('Häufig', Colors.green),
  selten('Selten', Colors.blue),
  sehrSelten('Sehr selten', Colors.purple),
  legendaer('Legendär', Colors.orange);

  const Seltenheit(this.name, this.farbe);
  final String name;
  final Color farbe;
}

const _haeufig = {
  'bachforelle', 'regenbogenforelle', 'hecht', 'zander', 'flussbarsch',
  'karpfen', 'schleie', 'brachse', 'aitel', 'rotauge', 'rotfeder', 'laube',
  'giebel', 'reinanke', 'aal', 'graskarpfen', 'sonnenbarsch', 'goldfisch',
  'gruendling', 'kaulbarsch', 'schwarzmundgrundel',
};
const _legendaer = {
  'huchen', 'hausen', 'sterlet', 'waxdick', 'glattdick', 'sternhausen',
  'seeforelle', 'zingel', 'streber', 'frauennerfling', 'perlfisch',
};

Seltenheit seltenheit(Fisch f) {
  if (_legendaer.contains(f.id)) return Seltenheit.legendaer;
  if (_haeufig.contains(f.id)) return Seltenheit.haeufig;
  if (f.geschuetzt) return Seltenheit.sehrSelten;
  return Seltenheit.selten;
}

/// Gesammelte Arten mit Anzahl, größtem Fang und Erstfang.
class AlbumEintrag {
  AlbumEintrag(this.fisch);

  final Fisch fisch;
  int anzahl = 0;
  double? groesste;
  DateTime? erster;
}

Map<String, AlbumEintrag> albumAus(List<Fang> faenge) {
  final album = <String, AlbumEintrag>{};
  for (final f in faenge) {
    final fisch = fischById(f.fischId);
    if (fisch == null) continue;
    final e = album.putIfAbsent(f.fischId, () => AlbumEintrag(fisch));
    e.anzahl++;
    final l = f.laengeCm;
    if (l != null && (e.groesste == null || l > e.groesste!)) e.groesste = l;
    if (e.erster == null || f.datum.isBefore(e.erster!)) e.erster = f.datum;
  }
  return album;
}

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  Future<List<Fang>>? _faenge;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    _faenge ??= konto?.uid == null
        ? Future.value(SpeicherScope.of(context).faenge)
        : fangDienst.meineFaenge(konto!.uid!).first;
    return Scaffold(
      appBar: AppBar(title: const Text('Arten-Sammelalbum')),
      body: FutureBuilder<List<Fang>>(
        future: _faenge,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Laden fehlgeschlagen.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final album = albumAus(snap.data!);
          final alle = fische.where((f) => !f.ausgestorben).toList()
            ..sort((a, b) {
              final ga = album.containsKey(a.id), gb = album.containsKey(b.id);
              if (ga != gb) return ga ? -1 : 1;
              return seltenheit(a).index.compareTo(seltenheit(b).index);
            });
          final text = Theme.of(context).textTheme;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${album.length} von ${alle.length} Arten',
                          style: text.headlineSmall),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                          value: album.length / alle.length, minHeight: 8),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final s in Seltenheit.values)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              avatar: CircleAvatar(backgroundColor: s.farbe),
                              label: Text('${s.name}: '
                                  '${album.values.where((e) => seltenheit(e.fisch) == s).length}'
                                  '/${alle.where((f) => seltenheit(f) == s).length}'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 135,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: alle.length,
                  itemBuilder: (context, i) =>
                      _Karte(alle[i], album[alle[i].id]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Karte extends StatelessWidget {
  const _Karte(this.f, this.e);

  final Fisch f;
  final AlbumEintrag? e;

  @override
  Widget build(BuildContext context) {
    final s = seltenheit(f);
    final bild = fischBilder[f.id];
    final hat = e != null;
    final name = f.name.split(' (').first;
    Widget foto = bild == null
        ? const Center(child: Text('🐟', style: TextStyle(fontSize: 40)))
        : Image.asset(bild.pfad, fit: BoxFit.cover, width: double.infinity);
    if (!hat) {
      foto = ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcATop),
        child: Opacity(opacity: 0.18, child: foto),
      );
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: hat ? s.farbe : Colors.grey.withValues(alpha: 0.3),
            width: hat ? 2.5 : 1),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => FischDetail(f))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  foto,
                  if (!hat)
                    const Center(
                        child: Text('?',
                            style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70))),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: s.farbe,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(s.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    !hat
                        ? 'noch nicht gefangen'
                        : '${e!.anzahl}×'
                            '${e!.groesste == null ? '' : ' · '}'
                            '${e!.groesste == null ? '' : '${e!.groesste!.round()} cm'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
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
