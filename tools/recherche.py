"""Holt Hintergrundtexte zu Buchreihen für die Quiz-Arbeit (läuft in GitHub Actions).

Quellen: deutsche und englische Wikipedia (Artikeltext) und Fan-Wikis auf
Fandom, falls vorhanden. Ergebnis: tools/quellen/recherche/<reihe>.txt
Nur zum Nachlesen beim Schreiben der Quizfragen – nichts davon kommt in die App.
"""

import html
import json
import re
import time
import urllib.parse
import urllib.request
from pathlib import Path

ZIEL = Path(__file__).resolve().parent / 'quellen' / 'recherche'
UA = 'Buecherwurm/0.3 (https://github.com/snake10-cool/Claude; Lern-Projekt) python-urllib'

REIHEN = {
    'woodwalkers': {
        'wiki': [('de', ['Woodwalkers', 'Woodwalkers (Film)', 'Katja Brandis'])],
        # Das Walkers-Wiki hat zu jedem Band eine Seite „<Titel>/Handlung".
        'fandom': ['woodwalkers'], 'nur': r'/Handlung$',
    },
    'seawalkers': {
        'wiki': [('de', ['Seawalkers', 'Windwalkers'])],
    },
    'magisterium': {
        'wiki': [('de', ['Magisterium (Romanreihe)', 'Magisterium']),
                 ('en', ['Magisterium (book series)', 'The Iron Trial', 'The Copper Gauntlet',
                         'The Bronze Key', 'The Silver Mask', 'The Golden Tower'])],
        'fandom': ['magisterium', 'themagisterium'],
        'nur': r'^(The (Iron Trial|Copper Gauntlet|Bronze Key|Silver Mask|Golden Tower|Enemy of Death)'
               r'|De[rn] .*|Die .*|Callum Hunt|Aaron Stewart|Tamara Rajavi|Alex Strike|Jasper deWinter'
               r'|Havoc|Master (Joseph|Rufus)|Anastasia Tarquin|Constantine Madden|Alastair Hunt)$',
    },
    'fluesterwald': {
        'wiki': [('de', ['Flüsterwald'])],
        # Keine Wikis – Rezensionen und Verlagsseiten (Links eine Ebene tief verfolgt).
        'urls': ['https://www.xn--flsterwald-beb.de/', 'https://www.xn--flsterwald-beb.de/die-buecher/',
                 'https://www.xn--flsterwald-beb.de/die-buecher-staffel-1/',
                 'https://www.xn--flsterwald-beb.de/die-buecher-staffel-2/',
                 'https://www.kinderbuch-couch.de/titel/2491-fluesterwald-das-abenteuer-beginnt/',
                 'https://www.buechertreff.de/details/1437770-andreas-suchanek-fluesterwald/',
                 'https://lesentogo.de/2022/03/25/flusterwald-das-abenteuer-beginnt/',
                 'https://www.buechereule.de/wbb/thread/103839-fluesterwald-das-abenteuer-beginnt-andreas-suchanek/',
                 'https://www.penguin.de/buecher/reihen/die-fluesterwald-reihe/5006109'],
        'folgen': r'(kinderbuch-couch\.de/titel/\d+-fl(ue|u|ü)sterwald[^"#?]*|buechertreff\.de/details/\d+-andreas-suchanek-fl[^"#?]*'
                  r'|flsterwald-beb\.de/[^"#?]*(band|buch|staffel)[^"#?]*|lovelybooks\.de/autor/Andreas-Suchanek/Fl[^"#?]*-w/'
                  r'|penguin\.de/[^"#?]*fluesterwald[^"#?]*)',
    },
    'meisterdiebe': {
        'wiki': [('de', ['Die Schule der Meisterdiebe']),
                 ('en', ['Crookhaven (novel)', 'Crookhaven: The School for Thieves', 'J. J. Arcanjo'])],
        'fandom': ['crookhaven'],
        'urls': ['https://www.kinderbuch-couch.de/titel/5936-schule-der-meisterdiebe/',
                 'https://www.buechertreff.de/buchreihe/175722-schule-der-meisterdiebe-j-j-arcanjo-reihenfolge/',
                 'https://www.buechertreff.de/details/1568289-j-j-arcanjo-schule-der-meisterdiebe/',
                 'https://www.lovelybooks.de/autor/J.-J.-Arcanjo/reihe/Schule-der-Meisterdiebe-in-Reihenfolge-14039937446/',
                 'https://www.lovelybooks.de/autor/J.-J.-Arcanjo/Schule-der-Meisterdiebe-8858746670-w/'],
        'folgen': r'(kinderbuch-couch\.de/titel/\d+-schule-der-meisterdiebe[^"#?]*|buechertreff\.de/details/\d+-j-j-arcanjo[^"#?]*'
                  r'|lovelybooks\.de/autor/J\.-J\.-Arcanjo/[^"#?]*-w/)',
    },
    'windwalkers': {
        'urls': ['https://www.lovelybooks.de/autor/Katja-Brandis/reihe/Windwalkers-in-Reihenfolge-25145151572/',
                 'https://www.arena-verlag.de/artikel/windwalkers-2-helden-der-luefte-978-3-401-60796-2'],
        'folgen': r'(lovelybooks\.de/autor/Katja-Brandis/Windwalkers[^"#?]*-w/|arena-verlag\.de/artikel/windwalkers-[^"#?]*'
                  r'|kinderbuch-couch\.de/titel/\d+-windwalkers[^"#?]*)',
    },
}


def holen(url):
    for i in range(3):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': UA})
            with urllib.request.urlopen(req, timeout=60) as r:
                return json.loads(r.read())
        except Exception as e:  # noqa: BLE001
            print(f'  {url[:90]} – {e}')
            if '404' in str(e) or 'Name or service' in str(e):
                return None
            time.sleep(2 * (i + 1))
    return None


