import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/sudoku.dart';
import '../widgets/ergebnis.dart';
import 'heute_screen.dart';

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({
    super.key,
    required this.nummer,
    required this.stufe,
    this.zaehlt = true,
  });

  final int nummer;
  final Stufe stufe;
  final bool zaehlt;

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with WidgetsBindingObserver {
  late final Raster _vorgabe;
  late final Raster _loesung;
  late Raster _feld;
  late List<Set<int>> _notizen;
  int? _auswahl;
  bool _notizModus = false;
  bool _fertig = false;
  int _sekunden = 0;
  Timer? _uhr;

  String get _schluessel => 'sudoku:${widget.stufe.name}:${widget.nummer}';

  @override
  void initState() {
    super.initState();
    final (r, l) = sudokuErzeugen(
      sudokuSeed(widget.nummer, widget.stufe),
      widget.stufe,
    );
    _vorgabe = r;
    _loesung = l;
    _feld = List.of(r);
    _notizen = List.generate(81, (_) => <int>{});
    if (widget.zaehlt) {
      final e = fortschritt.ergebnis(_schluessel);
      final lauf = fortschritt.laufend[_schluessel];
      if (e != null) {
        _feld = List.of(_loesung);
        _fertig = true;
        _sekunden = e['sekunden'] as int? ?? 0;
      } else if (lauf != null) {
        _feld = (lauf['feld'] as List).cast<int>();
        _sekunden = lauf['sekunden'] as int? ?? 0;
        final n = (lauf['notizen'] as List?)?.cast<List<dynamic>>();
        if (n != null) _notizen = [for (final x in n) x.cast<int>().toSet()];
      }
    }
    WidgetsBinding.instance.addObserver(this);
    if (!_fertig) _uhrStarten();
  }

  void _uhrStarten() {
    _uhr?.cancel();
    _uhr = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() => _sekunden++),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (_fertig) return;
    if (s == AppLifecycleState.resumed) {
      _uhrStarten();
    } else {
      _uhr?.cancel();
      _merken();
    }
  }

  @override
  void dispose() {
    _uhr?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (!_fertig && _sekunden > 0) _merken();
    super.dispose();
  }

  void _merken() {
    if (!widget.zaehlt) return;
    fortschritt.zwischenstand(_schluessel, {
      'feld': _feld,
      'sekunden': _sekunden,
      'notizen': [for (final n in _notizen) n.toList()],
    });
  }

  void _eingeben(int z) {
    final i = _auswahl;
    if (i == null || _fertig || _vorgabe[i] != 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (_notizModus) {
        _notizen[i].contains(z) ? _notizen[i].remove(z) : _notizen[i].add(z);
      } else {
        _feld[i] = _feld[i] == z ? 0 : z;
        _notizen[i].clear();
        if (_feld[i] != 0) _notizenAufraeumen(i, z);
      }
    });
    if (geloest(_feld, _loesung)) _geschafft();
  }

  /// Gesetzte Zahl aus den Notizen in Zeile, Spalte und Block entfernen.
  void _notizenAufraeumen(int i, int z) {
    final zeile = i ~/ 9, spalte = i % 9;
    for (var k = 0; k < 81; k++) {
      final gleich =
          k ~/ 9 == zeile ||
          k % 9 == spalte ||
          (k ~/ 27 == i ~/ 27 && (k % 9) ~/ 3 == spalte ~/ 3);
      if (gleich) _notizen[k].remove(z);
    }
  }

  void _loeschen() {
    final i = _auswahl;
    if (i == null || _fertig || _vorgabe[i] != 0) return;
    setState(() {
      _feld[i] = 0;
      _notizen[i].clear();
    });
  }

  Future<void> _tipp() async {
    final l = context.l;
    final leer = [
      for (var i = 0; i < 81; i++)
        if (_feld[i] != _loesung[i]) i,
    ];
    if (leer.isEmpty) return;
    final ok = kauf.istPro || await werbung.belohnungZeigen();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.videoNichtVerfuegbar)));
      return;
    }
    final i = _auswahl != null && leer.contains(_auswahl)
        ? _auswahl!
        : leer.first;
    setState(() {
      _feld[i] = _loesung[i];
      _notizen[i].clear();
      _auswahl = i;
    });
    if (geloest(_feld, _loesung)) _geschafft();
  }

  Future<void> _geschafft() async {
    final l = context.l;
    _fertig = true;
    _uhr?.cancel();
    if (widget.zaehlt) {
      await fortschritt.beenden(_schluessel, {
        'geloest': true,
        'sekunden': _sekunden,
      });
    }
    if (!mounted) return;
    setState(() {});
    final stufe = stufeName(l, widget.stufe);
    await ergebnisZeigen(
      context,
      geloest: true,
      titel: l.super_,
      text: l.sudokuGeschafft(stufe, zeitText(_sekunden)),
      teilen: widget.zaehlt
          ? '${appInfo.name} #${widget.nummer} · ${l.sudoku} ($stufe) ✅ ${zeitText(_sekunden)}'
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final c = t.colorScheme;
    final fehler = konflikte(_feld);
    final auswahlZahl = _auswahl == null ? 0 : _feld[_auswahl!];
    return Scaffold(
      appBar: AppBar(
        title: Text('${l.sudoku} · ${stufeName(l, widget.stufe)}'),
        actions: [
          Center(
            child: Text(zeitText(_sekunden), style: t.textTheme.titleMedium),
          ),
          IconButton(
            tooltip: l.tipp,
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: _fertig ? null : _tipp,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: c.onSurface, width: 2),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                            ),
                        itemCount: 81,
                        itemBuilder: (context, i) {
                          final z = _feld[i];
                          final vorgabe = _vorgabe[i] != 0;
                          final zeile = i ~/ 9, spalte = i % 9;
                          final ausgewaehlt = _auswahl == i;
                          final gleicheZahl =
                              auswahlZahl != 0 && z == auswahlZahl;
                          final bezug =
                              _auswahl != null &&
                              (zeile == _auswahl! ~/ 9 ||
                                  spalte == _auswahl! % 9 ||
                                  (zeile ~/ 3 == _auswahl! ~/ 27 &&
                                      spalte ~/ 3 == (_auswahl! % 9) ~/ 3));
                          Color? hinter;
                          if (ausgewaehlt) {
                            hinter = c.primary.withValues(alpha: 0.35);
                          } else if (gleicheZahl) {
                            hinter = c.primary.withValues(alpha: 0.2);
                          } else if (bezug) {
                            hinter = c.primary.withValues(alpha: 0.07);
                          }
                          final dick = BorderSide(
                            color: c.onSurface,
                            width: 1.5,
                          );
                          final duenn = BorderSide(
                            color: c.outlineVariant,
                            width: 0.5,
                          );
                          return GestureDetector(
                            onTap: () => setState(() => _auswahl = i),
                            child: Container(
                              decoration: BoxDecoration(
                                color: hinter,
                                border: Border(
                                  right: spalte == 8
                                      ? BorderSide.none
                                      : (spalte % 3 == 2 ? dick : duenn),
                                  bottom: zeile == 8
                                      ? BorderSide.none
                                      : (zeile % 3 == 2 ? dick : duenn),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: z != 0
                                  ? FittedBox(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          '$z',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: vorgabe
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color:
                                                fehler.contains(i) && !vorgabe
                                                ? c.error
                                                : vorgabe
                                                ? c.onSurface
                                                : c.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _Notizen(_notizen[i]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      avatar: const Icon(Icons.edit_note, size: 18),
                      label: Text(l.notizen),
                      selected: _notizModus,
                      onSelected: (v) => setState(() => _notizModus = v),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _loeschen,
                    icon: const Icon(Icons.backspace_outlined),
                    label: Text(l.loeschen),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Row(
                children: [
                  for (var z = 1; z <= 9; z++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 54),
                          ),
                          onPressed: _fertig ? null : () => _eingeben(z),
                          child: Text(
                            '$z',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
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

class _Notizen extends StatelessWidget {
  const _Notizen(this.zahlen);
  final Set<int> zahlen;

  @override
  Widget build(BuildContext context) {
    if (zahlen.isEmpty) return const SizedBox.shrink();
    final farbe = Theme.of(context).colorScheme.onSurfaceVariant;
    return GridView.count(
      crossAxisCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      children: [
        for (var z = 1; z <= 9; z++)
          Center(
            child: FittedBox(
              child: Text(
                zahlen.contains(z) ? '$z' : ' ',
                style: TextStyle(fontSize: 10, color: farbe),
              ),
            ),
          ),
      ],
    );
  }
}
