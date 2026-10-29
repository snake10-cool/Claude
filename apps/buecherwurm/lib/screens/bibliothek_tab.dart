import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';
import 'abhaken_screen.dart';
import 'online_suche_screen.dart';
import 'start_screen.dart';

class BibliothekTab extends StatefulWidget {
  const BibliothekTab({super.key});

  @override
  State<BibliothekTab> createState() => _BibliothekTabState();
}

class _BibliothekTabState extends State<BibliothekTab> {
  var _status = Status.gelesen;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final eintraege = speicher.eintraege.entries
        .where((e) => e.value.status == _status && speicher.buch(e.key) != null)
        .toList()
      ..sort((a, b) => b.value.datum.compareTo(a.value.datum));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _hinzufuegen(context),
        icon: const Icon(Icons.add),
        label: const Text('Buch hinzufügen'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                for (final s in Status.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${s.text} (${speicher.eintraege.values.where((e) => e.status == s).length})'),
                      selected: s == _status,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: eintraege.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        _status == Status.wunschliste
                            ? 'Deine Wunschliste ist leer.\nTippe bei einem Buch auf „Wunschliste".'
                            : 'Noch keine Bücher hier.\nÜber die Suche oben findest du alle Bücher.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: eintraege.length,
                    itemBuilder: (context, i) {
                      final MapEntry(key: id, value: e) = eintraege[i];
                      final buch = speicher.buch(id)!;
                      final quiz = speicher.quiz[id];
                      return ListTile(
                        leading: BuchCover(buch, breite: 36),
                        title: Text(buch.titel),
                        subtitle: Row(
                          children: [
                            if (e.sterne > 0) ...[
                              Sterne(e.sterne, groesse: 16),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                e.status == Status.gelesen ? '${buch.autor} · ${e.format.wort}' : buch.autor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: quiz != null && quiz.bestanden
                            ? const Tooltip(
                                message: 'Quiz bestanden',
                                child: Icon(Icons.verified, color: Colors.green),
                              )
                            : null,
                        onTap: () => buchOeffnen(context, id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _hinzufuegen(BuildContext context) {
    void oeffnen(Widget seite) {
      Navigator.of(context).pop();
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => seite));
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.travel_explore),
              title: const Text('Online suchen'),
              subtitle: const Text('Titel oder Autor – jedes Buch der Welt'),
              onTap: () => oeffnen(const OnlineSucheScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Strichcode scannen'),
              subtitle: const Text('ISBN auf der Rückseite des Buchs'),
              onTap: () => oeffnen(const OnlineSucheScreen(scannen: true)),
            ),
            ListTile(
              leading: const Icon(Icons.checklist),
              title: const Text('Viele Bücher abhaken'),
              subtitle: const Text('Alle Bücher der App durchgehen: gelesen ja/nein'),
              onTap: () => oeffnen(const AbhakenScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Von Hand eintragen'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _eigenesBuch(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _eigenesBuch(BuildContext context) async {
    final titel = TextEditingController();
    final autor = TextEditingController();
    final seiten = TextEditingController();
    final speicher = SpeicherScope.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eigenes Buch hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titel, autofocus: true, decoration: const InputDecoration(labelText: 'Titel')),
            TextField(controller: autor, decoration: const InputDecoration(labelText: 'Autor')),
            TextField(
              controller: seiten,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Seiten (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hinzufügen')),
        ],
      ),
    );
    if (ok == true && titel.text.trim().isNotEmpty) {
      final buch = await speicher.eigenesBuchAnlegen(
        titel.text.trim(),
        autor.text.trim().isEmpty ? 'Unbekannt' : autor.text.trim(),
        int.tryParse(seiten.text.trim()) ?? 0,
      );
      await speicher.eintragSetzen(buch.id, Eintrag(status: _status));
    }
    titel.dispose();
    autor.dispose();
    seiten.dispose();
  }
}
