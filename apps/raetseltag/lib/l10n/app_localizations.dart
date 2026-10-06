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

  /// No description provided for @mehr.
  ///
  /// In de, this message translates to:
  /// **'Mehr'**
  String get mehr;

  /// No description provided for @statistik.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get statistik;

  /// No description provided for @einstellungen.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get einstellungen;

  /// No description provided for @loeschen.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get loeschen;

  /// No description provided for @weiter.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get weiter;

  /// No description provided for @teilen.
  ///
  /// In de, this message translates to:
  /// **'Teilen'**
  String get teilen;

  /// No description provided for @tipp.
  ///
  /// In de, this message translates to:
  /// **'Tipp (Video)'**
  String get tipp;

  /// No description provided for @super_.
  ///
  /// In de, this message translates to:
  /// **'Super!'**
  String get super_;

  /// No description provided for @leiderNicht.
  ///
  /// In de, this message translates to:
  /// **'Leider nicht'**
  String get leiderNicht;

  /// No description provided for @raetselNr.
  ///
  /// In de, this message translates to:
  /// **'Rätsel #{nummer}'**
  String raetselNr(int nummer);

  /// No description provided for @wortraetsel.
  ///
  /// In de, this message translates to:
  /// **'Worträtsel'**
  String get wortraetsel;

  /// No description provided for @wortraetselText.
  ///
  /// In de, this message translates to:
  /// **'Finde das Wort mit 5 Buchstaben in 6 Versuchen.'**
  String get wortraetselText;

  /// No description provided for @sudoku.
  ///
  /// In de, this message translates to:
  /// **'Sudoku'**
  String get sudoku;

  /// No description provided for @sudokuText.
  ///
  /// In de, this message translates to:
  /// **'Leicht, mittel oder schwer.'**
  String get sudokuText;

  /// No description provided for @schiebepuzzle.
  ///
  /// In de, this message translates to:
  /// **'Schiebepuzzle'**
  String get schiebepuzzle;

  /// No description provided for @schiebepuzzleText.
  ///
  /// In de, this message translates to:
  /// **'Bring die Zahlen von 1 bis 15 in Reihe.'**
  String get schiebepuzzleText;

  /// No description provided for @geschafftVersuche.
  ///
  /// In de, this message translates to:
  /// **'Geschafft in {anzahl}/6 ✅'**
  String geschafftVersuche(int anzahl);

  /// No description provided for @nichtGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Diesmal nicht geschafft'**
  String get nichtGeschafft;

  /// No description provided for @geschafftZuege.
  ///
  /// In de, this message translates to:
  /// **'Geschafft in {zuege} Zügen ✅'**
  String geschafftZuege(int zuege);

  /// No description provided for @geschafftSudoku.
  ///
  /// In de, this message translates to:
  /// **'{stufe} geschafft in {zeit} ✅'**
  String geschafftSudoku(String stufe, String zeit);

  /// No description provided for @weiterspielen.
  ///
  /// In de, this message translates to:
  /// **'Weiterspielen …'**
  String get weiterspielen;

  /// No description provided for @alleDreiGeschafft.
  ///
  /// In de, this message translates to:
  /// **'⭐ Alle drei geschafft! Bis morgen!'**
  String get alleDreiGeschafft;

  /// No description provided for @archiv.
  ///
  /// In de, this message translates to:
  /// **'Archiv'**
  String get archiv;

  /// No description provided for @endlos.
  ///
  /// In de, this message translates to:
  /// **'Endlos spielen'**
  String get endlos;

  /// No description provided for @archivLeer.
  ///
  /// In de, this message translates to:
  /// **'Ab morgen findest du hier die Rätsel der vergangenen Tage.'**
  String get archivLeer;

  /// No description provided for @stufeWaehlen.
  ///
  /// In de, this message translates to:
  /// **'Schwierigkeit'**
  String get stufeWaehlen;

  /// No description provided for @leicht.
  ///
  /// In de, this message translates to:
  /// **'Leicht'**
  String get leicht;

  /// No description provided for @mittel.
  ///
  /// In de, this message translates to:
  /// **'Mittel'**
  String get mittel;

  /// No description provided for @schwer.
  ///
  /// In de, this message translates to:
  /// **'Schwer'**
  String get schwer;

  /// No description provided for @serieTage.
  ///
  /// In de, this message translates to:
  /// **'{anzahl, plural, =0{Starte heute deine Serie 🌱} =1{🔥 1 Tag am Stück} other{🔥 {anzahl} Tage am Stück}}'**
  String serieTage(int anzahl);

  /// No description provided for @zuKurz.
  ///
  /// In de, this message translates to:
  /// **'Zu wenige Buchstaben'**
  String get zuKurz;

  /// No description provided for @keinWort.
  ///
  /// In de, this message translates to:
  /// **'Kenne ich nicht als Wort'**
  String get keinWort;

  /// No description provided for @wortGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Du hast das Wort in {anzahl} Versuchen gefunden.'**
  String wortGeschafft(int anzahl);

  /// No description provided for @wortWar.
  ///
  /// In de, this message translates to:
  /// **'Das Wort war: {wort}'**
  String wortWar(String wort);

  /// No description provided for @tippText.
  ///
  /// In de, this message translates to:
  /// **'Tipp – Stelle {tipps}'**
  String tippText(String tipps);

  /// No description provided for @videoNichtVerfuegbar.
  ///
  /// In de, this message translates to:
  /// **'Gerade ist kein Video verfügbar. Versuch es später nochmal.'**
  String get videoNichtVerfuegbar;

  /// No description provided for @notizen.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notizen;

  /// No description provided for @sudokuGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Sudoku {stufe} gelöst in {zeit}.'**
  String sudokuGeschafft(String stufe, String zeit);

  /// No description provided for @schiebeGeschafft.
  ///
  /// In de, this message translates to:
  /// **'Gelöst in {zuege} Zügen und {zeit}.'**
  String schiebeGeschafft(int zuege, String zeit);

  /// No description provided for @zuege.
  ///
  /// In de, this message translates to:
  /// **'Züge'**
  String get zuege;

  /// No description provided for @zuegeKurz.
  ///
  /// In de, this message translates to:
  /// **'Züge'**
  String get zuegeKurz;

  /// No description provided for @schiebeHilfe.
  ///
  /// In de, this message translates to:
  /// **'Tippe auf ein Feld in der Reihe oder Spalte der Lücke – es rutscht hinein.'**
  String get schiebeHilfe;

  /// No description provided for @aktuelleSerie.
  ///
  /// In de, this message translates to:
  /// **'Serie'**
  String get aktuelleSerie;

  /// No description provided for @laengsteSerie.
  ///
  /// In de, this message translates to:
  /// **'Längste Serie'**
  String get laengsteSerie;

  /// No description provided for @tageGespielt.
  ///
  /// In de, this message translates to:
  /// **'Tage gelöst'**
  String get tageGespielt;

  /// No description provided for @gespielt.
  ///
  /// In de, this message translates to:
  /// **'Gespielt'**
  String get gespielt;

  /// No description provided for @gewonnen.
  ///
  /// In de, this message translates to:
  /// **'Gewonnen'**
  String get gewonnen;

  /// No description provided for @versucheVerteilung.
  ///
  /// In de, this message translates to:
  /// **'Versuche bis zur Lösung'**
  String get versucheVerteilung;

  /// No description provided for @bestzeit.
  ///
  /// In de, this message translates to:
  /// **'Bestzeit {zeit}'**
  String bestzeit(String zeit);

  /// No description provided for @geloestAnzahl.
  ///
  /// In de, this message translates to:
  /// **'Gelöst'**
  String get geloestAnzahl;

  /// No description provided for @wenigsteZuege.
  ///
  /// In de, this message translates to:
  /// **'Wenigste Züge'**
  String get wenigsteZuege;

  /// No description provided for @proTitel.
  ///
  /// In de, this message translates to:
  /// **'Rätseltag Pro'**
  String get proTitel;

  /// No description provided for @proKurz.
  ///
  /// In de, this message translates to:
  /// **'Archiv, Endlos-Modus, Tipps ohne Video, werbefrei'**
  String get proKurz;

  /// No description provided for @proArchiv.
  ///
  /// In de, this message translates to:
  /// **'Alle vergangenen Rätsel im Archiv'**
  String get proArchiv;

  /// No description provided for @proEndlos.
  ///
  /// In de, this message translates to:
  /// **'Endlos neue Rätsel'**
  String get proEndlos;

  /// No description provided for @proWerbefrei.
  ///
  /// In de, this message translates to:
  /// **'Keine Werbung, Tipps ohne Video'**
  String get proWerbefrei;

  /// No description provided for @proUnterstuetzen.
  ///
  /// In de, this message translates to:
  /// **'Du unterstützt die Weiterentwicklung'**
  String get proUnterstuetzen;

  /// No description provided for @werbeEinwilligung.
  ///
  /// In de, this message translates to:
  /// **'Einwilligung für Werbung ändern'**
  String get werbeEinwilligung;

  /// No description provided for @statistikLoeschen.
  ///
  /// In de, this message translates to:
  /// **'Statistik löschen'**
  String get statistikLoeschen;

  /// No description provided for @statistikLoeschenText.
  ///
  /// In de, this message translates to:
  /// **'Alle Ergebnisse und deine Serie werden gelöscht.'**
  String get statistikLoeschenText;
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
