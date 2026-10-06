/// Einfache Syntax-Hervorhebung für Java, Python, Dart, JavaScript.
/// Zerlegt Code in Stücke mit einer [TokenArt]; die Farben wählt die
/// Oberfläche.
enum TokenArt { text, schluesselwort, string, zahl, kommentar, typ, funktion }

class Token {
  const Token(this.text, this.art);
  final String text;
  final TokenArt art;

  @override
  String toString() => '${art.name}:$text';
}

const _schluesselwoerter = <String, Set<String>>{
  'java': {
    'abstract',
    'boolean',
    'break',
    'byte',
    'case',
    'catch',
    'char',
    'class',
    'continue',
    'default',
    'do',
    'double',
    'else',
    'enum',
    'extends',
    'final',
    'finally',
    'float',
    'for',
    'if',
    'implements',
    'import',
    'instanceof',
    'int',
    'interface',
    'long',
    'new',
    'null',
    'package',
    'private',
    'protected',
    'public',
    'record',
    'return',
    'short',
    'static',
    'super',
    'switch',
    'this',
    'throw',
    'throws',
    'true',
    'false',
    'try',
    'var',
    'void',
    'while',
    'yield',
  },
  'python': {
    'and',
    'as',
    'assert',
    'async',
    'await',
    'break',
    'class',
    'continue',
    'def',
    'del',
    'elif',
    'else',
    'except',
    'False',
    'finally',
    'for',
    'from',
    'global',
    'if',
    'import',
    'in',
    'is',
    'lambda',
    'None',
    'nonlocal',
    'not',
    'or',
    'pass',
    'raise',
    'return',
    'True',
    'try',
    'while',
    'with',
    'yield',
  },
  'dart': {
    'abstract',
    'as',
    'async',
    'await',
    'bool',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'double',
    'dynamic',
    'else',
    'enum',
    'extends',
    'extension',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'implements',
    'import',
    'in',
    'int',
    'is',
    'late',
    'mixin',
    'new',
    'null',
    'num',
    'required',
    'return',
    'sealed',
    'static',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
    'yield',
  },
  'javascript': {
    'async',
    'await',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'delete',
    'do',
    'else',
    'export',
    'extends',
    'false',
    'finally',
    'for',
    'function',
    'if',
    'import',
    'in',
    'instanceof',
    'let',
    'new',
    'null',
    'of',
    'return',
    'static',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'typeof',
    'undefined',
    'var',
    'void',
    'while',
    'yield',
  },
};

final _muster = RegExp(
  r'(?<kommentar>//[^\n]*|#[^\n]*|/\*[\s\S]*?\*/)'
  r'|(?<string>"""[\s\S]*?"""|'
  "'''"
  r"[\s\S]*?'''"
  r'|"(?:\\.|[^"\\\n])*"|'
  r"'(?:\\.|[^'\\\n])*'"
  r'|`(?:\\.|[^`\\])*`)'
  r'|(?<zahl>\b\d+(?:\.\d+)?[fFdDlL]?\b)'
  r'|(?<wort>[A-Za-z_$][A-Za-z0-9_$]*)'
  r'|(?<rest>[\s\S])',
);

List<Token> zerlegen(String code, String sprache) {
  final woerter = _schluesselwoerter[sprache] ?? const <String>{};
  final ergebnis = <Token>[];
  void hinzu(String text, TokenArt art) {
    // Gleiche Arten zusammenfassen (weniger TextSpans).
    if (ergebnis.isNotEmpty && ergebnis.last.art == art) {
      ergebnis.last = Token(ergebnis.last.text + text, art);
    } else {
      ergebnis.add(Token(text, art));
    }
  }

  for (final m in _muster.allMatches(code)) {
    final kommentar = m.namedGroup('kommentar');
    if (kommentar != null) {
      // „#“ ist nur in Python ein Kommentar.
      if (kommentar.startsWith('#') && sprache != 'python') {
        hinzu('#', TokenArt.text);
        ergebnis.addAll(zerlegen(kommentar.substring(1), sprache));
        continue;
      }
      // „//“ ist in Python Ganzzahl-Division.
      if (kommentar.startsWith('//') && sprache == 'python') {
        hinzu('//', TokenArt.text);
        ergebnis.addAll(zerlegen(kommentar.substring(2), sprache));
        continue;
      }
      hinzu(kommentar, TokenArt.kommentar);
    } else if (m.namedGroup('string') case final s?) {
      hinzu(s, TokenArt.string);
    } else if (m.namedGroup('zahl') case final z?) {
      hinzu(z, TokenArt.zahl);
    } else if (m.namedGroup('wort') case final w?) {
      final danach = m.end < code.length ? code[m.end] : '';
      if (woerter.contains(w)) {
        hinzu(w, TokenArt.schluesselwort);
      } else if (danach == '(') {
        hinzu(w, TokenArt.funktion);
      } else if (w[0].toUpperCase() == w[0] && w[0] != '_' && w[0] != r'$') {
        hinzu(w, TokenArt.typ);
      } else {
        hinzu(w, TokenArt.text);
      }
    } else {
      hinzu(m.group(0)!, TokenArt.text);
    }
  }
  return ergebnis;
}
