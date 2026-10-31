import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../services/empfehlung.dart';
import '../widgets/buch_kachel.dart';

enum _Richtung { rechts, links, hoch, runter }

/// „Was lese ich als Nächstes?" – Bücher einzeln wischen:
/// → Wunschliste · ← nicht für mich · ↑ schon gelesen · ↓ überspringen.
class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with SingleTickerProviderStateMixin {
  final _uebersprungen = <String>{};
  List<Empfehlung> _stapel = [];
  var _versatz = Offset.zero;
  late final _animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
  Animation<Offset>? _flug;
  var _geladen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_geladen) {
      _geladen = true;
      _nachfuellen();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _nachfuellen() {
    final s = SpeicherScope.of(context);
    _stapel = empfehlen(
      antworten: s.antworten,
      eintraege: s.eintraege,
      buecher: s.alleBuecher,
      vorlieben: s.vorlieben,
      nichtFuerMich: s.abgelehnt,
      ausschliessen: {...s.geprueft, ..._uebersprungen},
      anzahl: 50,
    );
  }

  Future<void> _entscheiden(_Richtung r) async {
    if (_stapel.isEmpty || _animation.isAnimating) return;
    final buch = _stapel.first.buch;
    final groesse = MediaQuery.sizeOf(context);
    final ziel = switch (r) {
      _Richtung.rechts => Offset(groesse.width * 1.5, _versatz.dy),
      _Richtung.links => Offset(-groesse.width * 1.5, _versatz.dy),
      _Richtung.hoch => Offset(_versatz.dx, -groesse.height),
      _Richtung.runter => Offset(_versatz.dx, groesse.height),
    };
    _flug = Tween(begin: _versatz, end: ziel).animate(CurvedAnimation(parent: _animation, curve: Curves.easeIn));
    await _animation.forward(from: 0);

    if (!mounted) return;
    final s = SpeicherScope.of(context);
    switch (r) {
      case _Richtung.rechts:
        await s.eintragSetzen(buch.id, Eintrag(status: Status.wunschliste));
      case _Richtung.links:
        await s.ablehnen(buch.id);
      case _Richtung.hoch:
        await s.abhaken(buch.id, true);
      case _Richtung.runter:
        _uebersprungen.add(buch.id);
    }
    if (!mounted) return;
    setState(() {
      _versatz = Offset.zero;
      _flug = null;
      _animation.reset();
      _nachfuellen();
    });
  }

  _Richtung? _richtungAus(Offset o, Size g) {
    if (o.dx.abs() > o.dy.abs()) {
      if (o.dx > g.width * 0.25) return _Richtung.rechts;
      if (o.dx < -g.width * 0.25) return _Richtung.links;
    } else {
      if (o.dy < -g.height * 0.15) return _Richtung.hoch;
      if (o.dy > g.height * 0.15) return _Richtung.runter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final groesse = MediaQuery.sizeOf(context);
    final hinweis = _richtungAus(_versatz, groesse);
    return Scaffold(
      appBar: AppBar(title: const Text('Was lese ich als Nächstes?')),
      body: _stapel.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Keine Vorschläge mehr – du hast alles durchgewischt! 🎉', textAlign: TextAlign.center),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        if (_stapel.length > 1) Positioned.fill(child: _Karte(_stapel[1], hinten: true)),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, kind) {
                              final o = _flug?.value ?? _versatz;
                              return Transform.translate(
                                offset: o,
                                child: Transform.rotate(angle: o.dx / groesse.width * pi / 10, child: kind),
                              );
                            },
                            child: GestureDetector(
                              onPanUpdate: (d) => setState(() => _versatz += d.delta),
                              onPanEnd: (_) {
                                final r = _richtungAus(_versatz, groesse);
                                if (r != null) {
                                  _entscheiden(r);
                                } else {
                                  setState(() => _versatz = Offset.zero);
                                }
                              },
                              child: _Karte(_stapel.first, hinweis: hinweis),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _Knopf(Icons.close, 'Nicht für mich', Colors.red, () => _entscheiden(_Richtung.links)),
                        _Knopf(Icons.skip_next, 'Überspringen', Colors.grey, () => _entscheiden(_Richtung.runter)),
                        _Knopf(Icons.check, 'Schon gelesen', Colors.blue, () => _entscheiden(_Richtung.hoch)),
                        _Knopf(Icons.bookmark_add, 'Wunschliste', Colors.green, () => _entscheiden(_Richtung.rechts)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Karte extends StatelessWidget {
  const _Karte(this.e, {this.hinweis, this.hinten = false});

  final Empfehlung e;
  final _Richtung? hinweis;
  final bool hinten;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buch = e.buch;
    final (text, farbe) = switch (hinweis) {
      _Richtung.rechts => ('WUNSCHLISTE', Colors.green),
      _Richtung.links => ('NICHT FÜR MICH', Colors.red),
      _Richtung.hoch => ('SCHON GELESEN', Colors.blue),
      _Richtung.runter => ('ÜBERSPRINGEN', Colors.grey),
      null => ('', Colors.transparent),
    };
    return Opacity(
      opacity: hinten ? 0.6 : 1,
      child: Card(
        elevation: hinten ? 1 : 4,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(20),
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Center(child: BuchCover(buch, breite: 140)),
                const SizedBox(height: 16),
                Text(buch.titel, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  [buch.autor, if (buch.jahr > 0) '${buch.jahr}', if (buch.seiten > 0) '${buch.seiten} S.'].join(' · '),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                if (buch.beschreibung.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(buch.beschreibung, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final g in e.gruende) Chip(label: Text(g), visualDensity: VisualDensity.compact),
                  ],
                ),
              ],
            ),
            if (hinweis != null)
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: farbe, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(text, style: theme.textTheme.titleLarge?.copyWith(color: farbe, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Knopf extends StatelessWidget {
  const _Knopf(this.icon, this.text, this.farbe, this.onTap);

  final IconData icon;
  final String text;
  final Color farbe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filledTonal(
            tooltip: text,
            onPressed: onTap,
            iconSize: 28,
            icon: Icon(icon, color: farbe),
          ),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}
