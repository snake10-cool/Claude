"""Holt Buchdaten für Bücherwurm von der Deutschen Nationalbibliothek.

Läuft in GitHub Actions (dort sind DNB und Open Library erreichbar).
Eingabe:  tools/quellen/buecherwurm_liste.json (Reihen und Einzeltitel)
Ausgabe:  apps/buecherwurm/lib/data/katalog_extra.dart  (Bücher ohne Quiz)
          apps/buecherwurm/lib/data/katalog_cover.dart  (Cover für Quiz-Bücher)
          tools/quellen/buecher_bericht.txt           (was fehlt, was gefunden wurde)

Nur was die DNB (oder ersatzweise Open Library) wirklich kennt, kommt in die
App. Bücher, die schon mit Quiz im Katalog stehen, werden übersprungen.

Aufruf: python tools/buecher_holen.py [--max 1000]
"""

import json
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
APP = WURZEL / 'apps' / 'buecherwurm'
LISTE = WURZEL / 'tools' / 'quellen' / 'buecherwurm_liste.json'
BERICHT = WURZEL / 'tools' / 'quellen' / 'buecher_bericht.txt'
UA = 'Buecherwurm/0.2 (https://github.com/snake10-cool/Claude; Lern-Projekt)'
GESAMT = 1000

# Schlüsselwörter → Merkmale (wie lib/services/buchsuche.dart, plus GND-Schlagwörter).
SCHLUESSEL = {
    'fantasy': ['fantasy', 'magie', 'zauber', 'drache', 'hexe', 'magic'],
    'scifi': ['science-fiction', 'science fiction', 'weltraum', 'zukunft', 'roboter'],
    'krimi': ['krimi', 'kriminal', 'detektiv', 'mord', 'ermittl'],
    'thriller': ['thriller'],
    'horror': ['horror', 'grusel', 'gespenst', 'vampir'],
    'liebe': ['liebe', 'liebesroman', 'romance'],
    'humor': ['humor', 'komik', 'satire', 'lustig'],
    'abenteuer': ['abenteuer'],
    'historisch': ['geschichte', 'historisch', 'weltkrieg', 'mittelalter'],
    'tiere': ['tiere', 'hund', 'katze', 'pferd', 'wolf'],
    'freundschaft': ['freundschaft'],
}


# ───────────────────────── Hilfen ─────────────────────────

def normal(s):
    s = unicodedata.normalize('NFKD', s.lower())
    s = s.replace('ß', 'ss')
    return re.sub(r'[^a-z0-9]', '', ''.join(c for c in s if not unicodedata.combining(c)))


def holen(url, versuche=3):
    for i in range(versuche):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=30) as r:
                return r.status, r.headers.get('Content-Type', ''), r.read()
        except urllib.error.HTTPError as e:
            if e.code in (404, 400):
                return e.code, '', b''
            time.sleep(2 * (i + 1))
        except Exception:
            time.sleep(2 * (i + 1))
    return 0, '', b''


