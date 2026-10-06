import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reine Entscheidung „Ist Pro freigeschaltet?“, getrennt vom Play Store,
/// damit sie sich testen lässt.
bool proFreigeschaltet({
  required bool kaufPflicht,
  required bool plattformMitKauf,
  required bool gekauft,
}) {
  // Vor dem Start oder auf Plattformen ohne Play Store (z. B. Windows) gibt
  // es nichts zu kaufen – dann ist alles frei.
  if (!kaufPflicht || !plattformMitKauf) return true;
  return gekauft;
}

/// Verwaltet die Käufe einer App über Google Play.
///
/// Abos und Einmalkäufe für „Pro“ werden gleich behandelt: Wer irgendeines
/// der [proIds] besitzt, hat Pro. Der Status wird lokal gespeichert, damit
/// die App auch ohne Internet weiß, dass Pro gekauft ist.
class KaufDienst extends ChangeNotifier {
  KaufDienst({required this.proIds, required this.kaufPflicht});

  /// Produkt-IDs aus der Play Console, die Pro freischalten.
  final Set<String> proIds;

  /// `false` = alles frei (Entwicklung, geschlossener Test vor dem Start).
  final bool kaufPflicht;

  static const _speicher = 'kauf_pro_gekauft';

  // Erst bei Bedarf holen: InAppPurchase.instance verbindet sich sofort mit
  // Google Play (und gibt es auf Windows gar nicht).
  InAppPurchase get _iap => InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _kaeufe;

  bool _gekauft = false;
  bool verfuegbar = false;
  bool laedt = false;
  String? fehler;
  List<ProductDetails> produkte = const [];

  static bool get plattformMitKauf =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get istPro => proFreigeschaltet(
        kaufPflicht: kaufPflicht,
        plattformMitKauf: plattformMitKauf,
        gekauft: _gekauft,
      );

  /// Wurde Pro wirklich gekauft (nicht nur „alles frei“)?
  bool get gekauft => _gekauft;

  Future<void> starten() async {
    final prefs = await SharedPreferences.getInstance();
    _gekauft = prefs.getBool(_speicher) ?? false;
    notifyListeners();
    if (!plattformMitKauf || _kaeufe != null) return;
    try {
      verfuegbar = await _iap.isAvailable();
      if (!verfuegbar) return;
      _kaeufe = _iap.purchaseStream.listen(
        _kaeufeVerarbeiten,
        onError: (Object e) {
          fehler = '$e';
          notifyListeners();
        },
      );
      final antwort = await _iap.queryProductDetails(proIds);
      produkte = [...antwort.productDetails]
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      await _bestandPruefen();
    } catch (e) {
      fehler = '$e';
    }
    notifyListeners();
  }

  /// Fragt Google Play, was der Nutzer gerade besitzt. Abgelaufene Abos
  /// tauchen hier nicht mehr auf – dann wird Pro wieder gesperrt.
  Future<void> _bestandPruefen() async {
    final android =
        _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final antwort = await android.queryPastPurchases();
    if (antwort.error != null) return; // Lieber alten Stand behalten.
    final besitzt = antwort.pastPurchases.any((k) =>
        proIds.contains(k.productID) &&
        k.status == PurchaseStatus.purchased);
    await _speichern(besitzt);
  }

  Future<void> _speichern(bool gekauft) async {
    _gekauft = gekauft;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_speicher, gekauft);
  }

  Future<void> _kaeufeVerarbeiten(List<PurchaseDetails> liste) async {
    for (final k in liste) {
      if (!proIds.contains(k.productID)) continue;
      switch (k.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _speichern(true);
          fehler = null;
        case PurchaseStatus.error:
          fehler = k.error?.message ?? 'Kauf fehlgeschlagen';
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }
      // Ohne Bestätigung erstattet Google den Kauf nach 3 Tagen zurück.
      if (k.pendingCompletePurchase) await _iap.completePurchase(k);
    }
    laedt = false;
    notifyListeners();
  }

  Future<void> kaufen(ProductDetails produkt) async {
    laedt = true;
    fehler = null;
    notifyListeners();
    try {
      // Abos werden in in_app_purchase ebenfalls als „non consumable“ gekauft.
      await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: produkt),
      );
    } catch (e) {
      laedt = false;
      fehler = '$e';
      notifyListeners();
    }
  }

  Future<void> wiederherstellen() async {
    if (!verfuegbar) return;
    await _iap.restorePurchases();
    await _bestandPruefen();
    notifyListeners();
  }

  @override
  void dispose() {
    _kaeufe?.cancel();
    super.dispose();
  }
}
