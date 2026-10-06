import 'dart:math';

import 'package:app_werbung/app_werbung.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/sudoku.dart';
import '../widgets/pro.dart';
import 'archiv_screen.dart';
import 'mehr_screen.dart';
import 'schiebe_screen.dart';
import 'statistik_screen.dart';
import 'sudoku_screen.dart';
import 'wort_screen.dart';

/// Die drei Rätsel des Tages.
class HeuteScreen extends StatelessWidget {
  const HeuteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    void oeffnen(Widget seite) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => seite));
    return Scaffold(
      appBar: AppBar(
        title: Text(appInfo.name),
        actions: [
          IconButton(
            tooltip: l.statistik,
            icon: const Icon(Icons.bar_chart),
            onPressed: () => oeffnen(const StatistikScreen()),
          ),
          IconButton(
            tooltip: l.mehr,
            icon: const Icon(Icons.more_horiz),
            onPressed: () => oeffnen(const MehrScreen()),
          ),
        ],
      ),
      bottomNavigationBar: WerbeBanner(dienst: werbung),
      body: ListenableBuilder(
        listenable: Listenable.merge([fortschritt, kauf]),
        builder: (context, _) {
          final n = fortschritt.heute;
          final serie = fortschritt.aktuelleSerie;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.raetselNr(n),
                          style: t.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'EEEE, d. MMMM',
                            'de',
                          ).format(DateTime.now()),
                          style: t.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: t.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      serie > 0 ? '🔥 $serie' : '🌱 0',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RaetselKarte(
                symbol: '🔤',
                titel: l.wortraetsel,
                text: l.wortraetselText,
                status: _status(
                  l,
                  'wort:$n',
                  (e) => e['geloest'] == true
                      ? l.geschafftVersuche(e['versuche'] as int)
                      : l.nichtGeschafft,
                ),
                laeuft: fortschritt.laufend.containsKey('wort:$n'),
                onTap: () => oeffnen(WortScreen(nummer: n)),
              ),
              _RaetselKarte(
                symbol: '🔢',
                titel: l.sudoku,
                text: l.sudokuText,
                status: _sudokuStatus(l, n),
                laeuft: Stufe.values.any(
                  (s) => fortschritt.laufend.containsKey('sudoku:${s.name}:$n'),
                ),
                onTap: () => _sudokuWaehlen(context, n),
              ),
              _RaetselKarte(
                symbol: '🧩',
                titel: l.schiebepuzzle,
                text: l.schiebepuzzleText,
                status: _status(
                  l,
                  'schiebe:$n',
                  (e) => l.geschafftZuege(e['zuege'] as int),
                ),
                laeuft: fortschritt.laufend.containsKey('schiebe:$n'),
                onTap: () => oeffnen(SchiebeScreen(nummer: n)),
              ),
              if (fortschritt.alleDrei(n))
                Card(
                  color: t.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l.alleDreiGeschafft,
                      textAlign: TextAlign.center,
                      style: t.textTheme.titleMedium,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => kauf.istPro
                          ? oeffnen(const ArchivScreen())
                          : proSeiteOeffnen(context),
                      icon: Icon(
                        kauf.istPro ? Icons.history : Icons.lock_outline,
                      ),
                      label: Text(l.archiv),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => kauf.istPro
                          ? _endlos(context)
                          : proSeiteOeffnen(context),
                      icon: Icon(
                        kauf.istPro ? Icons.all_inclusive : Icons.lock_outline,
                      ),
                      label: Text(l.endlos),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String? _status(
    AppLocalizations l,
    String schluessel,
    String Function(Map<String, dynamic>) text,
  ) {
    final e = fortschritt.ergebnis(schluessel);
    return e == null ? null : text(e);
  }

  static String? _sudokuStatus(AppLocalizations l, int n) {
    for (final s in Stufe.values.reversed) {
      final e = fortschritt.ergebnis('sudoku:${s.name}:$n');
      if (e?['geloest'] == true) {
        return l.geschafftSudoku(
          stufeName(l, s),
          zeitText(e!['sekunden'] as int),
        );
      }
    }
    return null;
  }

  static Future<void> _sudokuWaehlen(BuildContext context, int n) async {
    final stufe = await stufeWaehlen(context, n);
    if (stufe != null && context.mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SudokuScreen(nummer: n, stufe: stufe),
        ),
      );
    }
  }

  static Future<void> _endlos(BuildContext context) async {
    final l = context.l;
    final wahl = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.endlos),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'wort'),
            child: Text('🔤 ${l.wortraetsel}'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'sudoku'),
            child: Text('🔢 ${l.sudoku}'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'schiebe'),
            child: Text('🧩 ${l.schiebepuzzle}'),
          ),
        ],
      ),
    );
    if (wahl == null || !context.mounted) return;
    // Zufällige Nummer weit nach dem Starttag – zählt nicht für die Serie.
    final n = 100000 + Random().nextInt(900000);
    Widget seite;
    if (wahl == 'wort') {
      seite = WortScreen(nummer: n, zaehlt: false);
    } else if (wahl == 'schiebe') {
      seite = SchiebeScreen(nummer: n, zaehlt: false);
    } else {
      final s = await stufeWaehlen(context, null);
      if (s == null || !context.mounted) return;
      seite = SudokuScreen(nummer: n, stufe: s, zaehlt: false);
    }
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => seite));
  }
}

String zeitText(int sekunden) =>
    '${sekunden ~/ 60}:${(sekunden % 60).toString().padLeft(2, '0')}';

class _RaetselKarte extends StatelessWidget {
  const _RaetselKarte({
    required this.symbol,
    required this.titel,
    required this.text,
    required this.status,
    required this.laeuft,
    required this.onTap,
  });

  final String symbol;
  final String titel;
  final String text;
  final String? status;
  final bool laeuft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final t = Theme.of(context);
    final fertig = status != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: fertig ? t.colorScheme.secondaryContainer : null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text(symbol, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titel,
                        style: t.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        status ?? (laeuft ? l.weiterspielen : text),
                        style: t.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  fertig ? Icons.check_circle : Icons.play_circle_fill,
                  size: 36,
                  color: t.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String stufeName(AppLocalizations l, Stufe s) => switch (s) {
  Stufe.leicht => l.leicht,
  Stufe.mittel => l.mittel,
  Stufe.schwer => l.schwer,
};

/// Auswahl der Sudoku-Stufe (mit Status für den Tag).
Future<Stufe?> stufeWaehlen(BuildContext context, int? nummer) {
  final l = context.l;
  return showDialog<Stufe>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(l.stufeWaehlen),
      children: [
        for (final s in Stufe.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, s),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stufeName(l, s),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (nummer != null &&
                    fortschritt.geloest('sudoku:${s.name}:$nummer'))
                  const Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
          ),
      ],
    ),
  );
}
