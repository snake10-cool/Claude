import 'package:flutter/material.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import 'profil_screen.dart';
import 'widgets.dart';

/// Neuigkeiten: wer bei meinen Fängen Petri Heil gesagt oder kommentiert hat.
class AktivitaetenScreen extends StatefulWidget {
  const AktivitaetenScreen({super.key});

  @override
  State<AktivitaetenScreen> createState() => _AktivitaetenScreenState();
}

class _AktivitaetenScreenState extends State<AktivitaetenScreen> {
  Stream<List<Eintrag>>? _stream;

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context)!;
    _stream ??= fangDienst.aktivitaeten(konto.uid!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuigkeiten'),
        actions: [
          IconButton(
            tooltip: 'Alle löschen',
            icon: const Icon(Icons.done_all),
            onPressed: () => fangDienst.aktivitaetenLeeren(konto.uid!),
          ),
        ],
      ),
      body: StreamBuilder<List<Eintrag>>(
        stream: _stream,
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Laden fehlgeschlagen.'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          if (liste.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Noch nichts Neues. Teile Fänge, dann bekommst du '
                    'hier Petri Heil und Kommentare! 🎣',
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final a in liste)
                Card(
                  child: ListTile(
                    leading: Text(a.typ == 'petri' ? '👍' : '💬',
                        style: const TextStyle(fontSize: 26)),
                    title: Text(a.typ == 'petri'
                        ? '${at(a.nutzerName)} sagt Petri Heil!'
                        : '${at(a.nutzerName)} hat kommentiert'),
                    subtitle: Text([
                      if (a.text.isNotEmpty) '"${a.text}"',
                      '${datumText(a.erstellt)} ${uhrText(a.erstellt)}',
                    ].join('\n')),
                    trailing: const Icon(Icons.person_outline),
                    onTap: () => profilOeffnen(context, a.uid, a.nutzerName),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
