import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @tabLernen.
  ///
  /// In de, this message translates to:
  /// **'Lernen'**
  String get tabLernen;

  /// No description provided for @tabStapel.
  ///
  /// In de, this message translates to:
  /// **'Stapel'**
  String get tabStapel;

  /// No description provided for @tabSnippets.
  ///
  /// In de, this message translates to:
  /// **'Snippets'**
  String get tabSnippets;

  /// No description provided for @tabMehr.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get tabMehr;

  /// No description provided for @abbrechen.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get abbrechen;

  /// No description provided for @speichern.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get speichern;

  /// No description provided for @loeschen.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get loeschen;

  /// No description provided for @bearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get bearbeiten;

  /// No description provided for @fertig.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get fertig;

  /// No description provided for @name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @notiz.
  ///
  /// In de, this message translates to:
  /// **'Notiz'**
  String get notiz;

  /// No description provided for @titel.
  ///
  /// In de, this message translates to:
  /// **'Titel'**
  String get titel;

  /// No description provided for @sprache.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get sprache;

  /// No description provided for @code.
  ///
  /// In de, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @codeOptional.
  ///
  /// In de, this message translates to:
  /// **'Code (optional)'**
  String get codeOptional;

  /// No description provided for @frage.
  ///
  /// In de, this message translates to:
  /// **'Frage'**
  String get frage;

  /// No description provided for @antwort.
  ///
  /// In de, this message translates to:
  /// **'Antwort'**
  String get antwort;

  /// No description provided for @pflichtfeld.
  ///
  /// In de, this message translates to:
  /// **'Bitte ausfüllen'**
  String get pflichtfeld;

  /// No description provided for @app.
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @einstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get einstellungen;

  /// No description provided for @statistik.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statistik;

  /// No description provided for @lernen.
  ///
  /// In de, this message translates to:
  /// **'Lernen'**
  String get lernen;

  /// No description provided for @kopieren.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get kopieren;

  /// No description provided for @kopiert.
  ///
  /// In de, this message translates to:
  /// **'Kopiert'**
  String get kopiert;

  /// No description provided for @codeKopieren.
  ///
  /// In de, this message translates to:
  /// **'Code kopieren'**
  String get codeKopieren;

  /// No description provided for @leeren.
  ///
  /// In de, this message translates to:
  /// **'Leeren'**
  String get leeren;

  /// No description provided for @heuteTitel.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get heuteTitel;

  /// No description provided for @tagesziel.
  ///
  /// In de, this message translates to:
  /// **'Tagesziel'**
  String get tagesziel;

  /// No description provided for @zielGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Tagesziel geschafft! 🎉'**
  String get zielGeschafft;

  /// No description provided for @streakTage.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =1{1 Tag am Stück} other{{anzahl} Tage am Stück}}'**
  String streakTage(int anzahl);

  /// No description provided for @streakStarten.
  ///
  /// In de, this message translates to:
  /// **'Lerne heute dein Tagesziel und starte eine Serie.'**
  String get streakStarten;

  /// No description provided for @jetztLernen.
  ///
  /// In de, this message translates to:
  /// **'Jetzt lernen · {faellig} fällig, {neu} neu'**
  String jetztLernen(int faellig, int neu);

  /// No description provided for @allesErledigt.
  ///
  /// In de, this message translates to:
  /// **'Alles erledigt für heute'**
  String get allesErledigt;

  /// No description provided for @allesErledigtText.
  ///
  /// In de, this message translates to:
  /// **'Morgen sind wieder Karten fällig. Oder schalte weitere Stapel frei.'**
  String get allesErledigtText;

  /// No description provided for @deineStapel.
  ///
  /// In de, this message translates to:
  /// **'Deine Stapel'**
  String get deineStapel;

  /// No description provided for @alleStapel.
  ///
  /// In de, this message translates to:
  /// **'Alle Stapel'**
  String get alleStapel;

  /// No description provided for @keineAktivenStapel.
  ///
  /// In de, this message translates to:
  /// **'Kein Stapel ausgewählt. Wähle unter „Stapel“ aus, was du lernen willst.'**
  String get keineAktivenStapel;

  /// No description provided for @karteVon.
  ///
  /// In de, this message translates to:
  /// **'Karte {nr} von {gesamt}'**
  String karteVon(int nr, int gesamt);

  /// No description provided for @alsSnippet.
  ///
  /// In de, this message translates to:
  /// **'Als Snippet speichern'**
  String get alsSnippet;

  /// No description provided for @alsSnippetGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Als Snippet gespeichert'**
  String get alsSnippetGespeichert;

  /// No description provided for @neu.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get neu;

  /// No description provided for @gleich.
  ///
  /// In de, this message translates to:
  /// **'gleich'**
  String get gleich;

  /// No description provided for @tageKurz.
  ///
  /// In de, this message translates to:
  /// **'{tage} T'**
  String tageKurz(int tage);

  /// No description provided for @antwortZeigen.
  ///
  /// In de, this message translates to:
  /// **'Antwort zeigen'**
  String get antwortZeigen;

  /// No description provided for @nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get nochmal;

  /// No description provided for @schwer.
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get schwer;

  /// No description provided for @gut.
  ///
  /// In de, this message translates to:
  /// **'Gut'**
  String get gut;

  /// No description provided for @leicht.
  ///
  /// In de, this message translates to:
  /// **'Leicht'**
  String get leicht;

  /// No description provided for @waehleAntwort.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Antwort.'**
  String get waehleAntwort;

  /// No description provided for @zuLeicht.
  ///
  /// In de, this message translates to:
  /// **'Zu leicht'**
  String get zuLeicht;

  /// No description provided for @richtigWeiter.
  ///
  /// In de, this message translates to:
  /// **'Richtig! Weiter'**
  String get richtigWeiter;

  /// No description provided for @falschWeiter.
  ///
  /// In de, this message translates to:
  /// **'Weiter (kommt nochmal)'**
  String get falschWeiter;

  /// No description provided for @nichtsZuLernen.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist nichts fällig.'**
  String get nichtsZuLernen;

  /// No description provided for @rundeFertig.
  ///
  /// In de, this message translates to:
  /// **'Runde geschafft!'**
  String get rundeFertig;

  /// No description provided for @rundeErgebnis.
  ///
  /// In de, this message translates to:
  /// **'{gesamt} Karten, {richtig} davon gewusst.'**
  String rundeErgebnis(int gesamt, int richtig);

  /// No description provided for @fertigeStapel.
  ///
  /// In de, this message translates to:
  /// **'Fertige Stapel'**
  String get fertigeStapel;

  /// No description provided for @eigeneStapel.
  ///
  /// In de, this message translates to:
  /// **'Eigene Stapel'**
  String get eigeneStapel;

  /// No description provided for @eigeneStapelLeer.
  ///
  /// In de, this message translates to:
  /// **'Leg eigene Stapel an oder speichere Snippets als Lernkarten.'**
  String get eigeneStapelLeer;

  /// No description provided for @eigenerStapel.
  ///
  /// In de, this message translates to:
  /// **'Eigener Stapel'**
  String get eigenerStapel;

  /// No description provided for @stapelBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Stapel bearbeiten'**
  String get stapelBearbeiten;

  /// No description provided for @stapelBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. Mein Java-Kurs'**
  String get stapelBeispiel;

  /// No description provided for @stapelZahlen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Karten · {gelernt} angefangen · {gefestigt} gefestigt'**
  String stapelZahlen(int anzahl, int gelernt, int gefestigt);

  /// No description provided for @karten.
  ///
  /// In de, this message translates to:
  /// **'Karten'**
  String get karten;

  /// No description provided for @neuMehrzahl.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get neuMehrzahl;

  /// No description provided for @faellig.
  ///
  /// In de, this message translates to:
  /// **'Fällig'**
  String get faellig;

  /// No description provided for @gefestigt.
  ///
  /// In de, this message translates to:
  /// **'Gefestigt'**
  String get gefestigt;

  /// No description provided for @stapelLernen.
  ///
  /// In de, this message translates to:
  /// **'Diesen Stapel lernen'**
  String get stapelLernen;

  /// No description provided for @freiBis.
  ///
  /// In de, this message translates to:
  /// **'Per Video freigeschaltet bis {zeit}'**
  String freiBis(String zeit);

  /// No description provided for @inHeuteLernen.
  ///
  /// In de, this message translates to:
  /// **'In „Heute“ lernen'**
  String get inHeuteLernen;

  /// No description provided for @inHeuteLernenText.
  ///
  /// In de, this message translates to:
  /// **'Fällige Karten dieses Stapels kommen in die tägliche Runde.'**
  String get inHeuteLernenText;

  /// No description provided for @kartenAnsehen.
  ///
  /// In de, this message translates to:
  /// **'Alle Karten ansehen'**
  String get kartenAnsehen;

  /// No description provided for @vorschau.
  ///
  /// In de, this message translates to:
  /// **'Vorschau ansehen'**
  String get vorschau;

  /// No description provided for @fortschrittZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Fortschritt zurücksetzen'**
  String get fortschrittZuruecksetzen;

  /// No description provided for @fortschrittZuruecksetzenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Karten dieses Stapels gelten wieder als neu.'**
  String get fortschrittZuruecksetzenText;

  /// No description provided for @zuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get zuruecksetzen;

  /// No description provided for @stapelLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Stapel löschen'**
  String get stapelLoeschen;

  /// No description provided for @stapelLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Der Stapel und alle seine Karten werden gelöscht.'**
  String get stapelLoeschenText;

  /// No description provided for @stapelGesperrt.
  ///
  /// In de, this message translates to:
  /// **'Dieser Stapel ist ein Zusatzpaket.'**
  String get stapelGesperrt;

  /// No description provided for @kaufenNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Kaufen (gerade nicht verfügbar)'**
  String get kaufenNichtVerfuegbar;

  /// No description provided for @paketKaufen.
  ///
  /// In de, this message translates to:
  /// **'Für immer freischalten · {preis}'**
  String paketKaufen(String preis);

  /// No description provided for @videoFreischalten.
  ///
  /// In de, this message translates to:
  /// **'Video ansehen: 24 Stunden gratis'**
  String get videoFreischalten;

  /// No description provided for @allesAbo.
  ///
  /// In de, this message translates to:
  /// **'Oder alle Stapel mit dem Abo'**
  String get allesAbo;

  /// No description provided for @freigeschaltet24.
  ///
  /// In de, this message translates to:
  /// **'Freigeschaltet für 24 Stunden. Viel Spaß!'**
  String get freigeschaltet24;

  /// No description provided for @videoNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist kein Video verfügbar. Versuch es später nochmal.'**
  String get videoNichtVerfuegbar;

  /// No description provided for @karteHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Karte hinzufügen'**
  String get karteHinzufuegen;

  /// No description provided for @karteBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Karte bearbeiten'**
  String get karteBearbeiten;

  /// No description provided for @keineKarten.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Karten'**
  String get keineKarten;

  /// No description provided for @keineKartenText.
  ///
  /// In de, this message translates to:
  /// **'Füge deine erste Karte hinzu.'**
  String get keineKartenText;

  /// No description provided for @mehrNachFreischalten.
  ///
  /// In de, this message translates to:
  /// **'Weitere Karten nach dem Freischalten.'**
  String get mehrNachFreischalten;

  /// No description provided for @karteLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Karte löschen?'**
  String get karteLoeschen;

  /// No description provided for @karteLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Die Karte und ihr Lernstand werden gelöscht.'**
  String get karteLoeschenText;

  /// No description provided for @typBegriff.
  ///
  /// In de, this message translates to:
  /// **'Begriff'**
  String get typBegriff;

  /// No description provided for @typAusgabe.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get typAusgabe;

  /// No description provided for @typLuecke.
  ///
  /// In de, this message translates to:
  /// **'Lücke'**
  String get typLuecke;

  /// No description provided for @wasGibtAus.
  ///
  /// In de, this message translates to:
  /// **'Was gibt dieser Code aus?'**
  String get wasGibtAus;

  /// No description provided for @lueckeHilfe.
  ///
  /// In de, this message translates to:
  /// **'Schreib ___ (drei Unterstriche) an die Stelle der Lücke.'**
  String get lueckeHilfe;

  /// No description provided for @lueckeFehlt.
  ///
  /// In de, this message translates to:
  /// **'Im Code fehlt die Lücke ___'**
  String get lueckeFehlt;

  /// No description provided for @richtigeAntwort.
  ///
  /// In de, this message translates to:
  /// **'Richtige Antwort'**
  String get richtigeAntwort;

  /// No description provided for @falscheAntwort.
  ///
  /// In de, this message translates to:
  /// **'Falsche Antwort {nr}'**
  String falscheAntwort(int nr);

  /// No description provided for @mindestensEineFalsche.
  ///
  /// In de, this message translates to:
  /// **'Mindestens eine falsche Antwort'**
  String get mindestensEineFalsche;

  /// No description provided for @erklaerungOptional.
  ///
  /// In de, this message translates to:
  /// **'Erklärung (optional)'**
  String get erklaerungOptional;

  /// No description provided for @snippetsSuchen.
  ///
  /// In de, this message translates to:
  /// **'Snippets durchsuchen'**
  String get snippetsSuchen;

  /// No description provided for @neuesSnippet.
  ///
  /// In de, this message translates to:
  /// **'Neues Snippet'**
  String get neuesSnippet;

  /// No description provided for @keineSnippets.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Snippets'**
  String get keineSnippets;

  /// No description provided for @keineSnippetsText.
  ///
  /// In de, this message translates to:
  /// **'Speichere Code, den du dir merken willst. Beim Lernen geht das mit einem Tipp auf das Lesezeichen.'**
  String get keineSnippetsText;

  /// No description provided for @nichtsGefunden.
  ///
  /// In de, this message translates to:
  /// **'Nichts gefunden.'**
  String get nichtsGefunden;

  /// No description provided for @favorit.
  ///
  /// In de, this message translates to:
  /// **'Favorit'**
  String get favorit;

  /// No description provided for @alsLernkarte.
  ///
  /// In de, this message translates to:
  /// **'Als Lernkarte'**
  String get alsLernkarte;

  /// No description provided for @snippetLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Snippet löschen?'**
  String get snippetLoeschen;

  /// No description provided for @snippetBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Snippet bearbeiten'**
  String get snippetBearbeiten;

  /// No description provided for @snippetTitelBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. Liste sortieren'**
  String get snippetTitelBeispiel;

  /// No description provided for @tags.
  ///
  /// In de, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @tagsHilfe.
  ///
  /// In de, this message translates to:
  /// **'Mit Komma trennen, z. B. listen, sortieren'**
  String get tagsHilfe;

  /// No description provided for @stapelMeineSnippets.
  ///
  /// In de, this message translates to:
  /// **'Meine Snippets'**
  String get stapelMeineSnippets;

  /// No description provided for @wasMachtDieserCode.
  ///
  /// In de, this message translates to:
  /// **'Was macht dieser Code?'**
  String get wasMachtDieserCode;

  /// No description provided for @alsKarteGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Als Lernkarte im Stapel „Meine Snippets“ gespeichert'**
  String get alsKarteGespeichert;

  /// No description provided for @proTitel.
  ///
  /// In de, this message translates to:
  /// **'Codekarten Alles'**
  String get proTitel;

  /// No description provided for @proKurz.
  ///
  /// In de, this message translates to:
  /// **'Alle Stapel, alle neuen Stapel, ohne Werbung'**
  String get proKurz;

  /// No description provided for @proVorteilAlle.
  ///
  /// In de, this message translates to:
  /// **'Alle Stapel: Java Profi, Python, Dart, JavaScript'**
  String get proVorteilAlle;

  /// No description provided for @proVorteilNeue.
  ///
  /// In de, this message translates to:
  /// **'Alle neuen Stapel, sobald sie erscheinen'**
  String get proVorteilNeue;

  /// No description provided for @proVorteilWerbefrei.
  ///
  /// In de, this message translates to:
  /// **'Keine Werbung'**
  String get proVorteilWerbefrei;

  /// No description provided for @proVorteilUnterstuetzen.
  ///
  /// In de, this message translates to:
  /// **'Du unterstützt die Weiterentwicklung'**
  String get proVorteilUnterstuetzen;

  /// No description provided for @aktuelleSerie.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Serie'**
  String get aktuelleSerie;

  /// No description provided for @laengsteSerie.
  ///
  /// In de, this message translates to:
  /// **'Längste Serie'**
  String get laengsteSerie;

  /// No description provided for @wiederholungen.
  ///
  /// In de, this message translates to:
  /// **'Wiederholungen'**
  String get wiederholungen;

  /// No description provided for @trefferquote.
  ///
  /// In de, this message translates to:
  /// **'Trefferquote'**
  String get trefferquote;

  /// No description provided for @kartenGelernt.
  ///
  /// In de, this message translates to:
  /// **'Karten angefangen'**
  String get kartenGelernt;

  /// No description provided for @kartenGefestigt.
  ///
  /// In de, this message translates to:
  /// **'Karten gefestigt (21+ Tage)'**
  String get kartenGefestigt;

  /// No description provided for @letzte30Tage.
  ///
  /// In de, this message translates to:
  /// **'Letzte 30 Tage'**
  String get letzte30Tage;

  /// No description provided for @diagrammHilfe.
  ///
  /// In de, this message translates to:
  /// **'Kräftige Balken: Tagesziel erreicht.'**
  String get diagrammHilfe;

  /// No description provided for @kartenProTag.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Karten pro Tag'**
  String kartenProTag(int anzahl);

  /// No description provided for @neueProTag.
  ///
  /// In de, this message translates to:
  /// **'Neue Karten pro Tag'**
  String get neueProTag;

  /// No description provided for @neueProTagText.
  ///
  /// In de, this message translates to:
  /// **'Bis zu {anzahl} neue Karten am Tag (der Rest sind Wiederholungen)'**
  String neueProTagText(int anzahl);

  /// No description provided for @werbeEinwilligung.
  ///
  /// In de, this message translates to:
  /// **'Einwilligung für Werbung ändern'**
  String get werbeEinwilligung;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
