import 'package:flutter/material.dart';

import '../main.dart';
import 'kalender_screen.dart';
import 'knoten_screen.dart';
import 'konto_screen.dart';
import 'lexikon_screen.dart';
import 'pruefung_screen.dart';
import 'widgets.dart';

class MehrScreen extends StatelessWidget {
  const MehrScreen({super.key});

  void _oeffnen(BuildContext context, Widget seite) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => seite));

  @override
  Widget build(BuildContext context) {
    final konto = KontoScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Austro Angler')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(konto?.angemeldet == true
                  ? konto!.name ?? 'Mein Konto'
                  : 'Anmelden / Registrieren'),
              subtitle: Text(konto == null
                  ? 'Online-Funktionen kommen bald'
                  : konto.angemeldet
                      ? 'Mein Konto'
                      : 'Fänge teilen und auf allen Geräten speichern'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _oeffnen(context, const KontoScreen()),
            ),
          ),
          const SizedBox(height: 8),
          const BundeslandWahl(),
          const SizedBox(height: 8),
          _Eintrag(Icons.set_meal, 'Fischlexikon',
              'Schonzeiten & Brittelmaße', () => _oeffnen(context,
                  const LexikonScreen())),
          _Eintrag(Icons.calendar_month, 'Schonzeit-Kalender',
              'Welcher Fisch ist wann offen?', () => _oeffnen(context,
                  const KalenderScreen())),
          _Eintrag(Icons.school, 'Fischerprüfung üben', 'Übungsfragen',
              () => _oeffnen(context, const PruefungScreen())),
          _Eintrag(Icons.gesture, 'Knoten', 'Die wichtigsten Angelknoten',
              () => _oeffnen(context, const KnotenScreen())),
          _Eintrag(Icons.info_outline, 'Über die App', 'Quellen & Datenschutz',
              () => showAboutDialog(
                    context: context,
                    applicationName: 'Austro Angler',
                    applicationVersion: '0.3',
                    children: const [
                      Text(
                        'Alle Angaben zu Schonzeiten, Brittelmaßen und Preisen '
                        'ohne Gewähr. Es gelten immer die Landesgesetze und '
                        'die Lizenzbedingungen des Reviers.\n\n'
                        'Kartendaten © OpenStreetMap-Mitwirkende. '
                        'Wetter von Open-Meteo.\n\n'
                        'Mit Konto werden Nutzername, E-Mail und deine Fänge '
                        'bei Google Firebase gespeichert. Öffentliche Fänge '
                        'sind für alle sichtbar. Dein Konto und alle Daten '
                        'kannst du jederzeit unter "Konto" löschen.',
                      ),
                    ],
                  )),
          const SizedBox(height: 8),
          const HinweisKarte(
            'Angaben ohne Gewähr. Vor dem Fischen immer die Lizenz des Reviers '
            'lesen – dort gelten oft strengere Regeln.',
          ),
        ],
      ),
    );
  }
}

class _Eintrag extends StatelessWidget {
  const _Eintrag(this.icon, this.titel, this.untertitel, this.onTap);

  final IconData icon;
  final String titel;
  final String untertitel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(titel),
        subtitle: Text(untertitel),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
