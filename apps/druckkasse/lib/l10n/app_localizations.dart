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

  /// No description provided for @tabVerkaufen.
  ///
  /// In de, this message translates to:
  /// **'Verkaufen'**
  String get tabVerkaufen;

  /// No description provided for @tabAuftraege.
  ///
  /// In de, this message translates to:
  /// **'Aufträge'**
  String get tabAuftraege;

  /// No description provided for @tabProdukte.
  ///
  /// In de, this message translates to:
  /// **'Produkte'**
  String get tabProdukte;

  /// No description provided for @tabUebersicht.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get tabUebersicht;

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

  /// No description provided for @entfernen.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get entfernen;

  /// No description provided for @weiter.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get weiter;

  /// No description provided for @laden.
  ///
  /// In de, this message translates to:
  /// **'Laden'**
  String get laden;

  /// No description provided for @super_.
  ///
  /// In de, this message translates to:
  /// **'Super!'**
  String get super_;

  /// No description provided for @oder.
  ///
  /// In de, this message translates to:
  /// **' oder '**
  String get oder;

  /// No description provided for @pflichtfeld.
  ///
  /// In de, this message translates to:
  /// **'Bitte ausfüllen'**
  String get pflichtfeld;

  /// No description provided for @ungueltigerBetrag.
  ///
  /// In de, this message translates to:
  /// **'Bitte einen Betrag wie 12,50 eingeben'**
  String get ungueltigerBetrag;

  /// No description provided for @ungueltigeZahl.
  ///
  /// In de, this message translates to:
  /// **'Bitte eine Zahl eingeben'**
  String get ungueltigeZahl;

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

  /// No description provided for @menge.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get menge;

  /// No description provided for @preis.
  ///
  /// In de, this message translates to:
  /// **'Preis'**
  String get preis;

  /// No description provided for @kosten.
  ///
  /// In de, this message translates to:
  /// **'Kosten'**
  String get kosten;

  /// No description provided for @gewinn.
  ///
  /// In de, this message translates to:
  /// **'Gewinn'**
  String get gewinn;

  /// No description provided for @umsatz.
  ///
  /// In de, this message translates to:
  /// **'Umsatz'**
  String get umsatz;

  /// No description provided for @app.
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @daten.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get daten;

  /// No description provided for @grenzeErreicht.
  ///
  /// In de, this message translates to:
  /// **'Gratis-Grenze erreicht'**
  String get grenzeErreicht;

  /// No description provided for @proAnsehen.
  ///
  /// In de, this message translates to:
  /// **'Pro ansehen'**
  String get proAnsehen;

  /// No description provided for @proTitel.
  ///
  /// In de, this message translates to:
  /// **'Druckkasse Pro'**
  String get proTitel;

  /// No description provided for @proKurz.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt Produkte und Drucker, CSV-Export, 12-Monats-Verlauf'**
  String get proKurz;

  /// No description provided for @proVorteilUnbegrenzt.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt viele Produkte, Drucker und Sparziele'**
  String get proVorteilUnbegrenzt;

  /// No description provided for @proVorteilExport.
  ///
  /// In de, this message translates to:
  /// **'Export als CSV für Excel und Steuer'**
  String get proVorteilExport;

  /// No description provided for @proVorteilVerlauf.
  ///
  /// In de, this message translates to:
  /// **'Gewinn-Verlauf über 12 Monate'**
  String get proVorteilVerlauf;

  /// No description provided for @proVorteilSparziele.
  ///
  /// In de, this message translates to:
  /// **'Mehrere Sparziele gleichzeitig'**
  String get proVorteilSparziele;

  /// No description provided for @proVorteilUnterstuetzen.
  ///
  /// In de, this message translates to:
  /// **'Du unterstützt die Weiterentwicklung'**
  String get proVorteilUnterstuetzen;

  /// No description provided for @grenzeProdukte.
  ///
  /// In de, this message translates to:
  /// **'In der Gratis-Version kannst du bis zu {anzahl} Produkte anlegen. Mit Pro unbegrenzt viele.'**
  String grenzeProdukte(int anzahl);

  /// No description provided for @grenzeDrucker.
  ///
  /// In de, this message translates to:
  /// **'In der Gratis-Version kannst du bis zu {anzahl} Drucker anlegen. Mit Pro unbegrenzt viele.'**
  String grenzeDrucker(int anzahl);

  /// No description provided for @grenzeSparziele.
  ///
  /// In de, this message translates to:
  /// **'In der Gratis-Version gibt es ein Sparziel. Mit Pro kannst du mehrere gleichzeitig verfolgen.'**
  String get grenzeSparziele;

  /// No description provided for @exportNurPro.
  ///
  /// In de, this message translates to:
  /// **'Der CSV-Export ist Teil von Pro.'**
  String get exportNurPro;

  /// No description provided for @heuteVerkauft.
  ///
  /// In de, this message translates to:
  /// **'Heute verkauft'**
  String get heuteVerkauft;

  /// No description provided for @heuteUmsatz.
  ///
  /// In de, this message translates to:
  /// **'Umsatz heute'**
  String get heuteUmsatz;

  /// No description provided for @heuteGewinn.
  ///
  /// In de, this message translates to:
  /// **'Gewinn heute'**
  String get heuteGewinn;

  /// No description provided for @heuteStueck.
  ///
  /// In de, this message translates to:
  /// **'Stück heute'**
  String get heuteStueck;

  /// No description provided for @heuteNochNichts.
  ///
  /// In de, this message translates to:
  /// **'Heute wurde noch nichts verkauft.'**
  String get heuteNochNichts;

  /// No description provided for @wischenZumLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Nach links wischen, um einen Verkauf zu löschen.'**
  String get wischenZumLoeschen;

  /// No description provided for @ausAuftrag.
  ///
  /// In de, this message translates to:
  /// **'aus Auftrag'**
  String get ausAuftrag;

  /// No description provided for @verkauftMeldung.
  ///
  /// In de, this message translates to:
  /// **'{menge}× {name} verkauft · {betrag}'**
  String verkauftMeldung(int menge, String name, String betrag);

  /// No description provided for @rueckgaengig.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get rueckgaengig;

  /// No description provided for @zielErreichtTitel.
  ///
  /// In de, this message translates to:
  /// **'Ziel erreicht! 🎉'**
  String get zielErreichtTitel;

  /// No description provided for @zielErreichtText.
  ///
  /// In de, this message translates to:
  /// **'Du hast genug für „{name}“ zusammen. Glückwunsch!'**
  String zielErreichtText(String name);

  /// No description provided for @tippDesTages.
  ///
  /// In de, this message translates to:
  /// **'Druck-Tipp des Tages'**
  String get tippDesTages;

  /// No description provided for @ausblenden.
  ///
  /// In de, this message translates to:
  /// **'Ausblenden'**
  String get ausblenden;

  /// No description provided for @ersteSchritteTitel.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s!'**
  String get ersteSchritteTitel;

  /// No description provided for @ersteSchritteText.
  ///
  /// In de, this message translates to:
  /// **'Drei Schritte, dann kannst du verkaufen:'**
  String get ersteSchritteText;

  /// No description provided for @schrittDrucker.
  ///
  /// In de, this message translates to:
  /// **'Drucker anlegen'**
  String get schrittDrucker;

  /// No description provided for @schrittFilament.
  ///
  /// In de, this message translates to:
  /// **'Filament anlegen'**
  String get schrittFilament;

  /// No description provided for @schrittProdukt.
  ///
  /// In de, this message translates to:
  /// **'Erstes Produkt anlegen'**
  String get schrittProdukt;

  /// No description provided for @preisProStueck.
  ///
  /// In de, this message translates to:
  /// **'Preis pro Stück'**
  String get preisProStueck;

  /// No description provided for @verkaufenFuer.
  ///
  /// In de, this message translates to:
  /// **'Verkaufen für {betrag}'**
  String verkaufenFuer(String betrag);

  /// No description provided for @zahlungBar.
  ///
  /// In de, this message translates to:
  /// **'Bar'**
  String get zahlungBar;

  /// No description provided for @zahlungKarte.
  ///
  /// In de, this message translates to:
  /// **'Karte'**
  String get zahlungKarte;

  /// No description provided for @zahlungOnline.
  ///
  /// In de, this message translates to:
  /// **'Online'**
  String get zahlungOnline;

  /// No description provided for @sparStand.
  ///
  /// In de, this message translates to:
  /// **'{stand} von {ziel} ({basis})'**
  String sparStand(String stand, String ziel, String basis);

  /// No description provided for @sparZielErreicht.
  ///
  /// In de, this message translates to:
  /// **'Geschafft! Ziel erreicht 🎉'**
  String get sparZielErreicht;

  /// No description provided for @sparNoch.
  ///
  /// In de, this message translates to:
  /// **'Noch {rest}: z. B. {produkte}'**
  String sparNoch(String rest, String produkte);

  /// No description provided for @sparNochOhne.
  ///
  /// In de, this message translates to:
  /// **'Noch {rest}'**
  String sparNochOhne(String rest);

  /// No description provided for @archiv.
  ///
  /// In de, this message translates to:
  /// **'Archiv'**
  String get archiv;

  /// No description provided for @aktiveAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Aktive Produkte anzeigen'**
  String get aktiveAnzeigen;

  /// No description provided for @archivAnzeigen.
  ///
  /// In de, this message translates to:
  /// **'Archiv anzeigen'**
  String get archivAnzeigen;

  /// No description provided for @archivLeer.
  ///
  /// In de, this message translates to:
  /// **'Keine archivierten Produkte'**
  String get archivLeer;

  /// No description provided for @neuesProdukt.
  ///
  /// In de, this message translates to:
  /// **'Neues Produkt'**
  String get neuesProdukt;

  /// No description provided for @keineProdukte.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Produkte'**
  String get keineProdukte;

  /// No description provided for @keineProdukteText.
  ///
  /// In de, this message translates to:
  /// **'Leg dein erstes Produkt an. Die App rechnet Kosten und schlägt einen Preis vor.'**
  String get keineProdukteText;

  /// No description provided for @wiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get wiederherstellen;

  /// No description provided for @produktBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Produkt bearbeiten'**
  String get produktBearbeiten;

  /// No description provided for @duplizieren.
  ///
  /// In de, this message translates to:
  /// **'Duplizieren (z. B. andere Farbe)'**
  String get duplizieren;

  /// No description provided for @archivieren.
  ///
  /// In de, this message translates to:
  /// **'Archivieren'**
  String get archivieren;

  /// No description provided for @produktArchivieren.
  ///
  /// In de, this message translates to:
  /// **'Produkt archivieren?'**
  String get produktArchivieren;

  /// No description provided for @produktArchivierenText.
  ///
  /// In de, this message translates to:
  /// **'Das Produkt verschwindet aus der Liste und beim Verkaufen. Alte Verkäufe bleiben in der Übersicht. Du kannst es im Archiv wiederherstellen.'**
  String get produktArchivierenText;

  /// No description provided for @druck.
  ///
  /// In de, this message translates to:
  /// **'Druck'**
  String get druck;

  /// No description provided for @drucker.
  ///
  /// In de, this message translates to:
  /// **'Drucker'**
  String get drucker;

  /// No description provided for @druckerAnlegen.
  ///
  /// In de, this message translates to:
  /// **'Drucker anlegen'**
  String get druckerAnlegen;

  /// No description provided for @ohneDrucker.
  ///
  /// In de, this message translates to:
  /// **'Ohne Drucker (keine Strom-/Abnutzungskosten)'**
  String get ohneDrucker;

  /// No description provided for @stunden.
  ///
  /// In de, this message translates to:
  /// **'Druckzeit Stunden'**
  String get stunden;

  /// No description provided for @minuten.
  ///
  /// In de, this message translates to:
  /// **'Minuten'**
  String get minuten;

  /// No description provided for @stueckProDruck.
  ///
  /// In de, this message translates to:
  /// **'Stück pro Druck'**
  String get stueckProDruck;

  /// No description provided for @stueckProDruckHilfe.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Stück passen auf eine Druckplatte? Druckzeit und Gramm gelten für die ganze Platte.'**
  String get stueckProDruckHilfe;

  /// No description provided for @filamente.
  ///
  /// In de, this message translates to:
  /// **'Filamente'**
  String get filamente;

  /// No description provided for @filament.
  ///
  /// In de, this message translates to:
  /// **'Filament'**
  String get filament;

  /// No description provided for @filamentAnlegen.
  ///
  /// In de, this message translates to:
  /// **'Filament anlegen'**
  String get filamentAnlegen;

  /// No description provided for @farbeHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Farbe hinzufügen'**
  String get farbeHinzufuegen;

  /// No description provided for @gramm.
  ///
  /// In de, this message translates to:
  /// **'Gramm'**
  String get gramm;

  /// No description provided for @grammHilfe.
  ///
  /// In de, this message translates to:
  /// **'Gramm und Druckzeit so eintragen, wie der Slicer sie für den ganzen Druck anzeigt (Bambu Studio: „Gesamtfilament“).'**
  String get grammHilfe;

  /// No description provided for @spuelabfall.
  ///
  /// In de, this message translates to:
  /// **'Spülabfall pro Druck'**
  String get spuelabfall;

  /// No description provided for @spuelabfallHilfe.
  ///
  /// In de, this message translates to:
  /// **'Abfall bei Farbwechseln (AMS). Steht im Slicer unter „Spülung“/„Flushed“.'**
  String get spuelabfallHilfe;

  /// No description provided for @extrasUndArbeit.
  ///
  /// In de, this message translates to:
  /// **'Extras & Arbeit'**
  String get extrasUndArbeit;

  /// No description provided for @extrasVerwalten.
  ///
  /// In de, this message translates to:
  /// **'Verwalten'**
  String get extrasVerwalten;

  /// No description provided for @keineExtras.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Extras. Lege z. B. Verpackung oder Schlüsselringe an.'**
  String get keineExtras;

  /// No description provided for @arbeitProStueck.
  ///
  /// In de, this message translates to:
  /// **'Handarbeit pro Stück'**
  String get arbeitProStueck;

  /// No description provided for @arbeitHilfeOhneLohn.
  ///
  /// In de, this message translates to:
  /// **'Nacharbeit, Zusammenbauen, Verpacken. Zählt erst, wenn du in den Einstellungen einen Stundenlohn einträgst.'**
  String get arbeitHilfeOhneLohn;

  /// No description provided for @arbeitHilfe.
  ///
  /// In de, this message translates to:
  /// **'Wird mit {lohn}/h eingerechnet.'**
  String arbeitHilfe(String lohn);

  /// No description provided for @kostenMaterial.
  ///
  /// In de, this message translates to:
  /// **'Material'**
  String get kostenMaterial;

  /// No description provided for @kostenStrom.
  ///
  /// In de, this message translates to:
  /// **'Strom'**
  String get kostenStrom;

  /// No description provided for @kostenAbnutzung.
  ///
  /// In de, this message translates to:
  /// **'Abnutzung Drucker'**
  String get kostenAbnutzung;

  /// No description provided for @kostenFehldruck.
  ///
  /// In de, this message translates to:
  /// **'Fehldruck-Zuschlag ({prozent} %)'**
  String kostenFehldruck(int prozent);

  /// No description provided for @kostenExtras.
  ///
  /// In de, this message translates to:
  /// **'Extras'**
  String get kostenExtras;

  /// No description provided for @kostenArbeit.
  ///
  /// In de, this message translates to:
  /// **'Handarbeit'**
  String get kostenArbeit;

  /// No description provided for @kostenProStueck.
  ///
  /// In de, this message translates to:
  /// **'Kosten pro Stück'**
  String get kostenProStueck;

  /// No description provided for @aufschlag.
  ///
  /// In de, this message translates to:
  /// **'Aufschlag auf die Kosten: {prozent} %'**
  String aufschlag(int prozent);

  /// No description provided for @standardNehmen.
  ///
  /// In de, this message translates to:
  /// **'Standard'**
  String get standardNehmen;

  /// No description provided for @vorschlag.
  ///
  /// In de, this message translates to:
  /// **'Preisvorschlag: {betrag}'**
  String vorschlag(String betrag);

  /// No description provided for @eigenerPreis.
  ///
  /// In de, this message translates to:
  /// **'Eigener Verkaufspreis (optional)'**
  String get eigenerPreis;

  /// No description provided for @eigenerPreisHilfe.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, um den Vorschlag zu verwenden.'**
  String get eigenerPreisHilfe;

  /// No description provided for @verkaufspreis.
  ///
  /// In de, this message translates to:
  /// **'Verkaufspreis'**
  String get verkaufspreis;

  /// No description provided for @gewinnProStueck.
  ///
  /// In de, this message translates to:
  /// **'Gewinn {betrag}'**
  String gewinnProStueck(String betrag);

  /// No description provided for @margeVomPreis.
  ///
  /// In de, this message translates to:
  /// **'{prozent} % vom Preis'**
  String margeVomPreis(int prozent);

  /// No description provided for @keineDrucker.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Drucker'**
  String get keineDrucker;

  /// No description provided for @keineDruckerText.
  ///
  /// In de, this message translates to:
  /// **'Für Strom- und Abnutzungskosten braucht die App deinen Drucker.'**
  String get keineDruckerText;

  /// No description provided for @druckerInfo.
  ///
  /// In de, this message translates to:
  /// **'{watt} W · Abnutzung {betrag}/h'**
  String druckerInfo(int watt, String betrag);

  /// No description provided for @druckerBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Drucker bearbeiten'**
  String get druckerBearbeiten;

  /// No description provided for @druckerEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Drucker entfernen?'**
  String get druckerEntfernen;

  /// No description provided for @druckerEntfernenText.
  ///
  /// In de, this message translates to:
  /// **'Der Drucker wird ausgeblendet. Produkte, die ihn verwenden, rechnen weiter mit seinen Werten.'**
  String get druckerEntfernenText;

  /// No description provided for @vorlageWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Vorlage wählen (Werte danach anpassbar)'**
  String get vorlageWaehlen;

  /// No description provided for @verbrauch.
  ///
  /// In de, this message translates to:
  /// **'Durchschnittlicher Verbrauch'**
  String get verbrauch;

  /// No description provided for @verbrauchHilfe.
  ///
  /// In de, this message translates to:
  /// **'Beim Drucken gemessen, nicht die Netzteil-Angabe. Bambu A1 ca. 95 W, P1S ca. 120 W.'**
  String get verbrauchHilfe;

  /// No description provided for @anschaffungspreis.
  ///
  /// In de, this message translates to:
  /// **'Anschaffungspreis'**
  String get anschaffungspreis;

  /// No description provided for @lebensdauer.
  ///
  /// In de, this message translates to:
  /// **'Lebensdauer'**
  String get lebensdauer;

  /// No description provided for @lebensdauerHilfe.
  ///
  /// In de, this message translates to:
  /// **'Nach so vielen Druckstunden ist der Drucker abbezahlt. 5000 h sind ein guter Richtwert.'**
  String get lebensdauerHilfe;

  /// No description provided for @keineFilamente.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Filament'**
  String get keineFilamente;

  /// No description provided for @keineFilamenteText.
  ///
  /// In de, this message translates to:
  /// **'Leg deine Filamente mit Kilopreis an, damit die Materialkosten stimmen.'**
  String get keineFilamenteText;

  /// No description provided for @proKg.
  ///
  /// In de, this message translates to:
  /// **'{betrag}/kg'**
  String proKg(String betrag);

  /// No description provided for @filamentBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Filament bearbeiten'**
  String get filamentBearbeiten;

  /// No description provided for @filamentEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Filament entfernen?'**
  String get filamentEntfernen;

  /// No description provided for @filamentEntfernenText.
  ///
  /// In de, this message translates to:
  /// **'Das Filament wird ausgeblendet. Produkte, die es verwenden, rechnen weiter mit seinem Preis.'**
  String get filamentEntfernenText;

  /// No description provided for @material.
  ///
  /// In de, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @farbe.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get farbe;

  /// No description provided for @filamentNameHilfe.
  ///
  /// In de, this message translates to:
  /// **'z. B. „Bambu PLA Basic Rot“'**
  String get filamentNameHilfe;

  /// No description provided for @preisProKg.
  ///
  /// In de, this message translates to:
  /// **'Preis pro Kilo'**
  String get preisProKg;

  /// No description provided for @preisProKgHilfe.
  ///
  /// In de, this message translates to:
  /// **'Preis der Spule umgerechnet auf 1 kg (inkl. Versand, wenn du willst).'**
  String get preisProKgHilfe;

  /// No description provided for @extras.
  ///
  /// In de, this message translates to:
  /// **'Extras'**
  String get extras;

  /// No description provided for @extrasUntertitel.
  ///
  /// In de, this message translates to:
  /// **'Verpackung, Schlüsselringe, Magnete …'**
  String get extrasUntertitel;

  /// No description provided for @extraAnlegen.
  ///
  /// In de, this message translates to:
  /// **'Extra anlegen'**
  String get extraAnlegen;

  /// No description provided for @extraBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Extra bearbeiten'**
  String get extraBearbeiten;

  /// No description provided for @extraBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. Geschenkschachtel'**
  String get extraBeispiel;

  /// No description provided for @kostenProStueckFeld.
  ///
  /// In de, this message translates to:
  /// **'Kosten pro Stück'**
  String get kostenProStueckFeld;

  /// No description provided for @keineExtrasTitel.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Extras'**
  String get keineExtrasTitel;

  /// No description provided for @keineExtrasText.
  ///
  /// In de, this message translates to:
  /// **'Extras sind Dinge, die du zusätzlich zum Druck brauchst, z. B. Verpackung.'**
  String get keineExtrasText;

  /// No description provided for @neuerAuftrag.
  ///
  /// In de, this message translates to:
  /// **'Neuer Auftrag'**
  String get neuerAuftrag;

  /// No description provided for @auftragBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Auftrag bearbeiten'**
  String get auftragBearbeiten;

  /// No description provided for @filterOffen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get filterOffen;

  /// No description provided for @filterErledigt.
  ///
  /// In de, this message translates to:
  /// **'Erledigt'**
  String get filterErledigt;

  /// No description provided for @filterAlle.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get filterAlle;

  /// No description provided for @nochOffen.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht bezahlt: {betrag}'**
  String nochOffen(String betrag);

  /// No description provided for @keineOffenenAuftraege.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Aufträge'**
  String get keineOffenenAuftraege;

  /// No description provided for @keineAuftraege.
  ///
  /// In de, this message translates to:
  /// **'Keine Aufträge'**
  String get keineAuftraege;

  /// No description provided for @keineAuftraegeText.
  ///
  /// In de, this message translates to:
  /// **'Hier landen Bestellungen: wer, was, bis wann. Ein Auftrag ist erledigt, wenn er abgeholt und bezahlt ist.'**
  String get keineAuftraegeText;

  /// No description provided for @faelligAm.
  ///
  /// In de, this message translates to:
  /// **'Fällig am {datum}'**
  String faelligAm(String datum);

  /// No description provided for @statusOffen.
  ///
  /// In de, this message translates to:
  /// **'Offen'**
  String get statusOffen;

  /// No description provided for @statusGedruckt.
  ///
  /// In de, this message translates to:
  /// **'Gedruckt'**
  String get statusGedruckt;

  /// No description provided for @statusAbgeholt.
  ///
  /// In de, this message translates to:
  /// **'Abgeholt'**
  String get statusAbgeholt;

  /// No description provided for @bezahlt.
  ///
  /// In de, this message translates to:
  /// **'Bezahlt'**
  String get bezahlt;

  /// No description provided for @nichtBezahlt.
  ///
  /// In de, this message translates to:
  /// **'Nicht bezahlt'**
  String get nichtBezahlt;

  /// No description provided for @kunde.
  ///
  /// In de, this message translates to:
  /// **'Kunde'**
  String get kunde;

  /// No description provided for @kontaktFeld.
  ///
  /// In de, this message translates to:
  /// **'Kontakt (Telefon, Instagram …)'**
  String get kontaktFeld;

  /// No description provided for @keinTermin.
  ///
  /// In de, this message translates to:
  /// **'Kein Termin'**
  String get keinTermin;

  /// No description provided for @positionen.
  ///
  /// In de, this message translates to:
  /// **'Was wurde bestellt?'**
  String get positionen;

  /// No description provided for @produktHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get produktHinzufuegen;

  /// No description provided for @notizPosition.
  ///
  /// In de, this message translates to:
  /// **'Notiz (z. B. Farbe)'**
  String get notizPosition;

  /// No description provided for @statusUndZahlung.
  ///
  /// In de, this message translates to:
  /// **'Status & Zahlung'**
  String get statusUndZahlung;

  /// No description provided for @bezahltHilfe.
  ///
  /// In de, this message translates to:
  /// **'Bezahlte Aufträge zählen im Umsatz.'**
  String get bezahltHilfe;

  /// No description provided for @mindestensEinProdukt.
  ///
  /// In de, this message translates to:
  /// **'Bitte mindestens ein Produkt hinzufügen.'**
  String get mindestensEinProdukt;

  /// No description provided for @auftragLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Auftrag löschen?'**
  String get auftragLoeschen;

  /// No description provided for @auftragLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Der Auftrag und, falls bezahlt, sein Umsatz werden gelöscht.'**
  String get auftragLoeschenText;

  /// No description provided for @exportTitel.
  ///
  /// In de, this message translates to:
  /// **'Als CSV exportieren'**
  String get exportTitel;

  /// No description provided for @exportMonat.
  ///
  /// In de, this message translates to:
  /// **'Nur {monat}'**
  String exportMonat(String monat);

  /// No description provided for @exportAlles.
  ///
  /// In de, this message translates to:
  /// **'Alle Verkäufe'**
  String get exportAlles;

  /// No description provided for @csvDatum.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get csvDatum;

  /// No description provided for @csvProdukt.
  ///
  /// In de, this message translates to:
  /// **'Produkt'**
  String get csvProdukt;

  /// No description provided for @csvMenge.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get csvMenge;

  /// No description provided for @csvEinzelpreis.
  ///
  /// In de, this message translates to:
  /// **'Einzelpreis'**
  String get csvEinzelpreis;

  /// No description provided for @csvUmsatz.
  ///
  /// In de, this message translates to:
  /// **'Umsatz'**
  String get csvUmsatz;

  /// No description provided for @csvKosten.
  ///
  /// In de, this message translates to:
  /// **'Kosten'**
  String get csvKosten;

  /// No description provided for @csvGebuehr.
  ///
  /// In de, this message translates to:
  /// **'Gebühr'**
  String get csvGebuehr;

  /// No description provided for @csvGewinn.
  ///
  /// In de, this message translates to:
  /// **'Gewinn'**
  String get csvGewinn;

  /// No description provided for @csvZahlung.
  ///
  /// In de, this message translates to:
  /// **'Zahlung'**
  String get csvZahlung;

  /// No description provided for @vorherigerMonat.
  ///
  /// In de, this message translates to:
  /// **'Vorheriger Monat'**
  String get vorherigerMonat;

  /// No description provided for @naechsterMonat.
  ///
  /// In de, this message translates to:
  /// **'Nächster Monat'**
  String get naechsterMonat;

  /// No description provided for @stueckVerkauft.
  ///
  /// In de, this message translates to:
  /// **'Stück verkauft'**
  String get stueckVerkauft;

  /// No description provided for @davonGebuehren.
  ///
  /// In de, this message translates to:
  /// **'Kosten inkl. {betrag} Zahlungsgebühren'**
  String davonGebuehren(String betrag);

  /// No description provided for @gewinnProMonat.
  ///
  /// In de, this message translates to:
  /// **'Gewinn pro Monat'**
  String get gewinnProMonat;

  /// No description provided for @verlaufPro.
  ///
  /// In de, this message translates to:
  /// **'12 Monate mit Pro'**
  String get verlaufPro;

  /// No description provided for @bestseller.
  ///
  /// In de, this message translates to:
  /// **'Bestseller'**
  String get bestseller;

  /// No description provided for @keineVerkaeufeImMonat.
  ///
  /// In de, this message translates to:
  /// **'In diesem Monat gibt es noch keine Verkäufe.'**
  String get keineVerkaeufeImMonat;

  /// No description provided for @margeVomUmsatz.
  ///
  /// In de, this message translates to:
  /// **'{prozent} % vom Umsatz'**
  String margeVomUmsatz(int prozent);

  /// No description provided for @stueckKurz.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Stk.'**
  String stueckKurz(int anzahl);

  /// No description provided for @plusGewinn.
  ///
  /// In de, this message translates to:
  /// **'+{betrag}'**
  String plusGewinn(String betrag);

  /// No description provided for @speichernUnter.
  ///
  /// In de, this message translates to:
  /// **'Speichern unter …'**
  String get speichernUnter;

  /// No description provided for @teilen.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get teilen;

  /// No description provided for @gespeichert.
  ///
  /// In de, this message translates to:
  /// **'Gespeichert'**
  String get gespeichert;

  /// No description provided for @fehler.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {text}'**
  String fehler(String text);

  /// No description provided for @werkstatt.
  ///
  /// In de, this message translates to:
  /// **'Werkstatt'**
  String get werkstatt;

  /// No description provided for @ziele.
  ///
  /// In de, this message translates to:
  /// **'Ziele'**
  String get ziele;

  /// No description provided for @sparziele.
  ///
  /// In de, this message translates to:
  /// **'Sparziele'**
  String get sparziele;

  /// No description provided for @einstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get einstellungen;

  /// No description provided for @einstellungenUntertitel.
  ///
  /// In de, this message translates to:
  /// **'Strompreis, Aufschlag, Sicherung, Design'**
  String get einstellungenUntertitel;

  /// No description provided for @neuesSparziel.
  ///
  /// In de, this message translates to:
  /// **'Neues Sparziel'**
  String get neuesSparziel;

  /// No description provided for @keineSparziele.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Sparziel'**
  String get keineSparziele;

  /// No description provided for @keineSparzieleText.
  ///
  /// In de, this message translates to:
  /// **'Wofür sparst du? Ein neuer Drucker? Die App zeigt, wie viele Stück noch fehlen.'**
  String get keineSparzieleText;

  /// No description provided for @angeheftet.
  ///
  /// In de, this message translates to:
  /// **'Beim Verkaufen sichtbar'**
  String get angeheftet;

  /// No description provided for @anheften.
  ///
  /// In de, this message translates to:
  /// **'Beim Verkaufen zeigen'**
  String get anheften;

  /// No description provided for @seit.
  ///
  /// In de, this message translates to:
  /// **'seit {datum}'**
  String seit(String datum);

  /// No description provided for @sparzielBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Sparziel bearbeiten'**
  String get sparzielBearbeiten;

  /// No description provided for @wofuerSparstDu.
  ///
  /// In de, this message translates to:
  /// **'Wofür sparst du?'**
  String get wofuerSparstDu;

  /// No description provided for @sparzielBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. Bambu Lab P1S'**
  String get sparzielBeispiel;

  /// No description provided for @zielbetrag.
  ///
  /// In de, this message translates to:
  /// **'Zielbetrag'**
  String get zielbetrag;

  /// No description provided for @wasZaehlt.
  ///
  /// In de, this message translates to:
  /// **'Was zählt?'**
  String get wasZaehlt;

  /// No description provided for @basisGewinnHilfe.
  ///
  /// In de, this message translates to:
  /// **'Nur der Gewinn zählt, also was nach Material, Strom und Abnutzung übrig bleibt.'**
  String get basisGewinnHilfe;

  /// No description provided for @basisUmsatzHilfe.
  ///
  /// In de, this message translates to:
  /// **'Alles, was Kunden bezahlen, zählt.'**
  String get basisUmsatzHilfe;

  /// No description provided for @zaehltAb.
  ///
  /// In de, this message translates to:
  /// **'Zählt ab {datum}'**
  String zaehltAb(String datum);

  /// No description provided for @sparzielLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Sparziel löschen?'**
  String get sparzielLoeschen;

  /// No description provided for @sparzielLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Deine Verkäufe bleiben erhalten.'**
  String get sparzielLoeschenText;

  /// No description provided for @kalkulation.
  ///
  /// In de, this message translates to:
  /// **'Kalkulation'**
  String get kalkulation;

  /// No description provided for @strompreis.
  ///
  /// In de, this message translates to:
  /// **'Strompreis'**
  String get strompreis;

  /// No description provided for @strompreisFeld.
  ///
  /// In de, this message translates to:
  /// **'Cent pro kWh'**
  String get strompreisFeld;

  /// No description provided for @strompreisHilfe.
  ///
  /// In de, this message translates to:
  /// **'Steht auf deiner Stromrechnung. Österreich 2026 meist 20–30 ct/kWh.'**
  String get strompreisHilfe;

  /// No description provided for @standardAufschlag.
  ///
  /// In de, this message translates to:
  /// **'Standard-Aufschlag'**
  String get standardAufschlag;

  /// No description provided for @aufschlagFeld.
  ///
  /// In de, this message translates to:
  /// **'Prozent auf die Kosten'**
  String get aufschlagFeld;

  /// No description provided for @standardAufschlagHilfe.
  ///
  /// In de, this message translates to:
  /// **'200 % heißt: Kosten 1 € → Preis 3 €. Für jedes Produkt einzeln änderbar.'**
  String get standardAufschlagHilfe;

  /// No description provided for @fehldruckZuschlag.
  ///
  /// In de, this message translates to:
  /// **'Fehldruck-Zuschlag'**
  String get fehldruckZuschlag;

  /// No description provided for @prozentFeld.
  ///
  /// In de, this message translates to:
  /// **'Prozent'**
  String get prozentFeld;

  /// No description provided for @fehldruckHilfe.
  ///
  /// In de, this message translates to:
  /// **'Aufschlag auf Material, Strom und Abnutzung für misslungene Drucke.'**
  String get fehldruckHilfe;

  /// No description provided for @rundung.
  ///
  /// In de, this message translates to:
  /// **'Preisvorschlag aufrunden'**
  String get rundung;

  /// No description provided for @rundungKeine.
  ///
  /// In de, this message translates to:
  /// **'Nicht runden'**
  String get rundungKeine;

  /// No description provided for @rundungAuf.
  ///
  /// In de, this message translates to:
  /// **'Auf {betrag} aufrunden'**
  String rundungAuf(String betrag);

  /// No description provided for @stundenlohn.
  ///
  /// In de, this message translates to:
  /// **'Stundenlohn für Handarbeit'**
  String get stundenlohn;

  /// No description provided for @nichtEingerechnet.
  ///
  /// In de, this message translates to:
  /// **'Nicht eingerechnet'**
  String get nichtEingerechnet;

  /// No description provided for @stundenlohnFeld.
  ///
  /// In de, this message translates to:
  /// **'Euro pro Stunde'**
  String get stundenlohnFeld;

  /// No description provided for @stundenlohnHilfe.
  ///
  /// In de, this message translates to:
  /// **'Leer lassen, wenn deine Zeit nicht in die Kosten soll.'**
  String get stundenlohnHilfe;

  /// No description provided for @zahlung.
  ///
  /// In de, this message translates to:
  /// **'Zahlung'**
  String get zahlung;

  /// No description provided for @standardZahlungsart.
  ///
  /// In de, this message translates to:
  /// **'Standard-Zahlungsart'**
  String get standardZahlungsart;

  /// No description provided for @gebuehrKarte.
  ///
  /// In de, this message translates to:
  /// **'Gebühr Kartenzahlung'**
  String get gebuehrKarte;

  /// No description provided for @gebuehrKarteHilfe.
  ///
  /// In de, this message translates to:
  /// **'z. B. SumUp ca. 1,39 %. 0 = keine Gebühr.'**
  String get gebuehrKarteHilfe;

  /// No description provided for @gebuehrOnline.
  ///
  /// In de, this message translates to:
  /// **'Gebühr Online-Zahlung'**
  String get gebuehrOnline;

  /// No description provided for @gebuehrOnlineHilfe.
  ///
  /// In de, this message translates to:
  /// **'z. B. PayPal. 0 = keine Gebühr.'**
  String get gebuehrOnlineHilfe;

  /// No description provided for @sicherungErstellen.
  ///
  /// In de, this message translates to:
  /// **'Sicherung erstellen'**
  String get sicherungErstellen;

  /// No description provided for @sicherungErstellenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten als Datei speichern (z. B. in Google Drive)'**
  String get sicherungErstellenText;

  /// No description provided for @sicherungWiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Sicherung wiederherstellen'**
  String get sicherungWiederherstellen;

  /// No description provided for @wiederherstellenWarnung.
  ///
  /// In de, this message translates to:
  /// **'Alle aktuellen Daten werden durch die Sicherung ersetzt.'**
  String get wiederherstellenWarnung;

  /// No description provided for @wiederhergestellt.
  ///
  /// In de, this message translates to:
  /// **'Sicherung wiederhergestellt'**
  String get wiederhergestellt;

  /// No description provided for @keineSicherung.
  ///
  /// In de, this message translates to:
  /// **'Diese Datei ist keine gültige Druckkasse-Sicherung.'**
  String get keineSicherung;

  /// No description provided for @beispieldatenLaden.
  ///
  /// In de, this message translates to:
  /// **'Beispieldaten laden'**
  String get beispieldatenLaden;

  /// No description provided for @beispieldatenText.
  ///
  /// In de, this message translates to:
  /// **'Zum Ausprobieren: Drucker, Produkte, Verkäufe'**
  String get beispieldatenText;

  /// No description provided for @beispieldatenWarnung.
  ///
  /// In de, this message translates to:
  /// **'Beispiel-Drucker, -Produkte und -Verkäufe werden zu deinen Daten hinzugefügt.'**
  String get beispieldatenWarnung;

  /// No description provided for @beispieldatenGeladen.
  ///
  /// In de, this message translates to:
  /// **'Beispieldaten geladen'**
  String get beispieldatenGeladen;

  /// No description provided for @allesLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten löschen'**
  String get allesLoeschen;

  /// No description provided for @allesLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Drucker, Filamente, Produkte, Verkäufe, Aufträge und Sparziele werden endgültig gelöscht.'**
  String get allesLoeschenText;

  /// No description provided for @allesGeloescht.
  ///
  /// In de, this message translates to:
  /// **'Alle Daten gelöscht'**
  String get allesGeloescht;

  /// No description provided for @willkommen.
  ///
  /// In de, this message translates to:
  /// **'Willkommen bei Druckkasse'**
  String get willkommen;

  /// No description provided for @willkommenText.
  ///
  /// In de, this message translates to:
  /// **'Kosten, Preise und Verkäufe für deine 3D-Drucke, alles an einem Ort.'**
  String get willkommenText;

  /// No description provided for @einfuehrung1Titel.
  ///
  /// In de, this message translates to:
  /// **'Was kostet ein Druck wirklich?'**
  String get einfuehrung1Titel;

  /// No description provided for @einfuehrung1Text.
  ///
  /// In de, this message translates to:
  /// **'Material, Strom und Abnutzung pro Stück, mit Preisvorschlag.'**
  String get einfuehrung1Text;

  /// No description provided for @einfuehrung2Titel.
  ///
  /// In de, this message translates to:
  /// **'Verkaufen mit einem Tipp'**
  String get einfuehrung2Titel;

  /// No description provided for @einfuehrung2Text.
  ///
  /// In de, this message translates to:
  /// **'Große Knöpfe für den Verkauf vor Ort, mit Rückgängig.'**
  String get einfuehrung2Text;

  /// No description provided for @einfuehrung3Titel.
  ///
  /// In de, this message translates to:
  /// **'Sparziel im Blick'**
  String get einfuehrung3Titel;

  /// No description provided for @einfuehrung3Text.
  ///
  /// In de, this message translates to:
  /// **'Sieh, wie viele Stück bis zum neuen Drucker fehlen.'**
  String get einfuehrung3Text;

  /// No description provided for @selbstEinrichten.
  ///
  /// In de, this message translates to:
  /// **'Selbst einrichten'**
  String get selbstEinrichten;

  /// No description provided for @mitBeispielenStarten.
  ///
  /// In de, this message translates to:
  /// **'Mit Beispieldaten ausprobieren'**
  String get mitBeispielenStarten;

  /// No description provided for @beispieleSpaeterLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Beispieldaten kannst du später in den Einstellungen löschen.'**
  String get beispieleSpaeterLoeschen;
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
