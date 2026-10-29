"""Holt Inhaltstexte zu den Büchern, damit daraus Quizfragen geschrieben werden können.

Läuft in GitHub Actions. Quellen:
- Wikidata-Bücher (wd_Q…): Abschnitt „Handlung“/„Inhalt“ des deutschen Wikipedia-Artikels
- Bücher aus der Nationalbibliothek (mit ISBN): Beschreibung von Google Books

Ausgabe: tools/quellen/inhalte/inhalte.json.gz  {id: {"t": Titel, "q": Quelle, "x": Text}}
Nur zum Schreiben der Fragen – kommt nicht in die App.
"""

import gzip
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
APP = WURZEL / 'apps' / 'buecherwurm'
AUSGABE = WURZEL / 'tools' / 'quellen' / 'inhalte' / 'inhalte.json.gz'
UA = 'Buecherwurm/0.3 (https://github.com/snake10-cool/Claude; Lern-Projekt) python-urllib'
ABSCHNITTE = ('handlung', 'inhalt', 'zusammenfassung', 'handlungsübersicht', 'überblick', 'plot')
MAX_TEXT = 3000


def holen(url, versuche=4):
    for i in range(versuche):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.loads(r.read(), strict=False)
        except urllib.error.HTTPError as e:
            if e.code == 404:
                return None
            time.sleep(5 * (i + 1) if e.code == 429 else 2 * (i + 1))
        except Exception:  # noqa: BLE001
            time.sleep(2 * (i + 1))
    return None


def dewiki_titel(qids):
    """Q-IDs → Titel des deutschen Wikipedia-Artikels (je 50)."""
    titel = {}
    for i in range(0, len(qids), 50):
        a = holen('https://www.wikidata.org/w/api.php?' + urllib.parse.urlencode({
            'action': 'wbgetentities', 'ids': '|'.join(qids[i:i + 50]), 'props': 'sitelinks',
            'sitefilter': 'dewiki', 'format': 'json'})) or {}
        for q, e in a.get('entities', {}).items():
            t = e.get('sitelinks', {}).get('dewiki', {}).get('title')
            if t:
                titel[q] = t
        if i % 2000 == 0:
            print(f'  Sitelinks {i}/{len(qids)}', flush=True)
    return titel


def abschnitt(text):
    """Bevorzugt den Handlungs-Abschnitt, sonst die Einleitung."""
    teile = re.split(r'\n(==+)\s*(.+?)\s*\1\n', '\n' + text)
    einleitung = teile[0].strip()
    for i in range(1, len(teile) - 2, 3):
        name = teile[i + 1].lower()
        if any(name.startswith(a) for a in ABSCHNITTE):
            inhalt = teile[i + 2]
            # Unterabschnitte mitnehmen, bis zur nächsten gleich hohen Überschrift.
            j = i + 3
            while j < len(teile) - 2 and len(teile[j]) > len(teile[i]):
                inhalt += '\n' + teile[j + 1] + ': ' + teile[j + 2]
                j += 3
            return 'Handlung', (einleitung[:600] + '\n\n' + inhalt.strip())[:MAX_TEXT]
    return 'Einleitung', einleitung[:MAX_TEXT]


def wikipedia_text(titel):
    a = holen('https://de.wikipedia.org/w/api.php?' + urllib.parse.urlencode({
        'action': 'query', 'prop': 'extracts', 'explaintext': 1, 'exsectionformat': 'wiki',
        'redirects': 1, 'titles': titel, 'format': 'json'})) or {}
    for s in a.get('query', {}).get('pages', {}).values():
        if s.get('extract'):
            return abschnitt(s['extract'])
    return None


def google_books(isbn):
    a = holen('https://www.googleapis.com/books/v1/volumes?' + urllib.parse.urlencode({'q': f'isbn:{isbn}'}))
    for item in (a or {}).get('items', [])[:1]:
        d = item.get('volumeInfo', {}).get('description', '')
        if d:
            return re.sub(r'<[^>]+>', ' ', d)[:MAX_TEXT]
    return None


def main():
    alt = {}
    if AUSGABE.exists():
        alt = json.load(gzip.open(AUSGABE))
    ergebnis = dict(alt)

    # 1) Wikidata-Bücher
    wd = json.load(gzip.open(APP / 'assets' / 'daten' / 'katalog_wikidata.json.gz'))
    offen = [b for b in wd if b['id'] not in ergebnis]
    if '--max' in sys.argv:
        offen = offen[:int(sys.argv[sys.argv.index('--max') + 1])]
    print(f'{len(wd)} Wikidata-Bücher, {len(offen)} noch ohne Text', flush=True)
    titel = dewiki_titel([b['id'][3:] for b in offen])
    nach_id = {b['id']: b for b in offen}

    def eins(bid):
        t = titel.get(bid[3:])
        return bid, (wikipedia_text(t) if t else None)

    fertig = 0
    with ThreadPoolExecutor(4) as pool:
        for bid, r in pool.map(eins, list(nach_id)):
            fertig += 1
            if r and len(r[1]) >= 300:
                ergebnis[bid] = {'t': nach_id[bid]['t'], 'q': f'Wikipedia ({r[0]})', 'x': r[1]}
            if fertig % 500 == 0:
                print(f'  Wikipedia {fertig}/{len(nach_id)}, {len(ergebnis)} Texte', flush=True)

    # 2) Bücher aus der Nationalbibliothek mit ISBN
    extra = (APP / 'lib' / 'data' / 'katalog_extra.dart').read_text(encoding='utf-8')
    isbn_buecher = re.findall(r"Buch\(id: '([^']+)', titel: '((?:[^'\\]|\\.)*)'.*?isbn: '(\d{10,13})'", extra)
    print(f'{len(isbn_buecher)} Bücher mit ISBN', flush=True)
    for bid, t, isbn in isbn_buecher:
        if bid in ergebnis:
            continue
        d = google_books(isbn)
        if d and len(d) >= 200:
            ergebnis[bid] = {'t': t.replace("\\'", "'"), 'q': 'Google Books (Klappentext)', 'x': d}
        time.sleep(0.3)

    AUSGABE.parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(AUSGABE, 'wt', encoding='utf-8') as f:
        json.dump(ergebnis, f, ensure_ascii=False, separators=(',', ':'))
    handlung = sum(1 for e in ergebnis.values() if 'Handlung' in e['q'])
    print(f'{len(ergebnis)} Texte gespeichert ({handlung} mit Handlungsabschnitt)')


if __name__ == '__main__':
    main()
