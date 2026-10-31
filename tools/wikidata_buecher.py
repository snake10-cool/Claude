"""Holt bis zu 20.000 bekannte Bücher für Bücherwurm aus Wikidata.

Läuft in GitHub Actions (Wikidata ist dort erreichbar). Nur Werke mit
eigenem Artikel in der deutschen Wikipedia – so bleiben es bekannte Bücher
mit deutschem Titel. Sortiert nach Bekanntheit (Zahl der Wikipedia-Sprachen).

Ausgabe: apps/buecherwurm/assets/daten/katalog_wikidata.json.gz
         tools/quellen/wikidata_bericht.txt

Aufruf: python tools/wikidata_buecher.py [--max 20000]
"""

import gzip
import json
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent
APP = WURZEL / 'apps' / 'buecherwurm'
AUSGABE = APP / 'assets' / 'daten' / 'katalog_wikidata.json.gz'
BERICHT = WURZEL / 'tools' / 'quellen' / 'wikidata_bericht.txt'
UA = 'Buecherwurm/0.3 (https://github.com/snake10-cool/Claude; Lern-Projekt) python-urllib'
ZIEL = 20000

# Werk-Arten: literarisches Werk, Roman, Schriftwerk, Buch, Bühnenstück, Novelle,
# Erzählung, Kinderbuch, Jugendbuch, Bilderbuch, Sachbuch.
ARTEN = ['Q7725634', 'Q8261', 'Q47461344', 'Q571', 'Q25379', 'Q149537', 'Q12308638',
         'Q8275050', 'Q1233720', 'Q2140665', 'Q1135785']

# Genre-Wörter (deutsche Wikidata-Bezeichnungen) → Merkmale der App.
SCHLUESSEL = {
    'fantasy': ['fantasy', 'märchen', 'fantastik', 'phantastik', 'sage'],
    'scifi': ['science-fiction', 'science fiction', 'zukunftsroman', 'weltraum'],
    'krimi': ['krimi', 'kriminal', 'detektiv', 'mystery'],
    'thriller': ['thriller', 'spionage'],
    'horror': ['horror', 'schauer', 'grusel', 'gothic', 'vampir'],
    'liebe': ['liebesroman', 'romanze', 'liebes'],
    'humor': ['humor', 'satire', 'komödie', 'schelmen', 'groteske', 'parodie'],
    'abenteuer': ['abenteuer', 'reiseroman', 'seefahrt', 'western'],
    'historisch': ['historisch', 'geschichts'],
    'sachbuch': ['sachbuch', 'essay', 'biografie', 'autobiografie', 'memoiren', 'ratgeber', 'philosophie'],
    'dystopie': ['dystopie', 'antiutopie', 'postapokalyp'],
    'drama': ['drama', 'tragödie', 'trauerspiel', 'familienroman'],
    'nachdenklich': ['gesellschaftsroman', 'bildungsroman', 'entwicklungsroman', 'philosophisch', 'existenz'],
    'jungeHelden': ['kinder', 'jugend', 'coming-of-age', 'internat'],
    'tiere': ['tier', 'fabel'],
    'gegenwart': ['gegenwart', 'zeitroman'],
}
VERBOTEN = re.compile(r'erotik|erotisch|pornograf|pornograph', re.I)
# Schriftwerke, die keine Lesebücher sind: Gesetze, Verträge, heilige Schriften, Zeitschriften …
# Hetz-, Propaganda- und Anleitungsschriften: gehören nicht in eine Lese-App für Kinder und Jugendliche.
AUSSCHLUSS = set('Q48244 Q26193 Q662930 Q1542194 Q486292 Q706852 Q1198947 Q1137873 Q3058688 Q2367117 Q2628198 Q38343 Q468041 Q7734955 Q7756256 Q566691 Q951265 Q1193264 Q2009607 Q1926728'.split())

KEIN_LESEBUCH = re.compile(
    r'gesetz|verfassung|vertrag|abkommen|charta|deklaration|erklärung der|resolution|verordnung|'
    r'bibel|evangeli|testament|koran|sure\b|psalm|brief des|brief an die|enzyklika|katechismus|'
    r'zeitschrift|zeitung|magazin|periodikum|wörterbuch|lexikon|enzyklopädie|handschrift|kodex|'
    r'codex|inschrift|urkunde|lehrbuch|schulbuch|kurzgeschichte\b|gedicht von|^gedicht|aufsatz|'
    r'zeitungsartikel|fachartikel|\brede\b|predigt|songtext|libretto', re.I)


def normal(s):
    s = unicodedata.normalize('NFKD', s.lower()).replace('ß', 'ss')
    return re.sub(r'[^a-z0-9]', '', ''.join(c for c in s if not unicodedata.combining(c)))


