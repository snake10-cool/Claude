"""Holt Hintergrundtexte zu Buchreihen für die Quiz-Arbeit (läuft in GitHub Actions).

Quellen: deutsche und englische Wikipedia (Artikeltext) und Fan-Wikis auf
Fandom, falls vorhanden. Ergebnis: tools/quellen/recherche/<reihe>.txt
Nur zum Nachlesen beim Schreiben der Quizfragen – nichts davon kommt in die App.
"""

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
        'wiki': [('de', ['Flüsterwald', 'Andreas Suchanek'])],
        'fandom': ['fluesterwald', 'flusterwald', 'flüsterwald'],
    },
    'meisterdiebe': {
        'wiki': [('de', ['Die Schule der Meisterdiebe']),
                 ('en', ['Crookhaven (novel)', 'Crookhaven: The School for Thieves', 'J. J. Arcanjo'])],
        'fandom': ['crookhaven'],
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
        for sprache, titel_liste in q['wiki']:
            for titel in titel_liste:
                r = wikipedia(sprache, titel)
                if r:
                    texte.append(f'##### {sprache}.wikipedia – {r[0]}\n{r[1]}')
                time.sleep(0.5)
        for name in q.get('fandom', []):
            texte += fandom(name, q.get('nur'))
        (ZIEL / f'{reihe}.txt').write_text('\n\n'.join(texte) + '\n', encoding='utf-8')
        print(f'  {sum(len(t) for t in texte)} Zeichen')


if __name__ == '__main__':
    main()
