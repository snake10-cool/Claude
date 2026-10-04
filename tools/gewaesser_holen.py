"""Erzeugt die Liste aller benannten Gewässer Österreichs aus OpenStreetMap.

Läuft in GitHub Actions (Workflow "Gewässer holen"):
  1. austria-latest.osm.pbf von Geofabrik laden
  2. mit osmium auf Gewässer und Verwaltungsgrenzen filtern
  3. als GeoJSON-Sequenz exportieren
  4. dieses Skript: jedem Gewässer Bundesland, Bezirk und Gemeinde zuordnen

Aufruf: python gewaesser_holen.py daten.geojsonseq ausgabe.json.gz

Ausgabe (kompakt, gzip):
  {
    "stand": "2026-10-04",
    "laender": ["Wien", ...],                 # Reihenfolge wie Bundesland-Enum
    "bezirke": [["Braunau am Inn", 3], ...],  # Name, Index in laender
    "gemeinden": [["Mattighofen", 17], ...],  # Name, Index in bezirke
    "gewaesser": [[id, name, typ, lat, lon, [gemeinde...], groesse], ...]
  }
typ: f = Fluss, b = Bach, k = Kanal, s = See, t = Teich
groesse: km Länge (Fließgewässer im Bezirk) bzw. ha Fläche (stehende Gewässer)
"""

import datetime
import gzip
import json
import math
import sys
from collections import defaultdict

import numpy as np
import shapely
from shapely.geometry import shape
from shapely.strtree import STRtree

LAENDER = ['Wien', 'Niederösterreich', 'Burgenland', 'Oberösterreich',
           'Salzburg', 'Steiermark', 'Kärnten', 'Tirol', 'Vorarlberg']

FLIESS = {'river': 'f', 'stream': 'b', 'canal': 'k'}
RANG = {'b': 0, 'k': 1, 'f': 2}
# Flächen mit diesen water=-Werten sind keine eigenen Angelgewässer
# (Flussflächen haben schon ihre Linie) oder kein Fischgewässer.
OHNE = {'river', 'stream', 'canal', 'wastewater', 'lock', 'fountain',
        'reflecting_pool', 'basin', 'drain', 'ditch', 'stream_pool'}


def km_laenge(coords):
    a = np.asarray(coords, dtype=float)
    if len(a) < 2:
        return 0.0
    lon, lat = np.radians(a[:, 0]), np.radians(a[:, 1])
    dlat, dlon = np.diff(lat), np.diff(lon)
    h = (np.sin(dlat / 2) ** 2
         + np.cos(lat[:-1]) * np.cos(lat[1:]) * np.sin(dlon / 2) ** 2)
    return float(np.sum(2 * 6371.0 * np.arcsin(np.sqrt(h))))


def hektar(geom):
    lat = geom.centroid.y
    m_pro_grad = 111_320.0
    return geom.area * m_pro_grad * m_pro_grad * math.cos(math.radians(lat)) / 10_000


def bezirk_name(n):
    for p in ('Bezirk ', 'Statutarstadt '):
        if n.startswith(p):
            return n[len(p):]
    return n