def wikipedia(sprache, titel):
    api = f'https://{sprache}.wikipedia.org/w/api.php?'
    a = holen(api + urllib.parse.urlencode({
        'action': 'query', 'prop': 'extracts', 'explaintext': 1, 'redirects': 1,
        'titles': titel, 'format': 'json'}))
    seiten = (a or {}).get('query', {}).get('pages', {})
    for s in seiten.values():
        if s.get('extract'):
            return s['title'], s['extract']
    # Nicht gefunden: suchen und den ersten Treffer nehmen.
    a = holen(api + urllib.parse.urlencode({
        'action': 'query', 'list': 'search', 'srsearch': titel, 'srlimit': 3, 'format': 'json'}))
    for t in (a or {}).get('query', {}).get('search', []):
        return wikipedia(sprache, t['title']) if t['title'] != titel else None
    return None


def alle_seiten(api):
    seiten, weiter = [], {}
    while True:
        a = holen(api + urllib.parse.urlencode({
            'action': 'query', 'list': 'allpages', 'aplimit': 500, 'format': 'json', **weiter}))
        if not a:
            return seiten
        seiten += [p['title'] for p in a.get('query', {}).get('allpages', [])]
        if 'continue' not in a or len(seiten) > 20000:
            return seiten
        weiter = {'apcontinue': a['continue']['apcontinue']}


def fandom(name, nur=None):
    texte = []
    for basis in (f'https://{name}.fandom.com/de', f'https://{name}.fandom.com'):
        api = basis + '/api.php?'
        seiten = alle_seiten(api)
        if not seiten:
            continue
        print(f'  Fandom {basis}: {len(seiten)} Seiten')
        if nur:
            seiten = [t for t in seiten if re.search(nur, t)]
            print(f'  davon {len(seiten)} passend')
        texte.append(f'##### {basis}: Seiten: ' + ' | '.join(seiten))
        for i in range(0, min(len(seiten), 400), 20):
            a = holen(api + urllib.parse.urlencode({
                'action': 'query', 'prop': 'revisions', 'rvprop': 'content', 'rvslots': 'main',
                'titles': '|'.join(seiten[i:i + 20]), 'format': 'json'}))
            for s in (a or {}).get('query', {}).get('pages', {}).values():
                inhalt = (s.get('revisions') or [{}])[0].get('slots', {}).get('main', {}).get('*', '')
                if len(inhalt) > 200 and not inhalt.lower().startswith('#redirect') \
                        and not inhalt.lower().startswith('#weiterleitung'):
                    texte.append(f'##### {basis} – {s["title"]}\n{bereinigen(inhalt)}')
            time.sleep(0.5)
        break
    return texte


def seite_text(url):
    """HTML-Seite als reiner Text plus Liste aller Links."""
    for i in range(2):
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0 (Buecherwurm-Recherche)'})
            with urllib.request.urlopen(req, timeout=60) as r:
                roh = r.read().decode('utf-8', 'replace')
            break
        except Exception as e:  # noqa: BLE001
            print(f'  {url[:90]} – {e}')
            roh = ''
            time.sleep(2)
    links = [urllib.parse.urljoin(url, html.unescape(h)) for h in re.findall(r'href="([^"]+)"', roh)]
    t = re.sub(r'(?is)<(script|style|nav|header|footer|noscript)[^>]*>.*?</\1>', ' ', roh)
    t = re.sub(r'(?i)<br\s*/?>|</p>|</h\d>|</li>|</div>', '\n', t)
    t = html.unescape(re.sub(r'<[^>]+>', ' ', t))
    t = '\n'.join(z.strip() for z in re.sub(r'[ \t]+', ' ', t).split('\n') if len(z.strip()) > 40)
    return t, links


def webseiten(urls, folgen):
    texte, gesehen, warte = [], set(), list(urls)
    while warte and len(gesehen) < 60:
        url = warte.pop(0)
        if url in gesehen:
            continue
        gesehen.add(url)
        text, links = seite_text(url)
        if text:
            texte.append(f'##### {url}\n{text[:30000]}')
        if folgen and url in urls:
            for l in links:
                if re.search(folgen, l) and l not in gesehen:
                    warte.append(l)
                    if 'lovelybooks.de' in l and l.endswith('-w/'):
                        warte.append(l + 'rezensionen/')
        time.sleep(1)
    print(f'  {len(gesehen)} Webseiten')
    return texte


def bereinigen(wikitext):
    t = re.sub(r'<ref[^>]*?/>|<ref.*?</ref>', '', wikitext, flags=re.S)
    t = re.sub(r'\[\[(?:Datei|File|Bild|Kategorie|Category):[^\]]*\]\]', '', t)
    t = re.sub(r'\[\[(?:[^|\]]*\|)?([^\]]*)\]\]', r'\1', t)
    t = re.sub(r"'{2,}", '', t)
    return t.strip()


def main():
    ZIEL.mkdir(parents=True, exist_ok=True)
    for reihe, q in REIHEN.items():
        print(reihe)
        texte = []
        for sprache, titel_liste in q.get('wiki', []):
            for titel in titel_liste:
                r = wikipedia(sprache, titel)
                if r:
                    texte.append(f'##### {sprache}.wikipedia – {r[0]}\n{r[1]}')
                time.sleep(0.5)
        for name in q.get('fandom', []):
            texte += fandom(name, q.get('nur'))
        texte += webseiten(q.get('urls', []), q.get('folgen'))
        (ZIEL / f'{reihe}.txt').write_text('\n\n'.join(texte) + '\n', encoding='utf-8')
        print(f'  {sum(len(t) for t in texte)} Zeichen')


if __name__ == '__main__':
    main()
