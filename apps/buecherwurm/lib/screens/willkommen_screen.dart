import 'package:flutter/material.dart';

import '../main.dart';
import 'fragebogen_screen.dart';

class WillkommenScreen extends StatefulWidget {
  const WillkommenScreen({super.key});

  @override
  State<WillkommenScreen> createState() => _WillkommenScreenState();
}

class _WillkommenScreenState extends State<WillkommenScreen> {
  late final _name = TextEditingController(text: SpeicherScope.of(context).name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _los() async {
    if (_name.text.trim().isEmpty) return;
    await SpeicherScope.of(context).nameSetzen(_name.text);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const FragebogenScreen(pflicht: true),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const Text('🐛📚', textAlign: TextAlign.center, style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('Willkommen beim Bücherwurm!',
                textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text(
              'Verwalte deine Bücher, finde dein nächstes Lieblingsbuch und '
              'beweise im Quiz, wer am meisten liest.\n\n'
              'Zuerst ein großer Fragebogen (ca. 2 Minuten), damit die '
              'Empfehlungen zu dir passen. Du kannst ihn später jederzeit '
              'neu machen.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Dein Name (für die Rangliste)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _los(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _name.text.trim().isEmpty ? null : _los,
              icon: const Icon(Icons.quiz_outlined),
              label: Text(SpeicherScope.of(context).fragebogenEntwurf == null
                  ? 'Fragebogen starten'
                  : 'Fragebogen fortsetzen'),
            ),
          ],
        ),
      ),
    );
  }
}
