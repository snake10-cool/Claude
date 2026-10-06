"""Prüft alle Kartenstapel in assets/stapel/*.json.

- Pflichtfelder, eindeutige Keys, Antwort steht in den Optionen
- „ausgabe“-Karten: Code wird wirklich ausgeführt, Ausgabe == Antwort
- „luecke“-Karten: mit der Antwort ausgeführt == erwartet; jede falsche
  Option darf NICHT dasselbe ausgeben (sonst wäre sie auch richtig)

Braucht: java (21+), python3, dart, node.
Aufruf:  python3 tools/stapel_pruefen.py [stapel-id ...]
"""
import json
import subprocess
import sys
import tempfile
from pathlib import Path

ORDNER = Path(__file__).resolve().parent.parent / "assets" / "stapel"


def ausfuehren(sprache, code, rahmen):
    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        if sprache == "java":
            if rahmen != "voll":
                code = "public class Main {\n public static void main(String[] args) {\n" + code + "\n }\n}\n"
            datei = tmp / "Main.java"
            befehl = ["java", str(datei)]
        elif sprache == "python":
            datei = tmp / "main.py"
            befehl = ["python3", str(datei)]
        elif sprache == "dart":
            if rahmen != "voll" and "void main" not in code:
                code = "void main() {\n" + code + "\n}\n"
            datei = tmp / "main.dart"
            befehl = ["dart", "run", str(datei)]
        elif sprache == "javascript":
            datei = tmp / "main.js"
            befehl = ["node", str(datei)]
        else:
            return None, "unbekannte Sprache"
        datei.write_text(code)
        try:
            r = subprocess.run(befehl, capture_output=True, text=True, timeout=60, cwd=tmp)
        except subprocess.TimeoutExpired:
            return None, "Zeitüberschreitung"
        if r.returncode != 0:
            return None, (r.stderr or r.stdout).strip().splitlines()[-1:] or ["Fehler"]
        return r.stdout.rstrip("\n").rstrip(), None


def pruefen(datei):
    stapel = json.loads(datei.read_text())
    sprache = stapel["sprache"]
    fehler = []
    keys = set()
    for k in stapel["karten"]:
        key = k.get("key")
        wo = f"{stapel['id']}/{key}"
        if not key or key in keys:
            fehler.append(f"{wo}: Key fehlt oder doppelt")
        keys.add(key)
        for feld in ("typ", "frage", "antwort"):
            if not k.get(feld):
                fehler.append(f"{wo}: '{feld}' fehlt")
        typ = k.get("typ")
        if typ in ("ausgabe", "luecke"):
            optionen = k.get("optionen", [])
            if k.get("antwort") not in optionen:
                fehler.append(f"{wo}: Antwort nicht in den Optionen")
            if len(set(optionen)) != len(optionen) or len(optionen) < 3:
                fehler.append(f"{wo}: Optionen doppelt oder weniger als 3")
            if not k.get("code"):
                fehler.append(f"{wo}: Code fehlt")
                continue
        if typ == "ausgabe":
            aus, f = ausfuehren(sprache, k["code"], k.get("rahmen"))
            if f:
                fehler.append(f"{wo}: läuft nicht: {f}")
            elif aus != k["antwort"]:
                fehler.append(f"{wo}: Ausgabe {aus!r} ≠ Antwort {k['antwort']!r}")
        elif typ == "luecke":
            if "___" not in k["code"]:
                fehler.append(f"{wo}: keine Lücke ___ im Code")
                continue
            erwartet = k.get("erwartet")
            if erwartet is None:
                fehler.append(f"{wo}: 'erwartet' fehlt")
                continue
            aus, f = ausfuehren(sprache, k["code"].replace("___", k["antwort"]), k.get("rahmen"))
            if f:
                fehler.append(f"{wo}: mit Antwort läuft nicht: {f}")
            elif aus != erwartet:
                fehler.append(f"{wo}: mit Antwort {aus!r} ≠ erwartet {erwartet!r}")
            for o in k["optionen"]:
                if o == k["antwort"]:
                    continue
                aus2, _ = ausfuehren(sprache, k["code"].replace("___", o), k.get("rahmen"))
                if aus2 == erwartet:
                    fehler.append(f"{wo}: falsche Option {o!r} liefert auch {erwartet!r}")
        elif typ != "begriff":
            fehler.append(f"{wo}: unbekannter Typ {typ}")
    return stapel, fehler


def main():
    auswahl = set(sys.argv[1:])
    alle_fehler = []
    for datei in sorted(ORDNER.glob("*.json")):
        if auswahl and datei.stem not in auswahl:
            continue
        stapel, fehler = pruefen(datei)
        n = len(stapel["karten"])
        print(f"{'✓' if not fehler else '✗'} {stapel['id']}: {n} Karten")
        for f in fehler:
            print("   ", f)
        alle_fehler += fehler
    sys.exit(1 if alle_fehler else 0)


if __name__ == "__main__":
    main()
