// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'kauf_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class KaufLocalizationsEn extends KaufLocalizations {
  KaufLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get proHolen => 'Get Pro';

  @override
  String get proAktiv => 'Pro is active. Thank you!';

  @override
  String get allesFreiTestphase =>
      'During the test phase all Pro features are unlocked for free.';

  @override
  String get nurImPlayStore =>
      'Pro can only be bought in the Android app via Google Play.';

  @override
  String get keineProdukte =>
      'Offers could not be loaded. Please try again later.';

  @override
  String get storeFehlt => 'Google Play is currently not available.';

  @override
  String get aboKuendbar =>
      'Subscriptions renew automatically and can be cancelled anytime in Google Play.';

  @override
  String get wiederherstellen => 'Restore purchases';
}
