import 'package:flutter/material.dart';

class _Faq {
  const _Faq(this.frage, this.antwort);

  final String frage;
  final String antwort;
}

const _themen = <String, List<_Faq>>{
  '🎣 Allgemein': [
    _Faq('Was ist Austro Angler?',
        'Eine Angel-App für ganz Österreich mit Schwerpunkt Bezirk Braunau und '
            'Umgebung (Innviertel und Salzburger Flachgau). Sie zeigt dir, wo '
            'du fischen darfst, was die Karten kosten, welche Schonzeiten und '
            'Brittelmaße gelten, und du kannst deine Fänge eintragen und mit '
            'Freunden teilen.'),
    _Faq('Sind wirklich alle Gewässer drin?',
        'Alle Bäche, Flüsse, Kanäle, Seen und Teiche, die in OpenStreetMap '
            'einen Namen haben – über 22.000 in ganz Österreich. Mit Bezirk '
            'und Ort kannst du filtern. Rund um Braunau gibt es zusätzlich '
            'geprüfte Gewässer (✅) mit Lizenzinfos und Preisen. Bei allen '
            'anderen fehlen Lizenz und Preis noch: Hilf mit und ergänze sie!'),
    _Faq('Warum fehlt bei einem Gewässer der Preis?',
        'Für so viele Gewässer gibt es keine öffentliche Preisliste. Die '
            'Lizenz vergibt meist ein Verein, die Gemeinde oder ein '
            'Grundbesitzer. Wenn du den Preis kennst, tipp beim Gewässer auf '
            '"Preis ergänzen" – nach der Prüfung sehen ihn alle.'),
    _Faq('Stimmen alle Angaben?',
        'Wir recherchieren sorgfältig, aber alle Angaben sind ohne Gewähr. Es '
            'gelten immer die Landesgesetze und die Lizenzbedingungen des '
            'Reviers – dort stehen oft strengere Regeln. Findest du einen '
            'Fehler, melde ihn bitte direkt beim Gewässer.'),
    _Faq('Was brauche ich zum Fischen?',
        'Immer zwei Dinge: eine amtliche Fischerkarte (oder Gastfischerkarte) '
            'und eine Lizenz/Tageskarte für das Gewässer. Details stehen unter '
            '"Gewässer" → "Was brauche ich zum Fischen?".'),
  ],
  '👤 Konto & Datenschutz': [
    _Faq('Warum muss ich mich anmelden?',
        'Damit deine Fänge sicher in der Cloud liegen, du sie auf jedem Gerät '
            'hast und die Community (Feed, Freunde, Kommentare) funktioniert. '
            'Dein @Name ist öffentlich, deine E-Mail-Adresse nicht.'),
    _Faq('Wer sieht meine Fänge?',
        'Fänge sind standardmäßig öffentlich: @Name, Fischart, Größe, Gewässer, '
            'Datum und Foto. Pro Fang kannst du "Öffentlich teilen" '
            'ausschalten – dann siehst nur du ihn.'),
    _Faq('Wer sieht meine Angelplätze und Fangorte?',
        'Niemand außer dir. Eigene Angelplätze auf der Karte bleiben auf '
            'deinem Handy, Fangorte werden privat in deinem Konto gespeichert. '
            'Die App verfolgt deinen Standort nie – du wählst Orte selbst aus.'),
    _Faq('Wie lösche ich mein Konto?',
        'Unter "Mehr" → Konto → "Konto und alle Daten löschen". Dann werden '
            'alle Fänge, Fotos, Kommentare-Benachrichtigungen, Fangorte und '
            'dein @Name endgültig gelöscht.'),
    _Faq('Wo werden die Daten gespeichert?',
        'Bei Google Firebase in einem Rechenzentrum in Frankfurt. Wetterdaten '
            'kommen von Open-Meteo, Karten von OpenStreetMap.'),
  ],
  '🎯 Funktionen': [
    _Faq('Wie funktioniert die Beißzeit-Prognose?',
        'Eine Faustregel aus alter Angler-Erfahrung: leicht fallender '
            'Luftdruck, Neu- oder Vollmond, Bewölkung und leichter Wind gelten '
            'als gut, stark steigender Druck oder Sturm als schlecht. Es ist '
            'keine Garantie – aber ein guter Grund, ans Wasser zu gehen 😉'),
    _Faq('Woher kommt die Wasserführung?',
        'Aus Modelldaten (Open-Meteo/GloFAS). Bei großen Flüssen wie dem Inn '
            'ist das recht gut, bei kleinen Bächen nur ungefähr. Für genaue '
            'Pegelstände gibt es den Link zu eHYD, dem offiziellen Pegelportal.'),
    _Faq('Warum wird beim Fang das Wetter gespeichert?',
        'Damit du später in der Statistik siehst, bei welchem Wetter es bei '
            'dir am besten beißt. Das Wetter wird automatisch zu Datum, '
            'Uhrzeit und Ort deines Fangs geholt.'),
    _Faq('Was macht der Schonzeit-Wecker?',
        'Im Fischlexikon kannst du bei einem Fisch den Wecker einschalten. Am '
            'Morgen nach dem Ende der Schonzeit bekommst du eine Erinnerung. '
            'Das funktioniert am Handy, nicht am PC.'),
    _Faq('Was ist die Monats-Challenge?',
        'Jeden Monat gibt es einen Challenge-Fisch (einer, der gerade nicht '
            'geschont ist). Wer den längsten öffentlich teilt, gewinnt 1 Monat '
            'Premium. Länge eintragen nicht vergessen!'),
    _Faq('Warum bekomme ich keine Push-Benachrichtigungen?',
        'Echte Push-Nachrichten brauchen einen eigenen Server, den es noch '
            'nicht gibt. Bis dahin findest du Petri Heil und Kommentare zu '
            'deinen Fängen unter Feed → 🔔 Neuigkeiten.'),
    _Faq('Wofür ist der PDF-Export?',
        'Viele Reviere wollen am Saisonende eine Fangstatistik. Unter '
            'Fangbuch → Statistik kannst du dein Fangbuch eines Jahres als PDF '
            'erstellen, drucken oder verschicken.'),
  ],
  '⭐ Premium': [
    _Faq('Was ist gratis?',
        'Alles, was du zum legalen Fischen brauchst, und die ganze Community: '
            'Gewässer, Preise, Karte, Wetter, Fischlexikon, Schonzeiten, '
            'Fangbuch, Feed, Freunde, Kommentare, Angeltage, Challenge, '
            'Knoten, Checkliste, Prüfungstrainer.'),
    _Faq('Was bringt Premium?',
        'Beißzeit für die nächsten Tage, Statistik-Seite mit Wetter-Auswertung, '
            'Wasserführungs-Verlauf, Schonzeit-Wecker ohne Limit, PDF-Export, '
            'unbegrenzte Fotos, Prüfungsmodus und besondere Abzeichen. '
            'Premium-Funktionen sind mit ⭐ markiert.'),
    _Faq('Was kostet Premium?',
        '3,99 € im Monat oder 29,99 € im Jahr – vorher 7 Tage gratis testen. '
            'Das Abo kommt mit dem Start im Google Play Store. Bis dahin sind '
            'alle ⭐-Funktionen für alle freigeschaltet.'),
    _Faq('Warum gibt es überhaupt ein Abo?',
        'Damit die App weiterentwickelt werden kann: neue Gewässer, aktuelle '
            'Preise, neue Funktionen. Mit dem Abo unterstützt du das – die '
            'wichtigen Funktionen bleiben trotzdem für alle gratis.'),
  ],
  '🤝 Mitmachen': [
    _Faq('Wie kann ich Preise ergänzen?',
        'Beim Gewässer auf "Preis ergänzen" tippen. Ein Admin prüft den '
            'Vorschlag, danach sehen ihn alle sofort.'),
    _Faq('Wie schicke ich einen Wunsch?',
        'Im Tab "Wünsche". Du siehst dort, ob dein Wunsch geplant oder '
            'erledigt ist, und die Antwort des Teams.'),
    _Faq('Was mache ich bei unpassenden Inhalten?',
        'Beim Fang auf die Fahne 🚩 tippen und melden. Bitte nur eigene Fotos '
            'posten, freundlich bleiben und keine geschonten oder untermaßigen '
            'Fische entnehmen.'),
  ],
};

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('FAQ – Fragen & Antworten')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final e in _themen.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Text(e.key, style: text.titleLarge),
            ),
            for (final f in e.value)
              Card(
                child: ExpansionTile(
                  title: Text(f.frage),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(f.antwort)],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
