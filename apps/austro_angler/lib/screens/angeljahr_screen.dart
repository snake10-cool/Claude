import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/fische.dart';
import '../main.dart';
import '../models/fang.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

const _monate = ['Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
  'August', 'September', 'Oktober', 'November', 'Dezember'];

/// "Dein Angeljahr" – Jahresrückblick zum Teilen.
class AngeljahrScreen extends StatefulWidget {
  const AngeljahrScreen(this.faenge, {super.key});

  final List<Fang> faenge;

  @override
  State<AngeljahrScreen> createState() => _AngeljahrScreenState();
}

class _AngeljahrScreenState extends State<AngeljahrScreen> {
  final _schluessel = GlobalKey();
  late int _jahr = _jahre.first;
  int? _schneidertage;
  bool _teilt = false;

  List<int> get _jahre {
    final j = widget.faenge.map((f) => f.datum.year).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    return j.isEmpty ? [DateTime.now().year] : j;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _schneiderLaden();
  }

  Future<void> _schneiderLaden() async {
    final uid = KontoScope.of(context)?.uid;
    if (uid == null) return;
    try {
      final ausfluege = await fangDienst.ausfluege(uid).first;
      final fangTage = {
        for (final f in widget.faenge)
          DateTime(f.datum.year, f.datum.month, f.datum.day),
      };
      final schneider = ausfluege.where((a) =>
          a.start.year == _jahr &&
          !fangTage.contains(
              DateTime(a.start.year, a.start.month, a.start.day)));
      if (mounted) setState(() => _schneidertage = schneider.length);
    } catch (_) {}
  }

  Future<void> _teilen() async {
    setState(() => _teilt = true);
    try {
      final grenze = _schluessel.currentContext!.findRenderObject()!
          as RenderRepaintBoundary;
      final bild = await grenze.toImage(pixelRatio: 3);
      final daten = await bild.toByteData(format: ui.ImageByteFormat.png);
      final ordner = await getTemporaryDirectory();
      final datei = File('${ordner.path}/mein_angeljahr_$_jahr.png');
      await datei.writeAsBytes(daten!.buffer.asUint8List());
      await SharePlus.instance.share(ShareParams(
        files: [XFile(datei.path, mimeType: 'image/png')],
        text: 'Mein Angeljahr $_jahr 🎣 – mit Austro Angler',
      ));
    } catch (e) {
      if (mounted) meldung(context, 'Teilen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _teilt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.faenge.where((x) => x.datum.year == _jahr).toList();
    final arten = <String, int>{};
    final gewaesser = <String, int>{};
    final monate = List.filled(12, 0);
    for (final x in f) {
      arten[x.fischId] = (arten[x.fischId] ?? 0) + 1;
      if (x.gewaesser.isNotEmpty) {
        gewaesser[x.gewaesser] = (gewaesser[x.gewaesser] ?? 0) + 1;
      }
      monate[x.datum.month - 1]++;
    }
    String? top(Map<String, int> m) => m.isEmpty
        ? null
        : (m.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
            .first
            .key;
    final groesster = f.where((x) => x.laengeCm != null).fold<Fang?>(
        null, (m, x) => m == null || x.laengeCm! > m.laengeCm! ? x : m);
    final besterMonat = f.isEmpty
        ? null
        : monate.indexOf(monate.reduce((a, b) => a > b ? a : b));
    final zurueck = f.where((x) => x.zurueckgesetzt).length;
    final lieblingsfisch = top(arten);
    final lieblingsgewaesser = top(gewaesser);
    final tage = f
        .map((x) => DateTime(x.datum.year, x.datum.month, x.datum.day))
        .toSet()
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Dein Angeljahr ⭐')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_jahre.length > 1)
            Wrap(
              spacing: 6,
              children: [
                for (final j in _jahre)
                  ChoiceChip(
                    label: Text('$j'),
                    selected: j == _jahr,
                    onSelected: (_) {
                      setState(() => _jahr = j);
                      _schneiderLaden();
                    },
                  ),
              ],
            ),
          const SizedBox(height: 12),
          RepaintBoundary(
            key: _schluessel,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0E3B33), Color(0xFF1E6F5C), Color(0xFF2E9C7E)],
                ),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white, fontSize: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mein Angeljahr $_jahr',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(at(KontoScope.of(context)?.name ?? ''),
                        style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    _Zahl('${f.length}', 'Fänge an $tage Tagen'),
                    _Zahl('${arten.length}', 'verschiedene Fischarten'),
                    if (groesster != null)
                      _Zahl('${groesster.laengeCm!.toStringAsFixed(0)} cm',
                          'größter Fang: ${fischById(groesster.fischId)?.name ?? ''}'),
                    if (lieblingsfisch != null)
                      _Zahl(fischById(lieblingsfisch)?.name ?? lieblingsfisch,
                          'mein Fisch des Jahres (${arten[lieblingsfisch]}×)'),
                    if (lieblingsgewaesser != null)
                      _Zahl(lieblingsgewaesser,
                          'Lieblingsgewässer (${gewaesser[lieblingsgewaesser]} Fänge)'),
                    if (besterMonat != null)
                      _Zahl(_monate[besterMonat], 'bester Monat'),
                    if (zurueck > 0)
                      _Zahl('$zurueck', 'Fische schonend zurückgesetzt 🤝'),
                    if (_schneidertage != null && _schneidertage! > 0)
                      _Zahl('$_schneidertage', 'Schneidertage – gehört dazu 😅'),
                    const SizedBox(height: 16),
                    const Text('🎣 Austro Angler',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _teilt || f.isEmpty ? null : _teilen,
            icon: const Icon(Icons.share),
            label: const Text('Als Bild teilen'),
          ),
          if (f.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('In diesem Jahr noch keine Fänge eingetragen.'),
            ),
        ],
      ),
    );
  }
}

class _Zahl extends StatelessWidget {
  const _Zahl(this.wert, this.text);

  final String wert;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(wert,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD54F))),
          Text(text),
        ],
      ),
    );
  }
}
