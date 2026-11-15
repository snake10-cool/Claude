import 'package:flutter/material.dart';

import '../data/katalog.dart';
import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';

/// Bücher antippen, die man schon gelesen oder gehört hat, optional mit
/// Sternen. Das füttert die Empfehlungen.
class GelesenAuswahlScreen extends StatefulWidget {
  const GelesenAuswahlScreen({super.key, required this.pflicht});

  final bool pflicht;

  @override
  State<GelesenAuswahlScreen> createState() => _GelesenAuswahlScreenState();
}

class _GelesenAuswahlScreenState extends State<GelesenAuswahlScreen> {
  var _suche = '';

  Future<void> _fertig() async {
    final speicher = SpeicherScope.of(context);
    if (widget.pflicht) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      await speicher.einrichtungAbschliessen();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final s = _suche.toLowerCase();
    final buecher = katalog
        .where((b) => s.isEmpty || b.titel.toLowerCase().contains(s) || b.autor.toLowerCase().contains(s))
        .toList();
    final anzahl = speicher.eintraege.values
        .where((e) => e.status == Status.gelesen)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Was hast du schon gelesen?')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Tippe alle Bücher an, die du gelesen oder gehört hast. Mit Sternen '
              'werden die Empfehlungen noch genauer.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Titel oder Autor suchen',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (t) => setState(() => _suche = t),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: buecher.length,
              itemBuilder: (context, i) {
                final buch = buecher[i];
                final eintrag = speicher.eintraege[buch.id];
                final gelesen = eintrag?.status == Status.gelesen;
                return ListTile(
                  leading: BuchCover(buch, breite: 36),
                  title: Text(buch.titel),
                  subtitle: gelesen
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Sterne(
                            eintrag!.sterne,
                            groesse: 22,
                            onChanged: (n) {
                              eintrag.sterne = n;
                              speicher.eintragSetzen(buch.id, eintrag);
                            },
                          ),
                        )
                      : Text(buch.autor),
                  trailing: Checkbox(
                    value: gelesen,
                    onChanged: (_) => _umschalten(buch, gelesen),
                  ),
                  onTap: () => _umschalten(buch, gelesen),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _fertig,
            child: Text(anzahl == 0 ? 'Überspringen' : 'Fertig ($anzahl gewählt)'),
          ),
        ),
      ),
    );
  }

  void _umschalten(Buch buch, bool gelesen) {
    final speicher = SpeicherScope.of(context);
    if (gelesen) {
      speicher.eintragEntfernen(buch.id);
    } else {
      speicher.eintragSetzen(
        buch.id,
        Eintrag(
          status: Status.gelesen,
          format: speicher.lieblingsFormat == 1 ? Format.gehoert : Format.gelesen,
        ),
      );
    }
  }
}
