import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import '../models/fisch.dart';
import '../services/alle_gewaesser.dart';
import '../services/darf_ich.dart';
import 'lexikon_screen.dart';
import 'premium_screen.dart';

DarfIch? _ki;
List<Object>? _kiStand;

/// Der Erkenner kennt alle Gewässer – neu bauen, sobald die Liste geladen ist.
DarfIch get darfIch {
  final liste = alleGewaesser.liste;
  if (_ki == null || !identical(_kiStand?.first, liste)) {
    _ki = DarfIch(liste);
    _kiStand = [liste];
  }
  return _ki!;
}

const _beispiele = [
  'Darf ich heute einen Hecht fangen?',
  'Darf ich einen 45 cm Zander mitnehmen?',
  'Was darf ich morgen am Inn fangen?',
  'Äsche an der Mattig am Samstag?',
  'Waller im Mai in Tirol?',
];

/// „Darf ich …?“ – Frage eintippen, Antwort mit Ampel und Rechtsquelle.
class DarfIchScreen extends StatefulWidget {
  const DarfIchScreen({super.key, this.frage});

  final String? frage;

  @override
  State<DarfIchScreen> createState() => _DarfIchScreenState();
}

class _DarfIchScreenState extends State<DarfIchScreen> {
  late final _eingabe = TextEditingController(text: widget.frage ?? '');
  DarfIchAntwort? _antwort;

  @override
  void initState() {
    super.initState();
    alleGewaesser.laden();
    if ((widget.frage ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fragen());
    }
  }

  @override
  void dispose() {
    _eingabe.dispose();
    super.dispose();
  }

  void _fragen([String? text]) {
    if (text != null) _eingabe.text = text;
    final t = _eingabe.text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _antwort = darfIch.fragen(
        t, DateTime.now(), SpeicherScope.of(context).bundesland));
  }

  /// Andere Art aus der Liste prüfen – Datum und Gewässer bleiben.
  void _fischPruefen(Fisch f) {
    final a = _antwort;
    final teile = [
      'Darf ich',
      _eingabe.text.toLowerCase().contains('morgen') ? 'morgen' : '',
      f.name.split(' (').first,
      if (a?.gewaesser != null) 'am ${a!.gewaesser!.name}',
      if (a?.gewaesser == null) a?.land.name ?? '',
      'fangen?',
    ].where((s) => s.isNotEmpty);
    _fragen(teile.join(' '));
  }

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Darf ich …?')),
      body: ListenableBuilder(
        listenable: alleGewaesser,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Frag einfach, wie du redest.', style: text.titleMedium),
            const SizedBox(height: 4),
            Text(
              'Fisch, Gewässer, Tag und Länge – die Antwort kommt direkt aus '
              'den Schonzeiten und Brittelmaßen der Landesgesetze.',
              style: text.bodyMedium?.copyWith(color: farben.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (!hatPremium(context))
              const _Sperre()
            else ...[
              TextField(
                controller: _eingabe,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _fragen(),
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'z. B. Darf ich morgen am Inn einen Zander fangen?',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.chat_bubble_outline),
                  suffixIcon: IconButton(
                    tooltip: 'Prüfen',
                    icon: const Icon(Icons.send),
                    onPressed: _fragen,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_antwort == null)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final b in _beispiele)
                      ActionChip(label: Text(b), onPressed: () => _fragen(b)),
                  ],
                ),
              if (_antwort != null) ...[
                const SizedBox(height: 8),
                _AntwortKarte(_antwort!, onFisch: _fischPruefen),
              ],
            ],
            const SizedBox(height: 16),
            Text(
              'Alle Angaben ohne Gewähr. Es gelten immer das '
              'Landesfischereigesetz und die Lizenzbedingungen des Reviers.',
              style: text.bodySmall?.copyWith(color: farben.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sperre extends StatelessWidget {
  const _Sperre();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text('„Darf ich …?“ ist eine Premium-Funktion',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text('Stell jede Frage zu Schonzeit, Brittelmaß und '
                'Gewässer – 7 Tage gratis testen.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen())),
              child: const Text('Premium ansehen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AntwortKarte extends StatelessWidget {
  const _AntwortKarte(this.a, {required this.onFisch});

  final DarfIchAntwort a;
  final void Function(Fisch) onFisch;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final dunkel = Theme.of(context).brightness == Brightness.dark;
    final (symbol, farbe) = switch (a.ampel) {
      Ampel.ja => ('✅', Colors.green),
      Ampel.achtung => ('⚠️', Colors.orange),
      Ampel.nein => ('⛔', Colors.red),
      Ampel.info => ('💡', Colors.blue),
    };
    final grund = Color.alphaBlend(
        farbe.withValues(alpha: dunkel ? 0.22 : 0.12),
        Theme.of(context).colorScheme.surface);
    return Card(
      color: grund,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: farbe.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(symbol, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(child: Text(a.titel, style: text.titleLarge)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final v in a.verstanden)
                  Chip(
                    label: Text(v),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            for (final p in a.punkte)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  '),
                    Expanded(child: Text(p)),
                  ],
                ),
              ),
            if (a.offen.isNotEmpty || a.geschont.isNotEmpty) ...[
              const SizedBox(height: 6),
              if (a.offen.isNotEmpty) ...[
                Text('✅ Offen (${a.offen.length})', style: text.titleSmall),
                const SizedBox(height: 4),
                _FischChips(a.offen, onFisch),
              ],
              if (a.geschont.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('⛔ Geschont (${a.geschont.length})', style: text.titleSmall),
                const SizedBox(height: 4),
                _FischChips(a.geschont, onFisch),
              ],
            ],
            if (a.fisch != null)
              TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FischDetail(a.fisch!))),
                icon: const Icon(Icons.set_meal_outlined),
                label: const Text('Alle Regeln zu diesem Fisch'),
              ),
            if (a.quelle != null)
              TextButton.icon(
                onPressed: () => launchUrl(Uri.parse(a.quelle!.$2),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.gavel, size: 18),
                label: Text('Quelle: ${a.quelle!.$1}',
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
          ],
        ),
      ),
    );
  }
}

class _FischChips extends StatelessWidget {
  const _FischChips(this.liste, this.onFisch);

  final List<Fisch> liste;
  final void Function(Fisch) onFisch;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final f in liste)
            ActionChip(
              label: Text(f.name.split(' (').first),
              onPressed: () => onFisch(f),
            ),
        ],
      );
}

/// Kompaktes Frage-Feld für Startseite & Co. – öffnet den Darf-ich-Check.
class DarfIchFeld extends StatelessWidget {
  const DarfIchFeld({super.key});

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    return Card(
      color: farben.primaryContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DarfIchScreen())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('🤔', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Darf ich …?',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('„Darf ich morgen am Inn einen Zander mitnehmen?“',
                        style: TextStyle(color: farben.onPrimaryContainer)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
