"""Lädt die Fischerei-Verordnungen der Bundesländer aus dem RIS (OGD-API).

Läuft in GitHub Actions (vom Container aus ist das RIS gesperrt).
Speichert für jedes Bundesland die gefundenen Dokumente als Text unter
tools/quellen/ris/<land>/ sowie die rohen Suchergebnisse zum Nachprüfen.
"""

import json
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from html import unescape
from pathlib import Path

ZIEL = Path(__file__).resolve().parent / 'quellen' / 'ris'
UA = 'AustroAngler/1.0 (Lern-Projekt; github.com/snake10-cool)'
API = 'https://data.bka.gv.at/ris/api/v2.6/Landesrecht'

LAENDER = {
    'wien': 'Wien', 'noe': 'Niederoesterreich', 'bgld': 'Burgenland',
    'ooe': 'Oberoesterreich', 'sbg': 'Salzburg', 'stmk': 'Steiermark',
    'ktn': 'Kaernten', 'tirol': 'Tirol', 'vbg': 'Vorarlberg',
}
# (Feld, Wert): Titel-Suche mit Platzhalter und Volltext-Suche.
SUCHEN = [
    ('Titel', 'Fischerei*'), ('Titel', 'Fischerei'), ('Titel', '*fischerei*'),
    ('Suchworte', 'Schonzeit'), ('Suchworte', 'Brittelmaß'),
    ('Suchworte', 'Mindestmaß'), ('Suchworte', 'Fischerei'),
]
SEITEN = 4


