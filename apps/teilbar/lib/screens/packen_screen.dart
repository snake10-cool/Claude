import 'dart:convert';

import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../l10n/l.dart';
import '../logik/packvorlagen.dart';
import 'liste_screen.dart';
import 'listen_screen.dart';

String vorlagenName(AppLocalizations l, String id) => switch (id) {
  'strand' => l.vorlageStrand,
  'ski' => l.vorlageSki,
  'festival' => l.vorlageFestival,
  'stadt' => l.vorlageStadt,
  'camping' => l.vorlageCamping,
  'business' => l.vorlageBusiness,
  _ => id,
};

class PackenScreen extends StatelessWidget {
  const PackenScreen({super.key});

  Future<void> _neu(BuildContext context) async {
    final l = context.l;
    final eigene = await db.vorlagenBeobachten().first;
    if (!context.mounted) return;
    final wahl =
        await showModalBottomSheet<(String, String, Map<String, List<String>>)>(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) => DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            builder: (context, scroll) => ListView(
              controller: scroll,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l.wohinGehts,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (final v in packVorlagen)
                  ListTile(
                    leading: Text(
                      v.symbol,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(vorlagenName(l, v.id)),
                    subtitle: Text(
                      l.artikelAnzahl(
                        v.artikel.values.fold(0, (a, b) => a + b.length),
                      ),
                    ),
                    onTap: () => Navigator.pop(context, (
                      vorlagenName(l, v.id),
                      v.symbol,
                      v.artikel,
                    )),
                  ),
                if (eigene.isNotEmpty) Abschnitt(l.eigeneVorlagen),
                for (final v in eigene)
                  ListTile(
                    leading: Text(
                      v.symbol,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(v.name),
                    onTap: () => Navigator.pop(context, (
                      v.name,
                      v.symbol,
                      (jsonDecode(v.artikel) as Map).map(
                        (k, w) =>
                            MapEntry(k as String, (w as List).cast<String>()),
                      ),
                    )),
                    trailing: IconButton(
                      tooltip: l.loeschen,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await db.vorlageLoeschen(v.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ),
                ListTile(
                  leading: const Text('📝', style: TextStyle(fontSize: 28)),
                  title: Text(l.leerePackliste),
                  onTap: () => Navigator.pop(context, (
                    l.packliste,
                    '🧳',
                    <String, List<String>>{},
                  )),
                ),
              ],
            ),
          ),
        );
    if (wahl == null) return;
    final id = await db.packlisteAnlegen(wahl.$1, wahl.$2, wahl.$3);
    if (context.mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => ListeScreen(listeId: id)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(title: Text(l.tabPacken)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _neu(context),
        icon: const Icon(Icons.add),
        label: Text(l.neuePackliste),
      ),
      body: StreamBuilder<List<ListeInfo>>(
        stream: db.listenBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final listen = snap.data!
              .where((i) => i.liste.art == 'packliste')
              .toList();
          if (listen.isEmpty) {
            return LeerHinweis(
              symbol: Icons.luggage_outlined,
              titel: l.keinePacklisten,
              text: l.keinePacklistenText,
              knopf: l.neuePackliste,
              aktion: () => _neu(context),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 88),
            children: [for (final i in listen) ListenKachel(i)],
          );
        },
      ),
    );
  }
}
