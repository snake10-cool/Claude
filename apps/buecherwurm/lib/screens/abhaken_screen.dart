import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';

/// Ein Bereich zum Abhaken: Altersgruppe oder Merkmal.
class _Bereich {
  const _Bereich(this.name, this.passt);

  final String name;
  final bool Function(Buch b) passt;
}

final _bereiche = <_Bereich>[
  _Bereich('Alle', (_) => true),
  _Bereich('Kinder', (b) => b.zielgruppe == Zielgruppe.kinder),
  _Bereich('Jugend', (b) => b.zielgruppe == Zielgruppe.jugend),
  _Bereich('Erwachsene', (b) => b.zielgruppe == Zielgruppe.erwachsene),
  for (final t in const ['fantasy', 'krimi', 'thriller', 'scifi', 'liebe', 'abenteuer', 'humor', 'horror',
    'historisch', 'klassiker', 'sachbuch', 'serie'])
    _Bereich(Tags.namen[t]!, (b) => b.tags.contains(t)),
];

/// Viele Bücher schnell abhaken: gelesen ja/nein, auf Wunsch mit Sternen.
/// Jede Antwort wird sofort gespeichert – man kann jederzeit aufhören.
class AbhakenScreen extends StatefulWidget {
  const AbhakenScreen({super.key});

  @override
  State<AbhakenScreen> createState() => _AbhakenScreenState();
}

class _AbhakenScreenState extends State<AbhakenScreen> {
  var _bereich = _bereiche.first;
  var _nurOffene = true;

  /// In dieser Sitzung beantwortet: bleiben sichtbar (z. B. für Sterne).
  final _geradeErledigt = <String>{};

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final theme = Theme.of(context);
    final imBereich = speicher.alleBuecher.where(_bereich.passt).toList();
    final erledigt = imBereich.where((b) => speicher.abgehakt(b.id)).length;
    final liste = imBereich
        .where((b) => !_nurOffene || !speicher.abgehakt(b.id) || _geradeErledigt.contains(b.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bücher abhaken'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Einstellungen',
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: 'sterne', checked: speicher.sterneBeimAbhaken, child: const Text('Sterne vergeben')),
              CheckedPopupMenuItem(value: 'offen', checked: _nurOffene, child: const Text('Nur offene zeigen')),
            ],
            onSelected: (w) {
              if (w == 'sterne') speicher.sterneBeimAbhakenSetzen(!speicher.sterneBeimAbhaken);
              if (w == 'offen') setState(() => _nurOffene = !_nurOffene);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              children: [
                for (final b in _bereiche)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(b.name),
                      selected: b == _bereich,
                      onSelected: (_) => setState(() {
                        _bereich = b;
                        _geradeErledigt.clear();
                      }),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$erledigt von ${imBereich.length} erledigt', style: theme.textTheme.labelLarge),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: imBereich.isEmpty ? 0 : erledigt / imBereich.length,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
          Expanded(
            child: liste.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Alles in „${_bereich.name}" abgehakt! 🎉', textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    itemCount: liste.length,
                    itemBuilder: (context, i) => _Zeile(
                      buch: liste[i],
                      onAntwort: (gelesen) {
                        _geradeErledigt.add(liste[i].id);
                        speicher.abhaken(liste[i].id, gelesen);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Zeile extends StatelessWidget {
  const _Zeile({required this.buch, required this.onAntwort});

  final Buch buch;
  final ValueChanged<bool> onAntwort;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final eintrag = speicher.eintraege[buch.id];
    final gelesen = eintrag?.status == Status.gelesen;
    final nein = speicher.geprueft.contains(buch.id);
    final farben = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          BuchCover(buch, breite: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(buch.titel, maxLines: 2, overflow: TextOverflow.ellipsis),
                Text(buch.autor, style: Theme.of(context).textTheme.bodySmall),
                if (gelesen && speicher.sterneBeimAbhaken)
                  Sterne(
                    eintrag!.sterne,
                    groesse: 22,
                    onChanged: (n) {
                      eintrag.sterne = n;
                      speicher.eintragSetzen(buch.id, eintrag);
                    },
                  ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Gelesen',
            isSelected: gelesen,
            selectedIcon: const Icon(Icons.check),
            style: gelesen ? IconButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white) : null,
            icon: const Icon(Icons.check),
            onPressed: () => onAntwort(true),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'Nicht gelesen',
            isSelected: nein,
            style: nein ? IconButton.styleFrom(backgroundColor: farben.error, foregroundColor: farben.onError) : null,
            icon: const Icon(Icons.close),
            onPressed: () => onAntwort(false),
          ),
        ],
      ),
    );
  }
}