def main(eingabe, ausgabe):
    admin = {4: [], 6: [], 8: [], 9: []}      # (name, geom)
    linien = []                                # (name, typ, LineString, osmid)
    flaechen = []                              # (name, water, landuse, geom, osmid)

    with open(eingabe, encoding='utf-8') as f:
        for zeile in f:
            zeile = zeile.strip().lstrip('\x1e')
            if not zeile:
                continue
            feat = json.loads(zeile)
            p = feat.get('properties') or {}
            name = (p.get('name') or '').strip()
            if not name:
                continue
            g = feat.get('geometry')
            if not g:
                continue
            gtyp = g['type']
            osmid = f"{p.get('@type', 'x')[:1]}{p.get('@id', '')}"
            if p.get('boundary') == 'administrative' and gtyp in ('Polygon', 'MultiPolygon'):
                try:
                    lvl = int(p.get('admin_level', '0'))
                except ValueError:
                    continue
                if lvl in admin:
                    geom = shapely.make_valid(shape(g))
                    admin[lvl].append((name, geom))
                continue
            ww = p.get('waterway')
            if ww in FLIESS and gtyp == 'LineString':
                linien.append((name, FLIESS[ww], shape(g), osmid))
                continue
            if gtyp in ('Polygon', 'MultiPolygon') and (
                    p.get('natural') == 'water' or p.get('landuse') == 'reservoir'):
                if p.get('water') in OHNE or p.get('leisure') == 'swimming_pool':
                    continue
                flaechen.append((name, p.get('water') or '', p.get('landuse') or '',
                                 shape(g), osmid))

    print(f'Grenzen: { {k: len(v) for k, v in admin.items()} }')
    print(f'Fließgewässer-Stücke: {len(linien)}, Flächen: {len(flaechen)}')

    # --- Verwaltungseinheiten in Österreich ---------------------------------
    land_geoms = {}
    for name, geom in admin[4]:
        if name in LAENDER:
            alt = land_geoms.get(name)
            land_geoms[name] = geom if alt is None else alt.union(geom)
    fehlt = [l for l in LAENDER if l not in land_geoms]
    if fehlt:
        sys.exit(f'Bundesländer fehlen: {fehlt}')
    land_liste = [land_geoms[l] for l in LAENDER]
    land_baum = STRtree(land_liste)

    def land_von(geom):
        pt = geom.representative_point()
        treffer = land_baum.query(pt, predicate='within')
        return int(treffer[0]) if len(treffer) else None

    bezirke, bezirk_geoms = [], []           # [name, land], geom
    for name, geom in admin[6]:
        l = land_von(geom)
        if l is not None:
            bezirke.append([bezirk_name(name), l])
            bezirk_geoms.append(geom)
    # Wien hat keine Bezirke auf Ebene 6: das ganze Land ist ein "Bezirk".
    for i, l in enumerate(LAENDER):
        if not any(b[1] == i for b in bezirke):
            bezirke.append([l, i])
            bezirk_geoms.append(land_liste[i])
    bezirk_baum = STRtree(bezirk_geoms)

    gemeinden, gemeinde_geoms = [], []       # [name, bezirk], geom
    gem_index = {}

    def gemeinde_dazu(name, geom):
        pt = geom.representative_point()
        t = bezirk_baum.query(pt, predicate='within')
        if not len(t):
            return
        b = int(t[0])
        schluessel = (name, b)
        if schluessel in gem_index:
            return
        gem_index[schluessel] = len(gemeinden)
        gemeinden.append([name, b])
        gemeinde_geoms.append(geom)

    for name, geom in admin[8]:
        gemeinde_dazu(name, geom)
    # Wiener Gemeindebezirke (Ebene 9) als "Orte" von Wien.
    wien = LAENDER.index('Wien')
    for name, geom in admin[9]:
        if land_von(geom) == wien:
            gemeinde_dazu(name, geom)
    # Statutarstädte (Linz, Graz …) haben keine Gemeinden auf Ebene 8:
    # die Stadt selbst ist dann der Ort. Gleichnamige Bezirke (St. Pölten,
    # Wiener Neustadt) bekommen den Zusatz "(Stadt)".
    namen = defaultdict(int)
    for b in bezirke:
        namen[b[0]] += 1
    mit_gemeinden = {g[1] for g in gemeinden}
    for i, b in enumerate(bezirke):
        if i in mit_gemeinden:
            continue
        if namen[b[0]] > 1:
            b[0] = f'{b[0]} (Stadt)'
        gem_index[(b[0], i)] = len(gemeinden)
        gemeinden.append([b[0], i])
        gemeinde_geoms.append(bezirk_geoms[i])
    gemeinde_baum = STRtree(gemeinde_geoms)
    print(f'Bezirke: {len(bezirke)}, Gemeinden: {len(gemeinden)}')

    def orte(punkte):
        """Für jeden Punkt (Gemeinde, Bezirk) oder (None, None)."""
        arr = np.array(punkte, dtype=object)
        gem = [None] * len(punkte)
        bez = [None] * len(punkte)
        if not len(punkte):
            return gem, bez
        ein, ziel = gemeinde_baum.query(arr, predicate='within')
        for i, z in zip(ein, ziel):
            if gem[i] is None:
                gem[i] = int(z)
                bez[i] = gemeinden[int(z)][1]
        rest = [i for i in range(len(punkte)) if bez[i] is None]
        if rest:
            ein, ziel = bezirk_baum.query(arr[rest], predicate='within')
            for i, z in zip(ein, ziel):
                j = rest[i]
                if bez[j] is None:
                    bez[j] = int(z)
        return gem, bez

    # --- Fließgewässer: pro Name und Bezirk ein Eintrag ---------------------
    punkte, info = [], []
    for name, typ, linie, osmid in linien:
        laenge = km_laenge(linie.coords)
        for anteil in (0.0, 0.5, 1.0):
            punkte.append(linie.interpolate(anteil, normalized=True))
            info.append((name, typ, laenge / 3, osmid, anteil, linie))
    gem, bez = orte(punkte)

    gruppen = {}
    for (name, typ, km, osmid, anteil, linie), pt, g, b in zip(info, punkte, gem, bez):
        if b is None:
            continue
        schl = (name.lower(), b)
        gr = gruppen.get(schl)
        if gr is None:
            gr = gruppen[schl] = {'name': name, 'typ': typ, 'km': 0.0, 'gem': set(),
                                  'best': -1.0, 'pt': pt, 'id': osmid}
        gr['km'] += km
        if RANG[typ] > RANG[gr['typ']]:
            gr['typ'] = typ
        if g is not None:
            gr['gem'].add(g)
        if anteil == 0.5 and km > gr['best']:
            gr['best'], gr['pt'], gr['id'] = km, pt, osmid

    eintraege = []
    for (_, b), gr in gruppen.items():
        if gr['km'] < 0.3:      # winzige Gräben-Stücke weglassen
            continue
        eintraege.append([gr['id'], gr['name'], gr['typ'], round(gr['pt'].y, 4),
                          round(gr['pt'].x, 4), sorted(gr['gem']),
                          round(gr['km'], 1), b])

    # --- Stehende Gewässer --------------------------------------------------
    punkte = [shapely.make_valid(f[3]).representative_point() for f in flaechen]
    gem, bez = orte(punkte)
    beste = {}
    for (name, water, landuse, geom, osmid), pt, g, b in zip(flaechen, punkte, gem, bez):
        if b is None:
            continue
        ha = hektar(geom)
        if ha < 0.05:          # unter 500 m²: Biotop, Löschteich …
            continue
        if water == 'pond':
            typ = 's' if ha >= 20 else 't'
        elif water == 'lake':
            typ = 's' if ha >= 1 else 't'
        else:
            typ = 's' if ha >= 5 else 't'
        schl = (name.lower(), g if g is not None else -1 - b)
        alt = beste.get(schl)
        if alt is None or ha > alt[6]:
            beste[schl] = [osmid, name, typ, round(pt.y, 4), round(pt.x, 4),
                           [g] if g is not None else [], round(ha, 1), b]
    eintraege.extend(beste.values())

    # Bezirk steckt in den Gemeinden; nur ohne Gemeinde extra speichern.
    aus = []
    for e in sorted(eintraege, key=lambda e: (e[1].lower(), e[7])):
        zeile = e[:7]
        if not e[5]:
            zeile.append(e[7])
        aus.append(zeile)

    daten = {
        'stand': datetime.date.today().isoformat(),
        'quelle': '© OpenStreetMap-Mitwirkende, ODbL',
        'laender': LAENDER,
        'bezirke': bezirke,
        'gemeinden': gemeinden,
        'gewaesser': aus,
    }
    roh = json.dumps(daten, ensure_ascii=False, separators=(',', ':')).encode()
    with open(ausgabe, 'wb') as f:
        f.write(gzip.compress(roh, 9, mtime=0))
    zaehl = defaultdict(int)
    for e in aus:
        zaehl[e[2]] += 1
    print(f'Gewässer: {len(aus)} {dict(zaehl)}, {len(roh) // 1024} KB roh')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
