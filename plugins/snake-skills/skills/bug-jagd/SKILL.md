---
name: bug-jagd
description: Findet und behebt Fehler systematisch statt zu raten. Verwenden bei Fehlermeldungen, Abstürzen, "geht nicht" oder unerwartetem Verhalten.
---

# Bug-Jagd

1. **Nachstellen.** Erst den Fehler selbst auslösen (Test, Befehl oder Skript). Ohne Nachstellen nicht "reparieren".
2. **Genau lesen.** Die komplette Fehlermeldung und den Stacktrace lesen, die erste eigene Codezeile darin finden.
3. **Eine Vermutung nach der anderen.** Vermutung aufschreiben, mit einem kleinen Test oder einer Ausgabe prüfen, erst dann ändern.
4. **Kleinste Reparatur.** Nur das ändern, was den Fehler verursacht. Kein Umbau nebenbei.
5. **Gegenprobe.** Den Fehler erneut auslösen und zeigen, dass er weg ist. Vorhandene Tests laufen lassen.
6. **Bericht in einfachen Worten:** Was war kaputt, warum, was wurde geändert, wie wurde es geprüft. Wenn etwas nicht geprüft werden konnte, das ehrlich sagen.
