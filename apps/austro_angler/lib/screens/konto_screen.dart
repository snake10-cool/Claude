import 'package:flutter/material.dart';

import '../main.dart';
import '../services/fang_dienst.dart';
import '../services/konto.dart';
import 'widgets.dart';

class KontoScreen extends StatelessWidget {
  const KontoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Konto')),
      body: konto == null
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: HinweisKarte(
                'Die Online-Funktionen (Konto, Community) sind in dieser '
                'Version noch nicht eingerichtet.',
              ),
            )
          : konto.angemeldet
              ? _Profil(konto)
              : const AnmeldeFormular(),
    );
  }
}

class _Profil extends StatelessWidget {
  const _Profil(this.konto);

  final Konto konto;

  Future<void> _hochladen(BuildContext context) async {
    final speicher = SpeicherScope.of(context);
    final anzahl = speicher.faenge.length;
    try {
      for (final f in speicher.faenge) {
        await fangDienst.speichern(f.kopie(
          uid: konto.uid,
          nutzerName: konto.name ?? '',
          oeffentlich: false,
        ));
      }
      await speicher.lokaleFaengeLeeren();
      if (context.mounted) {
        meldung(context, '$anzahl Fänge hochgeladen (privat).');
      }
    } catch (_) {
      if (context.mounted) meldung(context, 'Hochladen fehlgeschlagen.');
    }
  }

  Future<void> _loeschen(BuildContext context) async {
    final passwort = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konto löschen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alle deine Fänge, Fotos und dein Name werden '
                'endgültig gelöscht. Das kann man nicht rückgängig machen.'),
            const SizedBox(height: 12),
            TextField(
              controller: passwort,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passwort'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await konto.kontoLoeschen(passwort.text);
      if (context.mounted) {
        meldung(context, 'Dein Konto wurde gelöscht.');
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (context.mounted) meldung(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final lokal = SpeicherScope.of(context).faenge.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(Icons.account_circle, size: 72),
        const SizedBox(height: 8),
        Text(
          at(konto.name ?? '…'),
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(konto.nutzer?.email ?? '', textAlign: TextAlign.center),
        if (konto.istPremium)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Chip(
                avatar: const Text('⭐'),
                label: Text('Premium bis ${datumText(konto.premiumBis!)}'),
              ),
            ),
          ),
        if (konto.istAdmin)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(
              child: Chip(
                avatar: Icon(Icons.admin_panel_settings, size: 18),
                label: Text('Administrator'),
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (!konto.emailBestaetigt)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📧 Bitte bestätige deine E-Mail-Adresse. Wir '
                      'haben dir einen Link geschickt (auch im Spam-Ordner '
                      'schauen).'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () async {
                          await konto.neuLaden();
                          if (context.mounted && !konto.emailBestaetigt) {
                            meldung(context, 'Noch nicht bestätigt.');
                          }
                        },
                        child: const Text('Ich habe bestätigt'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await konto.bestaetigungSenden();
                            if (context.mounted) {
                              meldung(context, 'E-Mail erneut gesendet.');
                            }
                          } catch (e) {
                            if (context.mounted) meldung(context, '$e');
                          }
                        },
                        child: const Text('Erneut senden'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (lokal > 0)
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text('$lokal Fänge nur auf diesem Handy'),
              subtitle: const Text('Ins Konto hochladen (zuerst privat)'),
              onTap: () => _hochladen(context),
            ),
          ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Abmelden'),
          onTap: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            konto.abmelden();
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_forever,
              color: Theme.of(context).colorScheme.error),
          title: const Text('Konto und alle Daten löschen'),
          onTap: () => _loeschen(context),
        ),
      ],
    );
  }
}

class AnmeldeFormular extends StatefulWidget {
  const AnmeldeFormular({super.key});

  @override
  State<AnmeldeFormular> createState() => _AnmeldenState();
}

class _AnmeldenState extends State<AnmeldeFormular> {
  bool _neu = false;
  bool _laedt = false;
  bool _agb = false;
  String? _fehler;
  final _email = TextEditingController();
  final _passwort = TextEditingController();
  final _name = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _passwort.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _los() async {
    final konto = KontoScope.of(context)!;
    if (_neu) {
      final problem = Konto.nameProblem(_name.text);
      if (problem != null) return setState(() => _fehler = 'Name: $problem');
      if (!_agb) {
        return setState(() => _fehler = 'Bitte die Regeln bestätigen.');
      }
    }
    setState(() {
      _laedt = true;
      _fehler = null;
    });
    try {
      if (_neu) {
        await konto.registrieren(_email.text, _passwort.text, _name.text);
      } else {
        await konto.anmelden(_email.text, _passwort.text);
      }
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    } on KontoFehler catch (e) {
      setState(() => _fehler = e.text);
    } catch (e) {
      setState(() => _fehler = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _laedt = false);
    }
  }

  Future<void> _vergessen() async {
    try {
      await KontoScope.of(context)!.passwortVergessen(_email.text);
      if (mounted) meldung(context, 'E-Mail zum Zurücksetzen verschickt.');
    } on KontoFehler catch (e) {
      setState(() => _fehler = e.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Anmelden')),
            ButtonSegment(value: true, label: Text('Registrieren')),
          ],
          selected: {_neu},
          onSelectionChanged: (s) => setState(() {
            _neu = s.first;
            _fehler = null;
          }),
        ),
        const SizedBox(height: 16),
        if (_neu) ...[
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Dein @Name (einzigartig, öffentlich)',
              prefixText: '@',
              helperText: 'Kein echter Name nötig, z. B. hechtjaeger99',
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'E-Mail'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passwort,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Passwort'),
          onSubmitted: (_) => _los(),
        ),
        if (_neu)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _agb,
            onChanged: (v) => setState(() => _agb = v ?? false),
            title: const Text(
              'Ich halte mich an die Regeln: keine Beleidigungen, nur eigene '
              'Fotos, keine untermaßigen oder geschonten Fische entnehmen.',
            ),
          ),
        if (_fehler != null) ...[
          const SizedBox(height: 12),
          Text(_fehler!,
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _laedt ? null : _los,
          child: _laedt
              ? const SizedBox.square(
                  dimension: 20, child: CircularProgressIndicator())
              : Text(_neu ? 'Konto erstellen' : 'Anmelden'),
        ),
        if (!_neu)
          TextButton(
            onPressed: _vergessen,
            child: const Text('Passwort vergessen?'),
          ),
        const SizedBox(height: 16),
        const HinweisKarte(
          'Deine Fänge sind standardmäßig öffentlich – mit Nutzername, '
          'Fischart, Größe und Gewässer. Deine eigenen Angelplätze auf der '
          'Karte bleiben immer privat auf deinem Handy.',
        ),
      ],
    );
  }
}

/// Startbildschirm: Ohne Anmeldung kommt man nicht in die App.
class AnmeldeSeite extends StatelessWidget {
  const AnmeldeSeite({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text('🎣', style: TextStyle(fontSize: 56)),
                Text('Austro Angler', style: text.headlineMedium),
                const Text('Fischen im Bezirk Braunau und Umgebung'),
                const Expanded(child: AnmeldeFormular()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
