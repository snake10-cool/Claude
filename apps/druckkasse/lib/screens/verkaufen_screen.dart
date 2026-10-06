import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../daten/datenbank.dart';
import '../daten/produkt_details.dart';
import '../daten/tipps.dart';
import '../l10n/l.dart';
import '../logik/sparziel_rechner.dart';
import '../logik/statistik.dart';
import '../logik/typen.dart';
import '../widgets/allgemein.dart';
import '../widgets/format.dart';
import '../widgets/sparziel_karte.dart';
import 'drucker_screen.dart';
import 'filamente_screen.dart';
import 'produkt_bearbeiten_screen.dart';
import 'sparziele_screen.dart';

/// Schnell-Verkauf: große Knöpfe, ein Tipp = +1 verkauft.
class VerkaufenScreen extends StatefulWidget {
  const VerkaufenScreen({super.key, required this.zuProdukten});

  final VoidCallback zuProdukten;

  @override
  State<VerkaufenScreen> createState() => _VerkaufenScreenState();
}

class _VerkaufenScreenState extends State<VerkaufenScreen> {
  static const _tippAusSchluessel = 'tipp_ausgeblendet_am';
  bool _tippZeigen = false;

  DateTime get _heute {
    final j = DateTime.now();
    return DateTime(j.year, j.month, j.day);
  }

