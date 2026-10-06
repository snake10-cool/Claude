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

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @los.
  ///
  /// In de, this message translates to:
  /// **'Los!'**
  String get los;

  /// No description provided for @nochmal.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get nochmal;

  /// No description provided for @spaeter.
  ///
  /// In de, this message translates to:
  /// **'Später'**
  String get spaeter;

  /// No description provided for @einstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get einstellungen;

  /// No description provided for @kaufen.
  ///
  /// In de, this message translates to:
  /// **'Kaufen'**
  String get kaufen;

  /// No description provided for @proSekunde.
  ///
  /// In de, this message translates to:
  /// **'{wert} pro Sekunde'**
  String proSekunde(String wert);

  /// No description provided for @shop.
  ///
  /// In de, this message translates to:
  /// **'Shop & Einstellungen'**
  String get shop;

  /// No description provided for @tiefe.
  ///
  /// In de, this message translates to:
  /// **'Tiefe'**
  String get tiefe;

  /// No description provided for @schichtWiese.
  ///
  /// In de, this message translates to:
  /// **'Wiese'**
  String get schichtWiese;

  /// No description provided for @schichtErde.
  ///
  /// In de, this message translates to:
  /// **'Erde'**
  String get schichtErde;

  /// No description provided for @schichtLehm.
  ///
  /// In de, this message translates to:
  /// **'Lehm'**
  String get schichtLehm;

  /// No description provided for @schichtStein.
  ///
  /// In de, this message translates to:
  /// **'Stein'**
  String get schichtStein;

  /// No description provided for @schichtKristall.
  ///
  /// In de, this message translates to:
  /// **'Kristallhöhle'**
  String get schichtKristall;

  /// No description provided for @schichtLava.
  ///
  /// In de, this message translates to:
  /// **'Lava'**
  String get schichtLava;

  /// No description provided for @schichtKern.
  ///
  /// In de, this message translates to:
  /// **'Erdkern'**
  String get schichtKern;

  /// No description provided for @tagesbonus.
  ///
  /// In de, this message translates to:
  /// **'Tagesbonus'**
  String get tagesbonus;

  /// No description provided for @wurmregen.
  ///
  /// In de, this message translates to:
  /// **'Wurmregen'**
  String get wurmregen;

  /// No description provided for @boost.
  ///
  /// In de, this message translates to:
  /// **'Boost'**
  String get boost;

  /// No description provided for @helfer.
  ///
  /// In de, this message translates to:
  /// **'Helfer'**
  String get helfer;

  /// No description provided for @verbesserungen.
  ///
  /// In de, this message translates to:
  /// **'Verbesserungen'**
  String get verbesserungen;

  /// No description provided for @huegel.
  ///
  /// In de, this message translates to:
  /// **'Hügel'**
  String get huegel;

  /// No description provided for @helferWurm.
  ///
  /// In de, this message translates to:
  /// **'Regenwurm'**
  String get helferWurm;

  /// No description provided for @helferIgel.
  ///
  /// In de, this message translates to:
  /// **'Igel-Kumpel'**
  String get helferIgel;

  /// No description provided for @helferSchaufel.
  ///
  /// In de, this message translates to:
  /// **'Spitzhacke'**
  String get helferSchaufel;

  /// No description provided for @helferLore.
  ///
  /// In de, this message translates to:
  /// **'Grubenlore'**
  String get helferLore;

  /// No description provided for @helferBohrer.
  ///
  /// In de, this message translates to:
  /// **'Tunnelbohrer'**
  String get helferBohrer;

  /// No description provided for @helferKristall.
  ///
  /// In de, this message translates to:
  /// **'Kristallsucher'**
  String get helferKristall;

  /// No description provided for @helferMagma.
  ///
  /// In de, this message translates to:
  /// **'Magmapumpe'**
  String get helferMagma;

  /// No description provided for @helferLaser.
  ///
  /// In de, this message translates to:
  /// **'Erdkern-Laser'**
  String get helferLaser;

  /// No description provided for @helferInfo.
  ///
  /// In de, this message translates to:
  /// **'je {einzeln}/s · gesamt {gesamt}/s'**
  String helferInfo(String einzeln, String gesamt);

  /// No description provided for @naechsterHelfer.
  ///
  /// In de, this message translates to:
  /// **'Neuer Helfer'**
  String get naechsterHelfer;

  /// No description provided for @abGold.
  ///
  /// In de, this message translates to:
  /// **'zeigt sich ab {gold}'**
  String abGold(String gold);

  /// No description provided for @vKrallen1.
  ///
  /// In de, this message translates to:
  /// **'Stärkere Krallen'**
  String get vKrallen1;

  /// No description provided for @vKrallen2.
  ///
  /// In de, this message translates to:
  /// **'Stahlkrallen'**
  String get vKrallen2;

  /// No description provided for @vKrallen3.
  ///
  /// In de, this message translates to:
  /// **'Diamantkrallen'**
  String get vKrallen3;

  /// No description provided for @vLampe.
  ///
  /// In de, this message translates to:
  /// **'Helle Grubenlampe'**
  String get vLampe;

  /// No description provided for @vLampe2.
  ///
  /// In de, this message translates to:
  /// **'Superlampe'**
  String get vLampe2;

  /// No description provided for @vKarte.
  ///
  /// In de, this message translates to:
  /// **'Schatzkarte'**
  String get vKarte;

  /// No description provided for @vKompass.
  ///
  /// In de, this message translates to:
  /// **'Goldkompass'**
  String get vKompass;

  /// No description provided for @vHelfer.
  ///
  /// In de, this message translates to:
  /// **'Training: {helfer}'**
  String vHelfer(String helfer);

  /// No description provided for @wirkungTippen.
  ///
  /// In de, this message translates to:
  /// **'Tippen ×{faktor}'**
  String wirkungTippen(String faktor);

  /// No description provided for @wirkungHelfer.
  ///
  /// In de, this message translates to:
  /// **'{helfer} ×{faktor}'**
  String wirkungHelfer(String helfer, String faktor);

  /// No description provided for @wirkungAnteil.
  ///
  /// In de, this message translates to:
  /// **'Tippen +{prozent} % der Produktion'**
  String wirkungAnteil(int prozent);

  /// No description provided for @wirkungAlles.
  ///
  /// In de, this message translates to:
  /// **'Alles ×{faktor}'**
  String wirkungAlles(String faktor);

  /// No description provided for @keineVerbesserungen.
  ///
  /// In de, this message translates to:
  /// **'Gerade keine Verbesserungen. Grab weiter – bald gibt\'s neue!'**
  String get keineVerbesserungen;

  /// No description provided for @neuerHuegel.
  ///
  /// In de, this message translates to:
  /// **'Neuer Hügel'**
  String get neuerHuegel;

  /// No description provided for @neuerHuegelText.
  ///
  /// In de, this message translates to:
  /// **'Fang auf einem neuen Hügel von vorne an und nimm Glitzersteine mit. Jeder Stein bringt +10 % für immer. Du hast {glitzer} ✨ (+{prozent} %).'**
  String neuerHuegelText(int glitzer, int prozent);

  /// No description provided for @neuerHuegelKnopf.
  ///
  /// In de, this message translates to:
  /// **'Neuer Hügel: +{anzahl} ✨'**
  String neuerHuegelKnopf(int anzahl);

  /// No description provided for @neuerHuegelAb.
  ///
  /// In de, this message translates to:
  /// **'Ab {gold} Gold in dieser Runde'**
  String neuerHuegelAb(String gold);

  /// No description provided for @erfolge.
  ///
  /// In de, this message translates to:
  /// **'Erfolge ({hast}/{gesamt})'**
  String erfolge(int hast, int gesamt);

  /// No description provided for @prestigeWarnung.
  ///
  /// In de, this message translates to:
  /// **'Gold, Helfer und Verbesserungen werden zurückgesetzt. Du bekommst {anzahl} Glitzersteine (+{prozent} % für immer).'**
  String prestigeWarnung(int anzahl, int prozent);

  /// No description provided for @losGehts.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get losGehts;

  /// No description provided for @erfolgFreigeschaltet.
  ///
  /// In de, this message translates to:
  /// **'Erfolg: {name}'**
  String erfolgFreigeschaltet(String name);

  /// No description provided for @klumpenGefunden.
  ///
  /// In de, this message translates to:
  /// **'Glücksklumpen! +{gold} Gold'**
  String klumpenGefunden(String gold);

  /// No description provided for @eTipp100.
  ///
  /// In de, this message translates to:
  /// **'100 Mal gebuddelt'**
  String get eTipp100;

  /// No description provided for @eTipp1000.
  ///
  /// In de, this message translates to:
  /// **'1.000 Mal gebuddelt'**
  String get eTipp1000;

  /// No description provided for @eTipp10000.
  ///
  /// In de, this message translates to:
  /// **'Buddel-Profi: 10.000 Tipps'**
  String get eTipp10000;

  /// No description provided for @eGold1k.
  ///
  /// In de, this message translates to:
  /// **'Erstes Säckchen: 1.000 Gold'**
  String get eGold1k;

  /// No description provided for @eGold1m.
  ///
  /// In de, this message translates to:
  /// **'Millionär'**
  String get eGold1m;

  /// No description provided for @eGold1b.
  ///
  /// In de, this message translates to:
  /// **'Milliardär'**
  String get eGold1b;

  /// No description provided for @eGold1t.
  ///
  /// In de, this message translates to:
  /// **'Goldkönig: 1 Billion'**
  String get eGold1t;

  /// No description provided for @eHelfer10.
  ///
  /// In de, this message translates to:
  /// **'10 Helfer'**
  String get eHelfer10;

  /// No description provided for @eHelfer100.
  ///
  /// In de, this message translates to:
  /// **'100 Helfer'**
  String get eHelfer100;

  /// No description provided for @eAlleHelfer.
  ///
  /// In de, this message translates to:
  /// **'Von jedem einen'**
  String get eAlleHelfer;

  /// No description provided for @ePrestige1.
  ///
  /// In de, this message translates to:
  /// **'Erster neuer Hügel'**
  String get ePrestige1;

  /// No description provided for @ePrestige5.
  ///
  /// In de, this message translates to:
  /// **'Hügel-Hüpfer: 5 Hügel'**
  String get ePrestige5;

  /// No description provided for @eWurm20.
  ///
  /// In de, this message translates to:
  /// **'Wurmfänger: 20 Punkte'**
  String get eWurm20;

  /// No description provided for @eWurm50.
  ///
  /// In de, this message translates to:
  /// **'Wurmmeister: 50 Punkte'**
  String get eWurm50;

  /// No description provided for @eSerie7.
  ///
  /// In de, this message translates to:
  /// **'Eine ganze Woche Bonus'**
  String get eSerie7;

  /// No description provided for @willkommenZurueck.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück!'**
  String get willkommenZurueck;

  /// No description provided for @offlineText.
  ///
  /// In de, this message translates to:
  /// **'Während du weg warst ({zeit}), hat Mos Team {gold} Gold gegraben.'**
  String offlineText(String zeit, String gold);

  /// No description provided for @einsammeln.
  ///
  /// In de, this message translates to:
  /// **'Einsammeln'**
  String get einsammeln;

  /// No description provided for @verdoppeln.
  ///
  /// In de, this message translates to:
  /// **'Video: ×2'**
  String get verdoppeln;

  /// No description provided for @videoNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist kein Video verfügbar. Versuch es später nochmal.'**
  String get videoNichtVerfuegbar;

  /// No description provided for @tagNummer.
  ///
  /// In de, this message translates to:
  /// **'Tag {tag}'**
  String tagNummer(int tag);

  /// No description provided for @tagesbonusText.
  ///
  /// In de, this message translates to:
  /// **'Komm jeden Tag vorbei – an Tag 7 gibt es einen Glitzerstein!'**
  String get tagesbonusText;

  /// No description provided for @tagesbonusMorgen.
  ///
  /// In de, this message translates to:
  /// **'Für heute schon abgeholt. Morgen geht\'s weiter!'**
  String get tagesbonusMorgen;

  /// No description provided for @abholen.
  ///
  /// In de, this message translates to:
  /// **'Abholen'**
  String get abholen;

  /// No description provided for @bonusErhalten.
  ///
  /// In de, this message translates to:
  /// **'+{gold} Gold!'**
  String bonusErhalten(String gold);

  /// No description provided for @bonusMitGlitzer.
  ///
  /// In de, this message translates to:
  /// **'+{gold} Gold und ein Glitzerstein ✨!'**
  String bonusMitGlitzer(String gold);

  /// No description provided for @boostTitel.
  ///
  /// In de, this message translates to:
  /// **'Doppelte Kraft'**
  String get boostTitel;

  /// No description provided for @boostText.
  ///
  /// In de, this message translates to:
  /// **'Schau ein kurzes Video: 10 Minuten lang gräbt alles doppelt so schnell. Mehrere Videos verlängern den Boost.'**
  String get boostText;

  /// No description provided for @videoAnsehen.
  ///
  /// In de, this message translates to:
  /// **'Video ansehen'**
  String get videoAnsehen;

  /// No description provided for @wurmregenErklaerung.
  ///
  /// In de, this message translates to:
  /// **'Tippe in 20 Sekunden so viele Würmer wie möglich. Goldene Würmer 🌟 zählen 5!'**
  String get wurmregenErklaerung;

  /// No description provided for @wurmErgebnis.
  ///
  /// In de, this message translates to:
  /// **'{punkte} Punkte!'**
  String wurmErgebnis(int punkte);

  /// No description provided for @wurmGold.
  ///
  /// In de, this message translates to:
  /// **'+{gold} Gold'**
  String wurmGold(String gold);

  /// No description provided for @rekord.
  ///
  /// In de, this message translates to:
  /// **'Rekord: {punkte}'**
  String rekord(int punkte);

  /// No description provided for @zurueckZuMo.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Mo'**
  String get zurueckZuMo;

  /// No description provided for @angebote.
  ///
  /// In de, this message translates to:
  /// **'Angebote'**
  String get angebote;

  /// No description provided for @shopNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Der Shop ist erst in der Play-Store-Version verfügbar.'**
  String get shopNichtVerfuegbar;

  /// No description provided for @werbefrei.
  ///
  /// In de, this message translates to:
  /// **'Werbefrei'**
  String get werbefrei;

  /// No description provided for @werbefreiText.
  ///
  /// In de, this message translates to:
  /// **'Kein Banner mehr. Videos für Boni bleiben freiwillig.'**
  String get werbefreiText;

  /// No description provided for @goldsack.
  ///
  /// In de, this message translates to:
  /// **'Goldsack'**
  String get goldsack;

  /// No description provided for @goldsackText.
  ///
  /// In de, this message translates to:
  /// **'2 Stunden Produktion sofort'**
  String get goldsackText;

  /// No description provided for @glitzerpaket.
  ///
  /// In de, this message translates to:
  /// **'Glitzerpaket'**
  String get glitzerpaket;

  /// No description provided for @glitzerpaketText.
  ///
  /// In de, this message translates to:
  /// **'5 Glitzersteine (+50 % für immer)'**
  String get glitzerpaketText;

  /// No description provided for @kaeufeWiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get kaeufeWiederherstellen;

  /// No description provided for @werbeEinwilligung.
  ///
  /// In de, this message translates to:
  /// **'Einwilligung für Werbung ändern'**
  String get werbeEinwilligung;

  /// No description provided for @spielZuruecksetzen.
  ///
  /// In de, this message translates to:
  /// **'Spiel zurücksetzen'**
  String get spielZuruecksetzen;

  /// No description provided for @spielZuruecksetzenText.
  ///
  /// In de, this message translates to:
  /// **'Der ganze Spielstand wird gelöscht, auch Glitzersteine und Erfolge.'**
  String get spielZuruecksetzenText;
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
