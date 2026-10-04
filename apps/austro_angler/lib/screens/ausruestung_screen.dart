import 'package:flutter/material.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

const _arten = ['Rute', 'Rolle', 'Schnur', 'Montage', 'Sonstiges'];

/// Ausrüstungs-Tagebuch: Ruten, Rollen, Schnüre.
class AusruestungScreen extends StatefulWidget {
  const AusruestungScreen({super.key});

  @override
  State<AusruestungScreen> createState() => _AusruestungScreenState();
}

class _AusruestungScreenState extends State<AusruestungScreen> {
  Stream<List<Ausruestung>>? _liste;

  Future<void> _bearbeiten(String uid, [Ausruestung? alt]) async {
    final name = TextEditingController(text: alt?.name ?? '');
    final notiz = TextEditingController(text: alt?.notiz ?? '');
    var art = alt?.art ?? _arten.first;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(alt == null ? 'Neue Ausrüstung' : 'Bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 6,
                  children: [
                    for (final a in _arten)
                      ChoiceChip(
                        label: Text(a),
                        selected: art == a,
                        onSelected: (_) => setState(() => art = a),
                      ),
                  ],
                ),
                TextField(
                  controller: name,
                  maxLength: 100,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'z. B. Spinnrute 2,40 m'),
                ),
                TextField(
                  controller: notiz,
                  maxLength: 300,
                  decoration: const InputDecoration(
                      labelText: 'Notiz', hintText: 'Wurfgewicht, Marke …'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Abbrechen')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Speichern')),
          ],
        ),
      ),
    );
    if (ok != true || name.text.trim().isEmpty) return;
    try {
      await fangDienst.ausruestungSpeichern(
          uid,
          Ausruestung(
              id: alt?.id ?? '',
              name: name.text.trim(),
              art: art,
              notiz: notiz.text.trim()));
    } catch (_) {
      if (mounted) meldung(context, 'Speichern fehlgeschlagen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    if (konto?.uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meine Ausrüstung')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: AnmeldenKarte('Melde dich an, um deine Ausrüstung zu '
              'speichern.'),
        ),
      );
    }
    final uid = konto!.uid!;
    _liste ??= fangDienst.ausruestung(uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Ausrüstung')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bearbeiten(uid),
        icon: const Icon(Icons.add),
        label: const Text('Hinzufügen'),
      ),
      body: StreamBuilder<List<Ausruestung>>(
        stream: _liste,
        builder: (context, snap) {
          final liste = snap.data ?? const <Ausruestung>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [
              const HinweisKarte(
                'Trag deine Ruten, Rollen und Schnüre ein. Beim Fang kannst du '
                'dann auswählen, womit du gefangen hast – die Statistik zeigt '
                'deine erfolgreichste Ausrüstung.',
                icon: Icons.handyman_outlined,
              ),
              if (snap.connectionState == ConnectionState.waiting &&
                  !snap.hasData)
                const Center(child: CircularProgressIndicator()),
              for (final a in liste)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(switch (a.art) {
                        'Rolle' => Icons.settings,
                        'Schnur' => Icons.linear_scale,
                        'Montage' => Icons.phishing,
                        'Rute' => Icons.straighten,
                        _ => Icons.handyman,
                      }),
                    ),
                    title: Text(a.name),
                    subtitle: Text([a.art, if (a.notiz.isNotEmpty) a.notiz]
                        .join(' · ')),
                    onTap: () => _bearbeiten(uid, a),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => fangDienst.ausruestungLoeschen(uid, a.id),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
