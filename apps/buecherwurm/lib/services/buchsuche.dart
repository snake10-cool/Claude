import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/katalog.dart';
import '../models/buch.dart';

/// Ein Treffer aus der Online-Suche.
class Treffer {
  const Treffer({
    required this.titel,
    required this.autor,
    this.jahr = 0,
    this.seiten = 0,
    this.coverUrl,
    this.isbn,
    this.beschreibung = '',
    this.tags = const {},
    this.zielgruppe = Zielgruppe.erwachsene,
  });

  final String titel;
  final String autor;
  final int jahr;
  final int seiten;
  final String? coverUrl;
  final String? isbn;
  final String beschreibung;
  final Set<String> tags;
  final Zielgruppe zielgruppe;

  /// Das passende Katalogbuch (mit Quiz), falls es eins gibt.
  Buch? get imKatalog {
    final t = _normal(titel);
    if (t.length < 3) return null;
    for (final b in katalog) {
      final k = _normal(b.titel);
      if (k == t || (t.length >= 6 && k.startsWith(t)) || (k.length >= 6 && t.startsWith(k))) {
        return b;
      }
    }
    return null;
  }
}

String _normal(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss')
    .replaceAll(RegExp(r'[^a-z0-9]'), '');

class SuchFehler implements Exception {
  const SuchFehler(this.text);
  final String text;
  @override
  String toString() => text;
}

/// Sucht Bücher bei Open Library (frei, ohne Schlüssel). Liefert das nichts,
/// wird Google Books gefragt.
class BuchSuche {
  BuchSuche([http.Client? client]) : _client = client ?? http.Client();

  final http.Client _client;
  static const _zeit = Duration(seconds: 12);

  Future<List<Treffer>> suchen(String text) async {
    final q = text.trim();
    if (q.isEmpty) return [];
    final isbn = isbnAus(q);
    if (isbn != null) {
      final t = await perIsbn(isbn);
      return t == null ? [] : [t];
    }
    return _mitReserve(
      () => _openLibrary({'q': q, 'lang': 'de'}),
      () => _googleBooks(q),
    );
  }

  Future<Treffer?> perIsbn(String isbn) async {
    final liste = await _mitReserve(
      () => _openLibrary({'isbn': isbn}),
      () => _googleBooks('isbn:$isbn'),
    );
    if (liste.isEmpty) return null;
    final t = liste.first;
    return Treffer(
      titel: t.titel,
      autor: t.autor,
      jahr: t.jahr,
      seiten: t.seiten,
      coverUrl: t.coverUrl,
      isbn: isbn,
      beschreibung: t.beschreibung,
      tags: t.tags,
      zielgruppe: t.zielgruppe,
    );
  }

  Future<List<Treffer>> _mitReserve(
    Future<List<Treffer>> Function() erst,
    Future<List<Treffer>> Function() dann,
  ) async {
    Object? fehler;
    try {
      final a = await erst();
      if (a.isNotEmpty) return a;
    } catch (e) {
      fehler = e;
    }
    try {
      return await dann();
    } catch (e) {
      // Beide Dienste nicht erreichbar: das ist ein echter Fehler. Hat nur
      // einer geantwortet (leer), gibt es eben keine Treffer.
      if (fehler != null) throw const SuchFehler('Keine Verbindung zur Bücher-Suche.');
      return [];
    }
  }

  Future<List<Treffer>> _openLibrary(Map<String, String> parameter) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      ...parameter,
      'fields': 'title,author_name,first_publish_year,number_of_pages_median,subject,cover_i,isbn',
      'limit': '25',
    });
    final antwort = await _client.get(uri).timeout(_zeit);
    if (antwort.statusCode != 200) throw SuchFehler('Open Library: ${antwort.statusCode}');
    return ausOpenLibrary(jsonDecode(utf8.decode(antwort.bodyBytes)) as Map<String, dynamic>);
  }

  Future<List<Treffer>> _googleBooks(String q) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': q,
      'maxResults': '25',
      'printType': 'books',
    });
    final antwort = await _client.get(uri).timeout(_zeit);
    if (antwort.statusCode != 200) throw SuchFehler('Google Books: ${antwort.statusCode}');
    return ausGoogleBooks(jsonDecode(utf8.decode(antwort.bodyBytes)) as Map<String, dynamic>);
  }
}

/// 10- oder 13-stellige ISBN aus einer Eingabe (Bindestriche erlaubt).
String? isbnAus(String text) {
  final ziffern = text.replaceAll(RegExp(r'[\s-]'), '');
  if (RegExp(r'^(97[89])?\d{9}[\dXx]$').hasMatch(ziffern)) return ziffern.toUpperCase();
  return null;
}

List<Treffer> ausOpenLibrary(Map<String, dynamic> json) => [
      for (final d in (json['docs'] as List? ?? const []).cast<Map<String, dynamic>>())
        if (d['title'] is String) _olTreffer(d),
    ];

