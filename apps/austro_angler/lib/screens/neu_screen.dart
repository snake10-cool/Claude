import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../design.dart';
import '../main.dart';
import '../services/darf_ich.dart';
import '../services/fern_konfig.dart';
import 'album_screen.dart';
import 'angelplaner_screen.dart';
import 'karriere_screen.dart';
import 'petri_screen.dart';
import 'darf_ich_screen.dart';
import 'einstellungen_screen.dart';
import 'fischerkarte_screen.dart';
import 'live_angeln_screen.dart';
import 'regeln_screen.dart';
import 'premium_screen.dart';
import 'wettfischen_screen.dart';
import 'zielfisch_screen.dart';

/// Stand der Neuigkeiten. Bei jedem Update mit neuem „Was ist neu“ erhöhen.
const neuigkeitenStand = 13;

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
              'Update 1.3${(snap.data ?? '').isEmpty ? '' : ' · Version ${snap.data}'}',
              style: text.labelLarge,
            ),
          ),
          const SizedBox(height: 8),
          const _Held13(),
          const SizedBox(height: 16),
          Text('Neu in 1.3', style: text.titleLarge),
          const SizedBox(height: 8),
          if (funktionAn('ki')) ...[
            _Punkt('🎣', 'Petri-KI – dein KI-Angelguide',
                'Frag alles rund ums Angeln. Petri kennt die Regeln deines '
                'Bundeslands, dein Fangbuch und den heutigen Tag.',
                () => _oeffnen(context, const PetriScreen())),
            _Punkt('📷', 'Fisch per Foto bestimmen',
                'Foto machen – Petri erkennt die Art, die App zeigt gleich '
                'Schonzeit und Brittelmaß.',
                () => _oeffnen(context, const PetriFotoScreen())),
            _Punkt('📊', 'Petri wertet dein Fangbuch aus',
                'Unter Statistik: wann, wo und womit du am besten fängst.'),
          ],
          _Punkt('🏆', 'Angel-Karriere',
              'Level und Ränge vom Grünschnabel bis zum Huchen-König. Punkte '
              'gibt es für Fänge, neue Arten, Challenges und vieles mehr.',
              () => _oeffnen(context, const KarriereScreen())),
          _Punkt('📅', 'Angelplaner',
              'Der beste Angeltag der Woche für deine Gewässer – mit '
              'Erinnerung aufs Handy.',
              () => _oeffnen(context, const AngelplanerScreen())),
          _Punkt('🧺', 'Tageslimit beim Live-Angeln',
              'Limit laut Revier eintragen – die App zählt mit, was du '
              'mitnimmst, und warnt rechtzeitig.',
              () => _oeffnen(context, const LiveAngelnScreen())),
          _Punkt('✨', 'Feinschliff',
              'Das neue Design auf allen Seiten geprüft, lange Fischnamen im '
              'Fang-Formular passen jetzt.'),
          const SizedBox(height: 16),
          Text('Aus Update 1.2', style: text.titleLarge),
          const SizedBox(height: 8),
          const _DesignHeld(),
          const SizedBox(height: 8),
          _Punkt('🎯', 'Beißindex 0–100',
              'Eine Zahl für heute: Luftdruck, Mond, Wolken, Wind und Dämmerung '
              'zusammen – dazu die besten Zeiten des Tages.'),
          _Punkt('⏱️', 'Live-Angeln',
              'Angeltag starten, Uhr läuft. Biss, Fang und Köderwechsel mit '
              'einem Tipp – am Ende siehst du, welcher Köder lief.',
              () => _oeffnen(context, const LiveAngelnScreen())),
          _Punkt('📋', 'Regeln heute',
              'Alle Fischarten deines Bundeslands: offen oder geschont, mit '
              'Brittelmaß. Deine Lieblingsfische oben.',
              () => _oeffnen(context, const RegelnScreen())),
          _Punkt('🎫', 'Digitale Fischerkarte',
              'Name, Nummer und Ablauf mit QR-Code – am Wasser griffbereit.',
              () => _oeffnen(context, const FischerkarteScreen())),
          _Punkt('🗺️', 'Google-Karte mit Suche',
              'Gewässer suchen, nach Flüssen, Seen und geprüften Gewässern filtern.'),
          _Punkt('🎨', 'Hell, dunkel oder automatisch',
              'Unabhängig vom Design einstellbar.',
              () => _oeffnen(context, const EinstellungenScreen())),
          const SizedBox(height: 8),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            shape: const Border(),
            collapsedShape: const Border(),
            title: Text('Aus Update 1.1', style: text.titleLarge),
            children: [
          const _DarfIchHeld(),
          const SizedBox(height: 8),
          _Punkt('🏠', 'Heute-Startseite',
              'Wetter, Beißzeit, deine Gewässer und Lieblingsfische auf einen Blick.'),
          _Punkt('🎯', 'Zielfisch-Modus',
              '„Ich will Hecht“: wo, wann und mit welchem Köder.',
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
          _Punkt('🎣', 'Freunde zu Angeltagen einladen',
              'Beim Angeltag Freunde auswählen – sie bekommen eine Einladung.'),
          _Punkt('⬇️', 'Updates in der App',
              'Neue Versionen laden im Hintergrund – ein Tipp zum Neustarten.'),
            ],
          ),
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

