import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import 'widgets.dart';

const _arten = ['Kunstköder', 'Gummifisch', 'Wobbler', 'Spinner', 'Blinker',
  'Fliege', 'Naturköder', 'Boilie', 'Sonstiges'];

/// Eigene Köder verwalten. Mit [auswahl] gibt ein Antippen den Namen zurück.
class KoederScreen extends StatefulWidget {
  const KoederScreen({super.key, this.auswahl = false});

  final bool auswahl;

  @override
  State<KoederScreen> createState() => _KoederScreenState();
}

class _KoederScreenState extends State<KoederScreen> {
  Stream<List<Koeder>>? _stream;

  Future<void> _bearbeiten(String uid, [Koeder? alt]) async {
    final name = TextEditingController(text: alt?.name ?? '');
    final notiz = TextEditingController(text: alt?.notiz ?? '');
    var art = alt?.art.isNotEmpty == true ? alt!.art : _arten.first;
    var foto = alt?.foto;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(alt == null ? 'Neuer Köder' : 'Köder bearbeiten'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final datei = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 400,
                        maxHeight: 400,
                        imageQuality: 50);
                    if (datei == null) return;
                    final bytes = await datei.readAsBytes();
                    setState(() => foto = base64Encode(bytes));
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        foto == null ? null : MemoryImage(base64Decode(foto!)),
                    child: foto == null
                        ? const Icon(Icons.add_a_photo, size: 30)
                        : null,
                  ),
                ),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                      labelText: 'Name, z. B. Shad 10 cm Motoroil'),
                ),
                DropdownButtonFormField<String>(
                  initialValue: art,
                  decoration: const InputDecoration(labelText: 'Art'),
                  items: [
                    for (final a in _arten)
                      DropdownMenuItem(value: a, child: Text(a)),
                  ],
                  onChanged: (v) => setState(() => art = v!),
                ),
                TextField(
                  controller: notiz,
                  maxLength: 200,
                  decoration: const InputDecoration(labelText: 'Notiz'),
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
    await fangDienst.koederSpeichern(
      uid,
      Koeder(
        id: alt?.id ?? '',
        name: name.text.trim(),
        art: art,
        notiz: notiz.text.trim(),
        foto: foto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = KontoScope.of(context)?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Köder-Box')),
        body: const Center(child: Text('Bitte anmelden.')),
      );
    }
    _stream ??= fangDienst.koederBox(uid);
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.auswahl ? 'Köder auswählen' : 'Meine Köder-Box')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bearbeiten(uid),
        icon: const Icon(Icons.add),
        label: const Text('Köder'),
      ),
      body: StreamBuilder<List<Koeder>>(
        stream: _stream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final liste = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
            children: [
              if (liste.length > 10)
                const HinweisKarte('Mehr als 10 Köder ist eine ⭐ Premium-'
                    'Funktion – zurzeit für alle gratis.'),
              if (liste.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                      'Leg deine Lieblingsköder an. Beim Fang kannst du sie '
                      'dann einfach auswählen, und die Statistik zeigt, welcher '
                      'am besten fängt.',
                      textAlign: TextAlign.center),
                ),
              for (final k in liste)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: k.foto == null
                          ? null
                          : MemoryImage(base64Decode(k.foto!)),
                      child: k.foto == null ? const Icon(Icons.phishing) : null,
                    ),
                    title: Text(k.name),
                    subtitle: Text([k.art, if (k.notiz.isNotEmpty) k.notiz]
                        .join(' · ')),
                    onTap: widget.auswahl
                        ? () => Navigator.pop(context, k.name)
                        : () => _bearbeiten(uid, k),
                    trailing: widget.auswahl
                        ? const Icon(Icons.check_circle_outline)
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => fangDienst.koederLoeschen(uid, k.id),
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
