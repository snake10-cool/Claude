import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'kauf_localizations_de.dart';
import 'kauf_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of KaufLocalizations
/// returned by `KaufLocalizations.of(context)`.
///
/// Applications need to include `KaufLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/kauf_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: KaufLocalizations.localizationsDelegates,
///   supportedLocales: KaufLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the KaufLocalizations.supportedLocales
/// property.
abstract class KaufLocalizations {
  KaufLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static KaufLocalizations of(BuildContext context) {
    return Localizations.of<KaufLocalizations>(context, KaufLocalizations)!;
  }

  static const LocalizationsDelegate<KaufLocalizations> delegate =
      _KaufLocalizationsDelegate();

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

  /// No description provided for @proHolen.
  ///
  /// In de, this message translates to:
  /// **'Hol dir Pro'**
  String get proHolen;

  /// No description provided for @proAktiv.
  ///
  /// In de, this message translates to:
  /// **'Pro ist aktiv. Danke!'**
  String get proAktiv;

  /// No description provided for @allesFreiTestphase.
  ///
  /// In de, this message translates to:
  /// **'In der Testphase sind alle Pro-Funktionen gratis freigeschaltet.'**
  String get allesFreiTestphase;

  /// No description provided for @nurImPlayStore.
  ///
  /// In de, this message translates to:
  /// **'Pro kann nur in der Android-App über Google Play gekauft werden.'**
  String get nurImPlayStore;

  /// No description provided for @keineProdukte.
  ///
  /// In de, this message translates to:
  /// **'Die Angebote konnten nicht geladen werden. Bitte später nochmal probieren.'**
  String get keineProdukte;

  /// No description provided for @storeFehlt.
  ///
  /// In de, this message translates to:
  /// **'Google Play ist gerade nicht erreichbar.'**
  String get storeFehlt;

  /// No description provided for @aboKuendbar.
  ///
  /// In de, this message translates to:
  /// **'Abos verlängern sich automatisch und sind jederzeit in Google Play kündbar.'**
  String get aboKuendbar;

  /// No description provided for @wiederherstellen.
  ///
  /// In de, this message translates to:
  /// **'Käufe wiederherstellen'**
  String get wiederherstellen;
}

class _KaufLocalizationsDelegate
    extends LocalizationsDelegate<KaufLocalizations> {
  const _KaufLocalizationsDelegate();

  @override
  Future<KaufLocalizations> load(Locale locale) {
    return SynchronousFuture<KaufLocalizations>(
      lookupKaufLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_KaufLocalizationsDelegate old) => false;
}

KaufLocalizations lookupKaufLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return KaufLocalizationsDe();
    case 'en':
      return KaufLocalizationsEn();
  }

  throw FlutterError(
    'KaufLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
