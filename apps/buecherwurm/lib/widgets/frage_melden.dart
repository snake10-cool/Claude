import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../models/meldung.dart';
import '../services/konto.dart';

/// Öffnet das Fenster „Problem mit dieser Frage melden“.
Future<void> frageMelden(BuildContext context, Buch buch, Frage frage, {String? gewaehlt}) =>
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _MeldenBlatt(buch: buch, frage: frage, gewaehlt: gewaehlt),
    );

class _MeldenBlatt extends StatefulWidget {
  const _MeldenBlatt({required this.buch, required this.frage, this.gewaehlt});

  final Buch buch;
  final Frage frage;
  final String? gewaehlt;

  @override
  State<_MeldenBlatt> createState() => _MeldenBlattState();
}

class _MeldenBlattState extends State<_MeldenBlatt> {
  String? _grund;
  final _text = TextEditingController();
  var _sendet = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool get _ok => _grund != null && (_grund != 'sonstiges' || _text.text.trim().isNotEmpty);

  Future<void> _senden() async {
    final speicher = SpeicherScope.of(context);
    final konto = KontoScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final meldung = FrageMeldung(
      buchId: widget.buch.id,
      buchTitel: widget.buch.titel,
      frage: widget.frage.text,
      richtig: widget.frage.richtig,
      gewaehlt: widget.gewaehlt ?? '',
      grund: _grund!,
      text: _text.text.trim(),
    );
    setState(() => _sendet = true);
    var text = 'Danke! Deine Meldung ist gespeichert und wird gesendet, sobald du angemeldet bist.';
    if (konto != null && konto.angemeldet) {
      try {
        // Ältere, noch nicht angekommene Meldungen gleich mitschicken.
        for (final alt in [...speicher.offeneMeldungen, meldung]) {
          await konto.frageMelden(alt);
        }
        await speicher.meldungenGesendet();
        text = 'Danke! Die Meldung ist beim Admin angekommen.';
      } on KontoFehler {
        await speicher.meldungMerken(meldung);
        text = 'Gerade keine Verbindung – die Meldung wird später gesendet.';
      }
    } else {
      await speicher.meldungMerken(meldung);
    }
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Problem mit der Frage melden', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('„${widget.frage.text}“', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            RadioGroup<String>(
              groupValue: _grund,
              onChanged: (g) => setState(() => _grund = g),
              child: Column(
                children: [
                  for (final MapEntry(:key, :value) in meldeGruende.entries)
                    RadioListTile<String>(value: key, title: Text(value), contentPadding: EdgeInsets.zero, dense: true),
                ],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _text,
              maxLength: 500,
              maxLines: 3,
              minLines: 1,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _grund == 'sonstiges' ? 'Was stimmt nicht? (Pflicht)' : 'Was stimmt nicht? (freiwillig)',
                hintText: 'z. B. „Im Buch essen sie zuerst Pfirsiche“',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _ok && !_sendet ? _senden : null,
                icon: const Icon(Icons.flag),
                label: const Text('Melden'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
