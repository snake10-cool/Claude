import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/grenzen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import 'produkt_bearbeiten_screen.dart';

/// Alle Produkte mit Kosten, Preis und Gewinn. Reihenfolge = Reihenfolge
/// der Knöpfe beim Verkaufen (ziehen zum Sortieren).
class ProdukteScreen extends StatefulWidget {
  const ProdukteScreen({super.key});

  @override
  State<ProdukteScreen> createState() => _ProdukteScreenState();
}

class _ProdukteScreenState extends State<ProdukteScreen> {
  bool _archiv = false;

  Future<void> _neu() async {
    final anzahl = await db.anzahlAktiverProdukte();
    if (!mounted) return;
    if (!darfAnlegen(
      vorhanden: anzahl,
      grenze: GratisGrenzen.produkte,
      istPro: kauf.istPro,
    )) {
      await proGrenzeZeigen(
        context,
        context.l.grenzeProdukte(GratisGrenzen.produkte),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProduktBearbeitenScreen()),
    );
  }

  void _bearbeiten(ProduktDetails p) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProduktBearbeitenScreen(produkt: p),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(_archiv ? l.archiv : l.tabProdukte),
        actions: [
          IconButton(
            tooltip: _archiv ? l.aktiveAnzeigen : l.archivAnzeigen,
            icon: Icon(_archiv ? Icons.unarchive : Icons.inventory_2_outlined),
            onPressed: () => setState(() => _archiv = !_archiv),
          ),
        ],
      ),
      floatingActionButton: _archiv
          ? null
          : FloatingActionButton.extended(
              heroTag: null,
              onPressed: _neu,
              icon: const Icon(Icons.add),
              label: Text(l.neuesProdukt),
            ),
      body: StreamBuilder<List<ProduktDetails>>(
        stream: _archiv
            ? db.produkteBeobachten().asyncMap(
                (_) => db.produkteLaden(archivierte: true),
              )
            : db.produkteBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          if (liste.isEmpty) {
            return _archiv
                ? LeerHinweis(symbol: Icons.inventory_2, titel: l.archivLeer)
                : LeerHinweis(
                    symbol: Icons.category,
                    titel: l.keineProdukte,
                    text: l.keineProdukteText,
                    knopf: l.neuesProdukt,
                    aktion: _neu,
                  );
          }
          if (_archiv) {
            return ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final p in liste)
                  _ProduktZeile(
                    p,
                    onTap: () => _bearbeiten(p),
                    trailing: IconButton(
                      tooltip: l.wiederherstellen,
                      icon: const Icon(Icons.unarchive),
                      onPressed: () => db.produktArchivieren(
                        p.produkt.id,
                        archiviert: false,
                      ),
                    ),
                  ),
              ],
            );
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: liste.length,
            onReorderItem: (alt, neu) {
              final ids = liste.map((p) => p.produkt.id).toList();
              ids.insert(neu, ids.removeAt(alt));
              db.produktReihenfolge(ids);
            },
            itemBuilder: (context, i) => _ProduktZeile(
              liste[i],
              key: ValueKey(liste[i].produkt.id),
              onTap: () => _bearbeiten(liste[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ProduktZeile extends StatelessWidget {
  const _ProduktZeile(this.p, {super.key, required this.onTap, this.trailing});

  final ProduktDetails p;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final gewinnFarbe = p.gewinnCent > 0
        ? Colors.green.shade600
        : t.colorScheme.error;
    return ListTile(
      onTap: onTap,
      leading: SymbolKreis(
        symbol: p.produkt.symbol,
        farbe: Color(p.anzeigeFarbe),
      ),
      title: Text(p.produkt.name),
      subtitle: Text(
        '${l.kosten} ${euro(p.kostenCent)} · ${dauer((p.produkt.druckzeitMinuten / (p.produkt.stueckProDruck < 1 ? 1 : p.produkt.stueckProDruck)).round())}',
      ),
      trailing:
          trailing ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                euro(p.preisCent),
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '+${euro(p.gewinnCent)}',
                style: t.textTheme.bodySmall?.copyWith(color: gewinnFarbe),
              ),
            ],
          ),
    );
  }
}
