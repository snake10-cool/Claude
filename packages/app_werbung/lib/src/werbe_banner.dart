import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'werbe_dienst.dart';

/// Banner für unten auf Übersichtsseiten. Zeigt nichts, solange keine
/// Werbung geladen ist oder Werbung aus ist – kein leerer Platzhalter.
class WerbeBanner extends StatefulWidget {
  const WerbeBanner({super.key, required this.dienst});
  final WerbeDienst dienst;

  @override
  State<WerbeBanner> createState() => _WerbeBannerState();
}

class _WerbeBannerState extends State<WerbeBanner> {
  BannerAd? _banner;
  bool _geladen = false;

  @override
  void initState() {
    super.initState();
    widget.dienst.addListener(_pruefen);
    _pruefen();
  }

  void _pruefen() {
    if (!mounted) return;
    if (!widget.dienst.bereit) {
      if (_banner != null) {
        _banner!.dispose();
        setState(() {
          _banner = null;
          _geladen = false;
        });
      }
      return;
    }
    if (_banner != null) return;
    _banner = BannerAd(
      adUnitId: widget.dienst.ids.bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _geladen = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _banner = null);
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    widget.dienst.removeListener(_pruefen);
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _banner;
    if (b == null || !_geladen) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: b.size.width.toDouble(),
        height: b.size.height.toDouble(),
        child: AdWidget(ad: b),
      ),
    );
  }
}
