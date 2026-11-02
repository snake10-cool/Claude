import 'dart:convert';

import 'package:buecherwurm/models/buch.dart';
import 'package:buecherwurm/services/buchsuche.dart';
import 'package:flutter_test/flutter_test.dart' hide Tags;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _ol = {
  'numFound': 1,
  'docs': [
    {
      'title': 'Tschick',
      'author_name': ['Wolfgang Herrndorf'],
      'first_publish_year': 2010,
      'number_of_pages_median': 256,
      'subject': ['Friendship', 'Juvenile fiction', 'Adventure stories'],
      'cover_i': 123,
      'isbn': ['9783499256356'],
    },
    {'author_name': ['Ohne Titel']},
  ],
};

const _gb = {
  'items': [
    {
      'volumeInfo': {
        'title': 'Der Drachenkönig',
        'authors': ['Anna Muster'],
        'publishedDate': '2021-03-01',
        'pageCount': 412,
        'categories': ['Young Adult Fiction / Fantasy'],
        'description': 'Eine Geschichte voller Magie und Drachen.',
        'imageLinks': {'thumbnail': 'http://books.google.com/bild.jpg'},
        'industryIdentifiers': [
          {'type': 'ISBN_10', 'identifier': '3123456789'},
          {'type': 'ISBN_13', 'identifier': '9783123456786'},
        ],
      },
    },
  ],
};

http.Response _json(Object o, [int code = 200]) =>
    http.Response.bytes(utf8.encode(jsonEncode(o)), code, headers: {'content-type': 'application/json'});

void main() {
  test('Open Library wird richtig gelesen', () {
    final t = ausOpenLibrary(_ol);
    expect(t.length, 1);
    expect(t.first.titel, 'Tschick');
    expect(t.first.coverUrl, 'https://covers.openlibrary.org/b/id/123-M.jpg');
    expect(t.first.tags, containsAll([Tags.freundschaft, Tags.abenteuer, Tags.jungeHelden]));
    expect(t.first.zielgruppe, Zielgruppe.kinder);
    expect(t.first.imKatalog?.id, 'tschick');
  });

  test('Google Books wird richtig gelesen', () {
    final t = ausGoogleBooks(_gb).single;
    expect(t.jahr, 2021);
    expect(t.isbn, '9783123456786');
    expect(t.coverUrl, startsWith('https://'));
    expect(t.tags, contains(Tags.fantasy));
    expect(t.zielgruppe, Zielgruppe.jugend);
    expect(t.imKatalog, isNull);
  });

  test('ISBN wird erkannt', () {
    expect(isbnAus('978-3-499-25635-6'), '9783499256356');
    expect(isbnAus('3-12-345678-X'), '312345678X');
    expect(isbnAus('Harry Potter'), isNull);
  });

  test('Ohne Treffer bei Open Library wird Google Books gefragt', () async {
    final gefragt = <String>[];
    final suche = BuchSuche(MockClient((anfrage) async {
      gefragt.add(anfrage.url.host);
      return anfrage.url.host == 'openlibrary.org' ? _json({'docs': []}) : _json(_gb);
    }));
    final t = await suche.suchen('Drachenkönig');
    expect(gefragt, ['openlibrary.org', 'www.googleapis.com']);
    expect(t.single.titel, 'Der Drachenkönig');
  });

  test('ISBN-Suche fragt nach der ISBN', () async {
    final suche = BuchSuche(MockClient((anfrage) async {
      expect(anfrage.url.queryParameters['isbn'], '9783499256356');
      return _json(_ol);
    }));
    final t = await suche.suchen('978-3-499-25635-6');
    expect(t.single.isbn, '9783499256356');
  });

  test('Beide Dienste weg ergibt einen Fehler', () async {
    final suche = BuchSuche(MockClient((_) async => _json({}, 500)));
    expect(suche.suchen('Momo'), throwsA(isA<SuchFehler>()));
  });

  test('Eigenes Buch mit Cover und Tags übersteht Speichern', () {
    const b = Buch(
      id: 'eigen_1',
      titel: 'X',
      autor: 'Y',
      jahr: 2020,
      seiten: 100,
      zielgruppe: Zielgruppe.jugend,
      tags: {'fantasy'},
      beschreibung: 'Z',
      eigenes: true,
      coverUrl: 'https://a/b.jpg',
      isbn: '123',
    );
    final c = Buch.eigenesAusJson(jsonDecode(jsonEncode(b.toJson())) as Map<String, dynamic>);
    expect(c.tags, {'fantasy'});
    expect(c.coverUrl, 'https://a/b.jpg');
    expect(c.zielgruppe, Zielgruppe.jugend);
    expect(c.isbn, '123');
  });
}
