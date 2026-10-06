import 'dart:async';
import 'dart:math' as math;

import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/katalog.dart';
import '../logik/spiel.dart';
import '../logik/zahlen.dart';
import '../widgets/mo_maler.dart';
import '../widgets/texte.dart';
import 'dialoge.dart';
import 'shop_screen.dart';
import 'wurmregen_screen.dart';

class SpielScreen extends StatefulWidget {
  const SpielScreen({super.key});

  @override
  State<SpielScreen> createState() => _SpielScreenState();
}

class _Popup {
  _Popup(this.id, this.position, this.text);
  final int id;
  final Offset position;
  final String text;
}

class _SpielScreenState extends State<SpielScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _druck = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
  );
  final _popups = <_Popup>[];
  int _popupId = 0;
  StreamSubscription<Erfolg>? _erfolge;

  @override
  void initState() {
    super.initState();
    _erfolge = spiel.erfolgeNeu.stream.listen((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${e.symbol}  ${context.l.erfolgFreigeschaltet(erfolgName(context.l, e.id))}',
          ),
        ),
      );
    });
    // Offline-Ertrag nach dem ersten Bild zeigen.
    WidgetsBinding.instance.addPostFrameCallback((_) => _offlineZeigen());
    spiel.addListener(_beiAenderung);
  }

  void _beiAenderung() {
    if (spiel.offlineMeldung != null) _offlineZeigen();
  }

  Future<void> _offlineZeigen() async {
    final m = spiel.offlineMeldung;
    if (m == null || !mounted) return;
    spiel.offlineMeldung = null;
    await offlineDialog(context, m.$1, m.$2);
  }

  @override
  void dispose() {
    spiel.removeListener(_beiAenderung);
    _erfolge?.cancel();
    _druck.dispose();
    super.dispose();
  }

  void _tippen(TapDownDetails d) {
    HapticFeedback.lightImpact();
    final w = spiel.tippen();
    _druck.forward(from: 0).then((_) => _druck.reverse());
    final id = _popupId++;
    setState(
      () => _popups.add(_Popup(id, d.localPosition, '+${grosseZahl(w)}')),
    );
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _popups.removeWhere((p) => p.id == id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: spiel,
          builder: (context, _) {
            final s = spiel.s;
            final stand = spiel.stand;
            final jetzt = DateTime.now();
            final schicht = schichtIndex(stand.goldGesamt);
            return Column(
              children: [
                _Kopf(schicht: schicht),
                Expanded(
                  flex: 5,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final groesse = math.min(c.maxWidth, c.maxHeight) * 0.78;
                      final klumpen = spiel.kluempchen;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: ErdeMaler(
                                oben: Color(schichten[schicht].oben),
                                unten: Color(schichten[schicht].unten),
                                tiefe: schicht,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: _tippen,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _druck,
                                  builder: (context, _) => CustomPaint(
                                    size: Size.square(groesse),
                                    painter: MoMaler(druck: _druck.value),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          for (final p in _popups)
                            _ZahlPopup(key: ValueKey(p.id), popup: p),
                          if (klumpen != null)
                            Positioned(
                              left: klumpen.$1.dx * c.maxWidth - 28,
                              top: klumpen.$1.dy * c.maxHeight - 28,
                              child: _Klumpen(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  final g = spiel.klumpenFangen();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l.klumpenGefunden(grosseZahl(g)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Positioned(
                            left: 12,
                            bottom: 8,
                            child: _Abzeichen(
                              text: '${l.tiefe}: ${schichtName(l, schicht)}',
                            ),
                          ),
                          if (s.boostAktiv(jetzt))
                            Positioned(
                              right: 12,
                              bottom: 8,
                              child: _Abzeichen(
                                text:
                                    '⚡ ×2 · ${dauerText(stand.boostBis!.difference(jetzt))}',
                                hervor: true,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                _Aktionen(),
                const Expanded(flex: 4, child: _Panel()),
                WerbeBanner(dienst: werbung),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Kopf extends StatelessWidget {
  const _Kopf({required this.schicht});
  final int schicht;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final s = spiel.s;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: CustomPaint(painter: KlumpenMaler()),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    grosseZahl(spiel.stand.gold),
                    style: t.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  l.proSekunde(grosseZahl(s.proSekunde())),
                  style: t.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (spiel.stand.glitzer > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Chip(
                visualDensity: VisualDensity.compact,
                label: Text('✨ ${spiel.stand.glitzer}'),
              ),
            ),
          IconButton(
            tooltip: l.shop,
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const ShopScreen())),
          ),
        ],
      ),
    );
  }
}

class _Aktionen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final jetzt = DateTime.now();
    final bonus = spiel.s.tagesbonusVerfuegbar(jetzt);
    Widget knopf(
      String symbol,
      String text,
      VoidCallback aktion, {
      bool punkt = false,
    }) => Expanded(
      child: InkWell(
        onTap: aktion,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Badge(
                isLabelVisible: punkt,
                smallSize: 10,
                child: Text(symbol, style: const TextStyle(fontSize: 24)),
              ),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Row(
        children: [
          knopf(
            '🎁',
            l.tagesbonus,
            () => tagesbonusDialog(context),
            punkt: bonus,
          ),
          knopf(
            '🪱',
            l.wurmregen,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const WurmregenScreen()),
            ),
          ),
          knopf('⚡', l.boost, () => boostDialog(context)),
        ],
      ),
    );
  }
}

enum _Menge { eins, zehn, max }

class _Panel extends StatefulWidget {
  const _Panel();

  @override
  State<_Panel> createState() => _PanelState();
}

class _PanelState extends State<_Panel> {
  _Menge _menge = _Menge.eins;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l.helfer),
              Tab(text: l.verbesserungen),
              Tab(text: l.huegel),
            ],
          ),
          Expanded(
            // Eigener Listener: Das Panel ist const und würde sonst beim
            // Gold-Zuwachs nicht neu gebaut.
            child: ListenableBuilder(
              listenable: spiel,
              builder: (context, _) => TabBarView(
                children: [
                  _helferListe(context),
                  _verbesserungsListe(context),
                  const _HuegelTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _helferListe(BuildContext context) {
    final l = context.l;
    final s = spiel.s;
    final sichtbar = helferArten.where(s.helferSichtbar).toList();
    final naechster = helferArten
        .where((h) => !s.helferSichtbar(h))
        .firstOrNull;
    return ListView(
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: SegmentedButton<_Menge>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: _Menge.eins, label: Text('×1')),
              ButtonSegment(value: _Menge.zehn, label: Text('×10')),
              ButtonSegment(value: _Menge.max, label: Text('Max')),
            ],
            selected: {_menge},
            onSelectionChanged: (m) => setState(() => _menge = m.first),
          ),
        ),
        for (final h in sichtbar) _helferZeile(context, h),
        if (naechster != null)
          ListTile(
            leading: const Text('❓', style: TextStyle(fontSize: 28)),
            title: Text(l.naechsterHelfer),
            subtitle: Text(l.abGold(gold(naechster.grundkosten * 0.5))),
          ),
      ],
    );
  }

  Widget _helferZeile(BuildContext context, HelferArt h) {
    final l = context.l;
    final s = spiel.s;
    final anzahl = spiel.stand.helfer[h.id] ?? 0;
    final menge = switch (_menge) {
      _Menge.eins => 1,
      _Menge.zehn => 10,
      _Menge.max => math.max(1, s.helferLeistbar(h)),
    };
    final kosten = s.helferKosten(h, menge);
    final leistbar = spiel.stand.gold >= kosten;
    return ListTile(
      leading: Text(h.symbol, style: const TextStyle(fontSize: 30)),
      title: Text('${helferName(l, h.id)}  ·  $anzahl'),
      subtitle: Text(
        l.helferInfo(
          grosseZahl(h.proSekunde),
          grosseZahl(s.helferProduktion(h)),
        ),
      ),
      trailing: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size(96, 40),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onPressed: leistbar
            ? () {
                HapticFeedback.selectionClick();
                s.helferKaufen(h, menge);
                spiel.geaendert();
              }
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              menge == 1 ? l.kaufen : '+$menge',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              grosseZahl(kosten),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verbesserungsListe(BuildContext context) {
    final l = context.l;
    final s = spiel.s;
    final liste = verbesserungen.where(s.verbesserungSichtbar).toList()
      ..sort((a, b) => a.kosten.compareTo(b.kosten));
    if (liste.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l.keineVerbesserungen, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView(
      children: [
        for (final v in liste)
          ListTile(
            leading: Text(v.symbol, style: const TextStyle(fontSize: 28)),
            title: Text(verbesserungName(l, v)),
            subtitle: Text(verbesserungWirkung(l, v)),
            trailing: FilledButton(
              onPressed: spiel.stand.gold >= v.kosten
                  ? () {
                      s.verbesserungKaufen(v);
                      spiel.geaendert();
                    }
                  : null,
              child: Text(grosseZahl(v.kosten)),
            ),
          ),
      ],
    );
  }
}

class _HuegelTab extends StatelessWidget {
  const _HuegelTab();

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: spiel,
    builder: (context, _) => _bauen(context),
  );

  Widget _bauen(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final s = spiel.s;
    final neu = s.glitzerFuerPrestige();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.neuerHuegel, style: t.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  l.neuerHuegelText(
                    spiel.stand.glitzer,
                    ((s.glitzerFaktor - 1) * 100).round(),
                  ),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: neu > 0
                      ? () => prestigeDialog(context, neu)
                      : null,
                  child: Text(
                    neu > 0
                        ? l.neuerHuegelKnopf(neu)
                        : l.neuerHuegelAb(grosseZahl(prestigeAb)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.erfolge(spiel.stand.erfolge.length, erfolge.length),
          style: t.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in erfolge)
              Tooltip(
                message: spiel.stand.erfolge.contains(e.id)
                    ? erfolgName(l, e.id)
                    : '???',
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: spiel.stand.erfolge.contains(e.id)
                        ? t.colorScheme.primaryContainer
                        : t.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spiel.stand.erfolge.contains(e.id) ? e.symbol : '🔒',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ZahlPopup extends StatelessWidget {
  const _ZahlPopup({super.key, required this.popup});
  final _Popup popup;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 850),
    builder: (context, v, _) => Positioned(
      left: popup.position.dx - 40,
      top: popup.position.dy - 30 - v * 70,
      child: IgnorePointer(
        child: Opacity(
          opacity: 1 - v,
          child: SizedBox(
            width: 80,
            child: Text(
              popup.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _Klumpen extends StatefulWidget {
  const _Klumpen({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_Klumpen> createState() => _KlumpenState();
}

class _KlumpenState extends State<_Klumpen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _puls = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _puls.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: widget.onTap,
    child: AnimatedBuilder(
      animation: _puls,
      builder: (context, child) =>
          Transform.scale(scale: 0.9 + _puls.value * 0.2, child: child),
      child: SizedBox(
        width: 56,
        height: 56,
        child: CustomPaint(painter: KlumpenMaler()),
      ),
    ),
  );
}

class _Abzeichen extends StatelessWidget {
  const _Abzeichen({required this.text, this.hervor = false});
  final String text;
  final bool hervor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: hervor ? const Color(0xCCFFC107) : Colors.black45,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: hervor ? Colors.black : Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    ),
  );
}
