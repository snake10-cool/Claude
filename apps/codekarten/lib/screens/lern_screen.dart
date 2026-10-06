import 'dart:math';

import 'package:app_basis/app_basis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../daten/datenbank.dart';
import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/lernrunde.dart';
import '../logik/srs.dart';
import '../logik/typen.dart';
import '../widgets/code_ansicht.dart';
import '../widgets/snippet_aus_karte.dart';

/// Eine Lernrunde über die gegebenen Stapel.
class LernScreen extends StatefulWidget {
  const LernScreen({super.key, required this.stapelIds});
  final List<int> stapelIds;

  @override
  State<LernScreen> createState() => _LernScreenState();
}

class _LernScreenState extends State<LernScreen> {
  List<LernKarte<Karte>>? _runde;
  Map<int, Stapel> _stapel = {};
  int _index = 0;
  bool _aufgedeckt = false;
  String? _gewaehlt;
  int _gesamt = 0;
  int _richtig = 0;

  @override
  void initState() {
    super.initState();
    _laden();
  }

  Future<void> _laden() async {
    final karten = await db.lernkarten(widget.stapelIds);
    final tage = await db.lerntageLaden();
    final heute = tage[tagBeginn(DateTime.now())];
    final stapel = {
      for (final s in await db.stapelLaden()) s.stapel.id: s.stapel,
    };
    final runde = lernrundeZusammenstellen(
      karten,
      jetzt: DateTime.now(),
      neueProTag: lernen.neueProTag,
      neueHeuteSchon: heute?.neu ?? 0,
    );
    if (!mounted) return;
    setState(() {
      _runde = runde;
      _stapel = stapel;
      _gesamt = runde.length;
    });
  }

  LernKarte<Karte> get _aktuell => _runde![_index];
  KartenTyp get _typ => KartenTyp.values.byName(_aktuell.karte.typ);
  String get _sprache => _stapel[_aktuell.karte.stapelId]?.sprache ?? 'andere';

  Future<void> _bewerten(Bewertung b, {bool? richtig}) async {
    HapticFeedback.selectionClick();
    final k = _aktuell;
    final neu = bewerten(k.stand, b, DateTime.now());
    final warRichtig = richtig ?? b != Bewertung.nochmal;
    await db.bewertungSpeichern(
      k.karte,
      neu,
      warNeu: k.neu,
      richtig: warRichtig,
    );
    if (warRichtig) _richtig++;
    setState(() {
      if (b == Bewertung.nochmal) {
        // Später in dieser Runde nochmal.
        _runde!.add(LernKarte(k.karte, neu, reihenfolge: k.reihenfolge));
      }
      _index++;
      _aufgedeckt = false;
      _gewaehlt = null;
    });
    if (_index >= _runde!.length) BewertungsBitte.vielleichtFragen();
  }

