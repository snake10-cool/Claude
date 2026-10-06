import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Öffnet den Play-Store-Eintrag einer App. Auf dem Handy direkt in der
/// Play-Store-App, sonst im Browser.
Future<void> oeffneStoreEintrag(String paketId) async {
  final market = Uri.parse('market://details?id=$paketId');
  final web = Uri.parse('https://play.google.com/store/apps/details?id=$paketId');
  final istAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  if (istAndroid &&
      await launchUrl(market, mode: LaunchMode.externalApplication)
          .catchError((_) => false)) {
    return;
  }
  await launchUrl(web, mode: LaunchMode.externalApplication);
}

Future<void> oeffneEmail(String adresse, {String? betreff}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: adresse,
    query: betreff == null ? null : 'subject=${Uri.encodeComponent(betreff)}',
  );
  await launchUrl(uri);
}

Future<void> oeffneWebseite(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
