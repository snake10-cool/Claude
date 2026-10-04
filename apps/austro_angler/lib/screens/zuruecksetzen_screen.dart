import 'package:flutter/material.dart';

import 'widgets.dart';

const _tipps = <(String, String)>[
  ('💧 Nasse Hände', 'Fass den Fisch nur mit nassen Händen an. Trockene Hände zerstören die Schleimhaut, die ihn vor Pilzen und Krankheiten schützt.'),
  ('⏱️ Schnell sein', 'Jede Sekunde an der Luft ist Stress. Halte Zange, Kescher und Maßband bereit, bevor du den Fisch landest.'),
  ('🪝 Schonhaken', 'Haken ohne Widerhaken (oder angedrückte Widerhaken) lassen sich viel leichter lösen.'),
  ('🥅 Gummi-Kescher', 'Ein Kescher mit gummiertem Netz verletzt Schuppen und Flossen nicht.'),
  ('🌊 Im Wasser lösen', 'Wenn es geht, den Haken lösen, während der Fisch noch im Wasser ist.'),
  ('✂️ Tief geschluckt?', 'Sitzt der Haken sehr tief, lieber die Schnur knapp abschneiden als lange herumzuziehen.'),
  ('🙅 Nicht quetschen', 'Fisch nicht fest drücken, nicht an den Kiemen anfassen und nicht auf trockenen Boden legen.'),
  ('📸 Foto kurz halten', 'Für das Foto den Fisch knapp über dem Wasser halten – und waagrecht, nicht am Maul hochhalten.'),
  ('🔄 Erholen lassen', 'Den Fisch mit dem Kopf gegen die Strömung ins Wasser halten, bis er von selbst wegschwimmt.'),
  ('📏 Untermaßig oder geschont', 'Diese Fische müssen sofort und schonend zurück – das ist Pflicht, nicht nur nett.'),
];

class ZuruecksetzenScreen extends StatelessWidget {
  const ZuruecksetzenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schonend zurücksetzen')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const HinweisKarte(
            'Catch & Release heißt fangen und freilassen. Damit der Fisch '
            'überlebt, kommt es auf die richtigen Handgriffe an.',
            icon: Icons.favorite_outline,
          ),
          const SizedBox(height: 8),
          for (final (titel, text) in _tipps)
            Card(child: ListTile(title: Text(titel), subtitle: Text(text))),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Achtung: In manchen Revieren ist Zurücksetzen von maßigen '
            'Fischen nicht erlaubt (Entnahmepflicht). Es gilt die Lizenz.',
            icon: Icons.gavel,
          ),
        ],
      ),
    );
  }
}
