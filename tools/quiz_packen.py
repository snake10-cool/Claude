#!/usr/bin/env python3
"""Packt alle tools/quellen/quiz_zusatz/*.json zu apps/buecherwurm/assets/daten/quiz_zusatz.json.gz.

Jede Quelldatei: {buchId: {"s": "leicht|mittel|schwierig" (optional), "q": [[Frage, richtig, falsch, falsch, falsch], …]}}
Prüft: mindestens 5 Fragen, 4 verschiedene Antworten, keine doppelten Fragen, Buch-ID existiert.
"""
import glob, gzip, json, os, re, sys

WURZEL = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(WURZEL, 'apps', 'buecherwurm')
ZIEL = os.path.join(APP, 'assets', 'daten', 'quiz_zusatz.json.gz')


def bekannte_ids():
    ids = set()
    for p in glob.glob(os.path.join(APP, 'lib', 'data', '*.dart')):
        ids |= set(re.findall(r"id: '([^']+)'", open(p, encoding='utf-8').read()))
    with gzip.open(os.path.join(APP, 'assets', 'daten', 'katalog_wikidata.json.gz')) as f:
        ids |= {b['id'] for b in json.load(f)}
    return ids


def main():
    ids = bekannte_ids()
    alles, fehler = {}, []
    for p in sorted(glob.glob(os.path.join(WURZEL, 'tools', 'quellen', 'quiz_zusatz', '*.json'))):
        for bid, w in json.load(open(p, encoding='utf-8')).items():
            ort = f'{os.path.basename(p)}:{bid}'
            if bid not in ids: fehler.append(f'{ort}: unbekannte Buch-ID')
            if bid in alles: fehler.append(f'{ort}: doppelt')
            q = w['q']
            if len(q) < 5: fehler.append(f'{ort}: nur {len(q)} Fragen')
            if len({f[0] for f in q}) != len(q): fehler.append(f'{ort}: doppelte Frage')
            for f in q:
                if len(f) != 5 or len(set(f[1:])) != 4 or not all(x.strip() for x in f):
                    fehler.append(f'{ort}: kaputte Frage {f[0][:50]!r}')
            if w.get('s') not in (None, 'leicht', 'mittel', 'schwierig'): fehler.append(f'{ort}: Stufe {w["s"]!r}')
            alles[bid] = {k: v for k, v in w.items() if k in ('s', 'q')}
    if fehler:
        print('\n'.join(fehler)); sys.exit(1)
    with gzip.open(ZIEL, 'wt', encoding='utf-8', compresslevel=9) as f:
        json.dump(alles, f, ensure_ascii=False, separators=(',', ':'))
    print(f'{len(alles)} Bücher, {sum(len(w["q"]) for w in alles.values())} Fragen -> {ZIEL}')


if __name__ == '__main__':
    main()
