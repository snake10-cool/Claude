import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'basis_localizations_de.dart';
import 'basis_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of BasisLocalizations
/// returned by `BasisLocalizations.of(context)`.
///
/// Applications need to include `BasisLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/basis_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: BasisLocalizations.localizationsDelegates,
///   supportedLocales: BasisLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the BasisLocalizations.supportedLocales
/// property.
abstract class BasisLocalizations {
  BasisLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static BasisLocalizations of(BuildContext context) {
    return Localizations.of<BasisLocalizations>(context, BasisLocalizations)!;
  }

  static const LocalizationsDelegate<BasisLocalizations> delegate =
      _BasisLocalizationsDelegate();

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @mehrApps.
  ///
  /// In de, this message translates to:
  /// **'Mehr Apps von mir'**
  String get mehrApps;

  /// No description provided for @mehrAppsBaldMehr.
  ///
  /// In de, this message translates to:
  /// **'Bald gibt es hier weitere Apps. Schau später wieder vorbei!'**
  String get mehrAppsBaldMehr;

  /// No description provided for @design.
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get design;

  /// No description provided for @designHell.
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get designHell;

  /// No description provided for @designDunkel.
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get designDunkel;

  /// No description provided for @designSystem.
  ///
  /// In de, this message translates to:
  /// **'Wie das System'**
  String get designSystem;

  /// No description provided for @appBewerten.
  ///
  /// In de, this message translates to:
  /// **'App bewerten'**
  String get appBewerten;

  /// No description provided for @appBewertenText.
  ///
  /// In de, this message translates to:
  /// **'Hilft mir sehr, danke!'**
  String get appBewertenText;

  /// No description provided for @kontakt.
  ///
  /// In de, this message translates to:
  /// **'Kontakt & Feedback'**
  String get kontakt;

  /// No description provided for @datenschutz.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get datenschutz;

  /// No description provided for @ueberApp.
  ///
  /// In de, this message translates to:
  /// **'Über {name}'**
  String ueberApp(String name);

  /// No description provided for @version.
  ///
  /// In de, this message translates to:
  /// **'Version {nummer}'**
  String version(String nummer);

  /// No description provided for @abbrechen.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get abbrechen;

  /// No description provided for @loeschen.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get loeschen;
}

class _BasisLocalizationsDelegate
    extends LocalizationsDelegate<BasisLocalizations> {
  const _BasisLocalizationsDelegate();

  @override
  Future<BasisLocalizations> load(Locale locale) {
    return SynchronousFuture<BasisLocalizations>(
      lookupBasisLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_BasisLocalizationsDelegate old) => false;
}

BasisLocalizations lookupBasisLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return BasisLocalizationsDe();
    case 'en':
      return BasisLocalizationsEn();
  }

  throw FlutterError(
    'BasisLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
