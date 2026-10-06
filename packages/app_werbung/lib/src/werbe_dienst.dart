import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'takt.dart';

/// Anzeigen-IDs einer App. Solange [nurTest] gilt, werden immer die
/// offiziellen Test-IDs von Google verwendet.
class WerbeIds {
  const WerbeIds({
    this.banner,
    this.belohnung,
    this.zwischen,
    this.nurTest = true,
  });

  final String? banner;
  final String? belohnung;
  final String? zwischen;

  /// Erst nach dem Play-Store-Start und mit echten IDs auf `false` setzen.
  final bool nurTest;

  // Offizielle Test-IDs von Google für Android.
  static const testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const testBelohnung = 'ca-app-pub-3940256099942544/5224354917';
  static const testZwischen = 'ca-app-pub-3940256099942544/1033173712';

  String get bannerId => nurTest || banner == null ? testBanner : banner!;
  String get belohnungId =>
      nurTest || belohnung == null ? testBelohnung : belohnung!;
  String get zwischenId => nurTest || zwischen == null ? testZwischen : zwischen!;
}

/// Startet AdMob nach der Einwilligung und zeigt Belohnungs- und
/// Zwischenwerbung.
class WerbeDienst extends ChangeNotifier {
  WerbeDienst({required this.ids, ZwischenwerbungsTakt? takt})
      : takt = takt ?? ZwischenwerbungsTakt();

  final WerbeIds ids;
  final ZwischenwerbungsTakt takt;

  /// Werbung abgeschaltet (z. B. „Werbefrei“ gekauft). Die App setzt das.
  bool _aus = false;
  bool get aus => _aus;
  set aus(bool wert) {
    if (_aus == wert) return;
    _aus = wert;
    notifyListeners();
  }

  bool _bereit = false;

  /// AdMob ist gestartet und darf Anzeigen laden.
  bool get bereit => _bereit && !_aus;

  static bool get plattformMitWerbung =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Einwilligung einholen (nur in EU/UK nötig, Google entscheidet) und
  /// AdMob starten. Fehler werden geschluckt – ohne Werbung läuft die App
  /// trotzdem.
  Future<void> starten() async {
    if (!plattformMitWerbung || _bereit) return;
    try {
      final fertig = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () async {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
          if (!fertig.isCompleted) fertig.complete();
        },
        (_) {
          if (!fertig.isCompleted) fertig.complete();
        },
      );
      await fertig.future;
      if (!await ConsentInformation.instance.canRequestAds()) return;
      await MobileAds.instance.initialize();
      _bereit = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Werbung nicht gestartet: $e');
    }
  }

  /// Muss in den Einstellungen angeboten werden, wenn Google es verlangt.
  Future<bool> datenschutzOptionenNoetig() async {
    if (!plattformMitWerbung) return false;
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  Future<void> datenschutzOptionenZeigen() async {
    if (!plattformMitWerbung) return;
    await ConsentForm.showPrivacyOptionsForm((_) {});
  }

  /// Freiwilliges Belohnungs-Video. `true`, wenn der Nutzer es bis zur
  /// Belohnung angesehen hat.
  Future<bool> belohnungZeigen() async {
    if (!plattformMitWerbung) return false;
    if (!_bereit) await starten();
    if (!_bereit) return false;
    final geladen = Completer<RewardedAd?>();
    await RewardedAd.load(
      adUnitId: ids.belohnungId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: geladen.complete,
        onAdFailedToLoad: (_) => geladen.complete(null),
      ),
    );
    final anzeige = await geladen.future;
    if (anzeige == null) return false;
    var belohnt = false;
    final zu = Completer<void>();
    anzeige.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) {
        a.dispose();
        if (!zu.isCompleted) zu.complete();
      },
      onAdFailedToShowFullScreenContent: (a, _) {
        a.dispose();
        if (!zu.isCompleted) zu.complete();
      },
    );
    await anzeige.show(onUserEarnedReward: (_, _) => belohnt = true);
    await zu.future;
    return belohnt;
  }

  /// Zwischenwerbung nach einer abgeschlossenen Aktion. Zeigt nur etwas,
  /// wenn der [takt] es erlaubt.
  Future<void> zwischenwerbung() async {
    if (!bereit) return;
    if (!takt.gelegenheit(DateTime.now())) return;
    final geladen = Completer<InterstitialAd?>();
    await InterstitialAd.load(
      adUnitId: ids.zwischenId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: geladen.complete,
        onAdFailedToLoad: (_) => geladen.complete(null),
      ),
    );
    final anzeige = await geladen.future;
    if (anzeige == null) return;
    anzeige.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (a) => a.dispose(),
      onAdFailedToShowFullScreenContent: (a, _) => a.dispose(),
    );
    await anzeige.show();
  }
}
