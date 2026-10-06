import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/schiebe.dart';
import '../widgets/ergebnis.dart';
import 'heute_screen.dart';

const _groesse = 4;

class SchiebeScreen extends StatefulWidget {
  const SchiebeScreen({super.key, required this.nummer, this.zaehlt = true});
  final int nummer;
  final bool zaehlt;

  @override
  State<SchiebeScreen> createState() => _SchiebeScreenState();
}

class _SchiebeScreenState extends State<SchiebeScreen> {
  late Schiebe _s;
  int _sekunden = 0;
  Timer? _uhr;
  bool _fertig = false;

  String get _schluessel => 'schiebe:${widget.nummer}';

  @override
  void initState() {
    super.initState();
    _s = Schiebe.gemischt(_groesse, schiebeSeed(widget.nummer));
    if (widget.zaehlt) {
      final e = fortschritt.ergebnis(_schluessel);
      final lauf = fortschritt.laufend[_schluessel];
      if (e != null) {
        _s = Schiebe.geloest(_groesse)..zuege = e['zuege'] as int? ?? 0;
        _sekunden = e['sekunden'] as int? ?? 0;
        _fertig = true;
      } else if (lauf != null) {
        _s = Schiebe(_groesse, (lauf['felder'] as List).cast<int>())
          ..zuege = lauf['zuege'] as int? ?? 0;
        _sekunden = lauf['sekunden'] as int? ?? 0;
      }
    }
  }

  @override
  void dispose() {
    _uhr?.cancel();
    if (!_fertig && widget.zaehlt && _s.zuege > 0) {
      fortschritt.zwischenstand(_schluessel, {
        'felder': _s.felder,
        'zuege': _s.zuege,
        'sekunden': _sekunden,
      });
    }
    super.dispose();
  }

  Future<void> _tippen(int i) async {
    if (_fertig) return;
    if (_s.tippen(i) == 0) return;
    HapticFeedback.selectionClick();
    _uhr ??= Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _sekunden++),
    );
    setState(() {});
    if (_s.istGeloest) {
      final l = context.l;
      _fertig = true;
      _uhr?.cancel();
      if (widget.zaehlt) {
        await fortschritt.beenden(_schluessel, {
          'geloest': true,
          'zuege': _s.zuege,
          'sekunden': _sekunden,
        });
      }
      if (!mounted) return;
      await ergebnisZeigen(
        context,
        geloest: true,
        titel: l.super_,
        text: l.schiebeGeschafft(_s.zuege, zeitText(_sekunden)),
        teilen: widget.zaehlt
            ? '${appInfo.name} #${widget.nummer} · ${l.schiebepuzzle} ✅ ${_s.zuege} ${l.zuegeKurz}, ${zeitText(_sekunden)}'
            : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final c = t.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.zaehlt
              ? '${l.schiebepuzzle} #${widget.nummer}'
              : l.schiebepuzzle,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${l.zuege}: ${_s.zuege}',
                    style: t.textTheme.titleLarge,
                  ),
                  Text(
                    '⏱ ${zeitText(_sekunden)}',
                    style: t.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, b) {
                        final kante = b.maxWidth / _groesse;
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: c.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            for (var i = 0; i < _s.felder.length; i++)
                              if (_s.felder[i] != 0)
                                AnimatedPositioned(
                                  key: ValueKey(_s.felder[i]),
                                  duration: const Duration(milliseconds: 120),
                                  left: (i % _groesse) * kante,
                                  top: (i ~/ _groesse) * kante,
                                  width: kante,
                                  height: kante,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Material(
                                      color: _fertig
                                          ? const Color(0xFF16A34A)
                                          : _s.felder[i] == i + 1
                                          ? c.primary
                                          : c.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => _tippen(i),
                                        child: Center(
                                          child: Text(
                                            '${_s.felder[i]}',
                                            style: TextStyle(
                                              fontSize: kante * 0.38,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  _fertig ||
                                                      _s.felder[i] == i + 1
                                                  ? Colors.white
                                                  : c.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Text(
                l.schiebeHilfe,
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