def holen(url):
    req = urllib.request.Request(url, headers={'User-Agent': UA,
                                               'Accept': 'application/json'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def text_aus_html(html):
    html = re.sub(r'(?is)<(script|style).*?</\1>', ' ', html)
    html = re.sub(r'(?i)<br\s*/?>|</p>|</tr>|</h\d>|</li>|</div>', '\n', html)
    html = re.sub(r'(?i)</td>', ' | ', html)
    text = unescape(re.sub(r'<[^>]+>', ' ', html))
    text = re.sub(r'[ \t\xa0]+', ' ', text)
    return re.sub(r'\n\s*\n+', '\n\n', text).strip()


def links(obj):
    """Alle Dokument-URLs (HTML) aus der API-Antwort."""
    gefunden = []
    def gehen(o):
        if isinstance(o, dict):
            for k, v in o.items():
                if isinstance(v, str) and v.startswith('http') and (
                        v.endswith('.html') or 'Dokument.wxe' in v):
                    gefunden.append(v)
                else:
                    gehen(v)
        elif isinstance(o, list):
            for x in o:
                gehen(x)
    gehen(obj)
    return list(dict.fromkeys(gefunden))


def anlagen_holen(html, basis, ziel):
    """Anlagen (z. B. Tirol: Schonzeit-Tabellen) liegen oft nur als PDF bei."""
    pdfs = []
    for a in re.finditer(r'(?is)<a[^>]+href="([^"]+\.pdf)"[^>]*>(.*?)</a>', html):
        url, text = unescape(a.group(1)), re.sub(r'<[^>]+>', ' ', a.group(2))
        if re.search(r'(?i)anl|beil', url + ' ' + text):
            pdfs.append(urllib.parse.urljoin(basis, url))
    for i, url in enumerate(list(dict.fromkeys(pdfs))[:25]):
        try:
            pdf = holen(url)
        except Exception as e:  # noqa: BLE001
            print(f'  {url}: {e}')
            continue
        datei = Path(f'{ziel}_anlage{i:02d}.pdf')
        datei.write_bytes(pdf)
        try:
            subprocess.run(['pdftotext', '-layout', str(datei),
                            str(datei.with_suffix('.txt'))], check=True)
            text = datei.with_suffix('.txt').read_text(encoding='utf-8', errors='replace')
            datei.with_suffix('.txt').write_text(f'QUELLE: {url}\n\n' + text, encoding='utf-8')
        except Exception as e:  # noqa: BLE001
            print(f'  pdftotext {url}: {e}')
        datei.unlink()
        time.sleep(0.5)


# Salzburg: Schonzeiten legt der Landesfischereiverband fest (nicht im RIS).
WEB = {
    'sbg_web': [
        'https://www.fischereiverband.at/node/147',
        'https://www.salzburg.gv.at/themen/aw/jagd/fischerei',
        'https://www.angel-urlaub.at/fischen/salzburg/schonzeiten/',
        'https://ssfv.at/images/content/Bestimmungen.pdf',
        'https://www.ssfv.at/wp-content/uploads/2021/01/Bestimmungen2021.pdf',
    ],
}


def web_holen():
    for kurz, urls in WEB.items():
        ordner = ZIEL / kurz
        ordner.mkdir(parents=True, exist_ok=True)
        for i, url in enumerate(urls):
            try:
                roh = holen(url)
            except Exception as e:  # noqa: BLE001
                print(f'  {url}: {e}')
                continue
            datei = ordner / f'{i:02d}'
            if url.endswith('.pdf') or roh[:4] == b'%PDF':
                datei.with_suffix('.pdf').write_bytes(roh)
                subprocess.run(['pdftotext', '-layout', str(datei.with_suffix('.pdf')),
                                str(datei.with_suffix('.txt'))], check=False)
                datei.with_suffix('.pdf').unlink()
                if datei.with_suffix('.txt').exists():
                    t = datei.with_suffix('.txt').read_text(encoding='utf-8', errors='replace')
                    datei.with_suffix('.txt').write_text(f'QUELLE: {url}\n\n{t}', encoding='utf-8')
            else:
                html = roh.decode('utf-8', 'replace')
                for a in re.finditer(r'href="([^"]+\.pdf)"', html):
                    link = urllib.parse.urljoin(url, unescape(a.group(1)))
                    if re.search(r'(?i)schon|brittel|mindest|verordnung', link) and link not in urls:
                        urls.append(link)
                datei.with_suffix('.txt').write_text(
                    f'QUELLE: {url}\n\n' + text_aus_html(html), encoding='utf-8')
            time.sleep(0.5)


def treffer(daten):
    try:
        r = daten['OgdSearchResult']['OgdDocumentResults']['OgdDocumentReference']
    except (KeyError, TypeError):
        return []
    return r if isinstance(r, list) else [r]


def main():
    ZIEL.mkdir(parents=True, exist_ok=True)
    web_holen()
    if '--nur-web' in sys.argv:
        return
    uebersicht = {}
    for kurz, land in LAENDER.items():
        ordner = ZIEL / kurz
        if ordner.exists():
            for alt in ordner.iterdir():
                alt.unlink()
        ordner.mkdir(exist_ok=True)
        gesetze = {}  # Gesetzesnummer -> (Kurztitel, URL der geltenden Fassung)
        for feld, wert in SUCHEN:
            for seite in range(1, SEITEN + 1):
                params = {
                    'Applikation': 'LrKons',
                    feld: wert,
                    'Bundesland.SucheIn' + land: 'true',
                    'DokumenteProSeite': 'OneHundred',
                    'Seitennummer': seite,
                }
                url = API + '?' + urllib.parse.urlencode(params)
                try:
                    daten = json.loads(holen(url))
                except Exception as e:  # noqa: BLE001
                    print(f'{kurz} {feld}={wert}: Fehler {e}')
                    break
                liste = treffer(daten)
                for t in liste:
                    lr = t.get('Data', {}).get('Metadaten', {}).get('Landesrecht', {})
                    kons = lr.get('LrKons', {})
                    titel = lr.get('Kurztitel', '') or ''
                    nr = kons.get('Gesetzesnummer')
                    ganz = kons.get('GesamteRechtsvorschriftUrl')
                    if nr and ganz and re.search(r'(?i)fisch', titel + ' ' + str(kons.get('Indizes', ''))):
                        gesetze.setdefault(nr, (titel, ganz))
                time.sleep(0.5)
                if len(liste) < 100:
                    break
        uebersicht[kurz] = {nr: t for nr, (t, _) in gesetze.items()}
        print(f'{kurz}: {len(gesetze)} Rechtsvorschriften')
        for nr, (titel, ganz) in gesetze.items():
            try:
                html = holen(ganz).decode('utf-8', 'replace')
            except Exception as e:  # noqa: BLE001
                print(f'  {ganz}: {e}')
                continue
            name = re.sub(r'[^A-Za-z0-9]+', '_', titel)[:60]
            (ordner / f'{nr}_{name}.txt').write_text(
                f'QUELLE: {ganz}\nTITEL: {titel}\n\n' + text_aus_html(html),
                encoding='utf-8')
            time.sleep(0.5)
            if re.search(r'(?i)fisch', titel):
                anlagen_holen(html, ganz, ordner / f'{nr}_{name}')
    (ZIEL / 'uebersicht.json').write_text(
        json.dumps(uebersicht, indent=1, ensure_ascii=False), encoding='utf-8')


if __name__ == '__main__':
    sys.exit(main())
