import 'package:flutter/material.dart';

import '../main.dart';
import '../services/wecker.dart';
import 'widgets.dart';

/// Eigene Fischerkarten und Lizenzen mit Ablaufdatum und Erinnerung.
class LizenzenScreen extends StatefulWidget {
  const LizenzenScreen({super.key});

  @override
  State<LizenzenScreen> createState() => _LizenzenScreenState();
}

class _LizenzenScreenState extends State<LizenzenScreen> {
  List<Lizenz>? _liste;

  @override
  void initState() {
    super.initState();
    Wecker.instanz.lizenzen().then((l) {
      if (mounted) setState(() => _liste = l);
    });
  }

  Future<void> _speichern() => Wecker.instanz
      .lizenzenSpeichern(_liste!, SpeicherScope.of(context).bundesland);

  Future<void> _neu() async {
    final name = TextEditingController();
    var ablauf = DateTime(DateTime.now().year, 12, 31);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Lizenz hinzufügen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: 'Name, z. B. Jahreslizenz Inn'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event),
                title: Text('Gültig bis ${datumText(ablauf)}'),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: ablauf,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (d != null) setState(() => ablauf = d);
                },
              ),
            ],
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
    setState(() => _liste = [..._liste!, Lizenz(name.text.trim(), ablauf)]
      ..sort((a, b) => a.ablauf.compareTo(b.ablauf)));
    await _speichern();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meine Lizenzen')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _liste == null ? null : _neu,
        icon: const Icon(Icons.add),
        label: const Text('Lizenz'),
      ),
      body: _liste == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
              children: [
                HinweisKarte(Wecker.unterstuetzt
                    ? 'Du bekommst 2 Wochen und 1 Tag vor dem Ablauf eine '
                        'Erinnerung.'
                    : 'Erinnerungen gibt es nur am Handy – am PC siehst du '
                        'hier die Übersicht.'),
                if (_liste!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                        'Trag deine Fischerkarte und Lizenzen ein, damit du '
                        'nie mit abgelaufener Karte am Wasser stehst.',
                        textAlign: TextAlign.center),
                  ),
                for (final l in _liste!)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        _tageBis(l.ablauf) < 0
                            ? Icons.error
                            : _tageBis(l.ablauf) < 14
                                ? Icons.warning_amber
                                : Icons.verified,
                        color: _tageBis(l.ablauf) < 0
                            ? Colors.red
                            : _tageBis(l.ablauf) < 14
                                ? Colors.orange
                                : Colors.green,
                      ),
                      title: Text(l.name),
                      subtitle: Text(switch (_tageBis(l.ablauf)) {
                        < 0 => 'Abgelaufen am ${datumText(l.ablauf)}',
                        0 => 'Gültig bis heute (${datumText(l.ablauf)})',
                        1 => 'Gültig bis morgen (${datumText(l.ablauf)})',
                        final n => 'Gültig bis ${datumText(l.ablauf)} '
                            '(noch $n Tage)',
                      }),
                      trailing: IconButton(
                        tooltip: 'Löschen',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          if (!await loeschenBestaetigen(context, l.name) ||
                              !mounted) {
                            return;
                          }
                          setState(() => _liste = [..._liste!]..remove(l));
                          await _speichern();
                        },
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Ganze Tage von heute bis [ablauf] (Ablauftag zählt noch als gültig).
int _tageBis(DateTime ablauf) {
  final heute = DateTime.now();
  return DateTime.utc(ablauf.year, ablauf.month, ablauf.day)
      .difference(DateTime.utc(heute.year, heute.month, heute.day))
      .inDays;
}