def dart_text(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$').replace('\n', ' ') + "'"


def aufraeumen(s):
    # DNB markiert Nichtsortierzeichen (Artikel) mit ¬ oder Steuerzeichen.
    s = unicodedata.normalize('NFC', s or '')
    s = re.sub(r'[\u0098\u009c¬]', '', s)
    s = re.split(r'\s/\s', s)[0]
    s = re.sub(r'\s*:?\s*\[[^\]]*\]', '', s)
    s = re.sub(r'\s+', ' ', s).strip()
    return s.strip(' /:;,.=').strip()


# ───────────────────────── DNB ─────────────────────────

def _felder(rec):
    """MARC-Datensatz → {tag: [ {code: [werte]} ]} und Leader."""
    leader = ''
    felder = {}
    for el in rec:
        tag = el.tag.split('}')[-1]
        if tag == 'leader':
            leader = el.text or ''
        elif tag == 'datafield':
            sub = {}
            for sf in el:
                sub.setdefault(sf.get('code'), []).append(sf.text or '')
            felder.setdefault(el.get('tag'), []).append(sub)
        elif tag == 'controlfield':
            felder.setdefault(el.get('tag'), []).append({'_': [el.text or '']})
    return leader, felder


def _eins(felder, tag, code):
    for f in felder.get(tag, []):
        if f.get(code):
            return f[code][0]
    return ''


def dnb_suchen(cql, anzahl=60):
    url = 'https://services.dnb.de/sru/dnb?' + urllib.parse.urlencode({
        'version': '1.1', 'operation': 'searchRetrieve', 'query': cql,
        'recordSchema': 'MARC21-xml', 'maximumRecords': str(anzahl),
    })
    status, _, daten = holen(url)
    if status != 200 or not daten:
        return []
    try:
        wurzel = ET.fromstring(daten)
    except ET.ParseError:
        return []
    ergebnis = []
    for rec in wurzel.iter():
        if rec.tag.split('}')[-1] != 'record' or not any(c.tag.endswith('leader') for c in rec):
            continue
        leader, f = _felder(rec)
        if len(leader) > 7 and leader[6] != 'a':
            continue  # kein Text (Hörbuch, Film …)
        medien = ' '.join(v for x in f.get('338', []) + f.get('337', []) for v in x.get('a', [])).lower()
        inhalt = ' '.join(v for x in f.get('336', []) for v in x.get('a', [])).lower()
        if 'online' in medien or 'computer' in medien or 'gesprochen' in inhalt or 'audio' in medien:
            continue
        titel = aufraeumen(_eins(f, '245', 'a'))
        teil = aufraeumen(_eins(f, '245', 'p'))
        nummer = aufraeumen(_eins(f, '245', 'n'))
        reihe = aufraeumen(_eins(f, '490', 'a'))
        band = aufraeumen(_eins(f, '490', 'v'))
        autor = aufraeumen(_eins(f, '100', 'a'))
        if ',' in autor:
            nach, vor = autor.split(',', 1)
            autor = f'{vor.strip()} {nach.strip()}'
        jahr_text = _eins(f, '264', 'c') or _eins(f, '260', 'c')
        jahr = int(m.group()) if (m := re.search(r'(1[5-9]|20)\d\d', jahr_text)) else 0
        seiten_text = _eins(f, '300', 'a')
        seiten = int(m.group(1)) if (m := re.search(r'(\d+)\s*(Seiten|S\.)', seiten_text)) else 0
        isbn = ''
        for x in f.get('020', []):
            for wert in x.get('9', []) + x.get('a', []):
                ziffern = re.sub(r'[^0-9X]', '', wert.split(' ')[0].upper())
                if len(ziffern) in (10, 13):
                    isbn = ziffern
                    break
            if isbn:
                break
        f008 = (f.get('008') or [{'_': ['']}])[0]['_'][0]
        sprache = ' '.join([v for x in f.get('041', []) for v in x.get('a', [])] + [f008[35:38]])
        schlagworte = [v for tag in ('650', '655', '689') for x in f.get(tag, []) for v in x.get('a', [])]
        if not titel:
            continue
        ergebnis.append({
            'titel': titel, 'teil': teil, 'nummer': nummer, 'reihe': reihe, 'band': band,
            'autor': autor, 'jahr': jahr, 'seiten': seiten, 'isbn': isbn,
            'sprache': sprache, 'schlagworte': schlagworte,
        })
    return ergebnis


UNERWUENSCHT = re.compile(
    r'sammel|box|schuber|kalender|sticker|malbuch|rätsel|fanbuch|mitmach|notizbuch|poster|'
    r'kochbuch|hörbuch|hörspiel|filmbuch|buch zum film|leserabe|lesestart|erstles|'
    r'arbeitsheft|lektürehilfe|interpretation|lernhilfe|königs erläuterungen|unterricht|'
    r'\bbd\.?\s*\d+\s*[-–]\s*\d+|band\s*\d+\s*[-–]\s*\d+|\d+\s*in\s*1|sonderausgabe|'
    r'adventskalender|postkarten|tagebuch zum|figuren|ausmalen|comic', re.I)


# Sammelbände, Planer, Merchandise und Ähnliches bei Reihen.
KEIN_BAND = re.compile(
    r'trilogie|gesamtausgabe|vorgeschichte|-saga\b|\bsaga$|doppelband|schulplaner|planer|'
    r'journal|brosche|kette\b|anhänger|\bvke\b|\bve\b|hausaufgabenheft|geschichten aus|'
    r'zum film|lesebuch|& friends|und friends|alle meine|unsere schönsten|\d+ weihnacht', re.I)


def kern(titel):
    """Der Teil nach dem letzten Gedankenstrich, z. B. der Bandtitel einer Reihe."""
    return re.split(r'\s[–-]\s', titel)[-1]


def anzeige_titel(e, reihe=None, praefix=True):
    a, p = e['titel'], e['teil']
    # „Woodwalkers (5). Feindliche Spuren" → Reihe und Bandtitel trennen.
    m = re.match(r'^(.*?)\s*\((\d+)\)\.?\s+(.+)$', a)
    if m and not p:
        a, p = m.group(1), m.group(3)
    if not reihe:
        return f'{a} – {p}' if p and normal(p) not in normal(a) else a
    k = p or a
    if normal(k) in normal(reihe):
        k = reihe
    if praefix and normal(reihe) not in normal(k):
        k = f'{reihe} – {k}'
    # Einheitliche Gedankenstriche; DNB schreibt Untertitel oft klein.
    k = re.sub(r'\s+-\s+', ' – ', k)
    k = re.sub(r'(^|\s–\s)(\w)', lambda m: m.group(1) + m.group(2).upper(), k)
    return k


def bandnummer(e):
    for text in (e['band'], e['nummer'], e['titel']):
        m = re.search(r'\((\d+)\)|^(\d+)\b|\bBd\.?\s*(\d+)|\b(\d+)$', text or '')
        if m:
            return int(next(g for g in m.groups() if g))
    return None


# ───────────────────────── Open Library (Reserve, Cover) ─────────────────────────

def ol_suchen(titel, autor):
    url = 'https://openlibrary.org/search.json?' + urllib.parse.urlencode({
        'title': titel, 'author': autor, 'limit': '5',
        'fields': 'title,author_name,first_publish_year,number_of_pages_median,cover_i,isbn,subject',
    })
    status, _, daten = holen(url)
    if status != 200:
        return None
    try:
        docs = json.loads(daten).get('docs', [])
    except ValueError:
        return None
    for d in docs:
        if normal(d.get('title', ''))[:12] == normal(titel)[:12]:
            return d
    return None


def cover_fuer(isbn):
    """Cover-URL, die wirklich ein Bild liefert, sonst None."""
    if not isbn:
        return None
    for url in (f'https://covers.openlibrary.org/b/isbn/{isbn}-M.jpg?default=false',
                f'https://portal.dnb.de/opac/mvb/cover?isbn={isbn}'):
        status, typ, daten = holen(url, versuche=2)
        if status == 200 and typ.startswith('image') and len(daten) > 2000:
            return url.replace('?default=false', '')
    return None


def tags_aus(woerter):
    text = ' '.join(woerter).lower()
    return {t for t, liste in SCHLUESSEL.items() if any(w in text for w in liste)}


# ───────────────────────── Ablauf ─────────────────────────

def katalog_mit_quiz():
    """(id, titel, autor) aller Bücher, die schon mit Quiz in der App stehen."""
    ergebnis = []
    for datei in sorted((APP / 'lib' / 'data').glob('katalog*.dart')):
        if datei.name in ('katalog_extra.dart', 'katalog_cover.dart'):
            continue
        text = datei.read_text(encoding='utf-8')
        for m in re.finditer(r"id: '([^']+)',\s*titel: '((?:[^'\\]|\\.)*)',\s*autor: '((?:[^'\\]|\\.)*)'", text):
            ergebnis.append((m.group(1), m.group(2).replace("\\'", "'"), m.group(3).replace("\\'", "'")))
    return ergebnis


def nachname(autor):
    return autor.replace('.', ' ').split()[-1] if autor.strip() else ''


def main():
    maximal = GESAMT
    if '--max' in sys.argv:
        maximal = int(sys.argv[sys.argv.index('--max') + 1])
    liste = json.loads(LISTE.read_text(encoding='utf-8'))
    quiz = katalog_mit_quiz()
    platz = maximal - len(quiz)
    bekannt = {normal(t) for _, t, _ in quiz}
    # Kerntitel (ohne Reihenname davor), damit „Lockwood & Co – X" und „X" als gleich gelten.
    kerne = {normal(kern(t)) for _, t, _ in quiz if len(normal(kern(t))) >= 8}
    print(f'{len(quiz)} Bücher mit Quiz, Platz für {platz} weitere')

    buecher = []
    bericht = []

    def hinzufuegen(eintrag):
        schluessel = normal(eintrag['titel'])
        k = normal(kern(eintrag['titel']))
        if schluessel in bekannt or (len(k) >= 8 and k in kerne) or len(buecher) >= platz:
            return False
        bekannt.add(schluessel)
        if len(k) >= 8:
            kerne.add(k)
        buecher.append(eintrag)
        return True

    for gruppe in liste['gruppen']:
        ziel = gruppe['zielgruppe']
        g_tags = set(gruppe.get('tags', []))
        min_alter = gruppe.get('minAlter', 0)

        praefix = gruppe.get('praefix', ziel != 'erwachsene')
        for r in gruppe.get('reihen', []):
            woerter = [normal(w) for w in r['autor'].split()]
            familienname = r['autor'].split()[-1] if r['autor'] else ''
            abfragen = [r['reihe']]
            if re.match(r'^(Die|Der|Das) ', r['reihe']):
                abfragen.append(r['reihe'].split(' ', 1)[1])  # zweiter Versuch ohne Artikel
            gefunden = {}
            for reihe_text in abfragen:
                abfrage = f'tit="{reihe_text}"' + (f' and per={familienname}' if familienname else '')
                treffer = dnb_suchen(abfrage, 100)
                time.sleep(0.5)
                for e in treffer:
                    if 'ger' not in e['sprache']:
                        continue
                    if woerter and not all(w in normal(e['autor']) for w in woerter):
                        continue
                    if not 20 <= e['seiten'] <= 1500:
                        continue  # Schmuck, Kalender, Riesen-Sammelbände
                    if normal(reihe_text) not in normal(e['titel'] + e['teil'] + e['reihe']):
                        continue
                    titel = anzeige_titel(e, r['reihe'], r.get('praefix', praefix))
                    if UNERWUENSCHT.search(titel) or KEIN_BAND.search(titel) or '`' in titel:
                        continue
                    # Ein Buch, das genauso heißt wie die Reihe, ist meist Band 1 –
                    # aber nur, wenn es nicht nach Sammelband aussieht.
                    if normal(titel) == normal(r['reihe']) and not 60 <= e['seiten'] <= 900:
                        continue
                    nr = bandnummer(e)
                    schluessel = ('band', nr) if nr else ('kern', normal(kern(titel)))
                    alt = gefunden.get(schluessel)
                    # Älteste Ausgabe gewinnt (meist das Original, nicht die Neuauflage).
                    if alt is None or (e['jahr'] and (not alt['jahr'] or e['jahr'] < alt['jahr'])):
                        gefunden[schluessel] = dict(e, anzeige=titel, nr=nr)
                if gefunden:
                    break
            # Gleicher Bandtitel unter verschiedenen Nummern/Schreibweisen nur einmal.
            auswahl, kerne = [], set()
            for e in sorted(gefunden.values(), key=lambda e: (e['nr'] or 999, e['jahr'] or 9999)):
                k = normal(kern(e['anzeige']))
                if k in kerne:
                    continue
                kerne.add(k)
                auswahl.append(e)
            auswahl = auswahl[:r['max']]
            for e in auswahl:
                hinzufuegen({
                    'titel': e['anzeige'], 'autor': e['autor'], 'jahr': e['jahr'], 'seiten': e['seiten'],
                    'isbn': e['isbn'], 'zielgruppe': ziel, 'minAlter': min_alter,
                    'tags': sorted(g_tags | set(r.get('tags', [])) | tags_aus(e['schlagworte']) | {'serie'}),
                    'beschreibung': (f'Band {e["nr"]} der Reihe „{r["reihe"]}".' if e['nr']
                                     else f'Aus der Reihe „{r["reihe"]}".'),
                })
            bericht.append(f'Reihe {r["reihe"]}: {len(auswahl)} Bände ' +
                           ('| ' + '; '.join(e['anzeige'] for e in auswahl) if auswahl else '– NICHTS GEFUNDEN'))
            print(bericht[-1][:150])

        for eintrag in gruppe.get('buecher', []):
            titel, autor = eintrag[0], eintrag[1]
            extra = set(eintrag[2]) if len(eintrag) > 2 else set()
            if normal(titel) in bekannt:
                continue
            treffer = dnb_suchen(f'tit="{titel}" and per={nachname(autor)}', 40)
            time.sleep(0.4)
            passend = [e for e in treffer
                       if 'ger' in e['sprache']
                       and normal(anzeige_titel(e)).startswith(normal(titel)[:14])
                       and not UNERWUENSCHT.search(anzeige_titel(e))]
            passend.sort(key=lambda e: (not e['seiten'], e['jahr'] or 9999))
            if passend:
                e = passend[0]
                daten = {'titel': titel, 'autor': e['autor'] or autor, 'jahr': e['jahr'],
                         'seiten': e['seiten'], 'isbn': e['isbn'], 'schlagworte': e['schlagworte']}
                quelle = 'DNB'
            else:
                d = ol_suchen(titel, autor)
                time.sleep(0.4)
                if not d:
                    bericht.append(f'NICHT GEFUNDEN: {titel} ({autor})')
                    print(bericht[-1])
                    continue
                daten = {'titel': titel, 'autor': autor, 'jahr': d.get('first_publish_year') or 0,
                         'seiten': d.get('number_of_pages_median') or 0,
                         'isbn': (d.get('isbn') or [''])[0], 'schlagworte': d.get('subject', [])[:20]}
                quelle = 'Open Library'
            hinzufuegen({
                **{k: daten[k] for k in ('titel', 'autor', 'jahr', 'seiten', 'isbn')},
                'zielgruppe': ziel, 'minAlter': min_alter,
                'tags': sorted(g_tags | extra | tags_aus(daten['schlagworte'])),
                'beschreibung': '',
            })
            bericht.append(f'{quelle}: {titel} ({daten["autor"]}, {daten["jahr"]}, {daten["seiten"]} S.)')

    print(f'{len(buecher)} Bücher gefunden, suche Cover …')
    for i, b in enumerate(buecher):
        b['cover'] = cover_fuer(b['isbn'])
        if i % 50 == 0:
            print(f'  {i}/{len(buecher)}')

    # Cover auch für die Quiz-Bücher (über DNB-Suche nach Titel und Autor).
    quiz_cover = {}
    for buch_id, titel, autor in quiz:
        treffer = [e for e in dnb_suchen(f'tit="{titel}" and per={nachname(autor)}', 20)
                   if e['isbn'] and normal(anzeige_titel(e)).startswith(normal(titel)[:10])]
        time.sleep(0.3)
        for e in treffer[:4]:
            url = cover_fuer(e['isbn'])
            if url:
                quiz_cover[buch_id] = url
                break

    schreiben(buecher, quiz_cover)
    bericht.insert(0, f'{len(buecher)} Bücher ohne Quiz, {sum(1 for b in buecher if b["cover"])} mit Cover; '
                      f'{len(quiz_cover)} von {len(quiz)} Quiz-Büchern mit Cover.')
    BERICHT.write_text('\n'.join(bericht) + '\n', encoding='utf-8')
    print(bericht[0])


def schreiben(buecher, quiz_cover):
    ids = set()
    zeilen = [
        '// GENERIERT von tools/buecher_holen.py aus Daten der Deutschen Nationalbibliothek',
        '// und von Open Library. Nicht von Hand ändern – Liste: tools/quellen/buecherwurm_liste.json',
        "import '../models/buch.dart';",
        '',
        'const katalogExtra = <Buch>[',
    ]
    for b in buecher:
        basis = 'x_' + normal(b['titel'])[:36]
        bid, n = basis, 2
        while bid in ids:
            bid, n = f'{basis}{n}', n + 1
        ids.add(bid)
        teile = [
            f"id: {dart_text(bid)}", f"titel: {dart_text(b['titel'])}", f"autor: {dart_text(b['autor'])}",
            f"jahr: {b['jahr'] or 0}", f"seiten: {b['seiten'] or 0}", f"zielgruppe: Zielgruppe.{b['zielgruppe']}",
            'tags: {' + ', '.join(dart_text(t) for t in b['tags']) + '}',
            f"beschreibung: {dart_text(b['beschreibung'])}",
        ]
        if b['minAlter']:
            teile.append(f"minAlter: {b['minAlter']}")
        if b.get('cover'):
            teile.append(f"coverUrl: {dart_text(b['cover'])}")
        if b['isbn']:
            teile.append(f"isbn: {dart_text(b['isbn'])}")
        zeilen.append('  Buch(' + ', '.join(teile) + '),')
    zeilen.append('];')
    (APP / 'lib' / 'data' / 'katalog_extra.dart').write_text('\n'.join(zeilen) + '\n', encoding='utf-8')

    cover = [
        '// GENERIERT von tools/buecher_holen.py – Cover-Bilder für die Bücher mit Quiz.',
        'const katalogCover = <String, String>{',
        *[f'  {dart_text(k)}: {dart_text(v)},' for k, v in sorted(quiz_cover.items())],
        '};',
    ]
    (APP / 'lib' / 'data' / 'katalog_cover.dart').write_text('\n'.join(cover) + '\n', encoding='utf-8')


if __name__ == '__main__':
    main()
