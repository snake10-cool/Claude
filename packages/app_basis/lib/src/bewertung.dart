import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wann darf die App nach einer Bewertung fragen? Reine Logik ohne Flutter,
/// damit sie sich testen lässt.
class BewertungsRegel {
  const BewertungsRegel({
    this.mindestNutzungstage = 4,
    this.mindestTageSeitInstallation = 5,
    this.abstandTage = 60,
    this.maxAnfragen = 2,
  });

  /// An so vielen verschiedenen Tagen muss die App geöffnet worden sein.
  final int mindestNutzungstage;
  final int mindestTageSeitInstallation;

  /// So lange wird nach einer Anfrage gewartet, bevor wieder gefragt wird.
  final int abstandTage;

  /// Danach wird nie wieder gefragt.
  final int maxAnfragen;

  bool sollteFragen({
    required DateTime installiert,
    required int nutzungstage,
    required int anfragen,
    required DateTime? zuletztGefragt,
    required DateTime jetzt,
  }) {
    if (anfragen >= maxAnfragen) return false;
    if (nutzungstage < mindestNutzungstage) return false;
    if (jetzt.difference(installiert).inDays < mindestTageSeitInstallation) {
      return false;
    }
    if (zuletztGefragt != null &&
        jetzt.difference(zuletztGefragt).inDays < abstandTage) {
      return false;
    }
    return true;
  }
}

/// Merkt sich, wie oft die App benutzt wurde, und zeigt zu einem ruhigen
/// Zeitpunkt den Bewertungsdialog von Google Play (kein eigenes Popup).
///
/// Ablauf in der App:
/// 1. Beim Start [appGestartet] aufrufen.
/// 2. Nach einer abgeschlossenen, erfolgreichen Aktion (nie mittendrin)
///    [vielleichtFragen] aufrufen.
class BewertungsBitte {
  BewertungsBitte._();

  static const _installiert = 'bewertung_installiert';
  static const _letzterTag = 'bewertung_letzter_tag';
  static const _tage = 'bewertung_tage';
  static const _anfragen = 'bewertung_anfragen';
  static const _zuletzt = 'bewertung_zuletzt';

  static Future<void> appGestartet() async {
    final prefs = await SharedPreferences.getInstance();
    final jetzt = DateTime.now();
    if (!prefs.containsKey(_installiert)) {
      await prefs.setString(_installiert, jetzt.toIso8601String());
    }
    final heute = '${jetzt.year}-${jetzt.month}-${jetzt.day}';
    if (prefs.getString(_letzterTag) != heute) {
      await prefs.setString(_letzterTag, heute);
      await prefs.setInt(_tage, (prefs.getInt(_tage) ?? 0) + 1);
    }
  }

  /// Gibt `true` zurück, wenn der Dialog angefordert wurde. Ob Google ihn
  /// wirklich zeigt, entscheidet Google Play selbst.
  static Future<bool> vielleichtFragen({
    BewertungsRegel regel = const BewertungsRegel(),
  }) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    final installiert =
        DateTime.tryParse(prefs.getString(_installiert) ?? '');
    if (installiert == null) return false;
    final zuletzt = DateTime.tryParse(prefs.getString(_zuletzt) ?? '');
    final anfragen = prefs.getInt(_anfragen) ?? 0;
    final jetzt = DateTime.now();
    final ok = regel.sollteFragen(
      installiert: installiert,
      nutzungstage: prefs.getInt(_tage) ?? 0,
      anfragen: anfragen,
      zuletztGefragt: zuletzt,
      jetzt: jetzt,
    );
    if (!ok) return false;
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return false;
    await prefs.setInt(_anfragen, anfragen + 1);
    await prefs.setString(_zuletzt, jetzt.toIso8601String());
    await review.requestReview();
    return true;
  }
}
