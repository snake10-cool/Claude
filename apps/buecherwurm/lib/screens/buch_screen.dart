import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../widgets/buch_kachel.dart';
import 'quiz_screen.dart';

class BuchScreen extends StatelessWidget {
  const BuchScreen(this.buchId, {super.key});

  final String buchId;

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final buch = speicher.buch(buchId);
    if (buch == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Buch nicht gefunden.')));
    }
    final eintrag = speicher.eintraege[buchId];
    final quiz = speicher.quiz[buchId];
    final theme = Theme.of(context);

    void setzen({Status? status, int? sterne, Format? format}) {
      final alt = eintrag;
      speicher.eintragSetzen(
        buchId,
        Eintrag(
          status: status ?? alt?.status ?? Status.gelesen,
          sterne: sterne ?? alt?.sterne ?? 0,
          format: format ?? alt?.format ?? (speicher.lieblingsFormat == 1 ? Format.gehoert : Format.gelesen),
          notiz: alt?.notiz ?? '',
          datum: status != null && status != alt?.status ? DateTime.now() : alt?.datum,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (eintrag != null)
            IconButton(
              tooltip: 'Aus meinen Büchern entfernen',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => speicher.eintragEntfernen(buchId),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BuchCover(buch, breite: 90),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(buch.titel, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(buch.autor, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (buch.jahr != 0) '${buch.jahr}',
                        if (buch.seiten != 0) '${buch.seiten} Seiten',
                        if (buch.minAlter > 0) 'ab ${buch.minAlter}',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(buch.beschreibung, style: theme.textTheme.bodyLarge),
          if (buch.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in buch.tags)
                  Chip(label: Text(Tags.namen[t] ?? t), visualDensity: VisualDensity.compact),
              ],
            ),
          ],
          const Divider(height: 32),
          Text('Status', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in Status.values)
                ChoiceChip(
                  label: Text(s.text),
                  selected: eintrag?.status == s,
                  onSelected: (_) => setzen(status: s),
                ),
            ],
          ),
          if (eintrag != null && eintrag.status != Status.wunschliste) ...[
            const SizedBox(height: 20),
            Text('Deine Bewertung', style: theme.textTheme.titleMedium),
            Sterne(eintrag.sterne, groesse: 36, onChanged: (n) => setzen(sterne: n)),
            const SizedBox(height: 12),
            SegmentedButton<Format>(
              segments: const [
                ButtonSegment(value: Format.gelesen, icon: Icon(Icons.menu_book), label: Text('Gelesen')),
                ButtonSegment(value: Format.gehoert, icon: Icon(Icons.headphones), label: Text('Gehört')),
              ],
              selected: {eintrag.format},
              onSelectionChanged: (s) => setzen(format: s.first),
            ),
            const SizedBox(height: 12),
            _Notiz(buchId: buchId, eintrag: eintrag),
          ],
          if (buch.hatQuiz) ...[
            const Divider(height: 32),
            Text('Quiz', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (quiz != null)
              Card(
                child: ListTile(
                  leading: Icon(
                    quiz.bestanden ? Icons.verified : Icons.cancel_outlined,
                    color: quiz.bestanden ? Colors.green : theme.colorScheme.error,
                  ),
                  title: Text('${quiz.richtig} von ${quiz.gesamt} richtig · ${quiz.punkte} Punkte'),
                  subtitle: Text(quiz.bestanden
                      ? 'Bestanden – zählt im Wettbewerb.'
                      : 'Nicht bestanden. Nur der erste Versuch zählt.'),
                ),
              ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => QuizScreen(buch: buch),
              )),
              icon: const Icon(Icons.play_arrow),
              label: Text(quiz == null ? 'Quiz starten (${buch.quiz.length} Fragen)' : 'Nochmal üben (ohne Punkte)'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Notiz extends StatefulWidget {
  const _Notiz({required this.buchId, required this.eintrag});

  final String buchId;
  final Eintrag eintrag;

  @override
  State<_Notiz> createState() => _NotizState();
}

class _NotizState extends State<_Notiz> {
  late final _text = TextEditingController(text: widget.eintrag.notiz);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _text,
      maxLines: null,
      decoration: const InputDecoration(
        labelText: 'Notiz (z. B. Lieblingsstelle)',
        border: OutlineInputBorder(),
      ),
      onChanged: (t) {
        widget.eintrag.notiz = t;
        SpeicherScope.of(context).eintragSetzen(widget.buchId, widget.eintrag);
      },
    );
  }
}
