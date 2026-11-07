import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../design.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import '../services/fern_konfig.dart';
import '../services/karriere.dart';
import '../services/live_angeln.dart';
import 'widgets.dart';

/// Liefert die eigenen Fänge – am Handy oder (angemeldet) aus der Cloud.
class MeineFaenge extends StatefulWidget {
  const MeineFaenge({super.key, required this.builder});

  final Widget Function(BuildContext context, List<Fang> faenge) builder;

  @override
  State<MeineFaenge> createState() => _MeineFaengeState();
}

class _MeineFaengeState extends State<MeineFaenge> {
  String? _uid;
  Stream<List<Fang>>? _stream;

  @override
  Widget build(BuildContext context) {
    final uid = KontoScope.of(context)?.uid;
    if (uid == null) {
      return widget.builder(context, SpeicherScope.of(context).faenge);
    }
    if (uid != _uid || _stream == null) {
      _uid = uid;
      _stream = fangDienst.meineFaenge(uid);
    }
    return StreamBuilder<List<Fang>>(
      stream: _stream,
      builder: (context, snap) =>
          widget.builder(context, snap.data ?? const []),
    );
  }
}

/// Karriere aus allem, was die App weiß.
Karriere meineKarriere(BuildContext context, List<Fang> faenge) {
  final s = SpeicherScope.of(context);
  return karriereBerechnen(
    faenge: faenge,
    challenges: s.erledigteChallenges.length,
    liveTage: liveAngeln.tage,
    pruefungBestanden: s.pruefungBestanden,
    quizRekord: s.besteQuizPunkte,
  );
}

/// Kleines Level-Abzeichen (Heute-Seite). Leuchtet bei einem neuen Level.
class KarriereChip extends StatelessWidget {
  const KarriereChip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('karriere')) return const SizedBox.shrink();
    return MeineFaenge(
      builder: (context, faenge) {
        final k = meineKarriere(context, faenge);
        final neu = k.level > SpeicherScope.of(context).karriereGesehen;
        final akzent = DesignInfo.von(context).akzent;
        final schema = Theme.of(context).colorScheme;
        return Tooltip(
          message: 'Angel-Karriere',
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const KarriereScreen())),
            child: Container(
              padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
              decoration: BoxDecoration(
                color: neu
                    ? akzent.withValues(alpha: 0.18)
                    : schema.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: neu ? akzent : schema.outlineVariant, width: 1.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CustomPaint(
                      painter: _RingMaler(
                          wert: k.fortschritt,
                          farbe: akzent,
                          grund: schema.outlineVariant,
                          dicke: 3.5),
                      child: Center(
                        child: Text('${k.level}',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(neu ? 'LEVEL-UP!' : 'LEVEL ${k.level}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: neu ? akzent : schema.onSurfaceVariant,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w700)),
                      Text('${k.rang.symbol} ${k.rang.titel}',
                          style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Angel-Karriere: Level, Rang, Punkte und Rangleiter.
class KarriereScreen extends StatefulWidget {
  const KarriereScreen({super.key});

  @override
  State<KarriereScreen> createState() => _KarriereScreenState();
}

class _KarriereScreenState extends State<KarriereScreen>
    with SingleTickerProviderStateMixin {
  late final _konfetti = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));

  /// Level, das beim Öffnen neu war (für die Feier), sonst null.
  int? _gefeiert;

  @override
  void initState() {
    super.initState();
    liveAngeln.laden();
  }

  @override
  void dispose() {
    _konfetti.dispose();
    super.dispose();
  }

  void _feiernWennNeu(Karriere k) {
    final speicher = SpeicherScope.of(context);
    if (_gefeiert == null && k.level > speicher.karriereGesehen) {
      _gefeiert = k.level;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        speicher.karriereGesehenSetzen(k.level);
        _konfetti.forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!funktionAn('karriere')) {
      return const FunktionAusSeite('Angel-Karriere');
    }
    return MeineFaenge(
      builder: (context, faenge) {
        final k = meineKarriere(context, faenge);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Angel-Karriere'),
            actions: [
              IconButton(
                tooltip: 'Karriere teilen',
                icon: const Icon(Icons.share_outlined),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        KarriereTeilenScreen(k, arten: {
                          for (final f in faenge) f.fischId
                        }.length, faenge: faenge.length))),
              ),
            ],
          ),
          body: Builder(builder: (context) {
          _feiernWennNeu(k);
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                children: [
                  if (_gefeiert != null) _LevelUp(level: _gefeiert!, k: k),
                  _Kopf(k),
                  const SizedBox(height: 8),
                  _Punkte(k),
                  const SizedBox(height: 8),
                  _Rangleiter(k),
                  const SizedBox(height: 8),
                  Text(
                    'Punkte gibt es für alles, was du einträgst, lernst und am '
                    'Wasser erlebst. Ehrliche Einträge machen die Karriere '
                    'wertvoll – Petri Heil!',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              IgnorePointer(
                child: AnimatedBuilder(
                  animation: _konfetti,
                  builder: (context, _) => _konfetti.isAnimating
                      ? CustomPaint(
                          size: Size.infinite,
                          painter: _KonfettiMaler(_konfetti.value))
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          );
          }),
        );
      },
    );
  }
}

/// Karriere als Bild zum Teilen (WhatsApp, Instagram …).
class KarriereTeilenScreen extends StatefulWidget {
  const KarriereTeilenScreen(this.k,
      {super.key, required this.arten, required this.faenge});

  final Karriere k;
  final int arten;
  final int faenge;

  @override
  State<KarriereTeilenScreen> createState() => _KarriereTeilenScreenState();
}

class _KarriereTeilenScreenState extends State<KarriereTeilenScreen> {
  final _schluessel = GlobalKey();
  bool _teilt = false;

  Future<void> _teilen() async {
    setState(() => _teilt = true);
    try {
      final grenze = _schluessel.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final bild = await grenze.toImage(pixelRatio: 3);
      final daten = await bild.toByteData(format: ui.ImageByteFormat.png);
      final ordner = await getTemporaryDirectory();
      final datei = File('${ordner.path}/austro_angler_karriere.png');
      await datei.writeAsBytes(daten!.buffer.asUint8List());
      final k = widget.k;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(datei.path, mimeType: 'image/png')],
        text: 'Ich bin Level ${k.level} – ${k.rang.symbol} ${k.rang.titel} '
            'in Austro Angler! 🎣 Wie weit bist du?',
      ));
    } catch (e) {
      if (mounted) meldung(context, 'Teilen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _teilt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karriere teilen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: RepaintBoundary(
              key: _schluessel,
              child: _KarriereKarte(widget.k,
                  arten: widget.arten, faenge: widget.faenge),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _teilt ? null : _teilen,
            icon: const Icon(Icons.share),
            label: const Text('Bild teilen'),
          ),
        ],
      ),
    );
  }
}

