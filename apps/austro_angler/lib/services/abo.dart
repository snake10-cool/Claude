import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// Bis zum Play-Store-Start sind alle ⭐-Funktionen für alle frei.
/// Zum Start auf `true` setzen – dann braucht man Premium (Abo oder Gewinn).
const premiumPflicht = false;

/// Produkt-IDs, wie sie in der Play Console angelegt werden müssen.
const aboMonat = 'premium_monat';
const aboJahr = 'premium_jahr';
const _produktIds = {aboMonat, aboJahr};

/// Google-Play-Abo. Der Kauf wird lokal gemerkt; beim Start stellt Google
/// Play aktive Abos wieder her.
class AboDienst extends ChangeNotifier {
  AboDienst._();

  static final instanz = AboDienst._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _abo;

  bool verfuegbar = false;
  bool aktiv = false;
  bool laedt = false;
  String? fehler;
  List<ProductDetails> produkte = const [];

  static bool get unterstuetzt =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<void> starten() async {
    if (!unterstuetzt || _abo != null) return;
    try {
      verfuegbar = await _iap.isAvailable();
      if (!verfuegbar) return;
      _abo = _iap.purchaseStream.listen(_kaeufe, onError: (Object e) {
        fehler = '$e';
        notifyListeners();
      });
      final antwort = await _iap.queryProductDetails(_produktIds);
      produkte = antwort.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      await _iap.restorePurchases();
    } catch (e) {
      fehler = '$e';
    }
    notifyListeners();
  }

  Future<void> _kaeufe(List<PurchaseDetails> liste) async {
    for (final k in liste) {
      if (!_produktIds.contains(k.productID)) continue;
      switch (k.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          aktiv = true;
          fehler = null;
        case PurchaseStatus.error:
          fehler = k.error?.message ?? 'Kauf fehlgeschlagen';
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }
      if (k.pendingCompletePurchase) await _iap.completePurchase(k);
    }
    laedt = false;
    notifyListeners();
  }

  Future<void> kaufen(ProductDetails p) async {
    laedt = true;
    fehler = null;
    notifyListeners();
    try {
      await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: p));
    } catch (e) {
      laedt = false;
      fehler = '$e';
      notifyListeners();
    }
  }

  Future<void> wiederherstellen() async {
    if (!verfuegbar) return;
    await _iap.restorePurchases();
  }
}

final aboDienst = AboDienst.instanz;
