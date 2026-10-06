// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabListen => 'Listen';

  @override
  String get tabGeld => 'Geld';

  @override
  String get tabPacken => 'Packen';

  @override
  String get tabKochen => 'Kochen';

  @override
  String get tabMehr => 'Mehr';

  @override
  String get abbrechen => 'Abbrechen';

  @override
  String get speichern => 'Speichern';

  @override
  String get loeschen => 'Löschen';

  @override
  String get anlegen => 'Anlegen';

  @override
  String get hinzufuegen => 'Hinzufügen';

  @override
  String get umbenennen => 'Umbenennen';

  @override
  String get ok => 'OK';

  @override
  String get name => 'Name';

  @override
  String get menge => 'Menge';

  @override
  String get pflichtfeld => 'Bitte ausfüllen';

  @override
  String get ungueltigerBetrag => 'Bitte einen Betrag wie 12,50 eingeben';

  @override
  String get app => 'App';

  @override
  String get leer => 'Leer';

  @override
  String get ich => 'ich';

  @override
  String get neueListe => 'Neue Liste';

  @override
  String get keineListen => 'Noch keine Liste';

  @override
  String get keineListenText =>
      'Leg eine Einkaufsliste an – für dich allein oder gemeinsam mit deiner WG.';

  @override
  String get fuerMich => 'Für mich';

  @override
  String get allesErledigt => 'Alles erledigt ✓';

  @override
  String offenVon(int offen, int gesamt) {
    return '$offen von $gesamt offen';
  }

  @override
  String get einkauf => 'Einkauf';

  @override
  String get werSiehtDieListe => 'Wer sieht die Liste?';

  @override
  String get nurIch => 'Nur ich';

  @override
  String get gruppeFuerTeilen =>
      'Zum Teilen zuerst unter „Geld“ eine Gruppe anlegen.';

  @override
  String get ichNehmWasMit => 'Ich nehm was mit';

  @override
  String get ichNehmWasMitText =>
      'Du kaufst für eine Person ein. Beträge zahlt nur diese Person.';

  @override
  String get fuerWen => 'Für wen?';

  @override
  String get werBistDu => 'Wer bist du?';

  @override
  String gekauft(String name) {
    return '$name gekauft';
  }

  @override
  String get betragHilfe =>
      'Trag den Preis ein, dann landet er automatisch in der Abrechnung der Gruppe.';

  @override
  String get betragOptional => 'Betrag (optional)';

  @override
  String get ohneBetrag => 'Ohne Betrag';

  @override
  String get abhaken => 'Abhaken';

  @override
  String get artikelBearbeiten => 'Artikel bearbeiten';

  @override
  String get vorlageGespeichert => 'Als Vorlage gespeichert';

  @override
  String get listeLoeschen => 'Liste löschen';

  @override
  String get alsTextTeilen => 'Als Text teilen';

  @override
  String get alleZuruecksetzen => 'Alle Häkchen entfernen';

  @override
  String get erledigteEntfernen => 'Erledigte entfernen';

  @override
  String get alsVorlageSpeichern => 'Als Vorlage speichern';

  @override
  String get artikelHinzufuegenHinweis => 'z. B. „2 Milch“ oder „500 g Mehl“';

  @override
  String get listeLeer => 'Die Liste ist leer';

  @override
  String get listeLeerText =>
      'Tipp oben ein, was fehlt. Mengen erkennt die App selbst.';

  @override
  String erledigtAnzahl(int anzahl) {
    return 'Erledigt ($anzahl)';
  }

  @override
  String get beitreten => 'Gruppe beitreten';

  @override
  String get neueGruppe => 'Neue Gruppe';

  @override
  String get rechner => 'Rechnung & Trinkgeld';

  @override
  String get rechnerText => 'Restaurant-Rechnung fair aufteilen';

  @override
  String get keineGruppen => 'Noch keine Gruppe';

  @override
  String get keineGruppenText =>
      'Gruppen für WG, Familie oder Urlaub: gemeinsame Listen und Ausgaben, die sich selbst abrechnen.';

  @override
  String get geteilt => 'Geteilt';

  @override
  String get nurAufDiesemGeraet => 'Nur auf diesem Gerät';

  @override
  String get duBistQuitt => 'Du bist quitt';

  @override
  String duBekommst(String betrag) {
    return 'Du bekommst $betrag';
  }

  @override
  String duSchuldest(String betrag) {
    return 'Du schuldest $betrag';
  }

  @override
  String get grenzeErreicht => 'Gratis-Grenze erreicht';

  @override
  String grenzeGruppen(int anzahl) {
    return 'Kostenlos kannst du $anzahl Gruppen haben. Mit Teilbar Plus unbegrenzt viele.';
  }

  @override
  String get artWg => 'WG';

  @override
  String get artFamilie => 'Familie';

  @override
  String get artUrlaub => 'Urlaub';

  @override
  String get artEssen => 'Essen gehen';

  @override
  String get artSonst => 'Andere';

  @override
  String get gruppenName => 'Name der Gruppe';

  @override
  String get gruppenNameBeispiel => 'z. B. WG Linz';

  @override
  String get deinName => 'Dein Name';

  @override
  String get weiterePersonen => 'Weitere Personen (optional)';

  @override
  String get weiterePersonenHilfe => 'Mit Komma trennen: Ben, Cem, Dana';

  @override
  String get gruppeLoeschen => 'Gruppe löschen';

  @override
  String get gruppeLoeschenText =>
      'Die Gruppe mit allen Listen und Ausgaben wird gelöscht.';

  @override
  String get gruppeLoeschenOnline =>
      'Die Gruppe wird für alle Mitglieder gelöscht, mit allen Listen und Ausgaben.';

  @override
  String get ausgaben => 'Ausgaben';

  @override
  String get wersSchuldet => 'Wer schuldet wem';

  @override
  String get mitglieder => 'Mitglieder';

  @override
  String get ausgabe => 'Ausgabe';

  @override
  String get keineAusgaben => 'Noch keine Ausgaben';

  @override
  String get keineAusgabenText =>
      'Trag ein, wer was bezahlt hat. Oder hak in einer Gruppenliste einen Artikel mit Betrag ab.';

  @override
  String gesamtAusgaben(String betrag) {
    return 'Insgesamt ausgegeben: $betrag';
  }

  @override
  String bezahltVon(String name) {
    return 'bezahlt von $name';
  }

  @override
  String get soGleichtIhrAus => 'So gleicht ihr aus';

  @override
  String get allesAusgeglichen => 'Alles ausgeglichen. 🎉';

  @override
  String zahltAn(String von, String an) {
    return '$von zahlt $an';
  }

  @override
  String get alsBezahltMarkieren => 'Als bezahlt markieren?';

  @override
  String alsBezahltText(String von, String betrag, String an) {
    return '$von hat $an $betrag gegeben.';
  }

  @override
  String get bezahlt => 'Bezahlt';

  @override
  String get rueckzahlung => 'Rückzahlung';

  @override
  String get personHinzufuegen => 'Person hinzufügen';

  @override
  String get person => 'Person';

  @override
  String get dasBistDu => 'Das bist du';

  @override
  String get dasBinIch => 'Das bin ich';

  @override
  String get gemeinsamNutzen => 'Gemeinsam nutzen';

  @override
  String get gemeinsamNutzenText =>
      'Stell die Gruppe online. Dann sehen alle Mitglieder Listen und Ausgaben live auf ihrem Handy.';

  @override
  String get onlineNichtEingerichtet =>
      'Online-Gruppen sind in dieser Version noch nicht eingerichtet. Die Gruppe funktioniert auf diesem Gerät.';

  @override
  String get onlineTeilen => 'Online teilen';

  @override
  String get keinInternet =>
      'Keine Verbindung. Bitte später nochmal probieren.';

  @override
  String get einladungscode => 'Einladungscode';

  @override
  String get einladen => 'Einladen';

  @override
  String einladungText(String gruppe, String code) {
    return 'Komm in unsere Gruppe „$gruppe“ bei Teilbar! Code: $code';
  }

  @override
  String get neueAusgabe => 'Neue Ausgabe';

  @override
  String get ausgabeBearbeiten => 'Ausgabe bearbeiten';

  @override
  String get ausgabeLoeschen => 'Ausgabe löschen?';

  @override
  String get mindestensEinePerson => 'Mindestens eine Person auswählen.';

  @override
  String get wofuer => 'Wofür?';

  @override
  String get wofuerBeispiel => 'z. B. Pizza, Tanken, Miete';

  @override
  String get betrag => 'Betrag';

  @override
  String get werHatBezahlt => 'Wer hat bezahlt?';

  @override
  String get fuerWenGeteilt => 'Für wen? (gleich aufgeteilt)';

  @override
  String get beitretenText =>
      'Gib den 6-stelligen Code ein, den du bekommen hast, oder scanne den QR-Code.';

  @override
  String get codeUngueltig => 'Der Code hat 6 Zeichen.';

  @override
  String get codeNichtGefunden => 'Diesen Code gibt es nicht.';

  @override
  String get ichBinNeu => 'Ich bin neu dabei';

  @override
  String get qrScannen => 'QR-Code scannen';

  @override
  String get rechnungsbetrag => 'Rechnungsbetrag';

  @override
  String trinkgeldProzent(int prozent) {
    return 'Trinkgeld: $prozent %';
  }

  @override
  String get personen => 'Personen';

  @override
  String get aufrunden => 'Aufrunden';

  @override
  String get aufrundenText => 'Auf 50 Cent pro Person aufrunden';

  @override
  String get proPerson => 'Pro Person';

  @override
  String rechnerErgebnis(String gesamt, String trinkgeld) {
    return 'Gesamt $gesamt, davon $trinkgeld Trinkgeld';
  }

  @override
  String get vorlageStrand => 'Strandurlaub';

  @override
  String get vorlageSki => 'Skiurlaub';

  @override
  String get vorlageFestival => 'Festival';

  @override
  String get vorlageStadt => 'Städtetrip';

  @override
  String get vorlageCamping => 'Camping';

  @override
  String get vorlageBusiness => 'Geschäftsreise';

  @override
  String get wohinGehts => 'Wohin geht\'s?';

  @override
  String artikelAnzahl(int anzahl) {
    return '$anzahl Sachen';
  }

  @override
  String get eigeneVorlagen => 'Eigene Vorlagen';

  @override
  String get leerePackliste => 'Leere Packliste';

  @override
  String get packliste => 'Packliste';

  @override
  String get neuePackliste => 'Neue Packliste';

  @override
  String get keinePacklisten => 'Noch keine Packliste';

  @override
  String get keinePacklistenText =>
      'Wähl eine Vorlage (Strand, Ski, Festival …) und pass sie an. Fertige Listen kannst du als eigene Vorlage speichern.';

  @override
  String get resteKueche => 'Resteküche';

  @override
  String get rezeptDesTages => 'Rezept des Tages';

  @override
  String get wasHastDuDa => 'Was hast du da?';

  @override
  String get zutatEingeben => 'Zutat eingeben, z. B. Eier';

  @override
  String get alleEntfernen => 'Alle entfernen';

  @override
  String get alleRezepte => 'Alle Rezepte';

  @override
  String dazuPasst(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl passende Rezepte',
      one: '1 passendes Rezept',
      zero: 'Kein passendes Rezept',
    );
    return '$_temp0';
  }

  @override
  String minutenPortionen(int minuten, int portionen) {
    return '$minuten Min. · $portionen Portionen';
  }

  @override
  String get allesDa => 'Du hast alles da!';

  @override
  String esFehlt(String zutaten) {
    return 'Es fehlt: $zutaten';
  }

  @override
  String get aufWelcheListe => 'Auf welche Liste?';

  @override
  String get neueEinkaufsliste => 'Neue Einkaufsliste';

  @override
  String aufListeGesetzt(int anzahl, String liste) {
    return '$anzahl Zutaten auf „$liste“ gesetzt';
  }

  @override
  String fehlendeAufListe(int anzahl) {
    return '$anzahl fehlende auf die Einkaufsliste';
  }

  @override
  String minuten(int anzahl) {
    return '$anzahl Min.';
  }

  @override
  String portionen(int anzahl) {
    return '$anzahl Portionen';
  }

  @override
  String get zutaten => 'Zutaten';

  @override
  String get grundzutat => 'Grundzutat – meist zu Hause';

  @override
  String get zubereitung => 'Zubereitung';

  @override
  String get plusTitel => 'Teilbar Plus';

  @override
  String get plusKurz => 'Unbegrenzt Gruppen, ohne Werbung';

  @override
  String get plusVorteilGruppen => 'Unbegrenzt viele Gruppen';

  @override
  String get plusVorteilWerbefrei => 'Keine Werbung';

  @override
  String get plusVorteilUnterstuetzen => 'Du unterstützt die Weiterentwicklung';

  @override
  String get werbefrei => 'Werbung entfernen';

  @override
  String get einmalkauf => 'Einmalkauf';

  @override
  String get profil => 'Profil';

  @override
  String get nichtGesetzt => 'Noch nicht gesetzt';

  @override
  String get werbeEinwilligung => 'Einwilligung für Werbung ändern';
}
