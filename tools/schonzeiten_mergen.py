"""Schonzeiten/Brittelmaße aus tools/quellen/schonzeiten/<land>.json in fische.dart übernehmen.

Die JSON-Dateien wurden aus den RIS-Texten (tools/quellen/ris) gezogen, jeder Wert mit wörtlichem Beleg.
Danach: dart format lib/data/fische.dart
"""
import json, re, sys, os
D = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'quellen', 'schonzeiten')
DART = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'apps', 'austro_angler', 'lib', 'data', 'fische.dart')
LAENDER = [('ooe', '_ooe'), ('sbg', '_sbg'), ('wien', '_w'), ('noe', '_noe'), ('bgld', '_bgld'),
           ('stmk', '_stmk'), ('ktn', '_ktn'), ('tirol', '_t'), ('vbg', '_vbg')]
REIHE = ['_ooe', '_sbg', '_w', '_noe', '_bgld', '_stmk', '_ktn', '_t', '_vbg']
daten = {}
quellen = {}
for datei, k in LAENDER:
    p = f'{D}/{datei}.json'
    if os.path.exists(p):
        j = json.load(open(p))
        if j.get('arten'):
            daten[k] = j['arten']
            quellen[k] = (j.get('vorschrift', ''), j.get('quelle', ''))

s = open(DART).read()

def eintraege(body):
    """'_ooe: Regel(...),' -> {'_ooe': 'Regel(...)'} unter Beachtung von Klammern."""
    out, i = {}, 0
    while True:
        m = re.compile(r'\s*(_\w+):\s*').match(body, i)
        if not m: break
        j, tiefe, instr = m.end(), 0, False
        while j < len(body):
            c = body[j]
            if c == "'" and body[j-1] != '\\': instr = not instr
            elif not instr:
                if c in '([{': tiefe += 1
                elif c in ')]}': tiefe -= 1
                elif c == ',' and tiefe == 0: break
            j += 1
        out[m.group(1)] = body[m.end():j].strip()
        i = j + 1
    return out

def tag(t):
    t = t.strip().rstrip('.')
    tg, mo = t.split('.')[:2]
    return f'Tag({int(tg)}, {int(mo)})'

def dartstr(x):
    return "'" + x.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"

def regel(e, flags):
    h = e.get('hinweis')
    hz = f', hinweis: {dartstr(h)}' if h else ''
    if e.get('ganzjaehrig'):
        return f'Regel(ganzjaehrigGeschont: true{hz})'
    if e.get('keine') or not (e.get('von') or e.get('cm')):
        if 'ausgestorben' in flags and not h: return '_ausgestorben'
        if 'geschuetzt' in flags and not h: return 'Regel(hinweis: _geschuetzt)'
        if 'eingeschleppt' in flags and not h: return 'Regel(hinweis: _fremd)'
        return f'Regel({hz[2:]})' if h else '_keine'
    teile = []
    if e.get('von') and e.get('bis'):
        teile += [f'von: {tag(e["von"])}', f'bis: {tag(e["bis"])}']
    if e.get('cm'):
        teile.append(f'mindestmassCm: {int(e["cm"])}')
    if h: teile.append(f'hinweis: {dartstr(h)}')
    return 'Regel(' + ', '.join(teile) + ')'

geaendert = 0
def ersetzen(m):
    global geaendert
    block = m.group(0)
    fid = re.search(r"id: '([^']+)'", block).group(1)
    flags = {f for f in ['geschuetzt', 'eingeschleppt', 'ausgestorben']
             if re.search(rf'\b{f}: true', block)}
    r = re.search(r'regeln: \{(.*?)\n    \},', block, re.S)
    alt = eintraege(r.group(1))
    neu = dict(alt)
    for k, arten in daten.items():
        if fid in arten:
            neu[k] = regel(arten[fid], flags)
    if neu != alt: geaendert += 1
    zeilen = []
    for k in REIHE:
        if k in neu:
            zeilen.append(f'      {k}: {neu[k]},')
    return block[:r.start()] + 'regeln: {\n' + '\n'.join(zeilen) + '\n    },' + block[r.end():]

s = re.sub(r'  Fisch\(\n.*?\n  \),', ersetzen, s, flags=re.S)

# Quellen-Liste
q = ['/// Rechtsquellen der Schonzeiten und Brittelmaße (RIS, geltende Fassung).',
     'const schonzeitQuellen = <Bundesland, (String, String)>{']
for k, (t, u) in quellen.items():
    q.append(f'  {k}: ({dartstr(t)}, {dartstr(u)}),')
q.append('};')
q = '\n'.join(q) + '\n'
if 'const schonzeitQuellen' in s:
    s = re.sub(r'/// Rechtsquellen.*?\n\};\n', q, s, flags=re.S)
else:
    s = s.replace('const _geschuetzt =', q + '\nconst _geschuetzt =', 1)
open(DART, 'w').write(s)
print('Arten geändert:', geaendert, 'Länder:', list(daten))
