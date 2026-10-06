import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../dienste.dart';
import '../l10n/l.dart';
import '../logik/sudoku.dart';
import '../logik/tag.dart';
import 'heute_screen.dart';
import 'schiebe_screen.dart';
import 'sudoku_screen.dart';
import 'wort_screen.dart';

/// Alle vergangenen Rätseltage (Pro).
class ArchivScreen extends StatelessWidget {
  const ArchivScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final heute = fortschritt.heute;
    return Scaffold(
      appBar: AppBar(title: Text(l.archiv)),
      body: ListenableBuilder(
        listenable: fortschritt,
        builder: (context, _) => heute <= 1
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(l.archivLeer, textAlign: TextAlign.center),
                ),
              )
            : ListView.builder(
                itemCount: heute - 1,
                itemBuilder: (context, i) {
                  final n = heute - 1 - i;
                  Widget symbol(String s, bool ok) => Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Opacity(
                      opacity: ok ? 1 : 0.3,
                      child: Text(s, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                  final sudokuOk = Stufe.values.any(
                    (s) => fortschritt.geloest('sudoku:${s.name}:$n'),
                  );
                  return ListTile(
                    title: Text(l.raetselNr(n)),
                    subtitle: Text(
                      DateFormat(
                        'EEEE, d. MMMM yyyy',
                        'de',
                      ).format(tagVonNummer(n)),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        symbol('🔤', fortschritt.geloest('wort:$n')),
                        symbol('🔢', sudokuOk),
                        symbol('🧩', fortschritt.geloest('schiebe:$n')),
                      ],
                    ),
                    onTap: () => _tagOeffnen(context, n),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _tagOeffnen(BuildContext context, int n) async {
    final l = context.l;
    final wahl = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l.raetselNr(n)),
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
    Widget? seite;
    if (wahl == 'wort') seite = WortScreen(nummer: n);
    if (wahl == 'schiebe') seite = SchiebeScreen(nummer: n);
    if (wahl == 'sudoku') {
      final s = await stufeWaehlen(context, n);
      if (s == null) return;
      seite = SudokuScreen(nummer: n, stufe: s);
    }
    if (seite != null && context.mounted) {
      await Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => seite!));
    }
  }
}
