import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Kurzform: `context.l.verkaufen` statt `AppLocalizations.of(context)...`.
extension TexteKurz on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}
