import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../design.dart';
import '../services/beisszeit.dart';
import '../services/sonne.dart';
import '../services/wetter.dart';

/// Beißindex 0–100 als Ring, dazu Wetter-Kacheln und die besten Zeiten
/// des Tages – für die Heute-Seite und die Gewässer-Ansicht.
class BeissindexKarte extends StatefulWidget {
  const BeissindexKarte(this.ort, {super.key, this.ortName});

  final LatLng ort;
  final String? ortName;

  /// Nur für Tests und Store-Bilder: feste Wetterdaten statt Internet.
  @visibleForTesting
  static Future<List<Stunde>> Function(LatLng)? testWetter;

  @override
  State<BeissindexKarte> createState() => _BeissindexKarteState();
}

class _BeissindexKarteState extends State<BeissindexKarte> {
  late Future<(Beissindex?, Stunde?)> _daten = _laden();

  @override
  void didUpdateWidget(BeissindexKarte alt) {
    super.didUpdateWidget(alt);
    if (alt.ort != widget.ort) _daten = _laden();
  }

  Future<(Beissindex?, Stunde?)> _laden() async {
    final stunden =
        await (BeissindexKarte.testWetter ?? stundenWetter)(widget.ort);
    final jetzt = DateTime.now();
    final sonne = sonnenZeiten(jetzt, widget.ort.latitude, widget.ort.longitude);
    final index = beissindex(stunden, jetzt,
        aufgang: sonne.aufgang, untergang: sonne.untergang);
    Stunde? aktuell;
    for (final s in stunden) {
      if (s.zeit.year == jetzt.year &&
          s.zeit.month == jetzt.month &&
          s.zeit.day == jetzt.day &&
          s.zeit.hour == jetzt.hour) {
        aktuell = s;
      }
    }
    return (index, aktuell);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return FutureBuilder<(Beissindex?, Stunde?)>(
      future: _daten,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final (index, jetzt) = snap.data ?? (null, null);
        if (index == null) {
          return Card(
            child: ListTile(
              leading: const Text('🌡️', style: TextStyle(fontSize: 24)),
              title: const Text('Beißindex gerade nicht verfügbar'),
              subtitle: const Text('Ohne Internet gibt es keine Wetterdaten.'),
              trailing: IconButton(
                tooltip: 'Nochmal laden',
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() => _daten = _laden()),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('BEISSINDEX${widget.ortName == null ? '' : ' · ${widget.ortName!.toUpperCase()}'}'),
                    const SizedBox(height: 8),
                    Center(child: _Ring(index)),
                    const SizedBox(height: 8),
                    Text(index.gruende.join(' · '),
                        textAlign: TextAlign.center,
                        style: text.bodySmall),
                  ],
                ),
              ),
            ),
            if (jetzt != null)
              Row(
                children: [
                  _Kachel('LUFT', '${jetzt.temp.round()} °C'),
                  _Kachel('DRUCK', '${jetzt.druck.round()}'),
                  _Kachel('WIND', '${jetzt.wind.round()} km/h'),
                  _Kachel('WOLKEN', '${jetzt.wolken.round()} %'),
                ],
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('BESTE ZEIT'),
                    const SizedBox(height: 10),
                    _Zeitleiste(index),
                    const SizedBox(height: 8),
                    Text(index.fensterText,
                        style: text.titleSmall),
                    Text('Schätzung aus Wetter, Mond und Dämmerung.',
                        style: text.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1));
}

class _Kachel extends StatelessWidget {
  const _Kachel(this.label, this.wert);

  final String label, wert;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Card(
          margin: const EdgeInsets.fromLTRB(0, 5, 6, 5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(label),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(wert,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
        ),
      );
}

/// Ring mit Zahl 0–100 und Bewertung.
class _Ring extends StatelessWidget {
  const _Ring(this.index);

  final Beissindex index;

  @override
  Widget build(BuildContext context) {
    final design = DesignInfo.von(context);
    final schema = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final gut = index.wert >= 50;
    return SizedBox(
      width: 180,
      height: 170,
      child: CustomPaint(
        painter: _RingMaler(
          wert: index.wert / 100,
          farbe: design.akzent,
          grund: schema.outlineVariant,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Text('${index.wert}',
                style: (design.neu ? text.displayLarge : text.displaySmall)
                    ?.copyWith(fontWeight: FontWeight.w700, height: 1)),
            Text(index.wort,
                style: text.labelLarge?.copyWith(
                    color: gut ? Colors.green.shade400 : schema.secondary,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}

class _RingMaler extends CustomPainter {
  _RingMaler({required this.wert, required this.farbe, required this.grund});

  final double wert;
  final Color farbe, grund;

  @override
  void paint(Canvas canvas, Size size) {
    const start = pi * 0.75, bogen = pi * 1.5;
    final r = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2 + 6),
        radius: min(size.width, size.height) / 2 - 8);
    final stift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, start, bogen, false, stift..color = grund);
    canvas.drawArc(r, start, bogen * wert.clamp(0.02, 1), false,
        stift..color = farbe);
  }

  @override
  bool shouldRepaint(_RingMaler alt) =>
      alt.wert != wert || alt.farbe != farbe || alt.grund != grund;
}

/// Tagesleiste 4–22 Uhr: helle Abschnitte sind die besten Zeiten.
class _Zeitleiste extends StatelessWidget {
  const _Zeitleiste(this.index);

  final Beissindex index;

  @override
  Widget build(BuildContext context) {
    final akzent = DesignInfo.von(context).akzent;
    final schema = Theme.of(context).colorScheme;
    final jetzt = DateTime.now().hour;
    bool imFenster(int h) => index.fenster.any((f) => h >= f.$1 && h < f.$2);
    return Column(
      children: [
        SizedBox(
          height: 16,
          child: Row(
            children: [
              for (var h = 4; h <= 22; h++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: imFenster(h)
                          ? akzent
                          : akzent.withValues(
                              alpha: 0.08 + (index.stunden[h] ?? 0) / 400),
                      borderRadius: BorderRadius.circular(4),
                      border: h == jetzt
                          ? Border.all(color: schema.onSurface, width: 1.5)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final h in [4, 8, 12, 16, 20])
              Text(h.toString().padLeft(2, '0'),
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
