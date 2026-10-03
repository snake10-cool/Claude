"""Holt Fisch- und Knotenbilder von Wikipedia/Wikimedia Commons.

Läuft in GitHub Actions (dort ist Wikimedia erreichbar). Für jeden Eintrag
wird das Hauptbild des Wikipedia-Artikels geladen, auf max. 800 px
verkleinert und mit Urheber und Lizenz gespeichert. Nur freie Lizenzen
(Public Domain, CC0, CC BY, CC BY-SA) werden übernommen.

Ausgabe:
  apps/austro_angler/assets/bilder/{fische,knoten}/<id>.jpg
  apps/austro_angler/lib/data/bilder.dart  (Quellenangaben für die App)
"""

import html
import io
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image

WURZEL = Path(__file__).resolve().parent.parent / 'apps' / 'austro_angler'
UA = 'AustroAngler/0.3 (https://github.com/snake10-cool/Claude; Lern-Projekt)'

# id → Liste von (Sprache, Artikel) – der erste Treffer mit freier Lizenz zählt.
FISCHE = {
    'bachforelle': [('de', 'Bachforelle'), ('en', 'Brown trout')],
    'regenbogenforelle': [('de', 'Regenbogenforelle'), ('en', 'Rainbow trout')],
    'seeforelle': [('de', 'Seeforelle'), ('en', 'Lake trout (Salmo trutta lacustris)')],
    'bachsaibling': [('de', 'Bachsaibling'), ('en', 'Brook trout')],
    'seesaibling': [('de', 'Seesaibling'), ('en', 'Arctic char')],
    'aesche': [('de', 'Äsche'), ('en', 'Grayling (species)')],
    'huchen': [('de', 'Huchen'), ('en', 'Huchen')],
    'reinanke': [('de', 'Große Schwebrenke'), ('en', 'Coregonus lavaretus')],
    'hecht': [('de', 'Hecht'), ('en', 'Northern pike')],
    'zander': [('de', 'Zander'), ('en', 'Zander')],
    'flussbarsch': [('de', 'Flussbarsch'), ('en', 'European perch')],
    'wels': [('de', 'Europäischer Wels'), ('en', 'Wels catfish')],
    'aalrutte': [('de', 'Quappe'), ('en', 'Burbot')],
    'karpfen': [('de', 'Karpfen'), ('en', 'Common carp')],
    'schleie': [('de', 'Schleie'), ('en', 'Tench')],
    'brachse': [('de', 'Brachse'), ('en', 'Common bream')],
    'barbe': [('de', 'Barbe (Fisch)'), ('en', 'Barbus barbus')],
    'nase': [('de', 'Nase (Fisch)'), ('en', 'Common nase')],
    'aitel': [('de', 'Döbel'), ('en', 'Common chub')],
    'rapfen': [('de', 'Rapfen'), ('en', 'Asp (fish)')],
    'rotauge': [('de', 'Plötze'), ('en', 'Common roach')],
    'rotfeder': [('de', 'Rotfeder'), ('en', 'Common rudd')],
    'laube': [('de', 'Ukelei'), ('en', 'Common bleak')],
    'seelaube': [('de', 'Mairenke'), ('en', 'Alburnus mento')],
    'giebel': [('de', 'Giebel'), ('en', 'Prussian carp')],
    'karausche': [('de', 'Karausche'), ('en', 'Crucian carp')],
    'perlfisch': [('de', 'Perlfisch'), ('en', 'Rutilus meidingeri')],
    'kaulbarsch': [('de', 'Kaulbarsch'), ('en', 'Eurasian ruffe')],
    'aal': [('de', 'Europäischer Aal'), ('en', 'European eel')],
    'koppe': [('de', 'Groppe'), ('en', 'European bullhead')],
    'elritze': [('de', 'Elritze'), ('en', 'Eurasian minnow')],
}

KNOTEN = {
    'clinch': [('en', 'Improved clinch knot'), ('en', 'Clinch knot')],
    'palomar': [('en', 'Palomar knot')],
    'grinner': [('en', 'Uni knot')],
    'doppelter_grinner': [('en', 'Double uni knot'), ('en', 'Uni knot')],
    'chirurgenschlaufe': [('en', "Surgeon's loop")],
}

FREI = re.compile(r'^(public domain|pd|cc0|cc[- ]by(-sa)?[- ]?\d)', re.I)


def api(sprache, **params):
    params.update(format='json', formatversion='2')
    url = (f'https://{sprache}.wikipedia.org/w/api.php?'
           if sprache != 'commons'
           else 'https://commons.wikimedia.org/w/api.php?')
    url += urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.load(r)