  String get _heuteText => _heute.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(
        () => _tippZeigen = prefs.getString(_tippAusSchluessel) != _heuteText,
      );
    });
  }

  Future<void> _tippAusblenden() async {
    setState(() => _tippZeigen = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tippAusSchluessel, _heuteText);
  }

  Future<void> _verkaufen(
    ProduktDetails p, {
    int menge = 1,
    int? preis,
    Zahlungsart? art,
  }) async {
    HapticFeedback.lightImpact();
    final id = await db.verkaufen(
      p,
      menge: menge,
      einzelpreisCent: preis,
      zahlungsart: art,
    );
    if (!mounted) return;
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l.verkauftMeldung(
            menge,
            p.produkt.name,
            euro(menge * (preis ?? p.preisCent)),
          ),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l.rueckgaengig,
          onPressed: () => db.verkaufLoeschen(id),
        ),
      ),
    );
    await _sparzielePruefen();
    // Ruhiger Moment nach einer erfolgreichen Aktion.
    if (await db.anzahlVerkaeufe() >= 10) BewertungsBitte.vielleichtFragen();
  }

  /// Feiert, wenn ein angeheftetes Sparziel gerade erreicht wurde.
  Future<void> _sparzielePruefen() async {
    final ziele = await db.sparzieleBeobachten().first;
    for (final z in ziele.where((z) => z.erreichtAm == null)) {
      final verkaeufe = await db.verkaeufeLaden(z.startDatum, DateTime(9999));
      final stand = sparStand(
        SparBasis.values[z.basis],
        auswerten(verkaeufe.map((v) => v.zeile)),
      );
      if (stand >= z.zielCent) {
        await db.sparzielErreicht(z.id, DateTime.now());
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Text(z.symbol, style: const TextStyle(fontSize: 48)),
            title: Text(context.l.zielErreichtTitel),
            content: Text(context.l.zielErreichtText(z.name)),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l.super_),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _sonderverkauf(ProduktDetails p) async {
    final ergebnis = await showModalBottomSheet<(int, int, Zahlungsart)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SonderverkaufBlatt(produkt: p),
    );
    if (ergebnis == null) return;
    final (menge, preis, art) = ergebnis;
    await _verkaufen(p, menge: menge, preis: preis, art: art);
  }

  void _heuteZeigen() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HeuteBlatt(von: _heute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.tabVerkaufen),
        actions: [
          IconButton(
            tooltip: l.heuteVerkauft,
            icon: const Icon(Icons.receipt_long),
            onPressed: _heuteZeigen,
          ),
        ],
      ),
      body: StreamBuilder<List<ProduktDetails>>(
        stream: db.produkteBeobachten(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final produkte = snap.data!;
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverList.list(
                  children: [
                    _HeuteKarte(von: _heute, onTap: _heuteZeigen),
                    const SizedBox(height: 12),
                    StreamBuilder<List<Sparziel>>(
                      stream: db.sparzieleBeobachten(),
                      builder: (context, s) {
                        final ziel = (s.data ?? const <Sparziel>[])
                            .where((z) => z.angeheftet)
                            .firstOrNull;
                        if (ziel == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SparzielKarte(
                            ziel: ziel,
                            produkte: produkte,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SparzieleScreen(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (_tippZeigen)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TippKarte(
                          text: tippDesTages(DateTime.now()),
                          schliessen: _tippAusblenden,
                        ),
                      ),
                  ],
                ),
              ),
              if (produkte.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErsteSchritte(zuProdukten: widget.zuProdukten),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: produkte.length,
                    itemBuilder: (context, i) => _ProduktKnopf(
                      produkt: produkte[i],
                      onTap: () => _verkaufen(produkte[i]),
                      onLongPress: () => _sonderverkauf(produkte[i]),
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

class _ProduktKnopf extends StatelessWidget {
  const _ProduktKnopf({
    required this.produkt,
    required this.onTap,
    required this.onLongPress,
  });

  final ProduktDetails produkt;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final farbe = Color(produkt.anzeigeFarbe);
    final dunkel = t.brightness == Brightness.dark;
    final hintergrund = Color.alphaBlend(
      farbe.withValues(alpha: dunkel ? 0.35 : 0.22),
      t.colorScheme.surfaceContainerLow,
    );
    return Material(
      color: hintergrund,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: farbe.withValues(alpha: 0.7), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                produkt.produkt.symbol,
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(height: 6),
              Text(
                produkt.produkt.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(euro(produkt.preisCent), style: t.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// „Heute: 23,50 € · 7 Stück · Gewinn 18,20 €“
class _HeuteKarte extends StatelessWidget {
  const _HeuteKarte({required this.von, required this.onTap});
  final DateTime von;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return StreamBuilder<List<Verkauf>>(
      stream: db.verkaeufeBeobachten(von, von.add(const Duration(days: 1))),
      builder: (context, snap) {
        final a = auswerten((snap.data ?? const []).map((v) => v.zeile));
        Widget wert(String titel, String zahl) => Expanded(
          child: Column(
            children: [
              Text(
                zahl,
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(titel, style: t.textTheme.bodySmall),
            ],
          ),
        );
        return Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Row(
                children: [
                  wert(l.heuteUmsatz, euro(a.umsatzCent)),
                  wert(l.heuteGewinn, euro(a.gewinnCent)),
                  wert(l.heuteStueck, '${a.stueck}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TippKarte extends StatelessWidget {
  const _TippKarte({required this.text, required this.schliessen});
  final String text;
  final VoidCallback schliessen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('💡', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l.tippDesTages,
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(text, style: t.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: context.l.ausblenden,
              icon: const Icon(Icons.close),
              onPressed: schliessen,
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkliste, solange es noch keine Produkte gibt.
class _ErsteSchritte extends StatelessWidget {
  const _ErsteSchritte({required this.zuProdukten});
  final VoidCallback zuProdukten;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    void oeffnen(Widget seite) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => seite));
    return StreamBuilder<List<Drucker>>(
      stream: db.druckerBeobachten(),
      builder: (context, d) => StreamBuilder<List<Filament>>(
        stream: db.filamenteBeobachten(),
        builder: (context, f) {
          final hatDrucker = (d.data ?? const []).isNotEmpty;
          final hatFilament = (f.data ?? const []).isNotEmpty;
          Widget schritt(int nr, String text, bool fertig, VoidCallback tap) =>
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: fertig ? const Icon(Icons.check) : Text('$nr'),
                  ),
                  title: Text(
                    text,
                    style: fertig
                        ? const TextStyle(
                            decoration: TextDecoration.lineThrough,
                          )
                        : null,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: tap,
                ),
              );
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.ersteSchritteTitel,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(l.ersteSchritteText),
                const SizedBox(height: 16),
                schritt(
                  1,
                  l.schrittDrucker,
                  hatDrucker,
                  () => oeffnen(const DruckerScreen()),
                ),
                const SizedBox(height: 8),
                schritt(
                  2,
                  l.schrittFilament,
                  hatFilament,
                  () => oeffnen(const FilamenteScreen()),
                ),
                const SizedBox(height: 8),
                schritt(
                  3,
                  l.schrittProdukt,
                  false,
                  () => oeffnen(const ProduktBearbeitenScreen()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Lange drücken: Menge, Sonderpreis und Zahlungsart wählen.
class _SonderverkaufBlatt extends StatefulWidget {
  const _SonderverkaufBlatt({required this.produkt});
  final ProduktDetails produkt;

  @override
  State<_SonderverkaufBlatt> createState() => _SonderverkaufBlattState();
}

class _SonderverkaufBlattState extends State<_SonderverkaufBlatt> {
  int _menge = 1;
  late final _preis = TextEditingController(
    text: euroFeld(widget.produkt.preisCent),
  );
  late Zahlungsart _art =
      Zahlungsart.values[widget.produkt.einstellungen.standardZahlungsart];

  @override
  void dispose() {
    _preis.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final p = widget.produkt;
    final einzel = parseEuro(_preis.text) ?? p.preisCent;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(p.produkt.symbol, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(p.produkt.name, style: t.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(l.menge, style: t.textTheme.titleMedium),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: _menge > 1 ? () => setState(() => _menge--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 48,
                child: Text(
                  '$_menge',
                  textAlign: TextAlign.center,
                  style: t.textTheme.headlineSmall,
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _menge++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          EuroFeld(
            controller: _preis,
            label: l.preisProStueck,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          SegmentedButton<Zahlungsart>(
            segments: [
              for (final a in Zahlungsart.values)
                ButtonSegment(value: a, label: Text(zahlungsartName(l, a))),
            ],
            selected: {_art},
            onSelectionChanged: (s) => setState(() => _art = s.first),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, (_menge, einzel, _art)),
            icon: const Icon(Icons.check),
            label: Text(l.verkaufenFuer(euro(_menge * einzel))),
          ),
        ],
      ),
    );
  }
}

/// Liste der heutigen Verkäufe mit Löschen.
class _HeuteBlatt extends StatelessWidget {
  const _HeuteBlatt({required this.von});
  final DateTime von;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scroll) => StreamBuilder<List<Verkauf>>(
        stream: db.verkaeufeBeobachten(von, von.add(const Duration(days: 1))),
        builder: (context, snap) {
          final liste = snap.data ?? const <Verkauf>[];
          return ListView(
            controller: scroll,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  l.heuteVerkauft,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (liste.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.heuteNochNichts, textAlign: TextAlign.center),
                ),
              for (final v in liste)
                Dismissible(
                  key: ValueKey(v.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete),
                  ),
                  onDismissed: (_) => db.verkaufLoeschen(v.id),
                  child: ListTile(
                    leading: Text(uhrzeit(v.zeitpunkt)),
                    title: Text('${v.menge}× ${v.produktName}'),
                    subtitle: Text(
                      zahlungsartName(l, Zahlungsart.values[v.zahlungsart]) +
                          (v.auftragId != null ? ' · ${l.ausAuftrag}' : ''),
                    ),
                    trailing: Text(
                      euro(v.menge * v.einzelpreisCent),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              if (liste.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l.wischenZumLoeschen,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

String zahlungsartName(AppLocalizations l, Zahlungsart a) => switch (a) {
  Zahlungsart.bar => l.zahlungBar,
  Zahlungsart.karte => l.zahlungKarte,
  Zahlungsart.online => l.zahlungOnline,
};
