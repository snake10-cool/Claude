# Meine Apps

Zwei Android-Apps, gebaut mit Flutter, für Google Play.

| App | Ordner | Inhalt |
|---|---|---|
| 🎣 **Petri** (Arbeitsname) | `apps/petri` | Angel-App für Oberösterreich und Salzburg, Schwerpunkt Bezirk Braunau |
| 🦊 **Lernfuchs** (Arbeitsname) | `apps/lernapp` | Lern-App für Volksschule 1–4 und Mittelschule 1–4 |

## Testversion aufs Handy holen (ohne PC)

1. Nach jeder Änderung baut GitHub beide Apps automatisch (Tab **Actions**, dauert ca. 10 Minuten).
2. Danach im Repo auf **Releases → Testversion** gehen.
3. `Petri.apk` oder `Lernfuchs.apk` antippen und herunterladen.
4. Die Datei öffnen. Android fragt beim ersten Mal, ob der Browser Apps installieren darf: erlauben.

## 🎣 Petri – was drin ist

- **Gewässer**: Wo man fischen darf, Preise für Tages-, Wochen- und Jahreskarten, wo man die Karten bekommt. Dazu "Was brauche ich zum Fischen?" für OÖ und Salzburg.
- **Karte**: Alle Gewässer auf einer OpenStreetMap-Karte. Lange drücken, um eigene Angelplätze zu speichern.
- **Fangbuch**: Fänge mit Länge, Gewicht, Gewässer, Köder und Notiz, dazu eine Statistik. Warnt, wenn ein Fisch Schonzeit hat oder unter dem Brittelmaß liegt.
- **Fischlexikon**: 19 Fischarten mit Schonzeit und Brittelmaß für OÖ und Salzburg und der Anzeige "heute offen" oder "Schonzeit".
- **Prüfungstrainer**: 37 eigene Übungsfragen zur Fischerprüfung.

Daten bearbeiten: `apps/petri/lib/data/` (`gewaesser.dart`, `fische.dart`, `fragen.dart`).
Fehlende Angaben sind in der App mit "bitte prüfen" markiert (z. B. Preise für Mattig und Ibmer Moor, einige Salzburger Schonzeiten).

## 🦊 Lernfuchs – was drin ist

- Klasse wählen (VS 1–4, MS 1–4), dann Deutsch, Mathematik oder Englisch.
- Pro Fach und Klasse 2–4 Themen, jede Runde mit 10 Aufgaben und bis zu 3 Sternen.
- Mathe-Aufgaben werden zufällig erzeugt, dadurch gibt es unendlich viele.
- 🔥 Lern-Serie: Tage in Folge.
- Nebenfächer sind schon sichtbar, aber gesperrt ("Premium – kommt bald").

Aufgaben bearbeiten: `apps/lernapp/lib/data/` (`mathe.dart`, `deutsch.dart`, `englisch.dart`).

## Nächste Schritte

1. **Testen**: Beide APKs installieren und ausprobieren, dazu den Freund aus Braunau die Gewässerdaten prüfen lassen.
2. **Namen festlegen**: "Petri" und "Lernfuchs" sind nur Arbeitsnamen. Vor dem Veröffentlichen im Play Store prüfen, ob es die Namen schon gibt.
3. **Google-Play-Konto** (25 $ einmalig, unter 18 über die Eltern).
4. **Upload-Schlüssel und AAB-Datei**: Für den Play Store braucht es eine signierte `.aab`-Datei. Das richten wir ein, sobald das Konto da ist.
5. **Firebase-Anmeldung und Gründer-Status** (Lernfuchs): Wer sich in der Gratis-Phase anmeldet, behält die Hauptfächer für immer gratis. Dafür muss ein kostenloses Firebase-Projekt angelegt werden.
6. **Premium-Abo** mit Testphase für die Nebenfächer (kostet für alle, auch für Gründer).
7. **Datenschutzerklärung** (Pflicht im Play Store).
