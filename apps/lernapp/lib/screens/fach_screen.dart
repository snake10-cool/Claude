import 'package:flutter/material.dart';

import '../data/faecher.dart';
import '../main.dart';
import '../models/lehrplan.dart';
import 'quiz_screen.dart';

class FachScreen extends StatelessWidget {
  const FachScreen({super.key, required this.fach, required this.stufe});

  final Fach fach;
  final Stufe stufe;

  @override
  Widget build(BuildContext context) {
    final fortschritt = FortschrittScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${fach.name} · ${stufe.kurz}'),
        backgroundColor: fach.farbe,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final t in themen(fach, stufe))
            Card(
              child: ListTile(
                title: Text(t.titel),
                subtitle: Text(
                  List.generate(3, (i) => i < fortschritt.sterne(t.id) ? '⭐' : '☆')
                      .join(' '),
                ),
                trailing: Icon(Icons.play_circle_fill, color: fach.farbe,
                    size: 36),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(thema: t, farbe: fach.farbe),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
