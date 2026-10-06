// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get tabLernen => 'Lernen';

  @override
  String get tabStapel => 'Stapel';

  @override
  String get tabSnippets => 'Snippets';

  @override
  String get tabMehr => 'Mehr';

  @override
  String get abbrechen => 'Abbrechen';

  @override
  String get speichern => 'Speichern';

  @override
  String get loeschen => 'Löschen';

  @override
  String get bearbeiten => 'Bearbeiten';

  @override
  String get fertig => 'Fertig';

  @override
  String get name => 'Name';

  @override
  String get notiz => 'Notiz';

  @override
  String get titel => 'Titel';

  @override
  String get sprache => 'Sprache';

  @override
  String get code => 'Code';

  @override
  String get codeOptional => 'Code (optional)';

  @override
  String get frage => 'Frage';

  @override
  String get antwort => 'Antwort';

  @override
  String get pflichtfeld => 'Bitte ausfüllen';

  @override
  String get app => 'App';

  @override
  String get einstellungen => 'Einstellungen';

  @override
  String get statistik => 'Statistik';

  @override
  String get lernen => 'Lernen';

  @override
  String get kopieren => 'Kopieren';

  @override
  String get kopiert => 'Kopiert';

  @override
  String get codeKopieren => 'Code kopieren';

  @override
  String get leeren => 'Leeren';

  @override
  String get heuteTitel => 'Heute';

  @override
  String get tagesziel => 'Tagesziel';

  @override
  String get zielGeschafft => 'Tagesziel geschafft! 🎉';

  @override
  String streakTage(int anzahl) {
    String _temp0 = intl.Intl.pluralLogic(
      anzahl,
      locale: localeName,
      other: '$anzahl Tage am Stück',
      one: '1 Tag am Stück',
    );
    return '$_temp0';
  }

  @override
  String get streakStarten =>
      'Lerne heute dein Tagesziel und starte eine Serie.';

  @override
  String jetztLernen(int faellig, int neu) {
    return 'Jetzt lernen · $faellig fällig, $neu neu';
  }

  @override
  String get allesErledigt => 'Alles erledigt für heute';

  @override
  String get allesErledigtText =>
      'Morgen sind wieder Karten fällig. Oder schalte weitere Stapel frei.';

  @override
  String get deineStapel => 'Deine Stapel';

  @override
  String get alleStapel => 'Alle Stapel';

  @override
  String get keineAktivenStapel =>
      'Kein Stapel ausgewählt. Wähle unter „Stapel“ aus, was du lernen willst.';

  @override
  String karteVon(int nr, int gesamt) {
    return 'Karte $nr von $gesamt';
  }

  @override
  String get alsSnippet => 'Als Snippet speichern';

  @override
  String get alsSnippetGespeichert => 'Als Snippet gespeichert';

  @override
  String get neu => 'Neu';

  @override
  String get gleich => 'gleich';

  @override
  String tageKurz(int tage) {
    return '$tage T';
  }

  @override
  String get antwortZeigen => 'Antwort zeigen';

  @override
  String get nochmal => 'Nochmal';

  @override
  String get schwer => 'Schwer';

  @override
  String get gut => 'Gut';

  @override
  String get leicht => 'Leicht';

  @override
  String get waehleAntwort => 'Wähle eine Antwort.';

  @override
  String get zuLeicht => 'Zu leicht';

  @override
  String get richtigWeiter => 'Richtig! Weiter';

  @override
  String get falschWeiter => 'Weiter (kommt nochmal)';

  @override
  String get nichtsZuLernen => 'Gerade ist nichts fällig.';

  @override
  String get rundeFertig => 'Runde geschafft!';

  @override
  String rundeErgebnis(int gesamt, int richtig) {
    return '$gesamt Karten, $richtig davon gewusst.';
  }

  @override
  String get fertigeStapel => 'Fertige Stapel';

  @override
  String get eigeneStapel => 'Eigene Stapel';

  @override
  String get eigeneStapelLeer =>
      'Leg eigene Stapel an oder speichere Snippets als Lernkarten.';

  @override
  String get eigenerStapel => 'Eigener Stapel';

  @override
  String get stapelBearbeiten => 'Stapel bearbeiten';

  @override
  String get stapelBeispiel => 'z. B. Mein Java-Kurs';

  @override
  String stapelZahlen(int anzahl, int gelernt, int gefestigt) {
    return '$anzahl Karten · $gelernt angefangen · $gefestigt gefestigt';
  }

  @override
  String get karten => 'Karten';

  @override
  String get neuMehrzahl => 'Neu';

  @override
  String get faellig => 'Fällig';

  @override
  String get gefestigt => 'Gefestigt';

  @override
  String get stapelLernen => 'Diesen Stapel lernen';

  @override
  String freiBis(String zeit) {
    return 'Per Video freigeschaltet bis $zeit';
  }

  @override
  String get inHeuteLernen => 'In „Heute“ lernen';

  @override
  String get inHeuteLernenText =>
      'Fällige Karten dieses Stapels kommen in die tägliche Runde.';

  @override
  String get kartenAnsehen => 'Alle Karten ansehen';

  @override
  String get vorschau => 'Vorschau ansehen';

  @override
  String get fortschrittZuruecksetzen => 'Fortschritt zurücksetzen';

  @override
  String get fortschrittZuruecksetzenText =>
      'Alle Karten dieses Stapels gelten wieder als neu.';

  @override
  String get zuruecksetzen => 'Zurücksetzen';

  @override
  String get stapelLoeschen => 'Stapel löschen';

  @override
  String get stapelLoeschenText =>
      'Der Stapel und alle seine Karten werden gelöscht.';

  @override
  String get stapelGesperrt => 'Dieser Stapel ist ein Zusatzpaket.';

  @override
  String get kaufenNichtVerfuegbar => 'Kaufen (gerade nicht verfügbar)';

  @override
  String paketKaufen(String preis) {
    return 'Für immer freischalten · $preis';
  }

  @override
  String get videoFreischalten => 'Video ansehen: 24 Stunden gratis';

  @override
  String get allesAbo => 'Oder alle Stapel mit dem Abo';

  @override
  String get freigeschaltet24 => 'Freigeschaltet für 24 Stunden. Viel Spaß!';

  @override
  String get videoNichtVerfuegbar =>
      'Gerade ist kein Video verfügbar. Versuch es später nochmal.';

  @override
  String get karteHinzufuegen => 'Karte hinzufügen';

  @override
  String get karteBearbeiten => 'Karte bearbeiten';

  @override
  String get keineKarten => 'Noch keine Karten';

  @override
  String get keineKartenText => 'Füge deine erste Karte hinzu.';

  @override
  String get mehrNachFreischalten => 'Weitere Karten nach dem Freischalten.';

  @override
  String get karteLoeschen => 'Karte löschen?';

  @override
  String get karteLoeschenText =>
      'Die Karte und ihr Lernstand werden gelöscht.';

  @override
  String get typBegriff => 'Begriff';

  @override
  String get typAusgabe => 'Ausgabe';

  @override
  String get typLuecke => 'Lücke';

  @override
  String get wasGibtAus => 'Was gibt dieser Code aus?';

  @override
  String get lueckeHilfe =>
      'Schreib ___ (drei Unterstriche) an die Stelle der Lücke.';

  @override
  String get lueckeFehlt => 'Im Code fehlt die Lücke ___';

  @override
  String get richtigeAntwort => 'Richtige Antwort';

  @override
  String falscheAntwort(int nr) {
    return 'Falsche Antwort $nr';
  }

  @override
  String get mindestensEineFalsche => 'Mindestens eine falsche Antwort';

  @override
  String get erklaerungOptional => 'Erklärung (optional)';

  @override
  String get snippetsSuchen => 'Snippets durchsuchen';

  @override
  String get neuesSnippet => 'Neues Snippet';

  @override
  String get keineSnippets => 'Noch keine Snippets';

  @override
  String get keineSnippetsText =>
      'Speichere Code, den du dir merken willst. Beim Lernen geht das mit einem Tipp auf das Lesezeichen.';

  @override
  String get nichtsGefunden => 'Nichts gefunden.';

  @override
  String get favorit => 'Favorit';

  @override
  String get alsLernkarte => 'Als Lernkarte';

  @override
  String get snippetLoeschen => 'Snippet löschen?';

  @override
  String get snippetBearbeiten => 'Snippet bearbeiten';

  @override
  String get snippetTitelBeispiel => 'z. B. Liste sortieren';

  @override
  String get tags => 'Tags';

  @override
  String get tagsHilfe => 'Mit Komma trennen, z. B. listen, sortieren';

  @override
  String get stapelMeineSnippets => 'Meine Snippets';

  @override
  String get wasMachtDieserCode => 'Was macht dieser Code?';

  @override
  String get alsKarteGespeichert =>
      'Als Lernkarte im Stapel „Meine Snippets“ gespeichert';

  @override
  String get proTitel => 'Codekarten Alles';

  @override
  String get proKurz => 'Alle Stapel, alle neuen Stapel, ohne Werbung';

  @override
  String get proVorteilAlle =>
      'Alle Stapel: Java Profi, Python, Dart, JavaScript';

  @override
  String get proVorteilNeue => 'Alle neuen Stapel, sobald sie erscheinen';

  @override
  String get proVorteilWerbefrei => 'Keine Werbung';

  @override
  String get proVorteilUnterstuetzen => 'Du unterstützt die Weiterentwicklung';

  @override
  String get aktuelleSerie => 'Aktuelle Serie';

  @override
  String get laengsteSerie => 'Längste Serie';

  @override
  String get wiederholungen => 'Wiederholungen';

  @override
  String get trefferquote => 'Trefferquote';

  @override
  String get kartenGelernt => 'Karten angefangen';

  @override
  String get kartenGefestigt => 'Karten gefestigt (21+ Tage)';

  @override
  String get letzte30Tage => 'Letzte 30 Tage';

  @override
  String get diagrammHilfe => 'Kräftige Balken: Tagesziel erreicht.';

  @override
  String kartenProTag(int anzahl) {
    return '$anzahl Karten pro Tag';
  }

  @override
  String get neueProTag => 'Neue Karten pro Tag';

  @override
  String neueProTagText(int anzahl) {
    return 'Bis zu $anzahl neue Karten am Tag (der Rest sind Wiederholungen)';
  }

  @override
  String get werbeEinwilligung => 'Einwilligung für Werbung ändern';
}
