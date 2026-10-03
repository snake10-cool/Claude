import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _standard = [
  'Amtliche Fischerkarte / Gastkarte',
  'Lizenz bzw. Tageskarte fürs Gewässer',
  'Fangstatistik / Fangbuch',
  'Rute und Rolle',
  'Ersatzschnur und Vorfächer',
  'Haken, Wirbel, Bleie',
  'Köder',
  'Kescher',
  'Maßband',
  'Hakenlöser / Lösezange',
  'Betäubungsholz und Messer',
  'Handtuch',
  'Getränk und Jause',
  'Sonnenschutz / Regenjacke',
  'Handy geladen',
];

/// Ausrüstungs-Checkliste zum Abhaken vor dem Losfahren.
class ChecklisteScreen extends StatefulWidget {
  const ChecklisteScreen({super.key});

  @override
  State<ChecklisteScreen> createState() => _ChecklisteScreenState();
}

class _ChecklisteScreenState extends State<ChecklisteScreen> {
  SharedPreferences? _prefs;
  List<String> _punkte = [];
  Set<String> _erledigt = {};

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) => setState(() {
          _prefs = p;
          _punkte = p.getStringList('checkliste') ?? List.of(_standard);
          _erledigt = (p.getStringList('checkliste_erledigt') ?? []).toSet();
        }));
  }

  void _speichern() {
    _prefs?.setStringList('checkliste', _punkte);
    _prefs?.setStringList('checkliste_erledigt', _erledigt.toList());
  }

  Future<void> _hinzufuegen() async {
    final c = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eigener Punkt'),
        content: TextField(
          controller: c,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text),
              child: const Text('Hinzufügen')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) return;
    setState(() => _punkte.add(text.trim()));
    _speichern();
  }

  @override
  Widget build(BuildContext context) {
    final fertig = _punkte.where(_erledigt.contains).length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkliste ($fertig/${_punkte.length})'),
        actions: [
          IconButton(
            tooltip: 'Alle Häkchen entfernen',
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              setState(() => _erledigt.clear());
              _speichern();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _hinzufuegen,
        child: const Icon(Icons.add),
      ),
      body: _prefs == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                if (fertig == _punkte.length && _punkte.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Alles dabei – Petri Heil! 🎣',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18)),
                  ),
                for (final p in _punkte)
                  Dismissible(
                    key: ValueKey(p),
                    background: Container(color: Colors.red.shade400),
                    onDismissed: (_) {
                      setState(() {
                        _punkte.remove(p);
                        _erledigt.remove(p);
                      });
                      _speichern();
                    },
                    child: CheckboxListTile(
                      title: Text(p),
                      value: _erledigt.contains(p),
                      onChanged: (v) {
                        setState(() =>
                            v == true ? _erledigt.add(p) : _erledigt.remove(p));
                        _speichern();
                      },
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Tipp: Zur Seite wischen löscht einen Punkt.'),
                ),
              ],
            ),
    );
  }
}
