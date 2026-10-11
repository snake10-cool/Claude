import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Fragt Google Play nach einer neuen Version und lädt sie im Hintergrund.
/// Ist sie fertig, kommt unten ein Hinweis mit „Jetzt neu starten“.
/// Außerhalb von Play (z. B. Test-APK) passiert einfach nichts.
Future<void> updatePruefen(ScaffoldMessengerState messenger) async {
  if (kIsWeb || kDebugMode || defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  try {
    final info = await InAppUpdate.checkForUpdate();
    if (info.installStatus == InstallStatus.downloaded) {
      _fertig(messenger);
      return;
    }
    if (info.updateAvailability != UpdateAvailability.updateAvailable ||
        !info.flexibleUpdateAllowed) {
      return;
    }
    final ergebnis = await InAppUpdate.startFlexibleUpdate();
    if (ergebnis == AppUpdateResult.success) _fertig(messenger);
  } catch (e) {
    debugPrint('Update: $e');
  }
}

void _fertig(ScaffoldMessengerState messenger) {
  messenger.showSnackBar(SnackBar(
    duration: const Duration(days: 1),
    content: const Text('Neue Version von Austro Angler ist bereit 🎣'),
    action: SnackBarAction(
      label: 'Neu starten',
      onPressed: () => InAppUpdate.completeFlexibleUpdate()
          .catchError((Object e) => debugPrint('Update: $e')),
    ),
  ));
}
