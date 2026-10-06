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

  /// No description provided for @tabListen.
  ///
  /// In de, this message translates to:
  /// **'Listen'**
  String get tabListen;

  /// No description provided for @tabGeld.
  ///
  /// In de, this message translates to:
  /// **'Geld'**
  String get tabGeld;

  /// No description provided for @tabPacken.
  ///
  /// In de, this message translates to:
  /// **'Packen'**
  String get tabPacken;

  /// No description provided for @tabKochen.
  ///
  /// In de, this message translates to:
  /// **'Kochen'**
  String get tabKochen;

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

  /// No description provided for @anlegen.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get anlegen;

  /// No description provided for @hinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Hinzufügen'**
  String get hinzufuegen;

  /// No description provided for @umbenennen.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get umbenennen;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @menge.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get menge;

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

  /// No description provided for @app.
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @leer.
  ///
  /// In de, this message translates to:
  /// **'Leer'**
  String get leer;

  /// No description provided for @ich.
  ///
  /// In de, this message translates to:
  /// **'ich'**
  String get ich;

  /// No description provided for @neueListe.
  ///
  /// In de, this message translates to:
  /// **'Neue Liste'**
  String get neueListe;

  /// No description provided for @keineListen.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Liste'**
  String get keineListen;

  /// No description provided for @keineListenText.
  ///
  /// In de, this message translates to:
  /// **'Leg eine Einkaufsliste an – für dich allein oder gemeinsam mit deiner WG.'**
  String get keineListenText;

  /// No description provided for @fuerMich.
  ///
  /// In de, this message translates to:
  /// **'Für mich'**
  String get fuerMich;

  /// No description provided for @allesErledigt.
  ///
  /// In de, this message translates to:
  /// **'Alles erledigt ✓'**
  String get allesErledigt;

  /// No description provided for @offenVon.
  ///
  /// In de, this message translates to:
  /// **'{offen} von {gesamt} offen'**
  String offenVon(int offen, int gesamt);

  /// No description provided for @einkauf.
  ///
  /// In de, this message translates to:
  /// **'Einkauf'**
  String get einkauf;

  /// No description provided for @werSiehtDieListe.
  ///
  /// In de, this message translates to:
  /// **'Wer sieht die Liste?'**
  String get werSiehtDieListe;

  /// No description provided for @nurIch.
  ///
  /// In de, this message translates to:
  /// **'Nur ich'**
  String get nurIch;

  /// No description provided for @gruppeFuerTeilen.
  ///
  /// In de, this message translates to:
  /// **'Zum Teilen zuerst unter „Geld“ eine Gruppe anlegen.'**
  String get gruppeFuerTeilen;

  /// No description provided for @ichNehmWasMit.
  ///
  /// In de, this message translates to:
  /// **'Ich nehm was mit'**
  String get ichNehmWasMit;

  /// No description provided for @ichNehmWasMitText.
  ///
  /// In de, this message translates to:
  /// **'Du kaufst für eine Person ein. Beträge zahlt nur diese Person.'**
  String get ichNehmWasMitText;

  /// No description provided for @fuerWen.
  ///
  /// In de, this message translates to:
  /// **'Für wen?'**
  String get fuerWen;

  /// No description provided for @werBistDu.
  ///
  /// In de, this message translates to:
  /// **'Wer bist du?'**
  String get werBistDu;

  /// No description provided for @gekauft.
  ///
  /// In de, this message translates to:
  /// **'{name} gekauft'**
  String gekauft(String name);

  /// No description provided for @betragHilfe.
  ///
  /// In de, this message translates to:
  /// **'Trag den Preis ein, dann landet er automatisch in der Abrechnung der Gruppe.'**
  String get betragHilfe;

  /// No description provided for @betragOptional.
  ///
  /// In de, this message translates to:
  /// **'Betrag (optional)'**
  String get betragOptional;

  /// No description provided for @ohneBetrag.
  ///
  /// In de, this message translates to:
  /// **'Ohne Betrag'**
  String get ohneBetrag;

  /// No description provided for @abhaken.
  ///
  /// In de, this message translates to:
  /// **'Abhaken'**
  String get abhaken;

  /// No description provided for @artikelBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Artikel bearbeiten'**
  String get artikelBearbeiten;

  /// No description provided for @vorlageGespeichert.
  ///
  /// In de, this message translates to:
  /// **'Als Vorlage gespeichert'**
  String get vorlageGespeichert;

  /// No description provided for @listeLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Liste löschen'**
  String get listeLoeschen;

  /// No description provided for @alsTextTeilen.
  ///
  /// In de, this message translates to:
  /// **'Als Text teilen'**
  String get alsTextTeilen;

  /// No description provided for @alleZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Alle Häkchen entfernen'**
  String get alleZuruecksetzen;

  /// No description provided for @erledigteEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Erledigte entfernen'**
  String get erledigteEntfernen;

  /// No description provided for @alsVorlageSpeichern.
  ///
  /// In de, this message translates to:
  /// **'Als Vorlage speichern'**
  String get alsVorlageSpeichern;

  /// No description provided for @artikelHinzufuegenHinweis.
  ///
  /// In de, this message translates to:
  /// **'z. B. „2 Milch“ oder „500 g Mehl“'**
  String get artikelHinzufuegenHinweis;

  /// No description provided for @listeLeer.
  ///
  /// In de, this message translates to:
  /// **'Die Liste ist leer'**
  String get listeLeer;

  /// No description provided for @listeLeerText.
  ///
  /// In de, this message translates to:
  /// **'Tipp oben ein, was fehlt. Mengen erkennt die App selbst.'**
  String get listeLeerText;

  /// No description provided for @erledigtAnzahl.
  ///
  /// In de, this message translates to:
  /// **'Erledigt ({anzahl})'**
  String erledigtAnzahl(int anzahl);

  /// No description provided for @beitreten.
  ///
  /// In de, this message translates to:
  /// **'Gruppe beitreten'**
  String get beitreten;

  /// No description provided for @neueGruppe.
  ///
  /// In de, this message translates to:
  /// **'Neue Gruppe'**
  String get neueGruppe;

  /// No description provided for @rechner.
  ///
  /// In de, this message translates to:
  /// **'Rechnung & Trinkgeld'**
  String get rechner;

  /// No description provided for @rechnerText.
  ///
  /// In de, this message translates to:
  /// **'Restaurant-Rechnung fair aufteilen'**
  String get rechnerText;

  /// No description provided for @keineGruppen.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Gruppe'**
  String get keineGruppen;

  /// No description provided for @keineGruppenText.
  ///
  /// In de, this message translates to:
  /// **'Gruppen für WG, Familie oder Urlaub: gemeinsame Listen und Ausgaben, die sich selbst abrechnen.'**
  String get keineGruppenText;

  /// No description provided for @geteilt.
  ///
  /// In de, this message translates to:
  /// **'Geteilt'**
  String get geteilt;

  /// No description provided for @nurAufDiesemGeraet.
  ///
  /// In de, this message translates to:
  /// **'Nur auf diesem Gerät'**
  String get nurAufDiesemGeraet;

  /// No description provided for @duBistQuitt.
  ///
  /// In de, this message translates to:
  /// **'Du bist quitt'**
  String get duBistQuitt;

  /// No description provided for @duBekommst.
  ///
  /// In de, this message translates to:
  /// **'Du bekommst {betrag}'**
  String duBekommst(String betrag);

  /// No description provided for @duSchuldest.
  ///
  /// In de, this message translates to:
  /// **'Du schuldest {betrag}'**
  String duSchuldest(String betrag);

  /// No description provided for @grenzeErreicht.
  ///
  /// In de, this message translates to:
  /// **'Gratis-Grenze erreicht'**
  String get grenzeErreicht;

  /// No description provided for @grenzeGruppen.
  ///
  /// In de, this message translates to:
  /// **'Kostenlos kannst du {anzahl} Gruppen haben. Mit Teilbar Plus unbegrenzt viele.'**
  String grenzeGruppen(int anzahl);

  /// No description provided for @artWg.
  ///
  /// In de, this message translates to:
  /// **'WG'**
  String get artWg;

  /// No description provided for @artFamilie.
  ///
  /// In de, this message translates to:
  /// **'Familie'**
  String get artFamilie;

  /// No description provided for @artUrlaub.
  ///
  /// In de, this message translates to:
  /// **'Urlaub'**
  String get artUrlaub;

  /// No description provided for @artEssen.
  ///
  /// In de, this message translates to:
  /// **'Essen gehen'**
  String get artEssen;

  /// No description provided for @artSonst.
  ///
  /// In de, this message translates to:
  /// **'Andere'**
  String get artSonst;

  /// No description provided for @gruppenName.
  ///
  /// In de, this message translates to:
  /// **'Name der Gruppe'**
  String get gruppenName;

  /// No description provided for @gruppenNameBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. WG Linz'**
  String get gruppenNameBeispiel;

  /// No description provided for @deinName.
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get deinName;

  /// No description provided for @weiterePersonen.
  ///
  /// In de, this message translates to:
  /// **'Weitere Personen (optional)'**
  String get weiterePersonen;

  /// No description provided for @weiterePersonenHilfe.
  ///
  /// In de, this message translates to:
  /// **'Mit Komma trennen: Ben, Cem, Dana'**
  String get weiterePersonenHilfe;

  /// No description provided for @gruppeLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Gruppe löschen'**
  String get gruppeLoeschen;

  /// No description provided for @gruppeLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Die Gruppe mit allen Listen und Ausgaben wird gelöscht.'**
  String get gruppeLoeschenText;

  /// No description provided for @gruppeLoeschenOnline.
  ///
  /// In de, this message translates to:
  /// **'Die Gruppe wird für alle Mitglieder gelöscht, mit allen Listen und Ausgaben.'**
  String get gruppeLoeschenOnline;

  /// No description provided for @ausgaben.
  ///
  /// In de, this message translates to:
  /// **'Ausgaben'**
  String get ausgaben;

  /// No description provided for @wersSchuldet.
  ///
  /// In de, this message translates to:
  /// **'Wer schuldet wem'**
  String get wersSchuldet;

  /// No description provided for @mitglieder.
  ///
  /// In de, this message translates to:
  /// **'Mitglieder'**
  String get mitglieder;

  /// No description provided for @ausgabe.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe'**
  String get ausgabe;

  /// No description provided for @keineAusgaben.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ausgaben'**
  String get keineAusgaben;

  /// No description provided for @keineAusgabenText.
  ///
  /// In de, this message translates to:
  /// **'Trag ein, wer was bezahlt hat. Oder hak in einer Gruppenliste einen Artikel mit Betrag ab.'**
  String get keineAusgabenText;

  /// No description provided for @gesamtAusgaben.
  ///
  /// In de, this message translates to:
  /// **'Insgesamt ausgegeben: {betrag}'**
  String gesamtAusgaben(String betrag);

  /// No description provided for @bezahltVon.
  ///
  /// In de, this message translates to:
  /// **'bezahlt von {name}'**
  String bezahltVon(String name);

  /// No description provided for @soGleichtIhrAus.
  ///
  /// In de, this message translates to:
  /// **'So gleicht ihr aus'**
  String get soGleichtIhrAus;

  /// No description provided for @allesAusgeglichen.
  ///
  /// In de, this message translates to:
  /// **'Alles ausgeglichen. 🎉'**
  String get allesAusgeglichen;

  /// No description provided for @zahltAn.
  ///
  /// In de, this message translates to:
  /// **'{von} zahlt {an}'**
  String zahltAn(String von, String an);

  /// No description provided for @alsBezahltMarkieren.
  ///
  /// In de, this message translates to:
  /// **'Als bezahlt markieren?'**
  String get alsBezahltMarkieren;

  /// No description provided for @alsBezahltText.
  ///
  /// In de, this message translates to:
  /// **'{von} hat {an} {betrag} gegeben.'**
  String alsBezahltText(String von, String betrag, String an);

  /// No description provided for @bezahlt.
  ///
  /// In de, this message translates to:
  /// **'Bezahlt'**
  String get bezahlt;

  /// No description provided for @rueckzahlung.
  ///
  /// In de, this message translates to:
  /// **'Rückzahlung'**
  String get rueckzahlung;

  /// No description provided for @personHinzufuegen.
  ///
  /// In de, this message translates to:
  /// **'Person hinzufügen'**
  String get personHinzufuegen;

  /// No description provided for @person.
  ///
  /// In de, this message translates to:
  /// **'Person'**
  String get person;

  /// No description provided for @dasBistDu.
  ///
  /// In de, this message translates to:
  /// **'Das bist du'**
  String get dasBistDu;

  /// No description provided for @dasBinIch.
  ///
  /// In de, this message translates to:
  /// **'Das bin ich'**
  String get dasBinIch;

  /// No description provided for @gemeinsamNutzen.
  ///
  /// In de, this message translates to:
  /// **'Gemeinsam nutzen'**
  String get gemeinsamNutzen;

  /// No description provided for @gemeinsamNutzenText.
  ///
  /// In de, this message translates to:
  /// **'Stell die Gruppe online. Dann sehen alle Mitglieder Listen und Ausgaben live auf ihrem Handy.'**
  String get gemeinsamNutzenText;

  /// No description provided for @onlineNichtEingerichtet.
  ///
  /// In de, this message translates to:
  /// **'Online-Gruppen sind in dieser Version noch nicht eingerichtet. Die Gruppe funktioniert auf diesem Gerät.'**
  String get onlineNichtEingerichtet;

  /// No description provided for @onlineTeilen.
  ///
  /// In de, this message translates to:
  /// **'Online teilen'**
  String get onlineTeilen;

  /// No description provided for @keinInternet.
  ///
  /// In de, this message translates to:
  /// **'Keine Verbindung. Bitte später nochmal probieren.'**
  String get keinInternet;

  /// No description provided for @einladungscode.
  ///
  /// In de, this message translates to:
  /// **'Einladungscode'**
  String get einladungscode;

  /// No description provided for @einladen.
  ///
  /// In de, this message translates to:
  /// **'Einladen'**
  String get einladen;

  /// No description provided for @einladungText.
  ///
  /// In de, this message translates to:
  /// **'Komm in unsere Gruppe „{gruppe}“ bei Teilbar! Code: {code}'**
  String einladungText(String gruppe, String code);

  /// No description provided for @neueAusgabe.
  ///
  /// In de, this message translates to:
  /// **'Neue Ausgabe'**
  String get neueAusgabe;

  /// No description provided for @ausgabeBearbeiten.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe bearbeiten'**
  String get ausgabeBearbeiten;

  /// No description provided for @ausgabeLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Ausgabe löschen?'**
  String get ausgabeLoeschen;

  /// No description provided for @mindestensEinePerson.
  ///
  /// In de, this message translates to:
  /// **'Mindestens eine Person auswählen.'**
  String get mindestensEinePerson;

  /// No description provided for @wofuer.
  ///
  /// In de, this message translates to:
  /// **'Wofür?'**
  String get wofuer;

  /// No description provided for @wofuerBeispiel.
  ///
  /// In de, this message translates to:
  /// **'z. B. Pizza, Tanken, Miete'**
  String get wofuerBeispiel;

  /// No description provided for @betrag.
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get betrag;

  /// No description provided for @werHatBezahlt.
  ///
  /// In de, this message translates to:
  /// **'Wer hat bezahlt?'**
  String get werHatBezahlt;

  /// No description provided for @fuerWenGeteilt.
  ///
  /// In de, this message translates to:
  /// **'Für wen? (gleich aufgeteilt)'**
  String get fuerWenGeteilt;

  /// No description provided for @beitretenText.
  ///
  /// In de, this message translates to:
  /// **'Gib den 6-stelligen Code ein, den du bekommen hast, oder scanne den QR-Code.'**
  String get beitretenText;

  /// No description provided for @codeUngueltig.
  ///
  /// In de, this message translates to:
  /// **'Der Code hat 6 Zeichen.'**
  String get codeUngueltig;

  /// No description provided for @codeNichtGefunden.
  ///
  /// In de, this message translates to:
  /// **'Diesen Code gibt es nicht.'**
  String get codeNichtGefunden;

  /// No description provided for @ichBinNeu.
  ///
  /// In de, this message translates to:
  /// **'Ich bin neu dabei'**
  String get ichBinNeu;

  /// No description provided for @qrScannen.
  ///
  /// In de, this message translates to:
  /// **'QR-Code scannen'**
  String get qrScannen;

  /// No description provided for @rechnungsbetrag.
  ///
  /// In de, this message translates to:
  /// **'Rechnungsbetrag'**
  String get rechnungsbetrag;

  /// No description provided for @trinkgeldProzent.
  ///
  /// In de, this message translates to:
  /// **'Trinkgeld: {prozent} %'**
  String trinkgeldProzent(int prozent);

  /// No description provided for @personen.
  ///
  /// In de, this message translates to:
  /// **'Personen'**
  String get personen;

  /// No description provided for @aufrunden.
  ///
  /// In de, this message translates to:
  /// **'Aufrunden'**
  String get aufrunden;

  /// No description provided for @aufrundenText.
  ///
  /// In de, this message translates to:
  /// **'Auf 50 Cent pro Person aufrunden'**
  String get aufrundenText;

  /// No description provided for @proPerson.
  ///
  /// In de, this message translates to:
  /// **'Pro Person'**
  String get proPerson;

  /// No description provided for @rechnerErgebnis.
  ///
  /// In de, this message translates to:
  /// **'Gesamt {gesamt}, davon {trinkgeld} Trinkgeld'**
  String rechnerErgebnis(String gesamt, String trinkgeld);

  /// No description provided for @vorlageStrand.
  ///
  /// In de, this message translates to:
  /// **'Strandurlaub'**
  String get vorlageStrand;

  /// No description provided for @vorlageSki.
  ///
  /// In de, this message translates to:
  /// **'Skiurlaub'**
  String get vorlageSki;

  /// No description provided for @vorlageFestival.
  ///
  /// In de, this message translates to:
  /// **'Festival'**
  String get vorlageFestival;

  /// No description provided for @vorlageStadt.
  ///
  /// In de, this message translates to:
  /// **'Städtetrip'**
  String get vorlageStadt;

  /// No description provided for @vorlageCamping.
  ///
  /// In de, this message translates to:
  /// **'Camping'**
  String get vorlageCamping;

  /// No description provided for @vorlageBusiness.
  ///
  /// In de, this message translates to:
  /// **'Geschäftsreise'**
  String get vorlageBusiness;

  /// No description provided for @wohinGehts.
  ///
  /// In de, this message translates to:
  /// **'Wohin geht\'s?'**
  String get wohinGehts;

  /// No description provided for @artikelAnzahl.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Sachen'**
  String artikelAnzahl(int anzahl);

  /// No description provided for @eigeneVorlagen.
  ///
  /// In de, this message translates to:
  /// **'Eigene Vorlagen'**
  String get eigeneVorlagen;

  /// No description provided for @leerePackliste.
  ///
  /// In de, this message translates to:
  /// **'Leere Packliste'**
  String get leerePackliste;

  /// No description provided for @packliste.
  ///
  /// In de, this message translates to:
  /// **'Packliste'**
  String get packliste;

  /// No description provided for @neuePackliste.
  ///
  /// In de, this message translates to:
  /// **'Neue Packliste'**
  String get neuePackliste;

  /// No description provided for @keinePacklisten.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Packliste'**
  String get keinePacklisten;

  /// No description provided for @keinePacklistenText.
  ///
  /// In de, this message translates to:
  /// **'Wähl eine Vorlage (Strand, Ski, Festival …) und pass sie an. Fertige Listen kannst du als eigene Vorlage speichern.'**
  String get keinePacklistenText;

  /// No description provided for @resteKueche.
  ///
  /// In de, this message translates to:
  /// **'Resteküche'**
  String get resteKueche;

  /// No description provided for @rezeptDesTages.
  ///
  /// In de, this message translates to:
  /// **'Rezept des Tages'**
  String get rezeptDesTages;

  /// No description provided for @wasHastDuDa.
  ///
  /// In de, this message translates to:
  /// **'Was hast du da?'**
  String get wasHastDuDa;

  /// No description provided for @zutatEingeben.
  ///
  /// In de, this message translates to:
  /// **'Zutat eingeben, z. B. Eier'**
  String get zutatEingeben;

  /// No description provided for @alleEntfernen.
  ///
  /// In de, this message translates to:
  /// **'Alle entfernen'**
  String get alleEntfernen;

  /// No description provided for @alleRezepte.
  ///
  /// In de, this message translates to:
  /// **'Alle Rezepte'**
  String get alleRezepte;

  /// No description provided for @dazuPasst.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Kein passendes Rezept} =1{1 passendes Rezept} other{{anzahl} passende Rezepte}}'**
  String dazuPasst(int anzahl);

  /// No description provided for @minutenPortionen.
  ///
  /// In de, this message translates to:
  /// **'{minuten} Min. · {portionen} Portionen'**
  String minutenPortionen(int minuten, int portionen);

  /// No description provided for @allesDa.
  ///
  /// In de, this message translates to:
  /// **'Du hast alles da!'**
  String get allesDa;

  /// No description provided for @esFehlt.
  ///
  /// In de, this message translates to:
  /// **'Es fehlt: {zutaten}'**
  String esFehlt(String zutaten);

  /// No description provided for @aufWelcheListe.
  ///
  /// In de, this message translates to:
  /// **'Auf welche Liste?'**
  String get aufWelcheListe;

  /// No description provided for @neueEinkaufsliste.
  ///
  /// In de, this message translates to:
  /// **'Neue Einkaufsliste'**
  String get neueEinkaufsliste;

  /// No description provided for @aufListeGesetzt.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Zutaten auf „{liste}“ gesetzt'**
  String aufListeGesetzt(int anzahl, String liste);

  /// No description provided for @fehlendeAufListe.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} fehlende auf die Einkaufsliste'**
  String fehlendeAufListe(int anzahl);

  /// No description provided for @minuten.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Min.'**
  String minuten(int anzahl);

  /// No description provided for @portionen.
  ///
  /// In de, this message translates to:
  /// **'{anzahl} Portionen'**
  String portionen(int anzahl);

  /// No description provided for @zutaten.
  ///
  /// In de, this message translates to:
  /// **'Zutaten'**
  String get zutaten;

  /// No description provided for @grundzutat.
  ///
  /// In de, this message translates to:
  /// **'Grundzutat – meist zu Hause'**
  String get grundzutat;

  /// No description provided for @zubereitung.
  ///
  /// In de, this message translates to:
  /// **'Zubereitung'**
  String get zubereitung;

  /// No description provided for @plusTitel.
  ///
  /// In de, this message translates to:
  /// **'Teilbar Plus'**
  String get plusTitel;

  /// No description provided for @plusKurz.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt Gruppen, ohne Werbung'**
  String get plusKurz;

  /// No description provided for @plusVorteilGruppen.
  ///
  /// In de, this message translates to:
  /// **'Unbegrenzt viele Gruppen'**
  String get plusVorteilGruppen;

  /// No description provided for @plusVorteilWerbefrei.
  ///
  /// In de, this message translates to:
  /// **'Keine Werbung'**
  String get plusVorteilWerbefrei;

  /// No description provided for @plusVorteilUnterstuetzen.
  ///
  /// In de, this message translates to:
  /// **'Du unterstützt die Weiterentwicklung'**
  String get plusVorteilUnterstuetzen;

  /// No description provided for @werbefrei.
  ///
  /// In de, this message translates to:
  /// **'Werbung entfernen'**
  String get werbefrei;

  /// No description provided for @einmalkauf.
  ///
  /// In de, this message translates to:
  /// **'Einmalkauf'**
  String get einmalkauf;

  /// No description provided for @profil.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profil;

  /// No description provided for @nichtGesetzt.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht gesetzt'**
  String get nichtGesetzt;

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
