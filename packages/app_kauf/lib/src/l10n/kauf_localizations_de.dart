// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'kauf_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class KaufLocalizationsDe extends KaufLocalizations {
  KaufLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get proHolen => 'Hol dir Pro';

  @override
  String get proAktiv => 'Pro ist aktiv. Danke!';

  @override
  String get allesFreiTestphase =>
      'In der Testphase sind alle Pro-Funktionen gratis freigeschaltet.';

  @override
  String get nurImPlayStore =>
      'Pro kann nur in der Android-App über Google Play gekauft werden.';

  @override
  String get keineProdukte =>
      'Die Angebote konnten nicht geladen werden. Bitte später nochmal probieren.';

  @override
  String get storeFehlt => 'Google Play ist gerade nicht erreichbar.';

  @override
  String get aboKuendbar =>
      'Abos verlängern sich automatisch und sind jederzeit in Google Play kündbar.';

  @override
  String get wiederherstellen => 'Käufe wiederherstellen';
}
