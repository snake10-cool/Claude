import 'package:flutter/material.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import 'konto_screen.dart';
import 'widgets.dart';

/// Schickt eine Meldung an den Betreiber (braucht ein Konto).
Future<void> meldenDialog(
  BuildContext context, {
  required String typ,
  required String bezug,
  required String titel,
  required String hinweis,
}) async {
  final konto = KontoScope.of(context);
  if (konto == null) {
    meldung(context, 'Melden geht erst, wenn die Online-Funktionen aktiv sind.');
    return;
  }
  if (!konto.angemeldet) {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const KontoScreen()),
    );
    return;
  }
  final controller = TextEditingController();
  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titel),
      content: TextField(
        controller: controller,
        maxLines: 5,
        maxLength: 1000,
        decoration: InputDecoration(hintText: hinweis),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('Senden'),
        ),
      ],
    ),
  );
  if (text == null || text.isEmpty) return;
  try {
    await fangDienst.melden(uid: konto.uid!, typ: typ, bezug: bezug, text: text);
    if (context.mounted) meldung(context, 'Danke! Wir schauen uns das an.');
  } catch (_) {
    if (context.mounted) meldung(context, 'Senden fehlgeschlagen.');
  }
}

/// Blockiert einen Nutzer: seine Fänge, Kommentare und Angeltage werden
/// ausgeblendet.
Future<void> blockierenDialog(
    BuildContext context, String andereUid, String name) async {
  final konto = KontoScope.of(context);
  if (konto?.uid == null) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('${at(name)} blockieren?'),
      content: const Text('Du siehst dann keine Fänge, Kommentare und '
          'Angeltage mehr von dieser Person. Du kannst das unter Konto → '
          'Blockierte Nutzer wieder aufheben.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen')),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Blockieren')),
      ],
    ),
  );
  if (ok != true) return;
  await fangDienst.blockieren(konto!.uid!, andereUid, name);
  if (context.mounted) meldung(context, '${at(name)} ist blockiert.');
}
