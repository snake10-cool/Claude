import 'package:flutter/material.dart';

import '../main.dart';
import 'ausfluege_screen.dart';
import 'checkliste_screen.dart';
import 'koeder_screen.dart';
import 'lizenzen_screen.dart';
import 'quiz_screen.dart';
import 'vereine_screen.dart';
import 'faq_screen.dart';
import 'kalender_screen.dart';
import 'statistik_screen.dart';
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
          _Eintrag(Icons.help_outline, 'FAQ – Fragen & Antworten',
              'Alles erklärt: wieso, weshalb, warum', () => _oeffnen(context,
                  const FaqScreen())),
          _Eintrag(Icons.bar_chart, 'Statistik & Abzeichen',
              'Rekorde, Auswertungen, PDF-Export', () => _oeffnen(context,
                  const StatistikScreen())),
          _Eintrag(Icons.event_available, 'Meine Angeltage ⭐',
              'Ganze Tage erfassen, auch Schneidertage', () => _oeffnen(context,
                  const AusfluegeScreen())),
          _Eintrag(Icons.phishing, 'Köder-Box',
              'Deine Köder mit Foto', () => _oeffnen(context,
                  const KoederScreen())),
          _Eintrag(Icons.badge, 'Meine Lizenzen',
              'Ablaufdatum und Erinnerung', () => _oeffnen(context,
                  const LizenzenScreen())),
          _Eintrag(Icons.groups_2, 'Vereine & Verbände',
              'Vereine der Region, Gewässer, Termine', () => _oeffnen(context,
                  const VereineScreen())),
          _Eintrag(Icons.quiz, 'Fisch-Quiz',
              'Erkennst du alle Fische?', () => _oeffnen(context,
                  const FischQuizScreen())),
          _Eintrag(Icons.checklist, 'Ausrüstungs-Checkliste',
              'Nichts vergessen vor dem Losfahren', () => _oeffnen(context,
                  const ChecklisteScreen())),
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
          _Eintrag(Icons.privacy_tip_outlined, 'Datenschutz',
              'Welche Daten wofür gespeichert werden',
              () => webseiteOeffnen('datenschutz')),
          _Eintrag(Icons.gavel, 'Nutzungsbedingungen & Regeln',
              'Community-Regeln, Premium, Haftung',
              () => webseiteOeffnen('nutzungsbedingungen')),
          _Eintrag(Icons.info_outline, 'Über die App', 'Impressum & Quellen',
              () => showAboutDialog(
                    context: context,
                    applicationName: 'Austro Angler',
                    applicationVersion: '1.0',
                    applicationIcon: Image.asset('assets/icon/app.png',
                        width: 48, height: 48),
                    children: [
                      const Text(
                        'Alle Angaben zu Schonzeiten, Brittelmaßen und Preisen '
                        'ohne Gewähr. Es gelten immer die Landesgesetze und '
                        'die Lizenzbedingungen des Reviers.\n\n'
                        'Kartendaten © OpenStreetMap-Mitwirkende. '
                        'Wetter von Open-Meteo.\n\n'
                        'Dein Konto und alle Daten kannst du jederzeit unter '
                        '"Konto" löschen.',
                      ),
                      TextButton(
                        onPressed: () => webseiteOeffnen('impressum'),
                        child: const Text('Impressum'),
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