def holen(url, daten=None, versuche=4):
    for i in range(versuche):
        try:
            req = urllib.request.Request(url, data=daten, headers={
                'User-Agent': UA, 'Accept': 'application/sparql-results+json, application/json'})
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.loads(r.read(), strict=False)  # Wikidata-Titel enthalten manchmal Steuerzeichen
        except urllib.error.HTTPError as e:
            print(f'  HTTP {e.code} – Versuch {i + 1}')
            time.sleep(10 * (i + 1) if e.code == 429 else 3 * (i + 1))
        except Exception as e:  # noqa: BLE001 – Netzfehler einfach erneut versuchen
            print(f'  Fehler {e} – Versuch {i + 1}')
            time.sleep(3 * (i + 1))
    return None


def sparql(abfrage):
    url = 'https://query.wikidata.org/sparql'
    return holen(url, urllib.parse.urlencode({'query': abfrage, 'format': 'json'}).encode())


def kandidaten():
    """Alle Werke der ARTEN mit deutschem Wikipedia-Artikel → {Q-ID: (Titel, Sprachen)}."""
    alle = {}
    for art in ARTEN:
        abfrage = f'''
SELECT ?item ?titel ?links WHERE {{
  ?item wdt:P31 wd:{art} .
  ?artikel schema:about ?item ; schema:isPartOf <https://de.wikipedia.org/> ; schema:name ?titel .
  ?item wikibase:sitelinks ?links .
}}'''
        antwort = sparql(abfrage)
        if not antwort:
            print(f'{art}: keine Antwort')
            continue
        n = 0
        for b in antwort['results']['bindings']:
            q = b['item']['value'].rsplit('/', 1)[-1]
            alle.setdefault(q, (b['titel']['value'], int(b['links']['value'])))
            n += 1
        print(f'{art}: {n} Werke')
        time.sleep(2)
    return alle


def kandidaten_mit_label(vorhanden, mindestens=4):
    """Zweite Runde: bekannte Werke mit deutschem Titel, aber ohne deutschen Artikel."""
    alle = {}
    for art in ['Q7725634', 'Q47461344', 'Q571']:
        for unten, oben in [(30, 1000), (15, 30), (8, 15), (mindestens, 8)]:
            abfrage = f'''
SELECT ?item ?titel ?links WHERE {{
  ?item wdt:P31 wd:{art} ; wikibase:sitelinks ?links .
  FILTER(?links >= {unten} && ?links < {oben})
  ?item rdfs:label ?titel . FILTER(LANG(?titel) = "de")
  FILTER NOT EXISTS {{ ?artikel schema:about ?item ; schema:isPartOf <https://de.wikipedia.org/> . }}
}}'''
            antwort = sparql(abfrage)
            if not antwort:
                print(f'{art} {unten}–{oben}: keine Antwort')
                continue
            for b in antwort['results']['bindings']:
                q = b['item']['value'].rsplit('/', 1)[-1]
                if q not in vorhanden:
                    alle.setdefault(q, (b['titel']['value'], int(b['links']['value'])))
            print(f'{art} {unten}–{oben}: {len(antwort["results"]["bindings"])} Werke')
            time.sleep(2)
    return alle


def entitaeten(ids):
    """Details zu bis zu 50 Wikidata-Einträgen."""
    url = 'https://www.wikidata.org/w/api.php?' + urllib.parse.urlencode({
        'action': 'wbgetentities', 'ids': '|'.join(ids), 'format': 'json',
        'props': 'labels|descriptions|claims', 'languages': 'de|en',
    })
    antwort = holen(url) or {}
    return antwort.get('entities', {})


def werte(e, eigenschaft):
    for c in e.get('claims', {}).get(eigenschaft, []):
        v = c.get('mainsnak', {}).get('datavalue', {}).get('value')
        if v is not None:
            yield v


def label(e):
    l = e.get('labels', {})
    return (l.get('de') or l.get('en') or {}).get('value', '')


def katalog_titel():
    """Normalisierte Titel aller Bücher, die schon in der App sind."""
    titel = set()
    for datei in (APP / 'lib' / 'data').glob('katalog*.dart'):
        for m in re.finditer(r"titel: '((?:[^'\\]|\\.)*)'", datei.read_text(encoding='utf-8')):
            titel.add(normal(m.group(1).replace("\\'", "'")))
    return titel


