"""Lädt die Fischerei-Verordnungen der Bundesländer aus dem RIS (OGD-API).

Läuft in GitHub Actions (vom Container aus ist das RIS gesperrt).
Speichert für jedes Bundesland die gefundenen Dokumente als Text unter
tools/quellen/ris/<land>/ sowie die rohen Suchergebnisse zum Nachprüfen.
"""

import json
import re
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
SUCHWORTE = ['Fischerei', 'Schonzeit', 'Fischereiverordnung']


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


def main():
    ZIEL.mkdir(parents=True, exist_ok=True)
    uebersicht = {}
    for kurz, land in LAENDER.items():
        ordner = ZIEL / kurz
        ordner.mkdir(exist_ok=True)
        alle = []
        for wort in SUCHWORTE:
            params = {
                'Applikation': 'LrKons',
                'Titel': wort,
                'Bundesland.SucheIn' + land: 'true',
                'DokumenteProSeite': 'Fifty',
            }
            url = API + '?' + urllib.parse.urlencode(params)
            try:
                roh = holen(url)
            except Exception as e:  # noqa: BLE001
                print(f'{kurz} {wort}: Fehler {e}')
                continue
            (ordner / f'_suche_{wort}.json').write_bytes(roh)
            try:
                daten = json.loads(roh)
            except ValueError:
                continue
            alle += links(daten)
            time.sleep(1)
        alle = list(dict.fromkeys(alle))[:40]
        uebersicht[kurz] = alle
        print(f'{kurz}: {len(alle)} Dokumente')
        for i, u in enumerate(alle):
            try:
                html = holen(u).decode('utf-8', 'replace')
            except Exception as e:  # noqa: BLE001
                print(f'  {u}: {e}')
                continue
            titel = re.search(r'(?is)<title>(.*?)</title>', html)
            name = re.sub(r'[^A-Za-z0-9]+', '_', (titel.group(1) if titel else str(i)))[:80]
            (ordner / f'{i:02d}_{name}.txt').write_text(
                f'QUELLE: {u}\n\n' + text_aus_html(html), encoding='utf-8')
            time.sleep(0.5)
    (ZIEL / 'uebersicht.json').write_text(
        json.dumps(uebersicht, indent=1, ensure_ascii=False), encoding='utf-8')


if __name__ == '__main__':
    sys.exit(main())
