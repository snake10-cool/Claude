import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/wortraetsel.dart';
import '../widgets/ergebnis.dart';

/// Worträtsel: 5 Buchstaben, 6 Versuche.
class WortScreen extends StatefulWidget {
  const WortScreen({super.key, required this.nummer, this.zaehlt = true});
  final int nummer;

  /// `false` im Endlos-Modus: nichts wird gespeichert.
  final bool zaehlt;

  @override
  State<WortScreen> createState() => _WortScreenState();
}

class _WortScreenState extends State<WortScreen>
    with SingleTickerProviderStateMixin {
  late final String _loesung = wortDesTages(Woerter.loesungen, widget.nummer);
  final _versuche = <String>[];
  String _eingabe = '';
  bool _fertig = false;
  late final AnimationController _wackeln = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );

  /// Per Video verratene Buchstaben: Stelle → Buchstabe.
  final _tipps = <int, String>{};

  String get _schluessel => 'wort:${widget.nummer}';

  @override
  void initState() {
    super.initState();
    if (!widget.zaehlt) return;
    final e = fortschritt.ergebnis(_schluessel);
    final l = e ?? fortschritt.laufend[_schluessel];
    if (l != null) {
      _versuche.addAll(((l['liste'] as List?) ?? const []).cast<String>());
      _fertig = e != null;
    }
  }

  @override
  void dispose() {
    _wackeln.dispose();
    super.dispose();
  }

  void _taste(String t) {
    if (_fertig) return;
    HapticFeedback.selectionClick();
    setState(() {
      if (t == '⌫') {
        if (_eingabe.isNotEmpty) {
          _eingabe = _eingabe.substring(0, _eingabe.length - 1);
        }
      } else if (_eingabe.length < wortLaenge) {
        _eingabe += t;
      }
    });
  }

  Future<void> _absenden() async {
    final l = context.l;
    if (_fertig) return;
    if (_eingabe.length < wortLaenge) {
      _fehler(l.zuKurz);
      return;
    }
    if (!Woerter.erlaubt.contains(_eingabe)) {
      _fehler(l.keinWort);
      return;
    }
    setState(() {
      _versuche.add(_eingabe);
      _eingabe = '';
    });
    final gewonnen = _versuche.last == _loesung;
    if (gewonnen || _versuche.length >= maxVersuche) {
      _fertig = true;
      if (widget.zaehlt) {
        await fortschritt.beenden(_schluessel, {
          'geloest': gewonnen,
          'versuche': _versuche.length,
          'liste': _versuche,
        });
      }
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      await ergebnisZeigen(
        context,
        geloest: gewonnen,
        titel: gewonnen ? l.super_ : l.leiderNicht,
        text: gewonnen
            ? l.wortGeschafft(_versuche.length)
            : l.wortWar(_loesung.toUpperCase()),
        teilen: widget.zaehlt
            ? '${appInfo.name} #${widget.nummer} · ${l.wortraetsel} ${gewonnen ? _versuche.length : 'X'}/$maxVersuche\n${emojiRaster(_versuche, _loesung)}'
            : null,
      );
    } else if (widget.zaehlt) {
      await fortschritt.zwischenstand(_schluessel, {'liste': _versuche});
    }
  }

  void _fehler(String text) {
    HapticFeedback.heavyImpact();
    _wackeln.forward(from: 0);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 1)),
      );
  }

  Future<void> _tipp() async {
    final l = context.l;
    final bekannt = <int>{
      ..._tipps.keys,
      for (final v in _versuche)
        for (var i = 0; i < wortLaenge; i++)
          if (v[i] == _loesung[i]) i,
    };
    final offen = [
      for (var i = 0; i < wortLaenge; i++)
        if (!bekannt.contains(i)) i,
    ];
    if (offen.isEmpty) return;
    final ok = kauf.istPro || await werbung.belohnungZeigen();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.videoNichtVerfuegbar)));
      return;
    }
    setState(() => _tipps[offen.first] = _loesung[offen.first]);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final status = tastaturStatus(_versuche, _loesung);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.zaehlt ? '${l.wortraetsel} #${widget.nummer}' : l.wortraetsel,
        ),
        actions: [
          if (!_fertig)
            IconButton(
              tooltip: l.tipp,
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: _tipp,
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_tipps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.tippText(
                    _tipps.entries
                        .map((e) => '${e.key + 1}: ${e.value.toUpperCase()}')
                        .join(', '),
                  ),
                ),
              ),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _wackeln,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(sin(_wackeln.value * pi * 6) * 8, 0),
                    child: child,
                  ),
                  child: _Raster(
                    versuche: _versuche,
                    eingabe: _eingabe,
                    loesung: _loesung,
                    fertig: _fertig,
                  ),
                ),
              ),
            ),
            _Tastatur(status: status, onTaste: _taste, onEnter: _absenden),
          ],
        ),
      ),
    );
  }
}

