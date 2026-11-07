import 'dart:async';

import 'package:flutter/material.dart';

import '../design.dart';
import '../main.dart';
import '../services/fang_dienst.dart';
import '../services/live_angeln.dart';
import 'fangbuch_screen.dart';
import 'widgets.dart';

/// Live-Angeln: den Angeltag am Wasser mitschreiben – Uhr läuft, Bisse,
/// Fänge und Köderwechsel mit einem Tipp, am Ende eine Zusammenfassung.
class LiveAngelnScreen extends StatefulWidget {
  const LiveAngelnScreen({super.key});

  @override
  State<LiveAngelnScreen> createState() => _LiveAngelnScreenState();
}

class _LiveAngelnScreenState extends State<LiveAngelnScreen> {
  String _gewaesser = '';
  final _koeder = TextEditingController();
  Timer? _uhr;

  @override
  void initState() {
    super.initState();
    liveAngeln.laden();
    // Die Uhr läuft nur, solange der Bildschirm offen ist.
    _uhr = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && liveAngeln.sitzung != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _uhr?.cancel();
    _koeder.dispose();
    super.dispose();
  }

  Future<String?> _textAbfragen(String titel, String hinweis,
      {String anfang = ''}) {
    final c = TextEditingController(text: anfang);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titel),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: InputDecoration(hintText: hinweis),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, c.text),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _fang(Sitzung s) async {
    final gespeichert = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FangFormular(
            vorGewaesser: s.gewaesser, vorKoeder: s.koeder),
      ),
    );
    if (gespeichert == true) await liveAngeln.eintragen(Ereignis.fang);
  }

  Future<void> _beenden() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Angeltag beenden?'),
        content: const Text('Du bekommst eine Zusammenfassung. Deine Fänge '
            'sind schon im Fangbuch gespeichert.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Weiter angeln')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Beenden')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final konto = KontoScope.of(context);
    final ende = DateTime.now();
    final s = await liveAngeln.beenden();
    if (s == null || !mounted) return;
    // Als Angeltag ins Konto (falls angemeldet).
    final uid = konto?.angemeldet == true ? konto?.uid : null;
    if (uid != null) {
      fangDienst
          .ausflugSpeichern(
              uid,
              Ausflug(
                gewaesser: s.gewaesser,
                start: s.start,
                ende: ende,
                notiz: _zusammenfassungText(s, ende),
              ))
          .catchError((Object e) => debugPrint('Angeltag: $e'));
    }
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => _Zusammenfassung(s, ende, gespeichert: uid != null)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: liveAngeln,
      builder: (context, _) {
        final s = liveAngeln.sitzung;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Live-Angeln'),
            actions: [
              if (s != null && s.eintraege.isNotEmpty)
                IconButton(
                  tooltip: 'Letzten Eintrag zurücknehmen',
                  icon: const Icon(Icons.undo),
                  onPressed: liveAngeln.rueckgaengig,
                ),
            ],
          ),
          body: s == null ? _start(context) : _laufend(context, s),
        );
      },
    );
  }

  Widget _start(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (DesignInfo.von(context).neu) ...[
          const RotWeissRot(),
          const SizedBox(height: 12),
        ],
        Text('Angeltag starten', style: text.headlineSmall),
        const SizedBox(height: 6),
        const Text('Die Uhr läuft, du tippst bei jedem Biss, Fang und '
            'Köderwechsel kurz drauf. Am Ende siehst du, was funktioniert '
            'hat – und der Tag landet in deinen Angeltagen.'),
        const SizedBox(height: 16),
        GewaesserFeld(
          anfang: _gewaesser,
          geaendert: (name, _) => _gewaesser = name,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _koeder,
          decoration: const InputDecoration(
            labelText: 'Köder zum Start',
            hintText: 'z. B. Gummifisch 10 cm',
            prefixIcon: Icon(Icons.phishing),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            if (_gewaesser.trim().isEmpty) {
              meldung(context, 'Bitte zuerst ein Gewässer wählen.');
              return;
            }
            liveAngeln.starten(_gewaesser, _koeder.text);
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Los geht’s'),
        ),
      ],
    );
  }

  Widget _laufend(BuildContext context, Sitzung s) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    final jetzt = DateTime.now();
    final d = s.dauer(jetzt);
    String zwei(int z) => z.toString().padLeft(2, '0');
    final uhr = '${d.inHours}:${zwei(d.inMinutes % 60)}:${zwei(d.inSeconds % 60)}';
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(s.gewaesser.toUpperCase(),
                    textAlign: TextAlign.center, style: text.labelLarge),
                const SizedBox(height: 4),
                Text(uhr,
                    style: text.displayMedium?.copyWith(
                        color: akzent,
                        fontFeatures: const [FontFeature.tabularFigures()])),
                Text('seit ${zwei(s.start.hour)}:${zwei(s.start.minute)} Uhr',
                    style: text.bodySmall),
              ],
            ),
          ),
        ),
        Row(
          children: [
            _Zahl('BISSE', '${s.zaehle(Ereignis.biss)}'),
            _Zahl('FÄNGE', '${s.zaehle(Ereignis.fang)}'),
            _Zahl('BISSE/H', s.bisseProStunde(jetzt).toStringAsFixed(1)),
          ],
        ),
        Card(
          child: ListTile(
            leading: const Text('🪝', style: TextStyle(fontSize: 24)),
            title: Text(s.koeder.isEmpty ? 'Kein Köder angegeben' : s.koeder),
            subtitle: const Text('Aktueller Köder'),
            trailing: TextButton(
              onPressed: () async {
                final k = await _textAbfragen(
                    'Köder wechseln', 'z. B. Spinner Gr. 3',
                    anfang: s.koeder);
                if (k != null && k.trim().isNotEmpty) {
                  await liveAngeln.eintragen(Ereignis.koeder, k);
                }
              },
              child: const Text('Wechseln'),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: _GrosserKnopf(
                symbol: '🎣',
                titel: 'Biss',
                onTap: () => liveAngeln.eintragen(Ereignis.biss),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _GrosserKnopf(
                symbol: '🐟',
                titel: 'Fang',
                hervor: true,
                onTap: () => _fang(s),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final n = await _textAbfragen('Notiz', 'z. B. Wind dreht auf West');
            if (n != null && n.trim().isNotEmpty) {
              await liveAngeln.eintragen(Ereignis.notiz, n);
            }
          },
          icon: const Icon(Icons.edit_note),
          label: const Text('Notiz'),
        ),
        const SizedBox(height: 12),
        if (s.eintraege.isNotEmpty) ...[
          Text('VERLAUF', style: text.labelMedium),
          const SizedBox(height: 4),
          for (final e in s.eintraege.reversed.take(30))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Text(e.art.symbol, style: const TextStyle(fontSize: 20)),
              title: Text(e.art.titel),
              subtitle: e.text.isEmpty ? null : Text(e.text),
              trailing: Text(
                  '${zwei(e.zeit.hour)}:${zwei(e.zeit.minute)}',
                  style: text.bodySmall),
            ),
        ],
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: _beenden,
          icon: const Icon(Icons.flag),
          label: const Text('Angeltag beenden'),
        ),
      ],
    );
  }
}

