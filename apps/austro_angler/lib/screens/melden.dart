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
