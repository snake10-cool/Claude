"""Ende-zu-Ende-Test gegen die echte Firebase-Datenbank mit zwei Testkonten.

Prüft die wichtigsten Abläufe UND die Sicherheitsregeln (was darf ein
fremdes Konto NICHT). Räumt am Ende alle Test-Daten wieder auf.

Aufruf: TESTKONTO_PASSWORT=... python3 tools/firebase_test.py
"""

import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

PROJEKT = 'austro-angler-202495bd'
API_KEY = 'AIzaSyCM_Y2UqxFRnLdBVpDJAzCUoTZltZyOJik'
BASIS = f'https://firestore.googleapis.com/v1/projects/{PROJEKT}/databases/(default)/documents'
KOPF = {'Content-Type': 'application/json', 'X-Android-Package': 'com.snake10.austroangler'}

ergebnisse = []


def anfrage(methode, url, daten=None, token=None):
    kopf = dict(KOPF)
    if token:
        kopf['Authorization'] = 'Bearer ' + token
    body = json.dumps(daten).encode() if daten is not None else None
    req = urllib.request.Request(url, data=body, method=methode, headers=kopf)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            t = r.read()
            return r.status, (json.loads(t) if t else {})
    except urllib.error.HTTPError as e:
        t = e.read()
        try:
            return e.code, json.loads(t)
        except ValueError:
            return e.code, {'roh': t.decode(errors='replace')}


def anmelden(email, pw):
    s, d = anfrage('POST', 'https://identitytoolkit.googleapis.com/v1/accounts:'
                   f'signInWithPassword?key={API_KEY}',
                   {'email': email, 'password': pw, 'returnSecureToken': True})
    if s != 200:
        sys.exit(f'Anmeldung {email} fehlgeschlagen: {d}')
    return d['localId'], d['idToken']


def wert(v):
    if v is None:
        return {'nullValue': None}
    if isinstance(v, bool):
        return {'booleanValue': v}
    if isinstance(v, int):
        return {'integerValue': str(v)}
    if isinstance(v, float):
        return {'doubleValue': v}
    if isinstance(v, str):
        return {'stringValue': v}
    if isinstance(v, list):
        return {'arrayValue': {'values': [wert(x) for x in v]}}
    if isinstance(v, dict):
        if v.get('__zeit__'):
            return {'timestampValue': v['__zeit__']}
        return {'mapValue': {'fields': {k: wert(x) for k, x in v.items()}}}
    raise TypeError(v)


def jetzt(plus_s=0):
    return {'__zeit__': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime(time.time() + plus_s))}


def doc_name(pfad):
    return f'projects/{PROJEKT}/databases/(default)/documents/{pfad}'


def commit(token, writes):
    return anfrage('POST', BASIS.replace('/documents', '/documents:commit'),
                   {'writes': writes}, token)


def setzen(token, pfad, felder, merge_felder=None):
    w = {'update': {'name': doc_name(pfad), 'fields': {k: wert(v) for k, v in felder.items()}}}
    if merge_felder is not None:
        w['updateMask'] = {'fieldPaths': merge_felder}
    return commit(token, [w])


def loeschen(token, pfad):
    return commit(token, [{'delete': doc_name(pfad)}])


def lesen(token, pfad):
    return anfrage('GET', f'{BASIS}/{pfad}', token=token)


def pruefe(name, ok, info=''):
    ergebnisse.append((name, ok, info))
    print(('✅' if ok else '❌'), name, ('' if ok else f'  → {info}'))


def erlaubt(name, antwort):
    s, d = antwort
    pruefe(name, s == 200, f'{s} {json.dumps(d)[:200]}')


def verboten(name, antwort):
    s, d = antwort
    pruefe(name + ' (muss verboten sein)', s in (403, 404) or (s == 400 and 'PERMISSION' in json.dumps(d)),
           f'{s} {json.dumps(d)[:200]}')


def admin_loeschen(pfade):
    """Nur-Admin-Dokumente mit dem gcloud-Zugang des Projektinhabers löschen (falls vorhanden)."""
    try:
        env = {k: v for k, v in os.environ.items() if k != 'CLOUDSDK_AUTH_ACCESS_TOKEN'}
        tok = subprocess.run(['gcloud', 'auth', 'print-access-token'], env=env,
                             capture_output=True, text=True, check=True).stdout.strip()
    except Exception:
        print('  (gcloud fehlt – Admin-Testdaten bleiben liegen)')
        return
    for p in pfade:
        loeschen(tok, p)


