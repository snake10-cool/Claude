// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'basis_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class BasisLocalizationsDe extends BasisLocalizations {
  BasisLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get mehrApps => 'Mehr Apps von mir';

  @override
  String get mehrAppsBaldMehr =>
      'Bald gibt es hier weitere Apps. Schau später wieder vorbei!';

  @override
  String get design => 'Design';

  @override
  String get designHell => 'Hell';

  @override
  String get designDunkel => 'Dunkel';

  @override
  String get designSystem => 'Wie das System';

  @override
  String get appBewerten => 'App bewerten';

  @override
  String get appBewertenText => 'Hilft mir sehr, danke!';

  @override
  String get kontakt => 'Kontakt & Feedback';

  @override
  String get datenschutz => 'Datenschutz';

  @override
  String ueberApp(String name) {
    return 'Über $name';
  }

  @override
  String version(String nummer) {
    return 'Version $nummer';
  }
}
