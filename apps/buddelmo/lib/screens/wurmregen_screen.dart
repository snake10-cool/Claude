import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/zahlen.dart';

/// Minispiel: 20 Sekunden lang fallende Würmer antippen.
/// Goldene Würmer zählen 5.
class WurmregenScreen extends StatefulWidget {
  const WurmregenScreen({super.key});

  @override
  State<WurmregenScreen> createState() => _WurmregenScreenState();
}

class _Wurm {
  _Wurm(this.x, this.geschwindigkeit, {this.golden = false});
  final double x; // 0–1
  final double geschwindigkeit; // Bildschirmhöhen pro Sekunde
  final bool golden;
  double y = -0.1;
  bool gefangen = false;
}

const spielDauer = Duration(seconds: 20);

class _WurmregenScreenState extends State<WurmregenScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _wuermer = <_Wurm>[];
  final _zufall = Random();
  Duration _zeit = Duration.zero;
  Duration _letzte = Duration.zero;
  double _bisNaechster = 0;
  int _punkte = 0;
  bool _laeuft = false;
  bool _fertig = false;

  void _start() {
    setState(() {
      _wuermer.clear();
      _punkte = 0;
      _zeit = Duration.zero;
      _letzte = Duration.zero;
      _laeuft = true;
      _fertig = false;
    });
    _ticker.start();
  }

  void _tick(Duration verstrichen) {
    final dt = (verstrichen - _letzte).inMicroseconds / 1e6;
    _letzte = verstrichen;
    _zeit = verstrichen;
    final fortschritt = (_zeit.inMilliseconds / spielDauer.inMilliseconds)
        .clamp(0.0, 1.0);
    _bisNaechster -= dt;
    if (_bisNaechster <= 0) {
      // Immer mehr und immer schnellere Würmer.
      _bisNaechster = 0.7 - 0.45 * fortschritt + _zufall.nextDouble() * 0.2;
      _wuermer.add(
        _Wurm(
          0.08 + _zufall.nextDouble() * 0.84,
          0.25 + 0.35 * fortschritt + _zufall.nextDouble() * 0.15,
          golden: _zufall.nextInt(12) == 0,
        ),
      );
    }
    for (final w in _wuermer) {
      w.y += w.geschwindigkeit * dt;
    }
    _wuermer.removeWhere((w) => w.y > 1.1 || w.gefangen);
    if (_zeit >= spielDauer) {
      _ticker.stop();
      _laeuft = false;
      _fertig = true;
      _abrechnen();
    }
    setState(() {});
  }

  /// Gold pro Punkt: mindestens 10, sonst 5 Sekunden Produktion.
  double get _goldProPunkt => max(10, spiel.s.proSekunde() * 5);

  void _abrechnen() {
    spiel.s.bonusGutschreiben(_punkte * _goldProPunkt);
    if (_punkte > spiel.stand.wurmRekord) spiel.stand.wurmRekord = _punkte;
    spiel.geaendert();
  }

  void _tippen(Offset pos, Size groesse) {
    if (!_laeuft) return;
    for (final w in _wuermer.reversed) {
      final mitte = Offset(w.x * groesse.width, w.y * groesse.height);
      if ((mitte - pos).distance < 44) {
        w.gefangen = true;
        _punkte += w.golden ? 5 : 1;
        HapticFeedback.selectionClick();
        break;
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final rest = spielDauer - _zeit;
    return Scaffold(
      backgroundColor: const Color(0xFF4E342E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E2723),
        foregroundColor: Colors.white,
        title: Text(l.wurmregen),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final groesse = Size(c.maxWidth, c.maxHeight);
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _tippen(d.localPosition, groesse),
            child: Stack(
              children: [
                for (final w in _wuermer)
                  Positioned(
                    left: w.x * groesse.width - 24,
                    top: w.y * groesse.height - 24,
                    child: Text(
                      w.golden ? '🌟' : '🪱',
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Text(
                        '🪱 $_punkte',
                        style: t.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_laeuft)
                        Text(
                          '⏱ ${rest.inSeconds + 1}',
                          style: t.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!_laeuft)
                  Center(
                    child: Card(
                      margin: const EdgeInsets.all(32),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _fertig ? '🎉' : '🪱',
                              style: const TextStyle(fontSize: 56),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _fertig
                                  ? l.wurmErgebnis(_punkte)
                                  : l.wurmregenErklaerung,
                              textAlign: TextAlign.center,
                              style: t.textTheme.titleMedium,
                            ),
                            if (_fertig) ...[
                              const SizedBox(height: 4),
                              Text(
                                l.wurmGold(grosseZahl(_punkte * _goldProPunkt)),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              l.rekord(spiel.stand.wurmRekord),
                              style: t.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _start,
                              child: Text(_fertig ? l.nochmal : l.los),
                            ),
                            if (_fertig)
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(l.zurueckZuMo),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
