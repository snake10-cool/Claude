import 'package:flutter/material.dart';

import '../data/faecher.dart';
import '../main.dart';
import '../models/lehrplan.dart';
import 'fach_screen.dart';
import 'klasse_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fortschritt = FortschrittScope.of(context);
    final stufe = fortschritt.stufe!;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernfuchs 🦊'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const KlasseScreen(wechseln: true),
              ),
            ),
            icon: const Icon(Icons.school),
            label: Text(stufe.kurz),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Text('🔥', style: TextStyle(fontSize: 32)),
              title: Text('${fortschritt.serie} Tage in Folge gelernt'),
              subtitle: const Text('Lerne jeden Tag eine Runde!'),
            ),
          ),
          const SizedBox(height: 16),
          Text('Hauptfächer', style: text.titleLarge),
          const SizedBox(height: 8),
          for (final f in hauptfaecher) _FachKachel(fach: f, stufe: stufe),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('Nebenfächer', style: text.titleLarge),
              const SizedBox(width: 8),
              const Chip(
                avatar: Icon(Icons.star, size: 18),
                label: Text('Premium'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final f in nebenfaecher(stufe)) _PremiumKachel(f),
            ],
          ),
        ],
      ),
    );
  }
}

class _FachKachel extends StatelessWidget {
  const _FachKachel({required this.fach, required this.stufe});

  final Fach fach;
  final Stufe stufe;

  @override
  Widget build(BuildContext context) {
    final fortschritt = FortschrittScope.of(context);
    final liste = themen(fach, stufe);
    final sterne = liste.fold(0, (s, t) => s + fortschritt.sterne(t.id));

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: fach.farbe,
          child: Icon(fach.icon, color: Colors.white),
        ),
        title: Text(fach.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text('${liste.length} Themen · ⭐ $sterne / ${liste.length * 3}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FachScreen(fach: fach, stufe: stufe)),
        ),
      ),
    );
  }
}

class _PremiumKachel extends StatelessWidget {
  const _PremiumKachel(this.fach);

  final Fach fach;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.star),
            title: Text('${fach.name} kommt bald'),
            content: const Text(
              'Alle Nebenfächer gibt es bald mit Lernfuchs Premium. '
              'Die Hauptfächer bleiben gratis!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(fach.icon, color: fach.farbe),
              const SizedBox(width: 8),
              Expanded(
                child: Text(fach.name, maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              const Icon(Icons.lock_outline, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
