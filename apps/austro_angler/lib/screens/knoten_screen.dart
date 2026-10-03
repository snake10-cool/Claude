import 'package:flutter/material.dart';

import '../data/knoten.dart';

class KnotenScreen extends StatelessWidget {
  const KnotenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Angelknoten')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final k in knotenListe)
            Card(
              child: ExpansionTile(
                leading: const Icon(Icons.gesture),
                title: Text(k.name),
                subtitle: Text(k.wofuer),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < k.schritte.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(radius: 12, child: Text('${i + 1}',
                              style: text.labelSmall)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(k.schritte[i])),
                        ],
                      ),
                    ),
                  if (k.tipp != null) Text('💡 ${k.tipp}'),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Tipp: Knoten vor dem Festziehen immer anfeuchten – sonst wird die '
            'Schnur durch die Reibung heiß und verliert Tragkraft.',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
