"""Hilfsfunktionen für die Stapel-Quellen.

b() = Begriff, a() = „Was gibt das aus?“, l() = Lückentext.
Nach Änderungen: python3 <datei>.py und danach tools/stapel_pruefen.py
"""
import json
from pathlib import Path

ZIEL = Path(__file__).resolve().parents[2] / "assets" / "stapel"
K = []
def b(key, frage, antwort, code=None, erkl=None):
    K.append({"key": key, "typ": "begriff", "frage": frage, "antwort": antwort, **({"code": code} if code else {}), **({"erklaerung": erkl} if erkl else {})})
def a(key, code, antwort, optionen, erkl, frage="Was gibt dieser Code aus?", rahmen=None):
    K.append({"key": key, "typ": "ausgabe", "frage": frage, "code": code, "antwort": antwort, "optionen": optionen, "erklaerung": erkl, **({"rahmen": rahmen} if rahmen else {})})
def l(key, frage, code, antwort, optionen, erwartet, erkl, rahmen=None):
    K.append({"key": key, "typ": "luecke", "frage": frage, "code": code, "antwort": antwort, "optionen": optionen, "erwartet": erwartet, "erklaerung": erkl, **({"rahmen": rahmen} if rahmen else {})})
def speichern(id, name, sprache, stufe, beschreibung, produkt):
    json.dump({"id": id, "name": name, "sprache": sprache, "stufe": stufe, "beschreibung": beschreibung, "produkt": produkt, "karten": K},
              open(ZIEL / f"{id}.json", "w"), ensure_ascii=False, indent=1)
    print(id, len(K), "Karten")
