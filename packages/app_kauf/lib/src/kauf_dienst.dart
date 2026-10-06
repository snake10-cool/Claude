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
  KaufDienst({
    required this.proIds,
    this.einzelIds = const {},
    required this.kaufPflicht,
  });

  /// Produkt-IDs aus der Play Console, die Pro (alles) freischalten.
  final Set<String> proIds;

  /// Einzelne Einmalkäufe, z. B. ein Kartenpaket oder „Werbefrei“.
  final Set<String> einzelIds;

  Set<String> get _alleIds => {...proIds, ...einzelIds};

  /// `false` = alles frei (Entwicklung, geschlossener Test vor dem Start).
  final bool kaufPflicht;

  static const _speicher = 'kauf_besitz';

  // Erst bei Bedarf holen: InAppPurchase.instance verbindet sich sofort mit
  // Google Play (und gibt es auf Windows gar nicht).
  InAppPurchase get _iap => InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _kaeufe;

  /// Alle gekauften Produkt-IDs (lokal gemerkt).
  Set<String> _besitz = {};
  bool verfuegbar = false;
  bool laedt = false;
  String? fehler;
  List<ProductDetails> produkte = const [];

  static bool get plattformMitKauf =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get istPro => proFreigeschaltet(
    kaufPflicht: kaufPflicht,
    plattformMitKauf: plattformMitKauf,
    gekauft: gekauft,
  );

  /// Wurde Pro wirklich gekauft (nicht nur „alles frei“)?
  bool get gekauft => _besitz.any(proIds.contains);

  /// Ist dieses Einzelprodukt freigeschaltet (gekauft, Pro, oder alles frei)?
  bool hat(String produktId) =>
      istPro ||
      proFreigeschaltet(
        kaufPflicht: kaufPflicht,
        plattformMitKauf: plattformMitKauf,
        gekauft: _besitz.contains(produktId),
      );

  /// Wurde dieses Produkt wirklich gekauft?
  bool besitzt(String produktId) => _besitz.contains(produktId);

  /// Preis eines Produkts aus Google Play, z. B. „2,99 €“.
  ProductDetails? produkt(String id) =>
      produkte.where((p) => p.id == id).firstOrNull;

  Future<void> starten() async {
    final prefs = await SharedPreferences.getInstance();
    _besitz = (prefs.getStringList(_speicher) ?? const []).toSet();
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
      final antwort = await _iap.queryProductDetails(_alleIds);
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
    final android = _iap
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final antwort = await android.queryPastPurchases();
    if (antwort.error != null) return; // Lieber alten Stand behalten.
    await _speichern({
      for (final k in antwort.pastPurchases)
        if (_alleIds.contains(k.productID) &&
            k.status == PurchaseStatus.purchased)
          k.productID,
    });
  }

  Future<void> _speichern(Set<String> besitz) async {
    _besitz = besitz;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_speicher, besitz.toList());
  }

  Future<void> _kaeufeVerarbeiten(List<PurchaseDetails> liste) async {
    for (final k in liste) {
      if (!_alleIds.contains(k.productID)) continue;
      switch (k.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _speichern({..._besitz, k.productID});
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
