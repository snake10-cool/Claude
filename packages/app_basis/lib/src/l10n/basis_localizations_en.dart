// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'basis_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class BasisLocalizationsEn extends BasisLocalizations {
  BasisLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get mehrApps => 'More apps by me';

  @override
  String get mehrAppsBaldMehr => 'More apps are coming soon. Check back later!';

  @override
  String get design => 'Theme';

  @override
  String get designHell => 'Light';

  @override
  String get designDunkel => 'Dark';

  @override
  String get designSystem => 'System default';

  @override
  String get appBewerten => 'Rate this app';

  @override
  String get appBewertenText => 'It helps a lot, thank you!';

  @override
  String get kontakt => 'Contact & feedback';

  @override
  String get datenschutz => 'Privacy';

  @override
  String ueberApp(String name) {
    return 'About $name';
  }

  @override
  String version(String nummer) {
    return 'Version $nummer';
  }
}