def ohne_html(text):
    return html.unescape(re.sub(r'<[^>]+>', '', text or '')).strip()


def bild_fuer(sprache, titel):
    """(Bild-URL, Dateiname, Urheber, Lizenz) oder None."""
    seite = api(sprache, action='query', prop='pageimages', piprop='name',
                titles=titel, redirects=1)['query']['pages'][0]
    datei = seite.get('pageimage')
    if not datei:
        return None
    info = api('commons', action='query', prop='imageinfo',
               titles=f'File:{datei}', iiprop='url|extmetadata',
               iiurlwidth=800)['query']['pages'][0]
    if 'imageinfo' not in info:
        # Datei liegt nur in der lokalen Wikipedia, nicht auf Commons.
        info = api(sprache, action='query', prop='imageinfo',
                   titles=f'File:{datei}', iiprop='url|extmetadata',
                   iiurlwidth=800)['query']['pages'][0]
    ii = info['imageinfo'][0]
    meta = ii.get('extmetadata', {})
    lizenz = ohne_html(meta.get('LicenseShortName', {}).get('value'))
    urheber = ohne_html(meta.get('Artist', {}).get('value')) or 'unbekannt'
    if not FREI.match(lizenz):
        print(f'  ✗ {datei}: Lizenz "{lizenz}" nicht frei', file=sys.stderr)
        return None
    return ii.get('thumburl') or ii['url'], datei, urheber[:120], lizenz


def laden(url):
    req = urllib.request.Request(url, headers={'User-Agent': UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def speichern(roh, ziel):
    bild = Image.open(io.BytesIO(roh))
    if bild.mode in ('RGBA', 'LA', 'P'):
        hintergrund = Image.new('RGB', bild.size, 'white')
        bild = bild.convert('RGBA')
        hintergrund.paste(bild, mask=bild.split()[-1])
        bild = hintergrund
    bild = bild.convert('RGB')
    bild.thumbnail((800, 800))
    bild.save(ziel, 'JPEG', quality=82, optimize=True)


def verarbeiten(gruppe, eintraege):
    quellen = {}
    ordner = WURZEL / 'assets' / 'bilder' / gruppe
    ordner.mkdir(parents=True, exist_ok=True)
    for id_, kandidaten in eintraege.items():
        for sprache, titel in kandidaten:
            try:
                treffer = bild_fuer(sprache, titel)
            except Exception as e:  # noqa: BLE001
                print(f'  ! {id_} ({sprache}:{titel}): {e}', file=sys.stderr)
                treffer = None
            if treffer:
                url, datei, urheber, lizenz = treffer
                speichern(laden(url), ordner / f'{id_}.jpg')
                quellen[id_] = {
                    'datei': datei, 'urheber': urheber, 'lizenz': lizenz,
                }
                print(f'✓ {gruppe}/{id_}: {datei} ({lizenz}, {urheber})')
                break
            time.sleep(0.5)
        else:
            print(f'– {gruppe}/{id_}: kein freies Bild gefunden')
    return quellen


def dart_string(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def main():
    fische = verarbeiten('fische', FISCHE)
    knoten = verarbeiten('knoten', KNOTEN)

    zeilen = [
        '// Automatisch erzeugt von tools/bilder_holen.py – nicht von Hand ändern.',
        '',
        'class BildQuelle {',
        '  const BildQuelle(this.pfad, this.datei, this.urheber, this.lizenz);',
        '',
        '  final String pfad;',
        '  final String datei;',
        '  final String urheber;',
        '  final String lizenz;',
        '',
        "  String get text => 'Bild: $urheber, $lizenz, via Wikimedia Commons';",
        '}',
        '',
    ]
    for name, gruppe, daten in (('fischBilder', 'fische', fische),
                                ('knotenBilder', 'knoten', knoten)):
        zeilen.append(f'const {name} = <String, BildQuelle>{{')
        for id_, q in daten.items():
            zeilen.append(
                f"  '{id_}': BildQuelle('assets/bilder/{gruppe}/{id_}.jpg', "
                f"{dart_string(q['datei'])}, {dart_string(q['urheber'])}, "
                f"{dart_string(q['lizenz'])}),")
        zeilen.append('};')
        zeilen.append('')
    (WURZEL / 'lib' / 'data' / 'bilder.dart').write_text('\n'.join(zeilen))
    print(f'\n{len(fische)} Fischbilder, {len(knoten)} Knotenbilder.')


if __name__ == '__main__':
    main()