Color feldFarbe(Feld f, ColorScheme c) => switch (f) {
  Feld.richtig => const Color(0xFF16A34A),
  Feld.enthalten => const Color(0xFFD4A017),
  Feld.falsch =>
    c.brightness == Brightness.dark
        ? const Color(0xFF3F3F46)
        : const Color(0xFF787C7E),
};

class _Raster extends StatelessWidget {
  const _Raster({
    required this.versuche,
    required this.eingabe,
    required this.loesung,
    required this.fertig,
  });

  final List<String> versuche;
  final String eingabe;
  final String loesung;
  final bool fertig;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, groesse) {
        final kante = ((groesse.maxHeight - 40) / maxVersuche).clamp(
          36.0,
          62.0,
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var z = 0; z < maxVersuche; z++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var s = 0; s < wortLaenge; s++)
                    () {
                      String buchstabe = '';
                      Color? farbe;
                      var rand = c.outlineVariant;
                      if (z < versuche.length) {
                        buchstabe = versuche[z][s];
                        farbe = feldFarbe(bewerten(versuche[z], loesung)[s], c);
                      } else if (z == versuche.length &&
                          !fertig &&
                          s < eingabe.length) {
                        buchstabe = eingabe[s];
                        rand = c.outline;
                      }
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250 + s * 80),
                        width: kante,
                        height: kante,
                        margin: const EdgeInsets.all(3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: farbe,
                          border: farbe == null
                              ? Border.all(color: rand, width: 2)
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          buchstabe.toUpperCase(),
                          style: TextStyle(
                            fontSize: kante * 0.5,
                            fontWeight: FontWeight.bold,
                            color: farbe != null ? Colors.white : c.onSurface,
                          ),
                        ),
                      );
                    }(),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _Tastatur extends StatelessWidget {
  const _Tastatur({
    required this.status,
    required this.onTaste,
    required this.onEnter,
  });
  final Map<String, Feld> status;
  final ValueChanged<String> onTaste;
  final VoidCallback onEnter;

  static const reihen = ['qwertzuiopü', 'asdfghjklöä', 'yxcvbnm'];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    Widget taste(String t, {int flex = 2, Widget? kind, VoidCallback? aktion}) {
      final f = status[t];
      return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Material(
            color: f == null ? c.surfaceContainerHighest : feldFarbe(f, c),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: aktion ?? () => onTaste(t),
              child: SizedBox(
                height: 52,
                child: Center(
                  child:
                      kind ??
                      Text(
                        t.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: f == null ? c.onSurface : Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Column(
        children: [
          for (final (i, r) in reihen.indexed)
            Row(
              children: [
                if (i == 2)
                  taste(
                    '⏎',
                    flex: 3,
                    kind: const Icon(Icons.keyboard_return),
                    aktion: onEnter,
                  ),
                for (final b in r.split('')) taste(b),
                if (i == 2)
                  taste(
                    '⌫',
                    flex: 3,
                    kind: const Icon(Icons.backspace_outlined),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