  void _waehlen(String option) {
    if (_gewaehlt != null) return;
    final richtig = option == _aktuell.karte.antwort;
    HapticFeedback.lightImpact();
    setState(() {
      _gewaehlt = option;
      _aufgedeckt = true;
    });
    if (!richtig) HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final runde = _runde;
    if (runde == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_index >= runde.length) {
      return _Fertig(gesamt: _gesamt, richtig: _richtig);
    }

    final karte = _aktuell.karte;
    final stapel = _stapel[karte.stapelId];
    final fortschritt = _index / runde.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.karteVon(_index + 1, runde.length)),
        actions: [
          IconButton(
            tooltip: l.alsSnippet,
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: () =>
                karteAlsSnippet(context, karte, _sprache, stapel?.name ?? ''),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: fortschritt),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      if (_aktuell.neu)
                        Chip(
                          label: Text(l.neu),
                          visualDensity: VisualDensity.compact,
                        ),
                      const Spacer(),
                      Text(
                        stapel?.name ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    karte.frage,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (karte.code != null) ...[
                    const SizedBox(height: 16),
                    CodeAnsicht(
                      code: _typ == KartenTyp.luecke && _gewaehlt != null
                          ? karte.code!.replaceAll('___', karte.antwort)
                          : karte.code!,
                      sprache: _sprache,
                      kopierbar: _aufgedeckt,
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (_typ == KartenTyp.begriff)
                    _aufgedeckt
                        ? _Antwort(karte: karte)
                        : const SizedBox.shrink()
                  else
                    ..._optionen(karte),
                  if (_aufgedeckt &&
                      _typ != KartenTyp.begriff &&
                      karte.erklaerung.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _Erklaerung(text: karte.erklaerung),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _knoepfe(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _optionen(Karte karte) {
    final t = Theme.of(context);
    // Gleiche Reihenfolge, solange die Karte angezeigt wird.
    final optionen = [...karte.optionenListe]
      ..shuffle(Random(karte.id + _index));
    return [
      for (final o in optionen)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: () {
            final istRichtig = o == karte.antwort;
            final gewaehlt = o == _gewaehlt;
            Color? rand;
            Color? fuellung;
            IconData? symbol;
            if (_gewaehlt != null && istRichtig) {
              rand = Colors.green.shade600;
              fuellung = Colors.green.withValues(alpha: 0.15);
              symbol = Icons.check_circle;
            } else if (gewaehlt) {
              rand = t.colorScheme.error;
              fuellung = t.colorScheme.errorContainer;
              symbol = Icons.cancel;
            }
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                side: BorderSide(
                  color: rand ?? t.colorScheme.outline,
                  width: rand == null ? 1 : 2,
                ),
                backgroundColor: fuellung,
              ),
              onPressed: () => _waehlen(o),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      o,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontFamilyFallback: const ['Courier New'],
                        fontSize: 15,
                        color: t.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (symbol != null) Icon(symbol, color: rand),
                ],
              ),
            );
          }(),
        ),
    ];
  }

  Widget _knoepfe(BuildContext context) {
    final l = context.l;
    final jetzt = DateTime.now();
    String vorschau(Bewertung b) {
      final tage = naechstesIntervall(_aktuell.stand, b, jetzt);
      return tage == 0 ? l.gleich : l.tageKurz(tage);
    }

    if (_typ == KartenTyp.begriff) {
      if (!_aufgedeckt) {
        return FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          onPressed: () => setState(() => _aufgedeckt = true),
          child: Text(l.antwortZeigen),
        );
      }
      return Row(
        children: [
          for (final (b, text, farbe) in [
            (Bewertung.nochmal, l.nochmal, Colors.red),
            (Bewertung.schwer, l.schwer, Colors.orange),
            (Bewertung.gut, l.gut, Colors.green),
            (Bewertung.leicht, l.leicht, Colors.blue),
          ])
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: farbe.withValues(alpha: 0.18),
                  ),
                  onPressed: () => _bewerten(b),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        vorschau(b),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }
    // Auswahl-Karten: Bewertung ergibt sich aus der Antwort.
    if (_gewaehlt == null) {
      return Text(
        l.waehleAntwort,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final richtig = _gewaehlt == _aktuell.karte.antwort;
    return Row(
      children: [
        if (richtig)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _bewerten(Bewertung.leicht),
              child: Text('${l.zuLeicht} · ${vorschau(Bewertung.leicht)}'),
            ),
          ),
        if (richtig) const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () =>
                _bewerten(richtig ? Bewertung.gut : Bewertung.nochmal),
            child: Text(richtig ? l.richtigWeiter : l.falschWeiter),
          ),
        ),
      ],
    );
  }
}

class _Antwort extends StatelessWidget {
  const _Antwort({required this.karte});
  final Karte karte;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(karte.antwort, style: t.textTheme.bodyLarge),
            if (karte.erklaerung.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(karte.erklaerung, style: t.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _Erklaerung extends StatelessWidget {
  const _Erklaerung({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      color: t.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: t.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

class _Fertig extends StatelessWidget {
  const _Fertig({required this.gesamt, required this.richtig});
  final int gesamt;
  final int richtig;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                gesamt == 0 ? '😴' : '🎉',
                style: const TextStyle(fontSize: 72),
              ),
              const SizedBox(height: 16),
              Text(
                gesamt == 0 ? l.nichtsZuLernen : l.rundeFertig,
                style: t.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (gesamt > 0)
                Text(
                  l.rundeErgebnis(gesamt, richtig),
                  style: t.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.fertig),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
