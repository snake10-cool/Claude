/// Entscheidet, ob eine Zwischenwerbung gezeigt werden darf. Reine Logik,
/// damit sie testbar ist.
class ZwischenwerbungsTakt {
  ZwischenwerbungsTakt({
    this.mindestAbstand = const Duration(minutes: 3),
    this.jedeNte = 2,
  });

  /// So lange nach der letzten Zwischenwerbung keine neue.
  final Duration mindestAbstand;

  /// Nur bei jeder n-ten Gelegenheit (z. B. jedes 2. gelöste Rätsel).
  final int jedeNte;

  DateTime? _zuletzt;
  int _gelegenheiten = 0;

  /// Eine Gelegenheit (z. B. Rätsel fertig). Gibt `true` zurück, wenn jetzt
  /// Werbung gezeigt werden darf, und merkt sich das.
  bool gelegenheit(DateTime jetzt) {
    _gelegenheiten++;
    if (_gelegenheiten % jedeNte != 0) return false;
    final z = _zuletzt;
    if (z != null && jetzt.difference(z) < mindestAbstand) return false;
    _zuletzt = jetzt;
    return true;
  }
}