Treffer _olTreffer(Map<String, dynamic> d) {
  final themen = (d['subject'] as List? ?? const []).cast<String>();
  final cover = d['cover_i'];
  return Treffer(
    titel: d['title'] as String,
    autor: _autoren(d['author_name']),
    jahr: d['first_publish_year'] as int? ?? 0,
    seiten: d['number_of_pages_median'] as int? ?? 0,
    coverUrl: cover is int ? 'https://covers.openlibrary.org/b/id/$cover-M.jpg' : null,
    isbn: (d['isbn'] as List?)?.cast<String>().firstOrNull,
    tags: tagsAus(themen),
    zielgruppe: zielgruppeAus(themen),
  );
}

List<Treffer> ausGoogleBooks(Map<String, dynamic> json) => [
      for (final item in (json['items'] as List? ?? const []).cast<Map<String, dynamic>>())
        if (item['volumeInfo'] case final Map<String, dynamic> v when v['title'] is String) _gbTreffer(v),
    ];

Treffer _gbTreffer(Map<String, dynamic> v) {
  final themen = (v['categories'] as List? ?? const []).cast<String>();
  final bild = (v['imageLinks'] as Map?)?['thumbnail'] as String?;
  final ids = (v['industryIdentifiers'] as List? ?? const []).cast<Map<String, dynamic>>();
  String? isbn(String typ) => ids.where((i) => i['type'] == typ).map((i) => i['identifier'] as String).firstOrNull;
  final beschreibung = v['description'] as String? ?? '';
  return Treffer(
    titel: v['title'] as String,
    autor: _autoren(v['authors']),
    jahr: int.tryParse((v['publishedDate'] as String? ?? '').split('-').first) ?? 0,
    seiten: v['pageCount'] as int? ?? 0,
    coverUrl: bild?.replaceFirst('http://', 'https://'),
    isbn: isbn('ISBN_13') ?? isbn('ISBN_10'),
    beschreibung: beschreibung.length > 400 ? '${beschreibung.substring(0, 400)}…' : beschreibung,
    tags: tagsAus([...themen, beschreibung]),
    zielgruppe: zielgruppeAus(themen),
  );
}

String _autoren(Object? liste) {
  final namen = (liste as List?)?.cast<String>() ?? const [];
  return namen.isEmpty ? 'Unbekannt' : namen.take(2).join(', ');
}

/// Schlüsselwörter (englisch und deutsch) für die Merkmale der Empfehlungen.
const _schluessel = <String, List<String>>{
  'fantasy': ['fantasy', 'magic', 'magie', 'zauber', 'wizard', 'dragon', 'drache', 'hexe', 'witch'],
  'scifi': ['science fiction', 'science-fiction', 'space', 'weltraum', 'robot', 'aliens', 'zeitreise', 'time travel'],
  'krimi': ['detective', 'mystery', 'krimi', 'kriminal', 'murder', 'mord', 'detektiv', 'crime'],
  'thriller': ['thriller', 'suspense'],
  'horror': ['horror', 'ghost', 'grusel', 'vampire', 'vampir', 'gespenst', 'zombie'],
  'liebe': ['love', 'romance', 'liebe', 'liebesroman'],
  'humor': ['humor', 'humour', 'humorous', 'funny', 'lustig', 'witzig', 'comedy'],
  'abenteuer': ['adventure', 'abenteuer', 'voyages'],
  'historisch': ['historical', 'history', 'geschichte', 'world war', 'weltkrieg', 'mittelalter', 'middle ages'],
  'sachbuch': ['nonfiction', 'non-fiction', 'sachbuch', 'biography', 'biografie', 'psychology', 'psychologie', 'business', 'health'],
  'dystopie': ['dystopia', 'dystopie', 'dystopian'],
  'drama': ['drama', 'family', 'familie', 'tragedy'],
  'jungeHelden': ['juvenile', 'children', 'kinder', 'jugend', 'young adult', 'teen', 'school', 'schule'],
  'tiere': ['animals', 'tiere', 'dogs', 'hunde', 'cats', 'katzen', 'horses', 'pferde'],
  'klassiker': ['classic', 'klassiker'],
  'selbsthilfe': ['self-help', 'selbsthilfe', 'ratgeber', 'personal development'],
  'freundschaft': ['friendship', 'freundschaft'],
  'gegenwart': ['contemporary', 'gegenwart'],
};

Set<String> tagsAus(Iterable<String> themen) {
  final text = themen.join(' | ').toLowerCase();
  return {
    for (final MapEntry(:key, :value) in _schluessel.entries)
      if (value.any(text.contains)) key,
  };
}

Zielgruppe zielgruppeAus(Iterable<String> themen) {
  final text = themen.join(' ').toLowerCase();
  if (text.contains('young adult') || text.contains('jugendbuch')) return Zielgruppe.jugend;
  if (text.contains('juvenile') || text.contains('children') || text.contains('kinderbuch')) {
    return Zielgruppe.kinder;
  }
  return Zielgruppe.erwachsene;
}
