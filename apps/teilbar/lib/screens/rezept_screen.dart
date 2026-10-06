import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/reste.dart';

class RezeptScreen extends StatelessWidget {
  const RezeptScreen({super.key, required this.rezept});
  final Rezept rezept;

  Future<void> _aufListe(BuildContext context, List<Zutat> fehlend) async {
    final l = context.l;
    final listen = (await db.listenLaden())
        .where((i) => i.liste.art != 'packliste')
        .toList();
    if (!context.mounted) return;
    final ziel = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.aufWelcheListe),
        children: [
          for (final i in listen)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, i.liste.id),
              child: Text('${i.liste.symbol} ${i.liste.name}'),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l.neueEinkaufsliste),
          ),
        ],
      ),
    );
    if (ziel == null) return;
    final id = ziel.isEmpty ? await db.listeAnlegen(name: l.einkauf) : ziel;
    final liste = (await db.listenLaden())
        .firstWhere((i) => i.liste.id == id)
        .liste;
    for (final z in fehlend) {
      await db.artikelHinzufuegen(liste, name: z.name, menge: z.menge);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.aufListeGesetzt(fehlend.length, liste.name))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return ListenableBuilder(
      listenable: profil,
      builder: (context, _) {
        final vorhanden = {for (final z in profil.zutaten) zutatSchluessel(z)};
        final fehlend = [
          for (final z in rezept.zutaten)
            if (!z.grund && !zutatVorhanden(z.name, vorhanden)) z,
        ];
        return Scaffold(
          appBar: AppBar(title: Text(rezept.name)),
          bottomNavigationBar: fehlend.isEmpty
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FilledButton.icon(
                      onPressed: () => _aufListe(context, fehlend),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: Text(l.fehlendeAufListe(fehlend.length)),
                    ),
                  ),
                ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    avatar: const Icon(Icons.timer_outlined, size: 18),
                    label: Text(l.minuten(rezept.minuten)),
                  ),
                  Chip(
                    avatar: const Icon(Icons.people_outline, size: 18),
                    label: Text(l.portionen(rezept.portionen)),
                  ),
                  for (final tag in rezept.tags) Chip(label: Text(tag)),
                ],
              ),
              const SizedBox(height: 16),
              Text(l.zutaten, style: t.textTheme.titleMedium),
              for (final z in rezept.zutaten)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    z.grund
                        ? Icons.kitchen_outlined
                        : zutatVorhanden(z.name, vorhanden)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: !z.grund && zutatVorhanden(z.name, vorhanden)
                        ? Colors.green.shade600
                        : null,
                  ),
                  title: Text(z.name),
                  trailing: Text(z.menge),
                  subtitle: z.grund ? Text(l.grundzutat) : null,
                ),
              const SizedBox(height: 16),
              Text(l.zubereitung, style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final (i, s) in rezept.schritte.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, child: Text('${i + 1}')),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s, style: t.textTheme.bodyLarge)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
