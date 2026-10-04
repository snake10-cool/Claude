import 'package:flutter/material.dart';

import '../main.dart';
import 'widgets.dart';

/// Einfache Erklärungen für Kinder und Anfänger.
const glossar = <(String, String)>[
  ('Aalrutte', 'Ein Fisch, der als einziger Dorschverwandter im Süßwasser lebt. Wird auch Quappe oder Rutte genannt.'),
  ('Abhaken', 'Den Haken vorsichtig aus dem Maul des Fisches lösen – am besten mit nassen Händen und einer Lösezange.'),
  ('Anfüttern', 'Futter ins Wasser werfen, damit Fische an deinen Platz kommen.'),
  ('Barteln', 'Fühler am Maul mancher Fische, z. B. beim Karpfen oder Wels. Damit tasten sie nach Futter.'),
  ('Beißzeit', 'Die Zeit, in der Fische besonders gern fressen – oft früh am Morgen und am Abend.'),
  ('Brittelmaß', 'Die Mindestlänge: Kleinere Fische müssen sofort zurück ins Wasser. Gemessen von der Maulspitze bis zum Ende der Schwanzflosse.'),
  ('Catch & Release', 'Englisch für "fangen und freilassen": Der Fisch wird schonend zurückgesetzt.'),
  ('Drill', 'Das Herankämpfen des Fisches nach dem Biss, bis du ihn landen kannst.'),
  ('Fettflosse', 'Kleine, weiche Flosse ohne Gräten zwischen Rücken- und Schwanzflosse. Haben z. B. Forellen.'),
  ('Fischerkarte', 'Der amtliche Ausweis zum Fischen. Dafür macht man meist einen Kurs und eine Prüfung. Ohne Prüfung gibt es eine Gastkarte.'),
  ('Friedfisch', 'Fisch, der Pflanzen, Würmer und kleine Tiere frisst – aber keine anderen Fische. Z. B. Karpfen.'),
  ('Gewässerordnung', 'Die Regeln eines bestimmten Reviers. Sie stehen auf der Lizenz und können strenger sein als das Gesetz.'),
  ('Hegene', 'Eine Montage mit mehreren kleinen Nymphen übereinander – damit fängt man Reinanken.'),
  ('Kescher', 'Ein Netz mit Stiel, um den Fisch sicher aus dem Wasser zu holen.'),
  ('Köderfisch', 'Ein kleiner Fisch, der als Köder für Raubfische verwendet wird. In vielen Revieren verboten oder geregelt.'),
  ('Laichzeit', 'Die Zeit, in der Fische ihre Eier ablegen. Deshalb gibt es die Schonzeit.'),
  ('Lizenz', 'Die Erlaubnis, an einem bestimmten Gewässer zu fischen – z. B. eine Tageskarte. Die brauchst du immer zusätzlich zur Fischerkarte.'),
  ('Montage', 'Wie Schnur, Haken, Blei und Pose zusammengebaut sind.'),
  ('Pose', 'Der Schwimmer: Er zeigt dir an, wenn ein Fisch beißt.'),
  ('Raubfisch', 'Fisch, der andere Fische frisst, z. B. Hecht, Zander oder Wels.'),
  ('Revier', 'Ein Gewässerabschnitt, der einem Verein oder Besitzer gehört. Für jedes Revier braucht man eine eigene Lizenz.'),
  ('Salmoniden', 'Lachsfische: Forellen, Saiblinge, Äschen, Huchen und Reinanken.'),
  ('Schneidertag', 'Ein Angeltag ganz ohne Fang. Passiert jedem!'),
  ('Schonzeit', 'Die Zeit, in der ein Fisch nicht gefangen werden darf, weil er gerade laicht. Wird er trotzdem gefangen: sofort zurücksetzen.'),
  ('Spinnfischen', 'Angeln mit Kunstködern wie Spinner, Blinker oder Gummifisch, die man durchs Wasser zieht.'),
  ('Tageskarte', 'Eine Lizenz, die nur für einen Tag gilt.'),
  ('Vorfach', 'Das letzte Stück Schnur vor dem Haken. Bei Hechten aus Stahl, damit sie es nicht durchbeißen.'),
  ('Waidgerecht', 'Fair und tierschonend fischen: Fisch schnell betäuben und töten, wenn man ihn mitnimmt.'),
];

class GlossarScreen extends StatefulWidget {
  const GlossarScreen({super.key});

  @override
  State<GlossarScreen> createState() => _GlossarScreenState();
}

class _GlossarScreenState extends State<GlossarScreen> {
  String _suche = '';

  @override
  Widget build(BuildContext context) {
    final s = _suche.toLowerCase();
    final liste = glossar
        .where((e) =>
            e.$1.toLowerCase().contains(s) || e.$2.toLowerCase().contains(s))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Angel-Wörterbuch')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Wort suchen',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _suche = v.trim()),
          ),
          const SizedBox(height: 8),
          for (final (wort, erklaerung) in liste)
            Card(
              child: ListTile(
                title: Text(wort),
                subtitle: Text(erklaerung),
              ),
            ),
        ],
      ),
    );
  }
}

/// Kleine Erklärung, die nur im Jungangler-Modus erscheint.
class JunganglerTipp extends StatelessWidget {
  const JunganglerTipp(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (!SpeicherScope.of(context).jungangler) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const GlossarScreen())),
        child: HinweisKarte('🧒 $text\n(Tippen für das Angel-Wörterbuch)',
            icon: Icons.lightbulb_outline),
      ),
    );
  }
}
