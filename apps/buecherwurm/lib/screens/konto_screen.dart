import 'package:flutter/material.dart';

import '../main.dart';
import '../services/konto.dart';

/// Anmelden, Registrieren und Konto verwalten für die Online-Rangliste.
class KontoScreen extends StatefulWidget {
  const KontoScreen({super.key});

  @override
  State<KontoScreen> createState() => _KontoScreenState();
}

class _KontoScreenState extends State<KontoScreen> {
  final _email = TextEditingController();
  final _passwort = TextEditingController();
  final _name = TextEditingController();
  var _neu = true;
  Stream<List<Vorschlag>>? _vorschlaege;
  var _laedt = false;
  String? _fehler;

  @override
  void dispose() {
    _email.dispose();
    _passwort.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _ausfuehren(Future<void> Function() aktion, {String? erfolg}) async {
    setState(() {
      _laedt = true;
      _fehler = null;
    });
    try {
      await aktion();
      if (!mounted) return;
      if (erfolg != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erfolg)));
      }
    } on KontoFehler catch (e) {
      if (mounted) setState(() => _fehler = e.text);
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: konto == null
          ? const Center(child: Text('Die Online-Rangliste ist noch nicht eingerichtet.'))
          : konto.angemeldet
              ? _verwalten(konto)
              : _anmelden(konto),
    );
  }

  Widget _anmelden(Konto konto) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Mit einem Konto erscheinst du in der Online-Rangliste und kannst '
          'Freunde über ihren @Namen hinzufügen. Deine Bücher bleiben auf deinem Handy.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Neues Konto')),
            ButtonSegment(value: false, label: Text('Anmelden')),
          ],
          selected: {_neu},
          onSelectionChanged: (s) => setState(() {
            _neu = s.first;
            _fehler = null;
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'E-Mail', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwort,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: const InputDecoration(labelText: 'Passwort', border: OutlineInputBorder()),
        ),
        if (_neu) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            autocorrect: false,
            maxLength: 21,
            decoration: const InputDecoration(
              labelText: '@Name (für Freunde)',
              helperText: 'z. B. @leseratte12 – a–z, 0–9, Punkt, Unterstrich',
              border: OutlineInputBorder(),
            ),
          ),
        ],
        if (_fehler != null) ...[
          const SizedBox(height: 12),
          Text(_fehler!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _laedt
              ? null
              : () => _ausfuehren(() => _neu
                  ? konto.registrieren(_email.text, _passwort.text, _name.text)
                  : konto.anmelden(_email.text, _passwort.text)),
          child: _laedt
              ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_neu ? 'Konto erstellen' : 'Anmelden'),
        ),
        if (!_neu)
          TextButton(
            onPressed: _laedt
                ? null
                : () => _ausfuehren(
                      () => konto.passwortVergessen(_email.text),
                      erfolg: 'Wir haben dir eine E-Mail zum Zurücksetzen geschickt.',
                    ),
            child: const Text('Passwort vergessen?'),
          ),
      ],
    );
  }

  Widget _verwalten(Konto konto) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(konto.name == null ? 'Profil wird geladen …' : '@${konto.name}'),
          subtitle: Text(konto.nutzer?.email ?? ''),
        ),
        const SizedBox(height: 8),
        const Text('Dein Stand wird automatisch hochgeladen, sobald du ein Quiz machst.'),
        if (!(konto.nutzer?.emailVerified ?? true)) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Deine E-Mail-Adresse ist noch nicht bestätigt.'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: _laedt
                            ? null
                            : () => _ausfuehren(konto.bestaetigungSenden,
                                erfolg: 'Bestätigungs-Mail verschickt. Schau in dein Postfach.'),
                        child: const Text('Mail senden'),
                      ),
                      TextButton(
                        onPressed: _laedt ? null : () => _ausfuehren(konto.neuLaden),
                        child: const Text('Ich habe bestätigt'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text('Deine Quizfragen', style: theme.textTheme.titleMedium),
        StreamBuilder<List<Vorschlag>>(
          stream: _vorschlaege ??= konto.meineVorschlaege(),
          builder: (context, snap) {
            final liste = snap.data ?? const [];
            if (liste.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Noch keine. Bei jedem Buch kannst du Quizfragen vorschlagen.'),
              );
            }
            return Column(
              children: [
                for (final v in liste)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(v.frage),
                    subtitle: Text(v.buchTitel),
                    trailing: Text(switch (v.status) {
                      'frei' => '✅ frei',
                      'abgelehnt' => '❌ abgelehnt',
                      _ => '⏳ wird geprüft',
                    }),
                  ),
              ],
            );
          },
        ),
        if (_fehler != null) ...[
          const SizedBox(height: 12),
          Text(_fehler!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: konto.abmelden,
          icon: const Icon(Icons.logout),
          label: const Text('Abmelden'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _laedt ? null : () => _loeschen(konto),
          icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
          label: Text('Konto löschen', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
    );
  }

  Future<void> _loeschen(Konto konto) async {
    final feld = TextEditingController();
    final passwort = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konto löschen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dein Eintrag in der Rangliste, deine Freundesliste und dein @Name '
                'werden gelöscht. Deine Bücher auf dem Handy bleiben.'),
            const SizedBox(height: 12),
            TextField(
              controller: feld,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort zur Bestätigung'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
          FilledButton(onPressed: () => Navigator.pop(context, feld.text), child: const Text('Löschen')),
        ],
      ),
    );
    feld.dispose();
    if (passwort == null || passwort.isEmpty) return;
    await _ausfuehren(() => konto.kontoLoeschen(passwort), erfolg: 'Dein Konto wurde gelöscht.');
  }
}
