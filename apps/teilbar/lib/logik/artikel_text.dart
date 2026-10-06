/// Liest Eingaben wie „2 Milch“, „500g Mehl“, „Brot x3“ in Menge und Name.
(String menge, String name) artikelLesen(String eingabe) {
  final t = eingabe.trim().replaceAll(RegExp(r'\s+'), ' ');
  // „2 Milch“, „2x Milch“, „500 g Mehl“, „1,5 l Saft“
  final vorne = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*(x|stk\.?|stück|g|kg|ml|l|pkg\.?|packung(?:en)?|dose(?:n)?|flasche(?:n)?|bund)?\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(t);
  if (vorne != null) {
    final zahl = vorne.group(1)!;
    final einheit = vorne.group(2);
    final menge = switch (einheit?.toLowerCase()) {
      null || 'x' || 'stk' || 'stk.' || 'stück' => zahl,
      _ => '$zahl $einheit',
    };
    return (menge, _gross(vorne.group(3)!));
  }
  // „Milch x2“, „Milch 2x“
  final hinten = RegExp(
    r'^(.+?)\s+(?:x\s*(\d+)|(\d+)\s*x)$',
    caseSensitive: false,
  ).firstMatch(t);
  if (hinten != null) {
    return (hinten.group(2) ?? hinten.group(3)!, _gross(hinten.group(1)!));
  }
  return ('', _gross(t));
}

String _gross(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
