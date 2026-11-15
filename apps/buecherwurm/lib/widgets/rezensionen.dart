import 'package:flutter/material.dart';

import '../main.dart';
import '../models/buch.dart';
import '../screens/konto_screen.dart';
import '../services/konto.dart';
import 'buch_kachel.dart';

/// Rezensionen der Leser zu einem Buch, mit Spoiler-Schutz.
class Rezensionen extends StatelessWidget {
  const Rezensionen({super.key, required this.buch, required this.konto});

  final Buch buch;
  final Konto konto;

  Future<void> _schreiben(BuildContext context) async {
    if (!konto.angemeldet) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const KontoScreen()));
      return;
    }
    final text = TextEditingController();
    var sterne = SpeicherScope.of(context).eintraege[buch.id]?.sterne ?? 0;
    var spoiler = false;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Deine Rezension'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Sterne(sterne, groesse: 32, onChanged: (n) => setState(() => sterne = n)),
                const SizedBox(height: 8),
                TextField(
                  controller: text,
                  maxLength: 1500,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Was hat dir gefallen, was nicht?',
                    border: OutlineInputBorder(),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: spoiler,
                  onChanged: (v) => setState(() => spoiler = v ?? false),
                  title: const Text('Enthält Spoiler'),
                  subtitle: const Text('Wird nur Lesern gezeigt, die das Buch schon gelesen haben'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: sterne == 0 ? null : () => Navigator.pop(context, true),
              child: const Text('Veröffentlichen'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) {
      try {
        await konto.rezensionSchreiben(buch.id, sterne, text.text, spoiler);
        messenger.showSnackBar(const SnackBar(content: Text('Danke für deine Rezension!')));
      } on KontoFehler catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.text)));
      }
    }
    text.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Rezensionen', style: theme.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => _schreiben(context),
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Schreiben'),
            ),
          ],
        ),
        StreamBuilder<List<Rezension>>(
          stream: konto.rezensionen(buch.id),
          builder: (context, snap) {
            if (snap.hasError) return const Text('Rezensionen konnten nicht geladen werden.');
            final liste = snap.data;
            if (liste == null) return const LinearProgressIndicator();
            if (liste.isEmpty) return const Text('Noch keine Rezensionen. Schreib die erste!');
            final schnitt = liste.fold(0, (s, r) => s + r.sterne) / liste.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Sterne(schnitt.round(), groesse: 18),
                    const SizedBox(width: 8),
                    Text('${schnitt.toStringAsFixed(1)} aus ${liste.length} Rezension(en)'),
                  ],
                ),
                const SizedBox(height: 8),
                for (final r in liste) _RezensionKarte(r, konto: konto),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RezensionKarte extends StatefulWidget {
  const _RezensionKarte(this.r, {required this.konto});

  final Rezension r;
  final Konto konto;

  @override
  State<_RezensionKarte> createState() => _RezensionKarteState();
}

class _RezensionKarteState extends State<_RezensionKarte> {
  var _spoilerZeigen = false;
  late Future<int> _hilfreich = widget.konto.hilfreichAnzahl(widget.r.id).catchError((_) => 0);

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final konto = widget.konto;
    final theme = Theme.of(context);
    final gelesen = SpeicherScope.of(context).eintraege[r.buchId]?.status == Status.gelesen;
    final verdeckt = r.spoiler && !gelesen && !_spoilerZeigen;
    final eigene = konto.nutzer?.uid == r.uid;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('@${r.name}', style: theme.textTheme.titleSmall),
                const SizedBox(width: 8),
                Sterne(r.sterne, groesse: 16),
                const Spacer(),
                if (eigene || konto.istAdmin)
                  IconButton(
                    tooltip: 'Löschen',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => konto.rezensionLoeschen(r.id).catchError((_) {}),
                  ),
              ],
            ),
            if (r.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (verdeckt)
                InkWell(
                  onTap: () => setState(() => _spoilerZeigen = true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('⚠️ Enthält Spoiler – erst nach dem Lesen. Tippen, um es trotzdem zu zeigen.'),
                  ),
                )
              else
                Text(r.text),
            ],
            const SizedBox(height: 4),
            FutureBuilder<int>(
              future: _hilfreich,
              builder: (context, snap) => TextButton.icon(
                onPressed: eigene || !konto.angemeldet
                    ? null
                    : () async {
                        await konto.hilfreich(r.id).catchError((_) {});
                        setState(() => _hilfreich = konto.hilfreichAnzahl(r.id).catchError((_) => 0));
                      },
                icon: const Icon(Icons.thumb_up_outlined, size: 18),
                label: Text('Hilfreich${(snap.data ?? 0) > 0 ? ' (${snap.data})' : ''}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
