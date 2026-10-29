import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import 'fragebogen_screen.dart';
import 'gelesen_auswahl_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final gelesen = speicher.eintraege.values.where((e) => e.status == Status.gelesen).toList();
    final gehoert = gelesen.where((e) => e.format == Format.gehoert).length;
    final bewertet = gelesen.where((e) => e.sterne > 0).toList();
    final schnitt = bewertet.isEmpty
        ? null
        : bewertet.fold(0, (s, e) => s + e.sterne) / bewertet.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(speicher.name),
            subtitle: const Text('Name in der Rangliste'),
            trailing: const Icon(Icons.edit),
            onTap: () => _nameAendern(context),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Zahl('${gelesen.length}', 'Bücher fertig'),
                _Zahl('$gehoert', 'davon gehört'),
                _Zahl(schnitt == null ? '–' : schnitt.toStringAsFixed(1), 'Ø Sterne'),
                _Zahl('${speicher.punkte}', 'Quiz-Punkte'),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Fragebogen neu machen'),
            subtitle: const Text('Deine Vorlieben ändern sich? Kein Problem.'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FragebogenScreen(pflicht: false),
            )),
          ),
          ListTile(
            leading: const Icon(Icons.checklist),
            title: const Text('Gelesene Bücher auswählen'),
            subtitle: const Text('Schnell viele Bücher abhaken und bewerten'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const GelesenAuswahlScreen(pflicht: false),
            )),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Alle Daten löschen', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () async {
              final navigator = Navigator.of(context);
              final ok = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Wirklich alles löschen?'),
                  content: const Text('Bücher, Bewertungen, Quiz-Punkte und Fragebogen werden gelöscht.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
                  ],
                ),
              );
              if (ok != true) return;
              navigator.popUntil((r) => r.isFirst);
              await speicher.allesLoeschen();
            },
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Alle Daten bleiben auf deinem Handy. Bücherwurm 0.1'),
          ),
        ],
      ),
    );
  }

  Future<void> _nameAendern(BuildContext context) async {
    final speicher = SpeicherScope.of(context);
    final feld = TextEditingController(text: speicher.name);
    final neu = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name ändern'),
        content: TextField(controller: feld, autofocus: true, maxLength: 20),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, feld.text), child: const Text('Speichern')),
        ],
      ),
    );
    feld.dispose();
    if (neu != null && neu.trim().isNotEmpty) await speicher.nameSetzen(neu);
  }
}

class _Zahl extends StatelessWidget {
  const _Zahl(this.wert, this.text);

  final String wert;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(wert, style: theme.textTheme.headlineMedium),
          Text(text, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
