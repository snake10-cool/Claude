import 'package:flutter/material.dart';

import '../main.dart';
import '../services/abo.dart';
import 'widgets.dart';

/// Ob ⭐-Funktionen gerade frei sind (vor dem Start für alle).
bool hatPremium(BuildContext context) =>
    !premiumPflicht ||
    aboDienst.aktiv ||
    (KontoScope.of(context)?.istPremium ?? false);

/// Zeigt [kind] mit Premium – sonst einen Hinweis zum Freischalten.
class PremiumSperre extends StatelessWidget {
  const PremiumSperre({super.key, required this.titel, required this.kind});

  final String titel;
  final Widget kind;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: aboDienst,
      builder: (context, _) {
        if (hatPremium(context)) return kind;
        return Card(
          child: ListTile(
            leading: const Text('⭐', style: TextStyle(fontSize: 26)),
            title: Text(titel),
            subtitle: const Text('Premium-Funktion – 7 Tage gratis testen'),
            trailing: const Icon(Icons.lock_outline),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumScreen())),
          ),
        );
      },
    );
  }
}

const _vorteile = [
  ('🎣', 'Beißzeit für die nächsten Tage'),
  ('📊', 'Statistik mit Wetter-, Köder- und Uhrzeit-Auswertung'),
  ('📈', 'Wasserführungs-Verlauf der letzten 14 Tage'),
  ('⏰', 'Schonzeit-Wecker ohne Limit'),
  ('📄', 'Fangbuch und Revier-Fangstatistik als PDF'),
  ('🗺️', 'Offline-Karte'),
  ('🎁', 'Dein Angeljahr – Jahresrückblick'),
  ('🎓', 'Prüfungsmodus mit Zeitlimit'),
  ('🏅', 'Besondere Abzeichen'),
];

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    aboDienst.starten();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('⭐ Premium')),
      body: ListenableBuilder(
        listenable: aboDienst,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Austro Angler Premium', style: text.headlineSmall),
            const SizedBox(height: 4),
            const Text('Alles, was du zum legalen Fischen brauchst, und die '
                'ganze Community bleiben gratis. Premium gibt dir Extras – '
                'und hilft, die App weiterzuentwickeln.'),
            const SizedBox(height: 12),
            for (final (icon, t) in _vorteile)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text(icon, style: const TextStyle(fontSize: 22)),
                title: Text(t),
              ),
            const SizedBox(height: 12),
            if (!premiumPflicht)
              const HinweisKarte(
                'Bis zum Start im Google Play Store sind alle ⭐-Funktionen '
                'für alle gratis. Danach: 3,99 € im Monat oder 29,99 € im '
                'Jahr, vorher 7 Tage gratis testen.',
                icon: Icons.celebration_outlined,
              ),
            if (aboDienst.aktiv || (konto?.istPremium ?? false))
              const HinweisKarte('Du hast Premium. Danke! 💚',
                  icon: Icons.verified)
            else if (AboDienst.unterstuetzt && aboDienst.produkte.isNotEmpty)
              for (final p in aboDienst.produkte)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton(
                    onPressed: aboDienst.laedt ? null : () => aboDienst.kaufen(p),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        '${p.id == aboJahr ? 'Jahres-Abo' : 'Monats-Abo'}: '
                        '${p.price}',
                      ),
                    ),
                  ),
                )
            else if (premiumPflicht)
              Text(
                AboDienst.unterstuetzt
                    ? 'Abos sind gerade nicht verfügbar. Bitte später nochmal '
                        'versuchen.'
                    : 'Premium kannst du in der Handy-App über Google Play '
                        'abschließen.',
                style: text.bodySmall,
              ),
            if (aboDienst.fehler != null)
              Text(aboDienst.fehler!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            if (AboDienst.unterstuetzt && aboDienst.verfuegbar)
              TextButton(
                onPressed: aboDienst.wiederherstellen,
                child: const Text('Käufe wiederherstellen'),
              ),
            const SizedBox(height: 8),
            Text(
              'Das Abo läuft über Google Play und verlängert sich automatisch. '
              'Kündigen kannst du jederzeit in Google Play unter "Abos". '
              'Den Monats-Challenge-Gewinn (1 Monat Premium) vergibt das Team.',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