def main():
    ziel = ZIEL
    if '--max' in sys.argv:
        ziel = int(sys.argv[sys.argv.index('--max') + 1])
    vorhanden = katalog_titel()
    platz = max(0, ziel - len(vorhanden))
    print(f'{len(vorhanden)} Bücher schon in der App, Platz für {platz}')

    kand = kandidaten()
    reihenfolge = sorted(kand.items(), key=lambda x: -x[1][1])
    print(f'{len(kand)} Kandidaten mit deutschem Wikipedia-Artikel')
    # Reicht das nicht, kommen bekannte Werke mit deutschem Titel ohne Artikel dazu (danach sortiert).
    zweite = kandidaten_mit_label(kand)
    reihenfolge += sorted(zweite.items(), key=lambda x: -x[1][1])
    print(f'{len(zweite)} weitere Kandidaten mit deutschem Titel')

    buecher, bericht, gesehen = [], [], set(vorhanden)
    personen = {}
    # In Blöcken arbeiten, bis genug Bücher beisammen sind.
    for start in range(0, len(reihenfolge), 50):
        if len(buecher) >= platz:
            break
        block = reihenfolge[start:start + 50]
        daten = entitaeten([q for q, _ in block])
        time.sleep(0.3)
        roh = []
        for q, (titel, links) in block:
            e = daten.get(q)
            if not e:
                continue
            titel = re.sub(r'\s*\([^)]*\)\s*$', '', titel).strip()  # „Momo (Roman)" → „Momo"
            autoren = [v['id'] for v in werte(e, 'P50') if isinstance(v, dict)]
            genres = [v['id'] for v in werte(e, 'P136') if isinstance(v, dict)]
            publikum = [v['id'] for v in werte(e, 'P2360') if isinstance(v, dict)]
            jahre = [int(m.group(1)) for v in werte(e, 'P577') if isinstance(v, dict)
                     if (m := re.match(r'[+-](\d{1,4})-', v.get('time', '')))]
            seiten = [int(float(v['amount'])) for v in werte(e, 'P1104') if isinstance(v, dict) and 'amount' in v]
            beschreibung = (e.get('descriptions', {}).get('de') or {}).get('value', '')
            roh.append((q, titel, links, autoren, genres, publikum, jahre, seiten, beschreibung))

        # Namen von Autoren und Genres nachladen (gesammelt, je 50).
        offen = list({i for r in roh for i in r[3] + r[4] + r[5] if i not in personen})
        for i in range(0, len(offen), 50):
            for qid, e in entitaeten(offen[i:i + 50]).items():
                personen[qid] = label(e)
            time.sleep(0.3)

        for q, titel, links, autoren, genres, publikum, jahre, seiten, beschreibung in roh:
            if not titel or normal(titel) in gesehen or q in AUSSCHLUSS:
                continue
            genre_namen = [personen.get(g, '') for g in genres]
            publikum_namen = [personen.get(p, '') for p in publikum]
            text = ' | '.join(genre_namen + publikum_namen + [beschreibung]).lower()
            if VERBOTEN.search(text) or KEIN_LESEBUCH.search(text):
                continue
            if not autoren:
                continue  # ohne bekannten Autor meist kein Lesebuch
            jahr = min(jahre) if jahre else 0
            tags = {t for t, woerter in SCHLUESSEL.items() if any(w in text for w in woerter)}
            if 0 < jahr < 1950:
                tags.add('klassiker')
            if 'kinder' in text or 'bilderbuch' in text:
                ziel_gruppe = 'kinder'
            elif 'jugend' in text or 'young adult' in text:
                ziel_gruppe = 'jugend'
            else:
                ziel_gruppe = 'erwachsene'
            autor = ', '.join(n for n in (personen.get(a, '') for a in autoren[:2]) if n) or 'Unbekannt'
            gesehen.add(normal(titel))
            buecher.append({
                'id': f'wd_{q}', 't': titel, 'a': autor, 'j': jahr, 's': seiten[0] if seiten else 0,
                'z': ziel_gruppe, 'g': sorted(tags), 'b': beschreibung[:200],
                'm': 16 if 'horror' in tags and ziel_gruppe == 'erwachsene' else 0,
            })
            if len(buecher) >= platz:
                break
        if start % 1000 == 0:
            print(f'  {start} geprüft, {len(buecher)} übernommen')

    AUSGABE.parent.mkdir(parents=True, exist_ok=True)
    with gzip.open(AUSGABE, 'wt', encoding='utf-8') as f:
        json.dump(buecher, f, ensure_ascii=False, separators=(',', ':'))
    mit_tags = sum(1 for b in buecher if b['g'])
    bericht.append(f'{len(buecher)} Bücher aus Wikidata ({mit_tags} mit Genre-Merkmalen); '
                   f'Kinder {sum(b["z"] == "kinder" for b in buecher)}, '
                   f'Jugend {sum(b["z"] == "jugend" for b in buecher)}, '
                   f'Erwachsene {sum(b["z"] == "erwachsene" for b in buecher)}')
    bericht += [f'{b["t"]} – {b["a"]} ({b["j"]}) {",".join(b["g"])}' for b in buecher[:300]]
    BERICHT.write_text('\n'.join(bericht) + '\n', encoding='utf-8')
    print(bericht[0])


if __name__ == '__main__':
    main()