def main():
    pw = os.environ.get('TESTKONTO_PASSWORT')
    if not pw:
        sys.exit('TESTKONTO_PASSWORT fehlt')
    u1, t1 = anmelden('testkonto1@austro-angler.test', pw)
    u2, t2 = anmelden('testkonto2@austro-angler.test', pw)
    print('Angemeldet:', u1, u2)

    # Profile (wie bei der Registrierung)
    for uid, tok, name in [(u1, t1, 'testkonto1'), (u2, t2, 'testkonto2')]:
        s, _ = lesen(tok, f'namen/{name}')
        if s != 200:
            erlaubt(f'Name @{name} reservieren', commit(tok, [
                {'update': {'name': doc_name(f'namen/{name}'), 'fields': {'uid': wert(uid)}}},
                {'update': {'name': doc_name(f'nutzer/{uid}'),
                            'fields': {'name': wert(name), 'erstellt': wert(jetzt())}}},
            ]))
    verboten('Fremden Namen @testkonto1 übernehmen',
             setzen(t2, 'namen/testkonto1', {'uid': u2}))
    erlaubt('Verein setzen', setzen(t1, f'nutzer/{u1}', {'name': 'testkonto1', 'erstellt': jetzt(), 'verein': 'Testverein'}))

    # Fänge
    fang = f'test_{int(time.time())}'
    fangdaten = {'fischId': 'hecht', 'laengeCm': 72.0, 'gewichtG': 2500, 'gewaesser': 'Mattig (Test)',
                 'bundesland': 'Oberösterreich', 'koeder': 'Gummifisch', 'notiz': 'Testfang',
                 'zurueckgesetzt': True, 'wetter': None, 'datum': jetzt(), 'uid': u1,
                 'nutzerName': 'testkonto1', 'hatFoto': False, 'petriHeil': [], 'erstellt': jetzt(),
                 'geschichte': 'Ein Test-Drill.', 'ausruestung': 'Spinnrute', 'verein': 'Testverein'}
    erlaubt('Öffentlichen Fang speichern', setzen(t1, f'faenge/{fang}', fangdaten))
    verboten('Fang im Namen eines anderen speichern',
             setzen(t2, f'faenge/{fang}_fake', {**fangdaten, 'uid': u1}))
    erlaubt('Privaten Fang speichern', setzen(t1, f'nutzer/{u1}/privat/{fang}', fangdaten))
    verboten('Fremden privaten Fang lesen', lesen(t2, f'nutzer/{u1}/privat/{fang}'))
    erlaubt('Fremden öffentlichen Fang lesen', lesen(t2, f'faenge/{fang}'))
    verboten('Fremden Fang ändern (Länge)', setzen(t2, f'faenge/{fang}', {'laengeCm': 150.0}, ['laengeCm']))
    erlaubt('Petri Heil geben', setzen(t2, f'faenge/{fang}', {'petriHeil': [u2]}, ['petriHeil']))

    # Kommentar
    erlaubt('Kommentieren', setzen(t2, f'faenge/{fang}/kommentare/k1',
                                   {'uid': u2, 'nutzerName': 'testkonto2', 'text': 'Petri!', 'erstellt': jetzt()}))

    # Freundschaftsanfrage
    erlaubt('Freundschaftsanfrage senden', setzen(t2, f'nutzer/{u1}/anfragen/{u2}',
                                                  {'name': 'testkonto2', 'zeit': jetzt()}))
    verboten('Anfrage im Namen eines anderen', setzen(t2, f'nutzer/{u1}/anfragen/fremd',
                                                      {'name': 'x', 'zeit': jetzt()}))
    erlaubt('Gesendete Anfrage sehen (Absender)', lesen(t2, f'nutzer/{u1}/anfragen/{u2}'))
    erlaubt('Anfrage annehmen (beide Seiten)', commit(t1, [
        {'update': {'name': doc_name(f'nutzer/{u1}/freunde/{u2}'),
                    'fields': {'name': wert('testkonto2'), 'seit': wert(jetzt())}}},
        {'update': {'name': doc_name(f'nutzer/{u2}/freunde/{u1}'),
                    'fields': {'name': wert('testkonto1'), 'seit': wert(jetzt())}}},
        {'delete': doc_name(f'nutzer/{u1}/anfragen/{u2}')},
    ]))
    verboten('Sich ohne Anfrage als Freund eintragen',
             setzen(t2, f'nutzer/{u1}/freunde/{u2}x', {'name': 'x', 'seit': jetzt()}))
    erlaubt('Freundschaft beidseitig beenden', commit(t2, [
        {'delete': doc_name(f'nutzer/{u2}/freunde/{u1}')},
        {'delete': doc_name(f'nutzer/{u1}/freunde/{u2}')},
    ]))

    # Angeltag + Zusage + Fahrgemeinschaft
    tr = f'test_{int(time.time())}'
    erlaubt('Angeltag planen', setzen(t1, f'treffen/{tr}', {
        'uid': u1, 'nutzerName': 'testkonto1', 'gewaesser': 'Mattig (Test)',
        'zeit': jetzt(86400), 'text': 'Test', 'zusagen': {u1: 'testkonto1'}}))
    erlaubt('Zusagen', setzen(t2, f'treffen/{tr}', {'zusagen': {u2: 'testkonto2'}}, [f'zusagen.`{u2}`']))
    verboten('Fremde Zusage entfernen', setzen(t2, f'treffen/{tr}', {'zusagen': {}}, [f'zusagen.`{u1}`']))
    erlaubt('Fahrgemeinschaft anbieten', setzen(t2, f'treffen/{tr}', {
        'fahrten': {u2: {'name': 'testkonto2', 'biete': True, 'plaetze': 2, 'von': 'Braunau'}}},
        [f'fahrten.`{u2}`']))
    verboten('Fremde Fahrt ändern', setzen(t2, f'treffen/{tr}', {
        'fahrten': {u1: {'name': 'x', 'biete': True, 'plaetze': 9, 'von': 'x'}}}, [f'fahrten.`{u1}`']))

    # Rangliste
    erlaubt('Eigenen Ranglisten-Eintrag schreiben', setzen(t1, 'rangliste/test', {
        'eintraege': {u1: {'name': 'testkonto1', 'faenge': 1}}}, [f'eintraege.`{u1}`']))
    verboten('Fremden Ranglisten-Eintrag schreiben', setzen(t2, 'rangliste/test', {
        'eintraege': {u1: {'name': 'testkonto1', 'faenge': 999}}}, [f'eintraege.`{u1}`']))
    erlaubt('Rangliste lesen', lesen(t2, 'rangliste/test'))

    # Wassertemperatur, Infos, Wunsch
    erlaubt('Wassertemperatur melden', setzen(t1, 'wassertemp/test/messungen/m1',
                                              {'uid': u1, 'nutzerName': 'testkonto1', 'grad': 12.5, 'zeit': jetzt()}))
    verboten('Unsinnige Temperatur (99 °C)', setzen(t1, 'wassertemp/test/messungen/m2',
                                                    {'uid': u1, 'nutzerName': 'x', 'grad': 99.0, 'zeit': jetzt()}))
    erlaubt('Infos zum Gewässer vorschlagen', setzen(t1, f'gewaesser_infos/{fang}', {
        'uid': u1, 'nutzerName': 'testkonto1', 'gewaesserId': 'test', 'gewaesserName': 'Test',
        'fische': ['hecht'], 'verkauf': 'Test', 'url': '', 'text': 'Test', 'erstellt': jetzt()}))
    verboten('Vorschläge lesen (nur Admin)', lesen(t2, f'gewaesser_infos/{fang}'))
    verboten('Geprüfte Infos selbst schreiben', setzen(t1, 'gepruefte_infos/test', {'fische': ['hecht']}))
    erlaubt('Mehr Infos wünschen', setzen(t1, f'wuensche/{fang}', {
        'uid': u1, 'nutzerName': 'testkonto1', 'text': 'Test', 'status': 'neu',
        'typ': 'infos', 'bezug': 'test', 'erstellt': jetzt()}))
    verboten('Premium selbst vergeben', setzen(t1, f'premium/{u1}', {'bis': jetzt(9999999)}))

    # Video
    erlaubt('Video-Info speichern', setzen(t1, f'videos/{fang}', {
        'uid': u1, 'oeffentlich': True, 'teile': 1, 'groesse': 3}))
    erlaubt('Video-Teil speichern', setzen(t1, f'videos/{fang}/teile/0', {'uid': u1, 'daten': 'AAAA'}))
    erlaubt('Öffentliches Video lesen', lesen(t2, f'videos/{fang}/teile/0'))
    verboten('Fremdes Video überschreiben', setzen(t2, f'videos/{fang}/teile/0', {'uid': u2, 'daten': 'BBBB'}))

    # Blockieren, Ausrüstung
    erlaubt('Nutzer blockieren', setzen(t1, f'nutzer/{u1}/blockiert/{u2}', {'name': 'testkonto2'}))
    verboten('Fremde Blockliste lesen', lesen(t2, f'nutzer/{u1}/blockiert/{u2}'))
    erlaubt('Ausrüstung speichern', setzen(t1, f'nutzer/{u1}/ausruestung/a1',
                                           {'name': 'Spinnrute', 'art': 'Rute', 'notiz': ''}))
    verboten('Fremde Ausrüstung lesen', lesen(t2, f'nutzer/{u1}/ausruestung/a1'))

    # Aufräumen
    print('\nAufräumen …')
    for tok, pfad in [
        (t2, f'faenge/{fang}/kommentare/k1'), (t1, f'faenge/{fang}'), (t1, f'nutzer/{u1}/privat/{fang}'),
        (t1, f'treffen/{tr}'), (t1, 'wassertemp/test/messungen/m1'),
        (t1, f'videos/{fang}/teile/0'), (t1, f'videos/{fang}'),
        (t1, f'nutzer/{u1}/blockiert/{u2}'), (t1, f'wuensche/{fang}'), (t1, f'nutzer/{u1}/ausruestung/a1'),
    ]:
        loeschen(tok, pfad)
    setzen(t1, 'rangliste/test', {'eintraege': {}}, [f'eintraege.`{u1}`'])
    admin_loeschen([f'gewaesser_infos/{fang}', 'gewaesser_infos/test1', 'wuensche/test1'])

    fehler = [e for e in ergebnisse if not e[1]]
    print(f'\n{len(ergebnisse) - len(fehler)} von {len(ergebnisse)} Prüfungen bestanden.')
    return 1 if fehler else 0


if __name__ == '__main__':
    sys.exit(main())
