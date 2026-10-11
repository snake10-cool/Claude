import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../main.dart';
import '../services/darf_ich.dart';
import 'album_screen.dart';
import 'darf_ich_screen.dart';
import 'premium_screen.dart';
import 'wettfischen_screen.dart';
import 'zielfisch_screen.dart';

/// Stand der Neuigkeiten. Bei jedem Update mit neuem „Was ist neu“ erhöhen.
const neuigkeitenStand = 11;

/// „Was ist neu?“ – nach einem Update einmal gezeigt, sonst unter Mehr.
class NeuScreen extends StatelessWidget {
  const NeuScreen({super.key});

  static final _version = PackageInfo.fromPlatform()
      .then((i) => i.version, onError: (_) => '');

  void _oeffnen(BuildContext context, Widget seite) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => seite));

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Was ist neu?')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<String>(
            future: _version,
            builder: (context, snap) => Text(
              'Update 1.1${(snap.data ?? '').isEmpty ? '' : ' · Version ${snap.data}'}',
              style: text.labelLarge,
            ),
          ),
          const SizedBox(height: 8),
          const _DarfIchHeld(),
          const SizedBox(height: 16),
          Text('Außerdem neu', style: text.titleLarge),
          const SizedBox(height: 8),
          _Punkt('🏠', 'Heute-Startseite',
              'Wetter, Beißzeit, deine Gewässer und Lieblingsfische auf einen Blick.'),
          _Punkt('🎯', 'Zielfisch-Modus',
              '„Ich will Hecht“ → wo, wann und mit welchem Köder.',
              () => _oeffnen(context, const ZielfischScreen())),
          _Punkt('⭐', 'Gewässer folgen',
              'Stern antippen – deine Gewässer stehen immer oben.'),
          _Punkt('🏆', 'Eigene Wettfischen',
              'Mit Freunden oder dem Verein, per Code. Mit Rangliste und Urkunde.',
              () => _oeffnen(context, const WettfischenScreen())),
          _Punkt('📒', 'Arten-Sammelalbum',
              'Sammle alle Fischarten Österreichs – von häufig bis legendär.',
              () => _oeffnen(context, const AlbumScreen())),
          _Punkt('⚖️', 'Gewicht schätzen',
              'Länge eingeben, das Gewicht wird für die Fischart geschätzt.'),
          _Punkt('🔔', 'Benachrichtigungen',
              'Glocke mit Zähler für Petri Heil, Kommentare und Freunde.'),
          _Punkt('🔗', 'Fang-Link teilen',
              'Ein Link zu deinem Fang – öffnet sich auch ohne App.'),
          _Punkt('📊', 'Fangbuch als CSV',
              'Alle Fänge als Tabelle für Excel – deine Daten gehören dir.'),
          _Punkt('🥇', 'Rangliste für viele',
              'Schneller und bereit für ganz Österreich.'),
          _Punkt('⬇️', 'Updates in der App',
              'Neue Versionen laden im Hintergrund – ein Tipp zum Neustarten.'),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Los geht’s – Petri Heil!'),
          ),
        ],
      ),
    );
  }
}

/// Der Darf-ich-Check groß vorgestellt – mit Beispiel-Frage und -Antwort.
class _DarfIchHeld extends StatelessWidget {
  const _DarfIchHeld();

  @override
  Widget build(BuildContext context) {
    final farben = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final premium = hatPremium(context);
    const frage = 'Darf ich morgen am Inn einen 45 cm Zander mitnehmen?';
    final a = darfIch.fragen(
        frage, DateTime.now(), SpeicherScope.of(context).bundesland);
    final (symbol, farbe) = switch (a.ampel) {
      Ampel.ja => ('✅', Colors.green),
      Ampel.achtung => ('⚠️', Colors.orange),
      Ampel.nein => ('⛔', Colors.red),
      Ampel.info => ('💡', Colors.blue),
    };
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [farben.primary, farben.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🤔', style: TextStyle(fontSize: 40)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Neu: „Darf ich …?“',
                          style: text.headlineSmall
                              ?.copyWith(color: farben.onPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Frag einfach, wie du redest. Die App versteht Fisch, '
                  'Gewässer, Tag und Länge – auch Mundart wie Waller, Rutte '
                  'oder Renke und Tippfehler – und antwortet sofort aus den '
                  'Schonzeiten und Brittelmaßen der Landesgesetze. '
                  'Funktioniert auch offline.',
                  style: TextStyle(color: farben.onPrimary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: farben.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(frage),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: farbe.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: farbe.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(symbol, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a.titel, style: text.titleMedium),
                            if (a.punkte.isNotEmpty) Text(a.punkte.first),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => premium
                              ? const DarfIchScreen()
                              : const PremiumScreen())),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(premium
                      ? 'Jetzt fragen'
                      : '⭐ Mit Premium – 7 Tage gratis testen'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Punkt extends StatelessWidget {
  const _Punkt(this.symbol, this.titel, this.text, [this.onTap]);

  final String symbol;
  final String titel;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Text(symbol, style: const TextStyle(fontSize: 26)),
          title: Text(titel),
          subtitle: Text(text),
          trailing: onTap == null ? null : const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );
}