String _zusammenfassungText(Sitzung s, DateTime ende) {
  final d = ende.difference(s.start);
  final koeder = s.besterKoeder();
  return [
    'Live-Angeln: ${d.inHours} h ${d.inMinutes % 60} min',
    '${s.zaehle(Ereignis.biss)} Bisse, ${s.zaehle(Ereignis.fang)} Fänge',
    if (koeder != null) 'Bester Köder: $koeder',
  ].join(' · ');
}

class _Zahl extends StatelessWidget {
  const _Zahl(this.label, this.wert);

  final String label, wert;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Card(
        margin: const EdgeInsets.fromLTRB(0, 5, 6, 5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Column(
            children: [
              Text(label,
                  style: text.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(wert, style: text.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrosserKnopf extends StatelessWidget {
  const _GrosserKnopf({
    required this.symbol,
    required this.titel,
    required this.onTap,
    this.hervor = false,
  });

  final String symbol, titel;
  final VoidCallback onTap;
  final bool hervor;

  @override
  Widget build(BuildContext context) {
    final schema = Theme.of(context).colorScheme;
    return Material(
      color: hervor ? schema.primary : schema.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22),
          child: Column(
            children: [
              Text(symbol, style: const TextStyle(fontSize: 38)),
              const SizedBox(height: 4),
              Text(titel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: hervor ? schema.onPrimary : schema.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Zusammenfassung nach dem Angeltag.
class _Zusammenfassung extends StatelessWidget {
  const _Zusammenfassung(this.s, this.ende, {required this.gespeichert});

  final Sitzung s;
  final DateTime ende;
  final bool gespeichert;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final d = ende.difference(s.start);
    final koeder = s.besterKoeder();
    final bisse = s.zaehle(Ereignis.biss), faenge = s.zaehle(Ereignis.fang);
    return Scaffold(
      appBar: AppBar(title: const Text('Dein Angeltag')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(faenge > 0 ? 'Petri Heil! 🎉' : 'Schneidertag – nächstes Mal! 💪',
              style: text.headlineSmall),
          const SizedBox(height: 4),
          Text(s.gewaesser, style: text.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              _Zahl('DAUER', '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}'),
              _Zahl('BISSE', '$bisse'),
              _Zahl('FÄNGE', '$faenge'),
            ],
          ),
          Card(
            child: ListTile(
              leading: const Text('🪝', style: TextStyle(fontSize: 24)),
              title: Text(koeder ?? 'Noch kein Lieblingsköder'),
              subtitle: Text(koeder == null
                  ? 'Trag Bisse ein, dann siehst du hier, welcher Köder lief.'
                  : 'Bester Köder heute'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Text('⏱️', style: TextStyle(fontSize: 24)),
              title: Text(
                  '${s.bisseProStunde(ende).toStringAsFixed(1)} Bisse pro Stunde'),
              subtitle: Text(
                  '${s.zaehle(Ereignis.koeder)} Köderwechsel · ${s.zaehle(Ereignis.notiz)} Notizen'),
            ),
          ),
          const SizedBox(height: 8),
          HinweisKarte(
            gespeichert
                ? 'Der Tag ist unter Mehr → Meine Angeltage gespeichert. '
                    'Deine Fänge stehen im Fangbuch.'
                : 'Deine Fänge stehen im Fangbuch. Mit Konto wird der ganze '
                    'Tag auch unter „Meine Angeltage“ gespeichert.',
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }
}