/// Das Bild selbst – immer im dunklen Austro-Angler-Look, egal welches Design.
class _KarriereKarte extends StatelessWidget {
  const _KarriereKarte(this.k, {required this.arten, required this.faenge});

  final Karriere k;
  final int arten;
  final int faenge;

  static const _gross = TextStyle(
      fontFamily: 'BebasNeue',
      fontFamilyFallback: ['NotoColorEmoji'],
      color: Colors.white,
      height: 1);
  static const _klein = TextStyle(
      fontFamily: 'Barlow',
      fontFamilyFallback: ['NotoColorEmoji'],
      color: Color(0xFFB8D4D2),
      fontSize: 13);

  @override
  Widget build(BuildContext context) {
    const akzent = Color(0xFF3FD0C9);
    Widget zahl(String wert, String was) => Expanded(
          child: Column(
            children: [
              Text(wert, style: _gross.copyWith(fontSize: 30)),
              const SizedBox(height: 2),
              Text(was.toUpperCase(),
                  style: _klein.copyWith(fontSize: 11, letterSpacing: 1)),
            ],
          ),
        );
    return Container(
      width: 320,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B2226), Color(0xFF14444A)],
        ),
      ),
      child: Column(
        children: [
          const Align(alignment: Alignment.centerLeft, child: RotWeissRot()),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('MEINE ANGEL-KARRIERE',
                style: _klein.copyWith(
                    color: akzent, letterSpacing: 1.6, fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: 168,
            height: 168,
            child: CustomPaint(
              painter: _RingMaler(
                  wert: k.fortschritt,
                  farbe: akzent,
                  grund: const Color(0xFF24565B),
                  dicke: 12),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('LEVEL',
                        style: _klein.copyWith(letterSpacing: 1.6, fontSize: 12)),
                    Text('${k.level}', style: _gross.copyWith(fontSize: 72)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('${k.rang.symbol} ${k.rang.titel}',
              style: _gross.copyWith(fontSize: 34)),
          const SizedBox(height: 4),
          Text('${xpText(k.xp)} Punkte',
              style: _klein.copyWith(
                  color: akzent, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          Row(
            children: [
              zahl('$faenge', 'Fänge'),
              zahl('$arten', 'Arten'),
              zahl('${k.quellen.firstWhere((q) => q.symbol == '🏅').anzahl}',
                  'Abzeichen'),
            ],
          ),
          const SizedBox(height: 18),
          Text('Austro Angler · Die Angel-App für Österreich',
              style: _klein.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _LevelUp extends StatelessWidget {
  const _LevelUp({required this.level, required this.k});

  final int level;
  final Karriere k;

  @override
  Widget build(BuildContext context) {
    final akzent = DesignInfo.von(context).akzent;
    final rang = rangFuer(level);
    return Card(
      color: akzent.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: akzent, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 34)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level $level erreicht!',
                      style: Theme.of(context).textTheme.titleLarge),
                  Text('Du bist jetzt ${rang.symbol} ${rang.titel}.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Kopf extends StatelessWidget {
  const _Kopf(this.k);

  final Karriere k;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    final schema = Theme.of(context).colorScheme;
    final naechster = k.naechsterRang;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            SizedBox(
              width: 170,
              height: 170,
              child: CustomPaint(
                painter: _RingMaler(
                    wert: k.fortschritt,
                    farbe: akzent,
                    grund: schema.outlineVariant,
                    dicke: 13),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('LEVEL',
                          style: text.labelMedium?.copyWith(
                              color: schema.onSurfaceVariant,
                              letterSpacing: 1.4)),
                      Text('${k.level}',
                          style: (DesignInfo.von(context).neu
                                  ? text.displayLarge
                                  : text.displayMedium)
                              ?.copyWith(fontWeight: FontWeight.w700, height: 1)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('${k.rang.symbol} ${k.rang.titel}',
                style: text.headlineSmall),
            const SizedBox(height: 4),
            Text('${xpText(k.xp)} Punkte',
                style: text.titleMedium?.copyWith(color: akzent)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: k.fortschritt,
                minHeight: 10,
                color: akzent,
                backgroundColor: schema.outlineVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Noch ${xpText(k.xpBisNaechstes)} Punkte bis Level ${k.level + 1}',
              style: text.bodyMedium,
            ),
            if (naechster != null)
              Text(
                'Nächster Rang: ${naechster.symbol} ${naechster.titel} '
                'ab Level ${naechster.abLevel}',
                style: text.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _Punkte extends StatelessWidget {
  const _Punkte(this.k);

  final Karriere k;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final leise = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SO HAST DU GEPUNKTET', style: text.labelMedium),
            const SizedBox(height: 6),
            for (final q in k.quellen)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                        width: 34,
                        child: Text(q.symbol,
                            style: const TextStyle(fontSize: 22))),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              q.symbol == '🎓'
                                  ? '${q.titel}: ${q.anzahl > 0 ? 'ja' : 'noch nicht'}'
                                  : '${q.titel}: ${q.anzahl}',
                              style: text.titleSmall),
                          Text(q.wie,
                              style: text.bodySmall?.copyWith(color: leise)),
                        ],
                      ),
                    ),
                    Text('+${xpText(q.xp)}',
                        style: text.titleMedium?.copyWith(
                            color: q.xp == 0 ? leise : null,
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Rangleiter extends StatelessWidget {
  const _Rangleiter(this.k);

  final Karriere k;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    final schema = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('RANGLEITER', style: text.labelMedium),
            const SizedBox(height: 6),
            for (final r in raenge)
              Builder(builder: (context) {
                final erreicht = k.level >= r.abLevel;
                final jetzt = r == k.rang;
                return Opacity(
                  opacity: erreicht ? 1 : 0.45,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: jetzt ? akzent.withValues(alpha: 0.15) : null,
                      borderRadius: BorderRadius.circular(10),
                      border: jetzt ? Border.all(color: akzent) : null,
                    ),
                    child: Row(
                      children: [
                        Text(r.symbol, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(r.titel, style: text.titleSmall)),
                        Text(
                          jetzt
                              ? 'DU'
                              : erreicht
                                  ? '✓'
                                  : 'ab Level ${r.abLevel}',
                          style: text.labelMedium?.copyWith(
                              color: jetzt ? akzent : schema.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _RingMaler extends CustomPainter {
  _RingMaler(
      {required this.wert,
      required this.farbe,
      required this.grund,
      required this.dicke});

  final double wert;
  final Color farbe, grund;
  final double dicke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: min(size.width, size.height) / 2 - dicke / 2);
    final stift = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = dicke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, 2 * pi, false, stift..color = grund);
    canvas.drawArc(r, -pi / 2, 2 * pi * wert.clamp(0.02, 1), false,
        stift..color = farbe);
  }

  @override
  bool shouldRepaint(_RingMaler alt) =>
      alt.wert != wert || alt.farbe != farbe || alt.grund != grund;
}

/// Konfetti in Rot-Weiß-Rot und Türkis, einmal beim Level-up.
class _KonfettiMaler extends CustomPainter {
  _KonfettiMaler(this.t);

  final double t;
  static final _teile = List.generate(70, (i) {
    final z = Random(i * 7919);
    return (
      x: z.nextDouble(),
      tempo: 0.6 + z.nextDouble() * 0.8,
      dreh: z.nextDouble() * pi,
      farbe: const [
        Color(0xFFED2939),
        Colors.white,
        Color(0xFF3FD0C9),
        Color(0xFFFFC94A),
      ][i % 4],
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    final ausblenden = t < 0.75 ? 1.0 : (1 - t) / 0.25;
    for (final k in _teile) {
      final y = (t * k.tempo * 1.4 - 0.15) * size.height;
      final x = k.x * size.width + sin(t * 8 + k.dreh) * 18;
      p.color = k.farbe.withValues(alpha: ausblenden.clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(k.dreh + t * 10);
      canvas.drawRect(const Rect.fromLTWH(-4, -2.5, 8, 5), p);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_KonfettiMaler alt) => alt.t != t;
}
