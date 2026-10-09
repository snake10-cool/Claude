import 'package:flutter/material.dart';

import '../main.dart';
import 'heimat_screen.dart';
import 'widgets.dart';

/// Kurze Einführung beim ersten Start (und jederzeit unter "Mehr").
class EinfuehrungScreen extends StatefulWidget {
  const EinfuehrungScreen({super.key});

  @override
  State<EinfuehrungScreen> createState() => _EinfuehrungScreenState();
}

class _Seite {
  const _Seite(this.symbol, this.titel, this.text);
  final String symbol;
  final String titel;
  final String text;
}

const _seiten = [
  _Seite('🎣', 'Servus und Petri Heil!',
      'Austro Angler hilft dir beim Fischen in ganz Österreich – '
          'ohne Werbung und ohne dass dein Standort verfolgt wird.'),
  _Seite('🌊', 'Gewässer finden',
      'Über 24.000 Flüsse, Bäche und Seen. Filtere nach Bundesland, Bezirk '
          'und Ort und sieh Wetter, Beißzeit, Wasserstand und Lizenz-Infos.'),
  _Seite('📖', 'Dein Fangbuch',
      'Fänge mit Foto, Länge, Köder und Wetter speichern. Die Länge kannst '
          'du sogar per Foto messen. Deine Angelplätze bleiben immer privat.'),
  _Seite('🐟', 'Schonzeiten immer dabei',
      'Schonzeiten und Brittelmaße für 83 Fischarten in allen 9 Bundesländern '
          '– direkt aus den Landesgesetzen. Dazu Lexikon und Bestimmungshilfe.'),
  _Seite('👥', 'Gemeinsam fischen',
      'Fänge teilen, Petri Heil geben, Freunde finden, Angeltage mit '
          'Fahrgemeinschaft ausmachen und in der Rangliste mitmischen.'),
];

class _EinfuehrungScreenState extends State<EinfuehrungScreen> {
  final _blaettern = PageController();
  int _seite = 0;

  // Die letzte Seite ist die Einrichtung (Bundesland und Heimatort).
  int get _anzahl => _seiten.length + 1;
  bool get _letzte => _seite == _anzahl - 1;

  @override
  void dispose() {
    _blaettern.dispose();
    super.dispose();
  }

  Future<void> _fertig() async {
    await SpeicherScope.of(context).einfuehrungErledigt();
    if (mounted) Navigator.of(context).pop();
  }

  void _weiter() => _blaettern.nextPage(
      duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _letzte ? null : _fertig,
                child: Text(_letzte ? '' : 'Überspringen'),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _blaettern,
                onPageChanged: (i) => setState(() => _seite = i),
                children: [
                  for (final s in _seiten)
                    ListView(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
                      children: [
                        Text(s.symbol,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 72)),
                        const SizedBox(height: 24),
                        Text(s.titel,
                            textAlign: TextAlign.center,
                            style: text.headlineSmall),
                        const SizedBox(height: 12),
                        Text(s.text,
                            textAlign: TextAlign.center,
                            style: text.bodyLarge),
                      ],
                    ),
                  const _Einrichtung(),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _anzahl; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.all(4),
                    width: i == _seite ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _seite
                          ? farben.primary
                          : farben.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _letzte ? _fertig : _weiter,
                  child: Text(_letzte ? 'Los geht\'s!' : 'Weiter'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Letzte Seite: Bundesland und (freiwillig) Heimatort wählen.
class _Einrichtung extends StatelessWidget {
  const _Einrichtung();

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      children: [
        const Text('📍',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 72)),
        const SizedBox(height: 24),
        Text('Wo fischst du?',
            textAlign: TextAlign.center, style: text.headlineSmall),
        const SizedBox(height: 12),
        Text(
          'Wähle dein Bundesland – danach richten sich die Schonzeiten. '
          'Mit einem Heimatort siehst du Gewässer nach Entfernung sortiert. '
          'Kein GPS nötig, du kannst alles später unter „Mehr“ ändern.',
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
        const SizedBox(height: 20),
        const BundeslandWahl(),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: speicher,
          builder: (context, _) => OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HeimatScreen())),
            icon: const Icon(Icons.home_outlined),
            label: Text(speicher.heimat.isEmpty
                ? 'Heimatort wählen'
                : 'Heimatort: ${speicher.heimatName}'),
          ),
        ),
      ],
    );
  }
}