/// Der große Aufmacher von 1.3: Petri-KI (wenn eingeschaltet), sonst die
/// Angel-Karriere.
class _Held13 extends StatelessWidget {
  const _Held13();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    void oeffnen(Widget w) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
    final ki = funktionAn('ki');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RotWeissRot(),
            const SizedBox(height: 12),
            Text(ki ? 'DAS KI-UPDATE' : 'DAS GROSSE UPDATE',
                style: text.labelLarge
                    ?.copyWith(color: akzent, letterSpacing: 1.4)),
            Text(ki ? 'Petri – dein KI-Angelguide.' : 'Deine Angel-Karriere.',
                style: text.headlineMedium),
            const SizedBox(height: 6),
            Text(ki
                ? 'Frag Petri alles rund ums Angeln – Köder, Taktik, Regeln. Oder '
                    'fotografier deinen Fang: Petri erkennt die Art und sagt dir '
                    'gleich, ob sie heute geschont ist.'
                : 'Ab sofort sammelst du Punkte für alles, was du am Wasser '
                    'erlebst und in der App lernst – vom Grünschnabel bis zum '
                    'Huchen-König. Schau, welches Level du schon hast!'),
            const SizedBox(height: 12),
            if (ki)
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => oeffnen(const PetriScreen()),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Frag Petri'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => oeffnen(const PetriFotoScreen()),
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Foto'),
                    ),
                  ),
                ],
              )
            else
              const KarriereChip(),
          ],
        ),
      ),
    );
  }
}

/// Das neue Design groß vorgestellt – direkt umschaltbar.
class _DesignHeld extends StatelessWidget {
  const _DesignHeld();

  @override
  Widget build(BuildContext context) {
    final speicher = SpeicherScope.of(context);
    final text = Theme.of(context).textTheme;
    final akzent = DesignInfo.von(context).akzent;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RotWeissRot(),
            const SizedBox(height: 12),
            Text('DAS GROSSE UPDATE',
                style: text.labelLarge
                    ?.copyWith(color: akzent, letterSpacing: 1.4)),
            Text('Neues Design. Mehr am Wasser.', style: text.headlineMedium),
            const SizedBox(height: 6),
            const Text('Klarer, dunkler, österreichischer. Gefällt dir das '
                'alte besser? Einfach umschalten – jederzeit auch in den '
                'Einstellungen.'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<AppDesign>(
                segments: [
                  for (final d in AppDesign.values)
                    ButtonSegment(value: d, label: Text(d.titel)),
                ],
                selected: {speicher.design},
                onSelectionChanged: (w) => speicher.designSetzen(w.first),
              ),
            ),
          ],
        ),
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
