import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l.dart';
import '../logik/syntax.dart';

/// Farben für die Hervorhebung, je nach Hell/Dunkel.
Map<TokenArt, Color> _farben(bool dunkel) => dunkel
    ? const {
        TokenArt.text: Color(0xFFE6E1F0),
        TokenArt.schluesselwort: Color(0xFFC792EA),
        TokenArt.string: Color(0xFFC3E88D),
        TokenArt.zahl: Color(0xFFF78C6C),
        TokenArt.kommentar: Color(0xFF8A8FA3),
        TokenArt.typ: Color(0xFFFFCB6B),
        TokenArt.funktion: Color(0xFF82AAFF),
      }
    : const {
        TokenArt.text: Color(0xFF1F1B2E),
        TokenArt.schluesselwort: Color(0xFF7A1FA2),
        TokenArt.string: Color(0xFF2E7D32),
        TokenArt.zahl: Color(0xFFC2410C),
        TokenArt.kommentar: Color(0xFF6B7280),
        TokenArt.typ: Color(0xFF9A6700),
        TokenArt.funktion: Color(0xFF1D4ED8),
      };

TextSpan codeSpan(
  String code,
  String sprache, {
  required bool dunkel,
  double groesse = 14,
}) {
  final farben = _farben(dunkel);
  return TextSpan(
    style: TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: const ['Courier New', 'Courier'],
      fontSize: groesse,
      height: 1.4,
      color: farben[TokenArt.text],
    ),
    children: [
      for (final t in zerlegen(code, sprache))
        TextSpan(
          text: t.text,
          style: TextStyle(
            color: farben[t.art],
            fontStyle: t.art == TokenArt.kommentar ? FontStyle.italic : null,
            fontWeight: t.art == TokenArt.schluesselwort
                ? FontWeight.w600
                : null,
          ),
        ),
    ],
  );
}

/// Code-Block mit Hervorhebung, waagrecht scrollbar, optional mit
/// Kopieren-Knopf.
class CodeAnsicht extends StatelessWidget {
  const CodeAnsicht({
    super.key,
    required this.code,
    required this.sprache,
    this.kopierbar = true,
    this.groesse = 14,
    this.maxZeilen,
  });

  final String code;
  final String sprache;
  final bool kopierbar;
  final double groesse;
  final int? maxZeilen;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final dunkel = t.brightness == Brightness.dark;
    final hintergrund = dunkel
        ? const Color(0xFF1B1830)
        : const Color(0xFFF6F4FB);
    final text = maxZeilen == null
        ? code
        : code.split('\n').take(maxZeilen!).join('\n');
    return Container(
      decoration: BoxDecoration(
        color: hintergrund,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(14, 12, kopierbar ? 48 : 14, 12),
            child: SelectableText.rich(
              codeSpan(text, sprache, dunkel: dunkel, groesse: groesse),
            ),
          ),
          if (kopierbar)
            Positioned(
              top: 2,
              right: 2,
              child: IconButton(
                tooltip: context.l.kopieren,
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () => kopieren(context, code),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> kopieren(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l.kopiert),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
