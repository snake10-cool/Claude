# 🌍 Echtleben – Spielplan (Arbeitsname)

> **Stand:** 11.11.2026 (3. Fassung) · **Status:** nur Planung, es wird noch nichts gebaut
> **1. Regel:** Beeile dich niemals. Mach gründlich.
> **Grundsatz:** Ein Meilenstein soll dauern. Erst wenn einer wirklich fertig ist, kommt der nächste.

Dieser Plan arbeitet die zwei Zettel „Ein Spiel“ aus. Alles, was auf den Zetteln steht, ist hier drin.
Wo ich etwas **ehrlich als schwierig oder rechtlich problematisch** sehe, steht das dabei, zusammen mit einem Vorschlag.
Deine Antworten auf meine Fragen stehen ganz unten unter **„Entscheidungen“**.

### Grundsatz für alles: „Zeig, wie, was, wo“
Bei **jedem** Teil des Spiels (nicht nur bei der KI) wird gezeigt und erklärt:
- **Was** gebaut wurde,
- **wie** es funktioniert,
- **wo** es im Projekt liegt.

Dafür bekommt jeder Meilenstein eine eigene Erklär-Seite im Repo (`plaene/echtleben/erklaert/`).

---

## 0. Worum geht es?

Ein Lebens-Simulator, in dem **alles so ist wie im echten Leben**:

- Man spielt eine Person mit Geschlecht, Alter, Familie, Geld, Job, Wohnort und Besitz.
- Die Welt sieht **echt** aus, nicht wie Klötze mit Farbe.
- **Jeder andere Mensch** im Spiel ist genauso aufgebaut wie die Spielfigur und **lebt sein eigenes Leben**, auch wenn der Spieler gar nicht hinschaut.
- Man kann mit den Menschen **reden** (eigene KI).
- Es gibt **echte Computer und Handys** im Spiel, die man kaufen und benutzen kann.
- Dadurch kann man das Spiel **(fast) mit unendlich vielen Möglichkeiten** spielen: kein fester Weg, kein „Level 1, Level 2“.

### Ehrlich vorweg: wie groß ist das?

Jeder der 5 Punkte ist für sich so groß wie ein eigenes Spiel. Große Firmen bauen so etwas mit Hunderten Leuten über Jahre.
Das heißt **nicht**, dass es unmöglich ist. Es heißt:

1. Wir bauen **klein und echt** statt groß und halb. Zuerst **ein Ort** (z. B. eine kleine Stadt mit Umgebung), nicht ein ganzes Land.
2. Jeder Meilenstein bekommt eine klare **„Fertig, wenn …“-Liste**. Erst wenn alles abgehakt ist, geht es weiter. Das passt genau zu deiner Regel.
3. Die Teile werden so gebaut, dass sie **später wachsen** können (mehr Menschen, mehr Orte, mehr Geräte), ohne dass man von vorne anfangen muss.

---

## 1. Technik-Entscheidungen

### 1.1 Spiel-Engine: Unreal Engine 5 (Vorschlag)

Eine „Engine“ ist das Grundgerüst, auf dem das Spiel läuft (Grafik, Licht, Physik, Ton).
Für **„soll echt aussehen“** ist Unreal Engine 5 die passende Wahl:

| Was du willst | Was Unreal dafür hat |
|---|---|
| Echte Menschen, realistisches Alter | **MetaHuman**: fotorealistische Menschen, Gesichter, Haut, Haare; Alterung über Gesichts-Varianten möglich |
| Gebäude, Boden, Steine sollen echt aussehen | **Quixel Megascans**: tausende eingescannte echte Oberflächen und Objekte (Mauern, Holz, Rasen, Erde …), für Unreal-Projekte gratis |
| Sehr viele Details ohne Ruckeln | **Nanite** (sehr detaillierte Modelle) |
| Echtes Licht, Tageszeiten, Schatten | **Lumen** (Licht in Echtzeit) |
| Wald, Wiesen, Pflanzen automatisch verteilt | **PCG** (Prozedurale Inhaltserzeugung) |

**Kosten:** Unreal ist gratis. Erst wenn ein Spiel über 1 Million Dollar einnimmt, gehen 5 % an Epic.

**Alternativen** (falls du sie lieber willst): *Unity* (einfacher, aber für Fotorealismus mehr Arbeit) oder *Godot* (komplett frei, aber deutlich weniger realistisch). Für dein Ziel empfehle ich klar Unreal.

### 1.2 Plattform

- **Zuerst nur PC (Windows).** Fotorealistische Grafik schafft ein Handy nicht.
- Konsole/Handy erst viel später oder nie.

### 1.3 Was du dafür brauchst

| Was | Mindestens | Besser | Du hast (Stand 10.11.2026) |
|---|---|---|---|
| Grafikkarte | RTX 3060 | RTX 4070 oder stärker | **RTX 3060 Ti, 8 GB** ✅ reicht zum Bauen |
| Arbeitsspeicher | 32 GB | 64 GB | **16 GB DDR4-3200** ⚠️ knapp |
| Speicherplatz | 300 GB freie SSD | 1 TB SSD | **1 TB NVMe (WD Blue SN5100)** ✅ + alte 750-GB-Festplatte |
| Prozessor | 6 Kerne | 8+ Kerne | **i7-5820K** (6 Kerne, Baujahr 2014) ⚠️ größte Bremse |

**Weihnachts-Upgrade (Budget 150–200 €), Plan:**
- **Schritt 1 (Weihnachten): neuer Prozessor + Mainboard.** Vorschlag: AMD Ryzen 7 5700X (8 Kerne) + ein B550-Mainboard. Der vorhandene **DDR4-3200-Arbeitsspeicher passt** und wird weiterverwendet, Grafikkarte und SSD bleiben auch. Laut Preisvergleich (Nov. 2026) ca. 150 € (Tray-Version) + ca. 80 € (günstiges B550) ≈ 230 €. Wenn das zu viel ist: ein günstigerer Ryzen mit 6 Kernen.
  - Die Tray-Version hat **keinen Kühler** dabei: prüfen, ob der jetzige Kühler auf AM4 passt, sonst einen günstigen Kühler dazurechnen.
  - Nach dem Mainboard-Tausch muss Windows eventuell neu aktiviert werden (geht über das Microsoft-Konto).
- **Schritt 2 (später): auf 32 GB Arbeitsspeicher.** DDR4 ist gerade sehr teuer (32-GB-Kits ca. 235 € und mehr). Darum warten, bis die Preise fallen, oder gebraucht 16 GB DDR4-3200 dazukaufen.
- M0 (Fundament) kann schon **vor** dem Upgrade starten.

⚠️ **Wichtig:** Anders als bei deinen Apps kann GitHub dieses Spiel **nicht automatisch bauen**, und ich kann es in meiner Cloud-Umgebung nicht starten. Unreal braucht einen echten PC mit Grafikkarte.
So würden wir arbeiten:
- Ich schreibe Code (C++), Pläne, Daten und Anleitungen ins Repo.
- Du baust und startest es auf deinem PC und sagst mir, was du siehst (Screenshots helfen sehr).
- Große Dateien (3D-Modelle, Texturen) kommen über **Git LFS** ins Repo, sonst wird es zu groß.

### 1.4 Grundaufbau des Programms

Das Spiel wird in getrennte Bausteine aufgeteilt, damit jeder für sich gründlich gebaut und getestet werden kann:

```
Echtleben
├── Mensch        (Punkt 1 + 3: Daten einer Person, Bedürfnisse, Alter, Familie, Geld …)
├── Welt          (Punkt 2: Gelände, Natur, Gebäude, Tiere, Wetter, Uhrzeit)
├── Simulation    (Punkt 3: lässt alle Menschen ihr Leben leben, auch ohne Spieler)
├── Wirtschaft    (Geld, Jobs, Preise, Geschäfte, Wohnungen, Besitz)
├── KI            (Punkt 4: eigenes Sprachmodell + Verhaltens-KI)
├── Geräte        (Punkt 5: PCs, Handys mit echtem Betriebssystem)
└── Speichern     (Spielstände)
```

---

## 2. Die 5 Punkte ausgearbeitet

### Punkt 1 – Charakter

**Vom Zettel:** Geschlecht, Alter, Familie, Kohle, Job, Wohnort, Besitz. Alles soll realistisch aussehen (darum ist es ein ganzer Meilenstein). So kann man das Ganze (fast) mit ∞ Möglichkeiten zocken.

**Was eine Person im Spiel alles hat:**

| Bereich | Inhalt |
|---|---|
| Körper | Geschlecht, Geburtsdatum (Alter läuft mit), Größe, Gewicht, Aussehen (Gesicht, Haut, Haare, Augen), Gesundheit, Fitness |
| Familie | Eltern, Geschwister, Partner/in, Kinder, Großeltern; jede/r davon ist selbst eine vollständige Person |
| Geld („Kohle“) | Bargeld, Bankkonto, Einkommen, laufende Kosten (Miete, Strom, Handy, Essen), Schulden, Erspartes |
| Job | Beruf, Arbeitgeber, Arbeitszeiten, Gehalt, Erfahrung, Ausbildung/Schule |
| Wohnort | Adresse, Wohnung/Haus, Miete oder Eigentum, Mitbewohner |
| Besitz | Jeder Gegenstand ist ein echtes Ding in der Welt: Kleidung, Möbel, Auto, Fahrrad, Handy, PC … |
| Innen | Bedürfnisse (Hunger, Schlaf, Hygiene, Gesellschaft, Spaß), Stimmung, Charakterzüge, Fähigkeiten, Erinnerungen, Beziehungen zu anderen |

**Realistisches Aussehen:**
- Körper und Gesicht über MetaHuman.
- **Alter sieht echt aus:** Babys, Kinder, Jugendliche, Erwachsene, ältere Menschen. Das ist technisch der schwierigste Teil von Punkt 1, weil MetaHuman eigentlich für Erwachsene gemacht ist. Kinder und fließendes Altern müssen wir eigens lösen (z. B. mehrere Gesichts-Stufen pro Person, zwischen denen weich übergeblendet wird).
- Kleidung passt sich an Körper, Alter und Wetter an.

**Spielstart (∞ Möglichkeiten):**
- Entweder alles selbst wählen (Geschlecht, Alter, Familie, Startgeld, Job …)
- oder **„Zufallsleben“**: man wird irgendwo in die Welt geboren bzw. bekommt ein zufälliges Leben mit allem, was dazugehört (reich/arm, Familie/allein, Stadt/Land).
- Danach gibt es kein festes Ziel. Man entscheidet selbst.

**Fertig, wenn …**
- [ ] Eine Person kann mit allen Werten oben erstellt, gespeichert und geladen werden.
- [ ] Sie sieht in mindestens 5 Altersstufen realistisch aus (Baby, Kind, Jugend, Erwachsen, Alt).
- [ ] Altern über die Spielzeit funktioniert sichtbar.
- [ ] Geld, Job, Wohnung und Besitz wirken sich aus (Miete wird abgebucht, Gehalt kommt …).
- [ ] Man kann mit der Figur durch eine kleine Testgegend gehen.

---

### Punkt 2 – Welt

**Vom Zettel:** Gras, Rasen/Boden, Wald, Pflanzen, Tiere, Wasser. Gebäude sollen keine Quader mit Farbe sein, sondern echt aussehen. (Alles andere natürlich auch.)

**Erste Spielwelt: Mattighofen (echt).** ✅ entschieden

So wird der echte Ort nachgebaut:

| Was | Woher |
|---|---|
| Gelände (Höhen, Hügel, Täler, Flusslauf der Mattig) | Offene Geländedaten von Österreich (data.gv.at / Land OÖ) |
| Straßen, Wege, Gebäude-Umrisse, Wälder, Felder, Gewässer | OpenStreetMap (frei nutzbar, muss im Spiel genannt werden) |
| Wie die Gebäude aussehen | Luftbilder (basemap.at) und eigene Fotos von dir vor Ort als Vorlage |
| Oberflächen (Mauern, Dächer, Asphalt, Wiese) | Megascans, passend zu den Vorlagen |

Wichtig dabei:
- **Fotos von dir** sind Gold wert: Hausfassaden, Plätze, Geschäfte, Ufer. Je mehr echte Vorlagen, desto echter das Spiel.
- **Echte Firmennamen und Logos** (Geschäfte, Firmen in Mattighofen) darf man nicht einfach ins Spiel nehmen, das ist Markenrecht. Gebäude und Orte ja, Firmennamen bekommen leicht veränderte Namen.
- **Privathäuser** werden nachgebaut, aber ohne echte Namen der Bewohner. Die Menschen im Spiel sind erfunden.
- Start ist der Ortskern mit Umgebung. Später kommen die Nachbarorte und das Umland dazu.

**Echt aussehen heißt konkret:**

| Teil | Wie |
|---|---|
| Boden, Gras, Rasen | Eingescannte echte Oberflächen, Gras bewegt sich im Wind, wird bei Regen nass, ist im Winter mit Schnee bedeckt |
| Wald, Pflanzen | Echte heimische Arten (Fichte, Buche, Eiche, Holunder …), wachsen über die Zeit, Jahreszeiten (Laub im Herbst, kahl im Winter) |
| Wasser | Fluss mit Strömung, Spiegelungen, Ufer, Wellen |
| Tiere | Heimische Tiere mit eigenem Verhalten: Vögel, Rehe, Füchse, Hasen, Fische, Haustiere (Hunde, Katzen) |
| Gebäude | **Keine Quader.** Echte Mauern, Dächer, Fenster, Dachrinnen, Gebrauchsspuren, Innenräume mit Möbeln. Man kann in jedes Haus hineingehen, das einem gehört oder wo man eingeladen ist |
| Himmel und Wetter | Tag/Nacht, Sonne, Regen, Gewitter, Nebel, Schnee, 4 Jahreszeiten |
| Zeit | Echter Kalender. Die Spielzeit läuft schneller als echt (einstellbar) |

**Fertig, wenn …**
- [ ] Die Kleinstadt mit Umgebung ist begehbar und sieht in jeder Ecke echt aus (kein „Klotz mit Farbe“).
- [ ] Tag/Nacht, Wetter und Jahreszeiten laufen.
- [ ] Mindestens 10 Tierarten leben mit eigenem Verhalten.
- [ ] Jedes Gebäude hat ein echtes Aussehen, wichtige Gebäude haben Innenräume.
- [ ] Läuft flüssig (mindestens 60 Bilder pro Sekunde auf der „Besser“-Hardware).

---

### Punkt 3 – Andere Menschen

**Vom Zettel:** Jeder ist so aufgebaut wie bei Nr. 1 und lebt sein Leben, unabhängig vom Player. (Echt jeder.)

**Wie das gehen kann:**
- **Jeder Mensch ist dieselbe Datenstruktur wie die Spielfigur.** Es gibt keinen Unterschied zwischen „Spieler“ und „NPC“, außer wer ihn steuert. (Man könnte dadurch sogar die Person wechseln.)
- Jeder hat einen **Tagesablauf** aus seinen Bedürfnissen und Pflichten: aufstehen, frühstücken, Arbeit/Schule, einkaufen, Freunde treffen, Hobbys, schlafen.
- Über die Zeit passiert das **ganze Leben**: Leute werden geboren, gehen zur Schule, suchen Jobs, verlieben sich, ziehen um, bekommen Kinder, werden krank, werden alt, sterben.
- Das passiert **auch wenn der Spieler nicht hinschaut.**

**Das technische Problem und die Lösung:**
Tausende Menschen gleichzeitig in voller 3D-Grafik zu berechnen, schafft kein PC. Darum zwei Stufen:

| Stufe | Wo | Was berechnet wird |
|---|---|---|
| **Nah** | Rund um den Spieler | Volle 3D-Figur, geht wirklich, redet, benutzt Dinge |
| **Fern** | Überall sonst | Nur die Daten: „ist von 8–16 Uhr in der Arbeit, verdient X, trifft um 18 Uhr Y“. Ergebnis ist dasselbe, nur ohne Grafik |

Wenn der Spieler in die Nähe kommt, wird aus der „fernen“ Person nahtlos eine „nahe“ an genau der Stelle, wo sie laut Simulation gerade ist.

**Größe:** Mattighofen hat in echt einige tausend Einwohner. Wir starten mit ca. **500 Menschen** im Ortskern. Wenn das stabil läuft, wird schrittweise bis auf die echte Einwohnerzahl erhöht.

**Das volle Programm (entschieden):** Krankheit, Tod, Verbrechen und Polizei, Unfälle, alles drin. Dafür braucht es zusätzlich:
- Arzt, Krankenhaus, Rettung
- Polizei, Strafen, Gericht, Gefängnis
- Versicherungen, Erbe, Begräbnis
- Altersfreigabe: **einstellbar**, siehe Abschnitt 2d (voller Modus ab 18, Jugendmodus).

**Fertig, wenn …**
- [ ] 500 Menschen leben mit vollständigen Daten (wie Punkt 1).
- [ ] Jeder hat einen glaubwürdigen Tagesablauf, der sich aus Bedürfnissen und Job ergibt.
- [ ] Über mehrere Spieljahre entstehen Beziehungen, Kinder, Umzüge, Todesfälle, Jobwechsel, ohne dass der Spieler etwas tut.
- [ ] Testbeweis: Spieler steht 1 Spieljahr still → danach hat sich die Stadt nachvollziehbar verändert.
- [ ] Die Wirtschaft bleibt stabil (nicht alle pleite, nicht alle Millionäre).

---

### Punkt 4 – KI

**Vom Zettel:** Fast ein eigenes Projekt. Von 0 auf. Auf keinen Fall Wikipedia o. ä. (bis ich ok sag). 50 % zum Ingame-Quatschen, 50 % als klassische KI. Zeig, wie, was, wo.

**Wie ich das verstehe:** Die KI hat zwei Hälften:

| Hälfte | Aufgabe |
|---|---|
| **A) Quatsch-KI (50 %)** | Die Menschen im Spiel können frei mit dir reden. Sie wissen, wer sie sind (Name, Job, Familie, Laune, was heute passiert ist) und antworten passend. |
| **B) Eigene KI (50 %)** | Eine **richtige, eigene KI** wie ein Chat-Assistent, **abgeschottet vom Spiel**, mit Internetsuche und Wikipedia. Nebenprojekt, kommt erst wenn das Spiel einigermaßen fertig ist (siehe M7). Später kann sie auch im Spiel vorkommen. |

**Verhaltens-KI** (wie Menschen und Tiere entscheiden, was sie tun) gehört zu Punkt 3 und wird dort gebaut. **Teil B** ist deine eigene KI, siehe unten und M7.

**Warum deine erste KI kaputt war (und wie wir es diesmal machen):**

Du hast erzählt: Du fragst „Was ist die Hauptstadt von Deutschland?“ und sie erzählt etwas über den Zweiten Weltkrieg. Das liegt nicht daran, dass Wikipedia „böse“ ist, sondern am **Training**:
- Ein Modell, das nur Wikipedia-Texte gelernt hat, kann nur eins: **Text weiterschreiben, der so ähnlich klingt wie Wikipedia.** Es weiß gar nicht, dass eine Frage eine Antwort will. Bei „Deutschland“ schreibt es einfach einen Wikipedia-artigen Absatz über Deutschland weiter.
- Ein kleines Modell kann außerdem nicht Millionen Fakten auswendig lernen. Es bringt sie durcheinander.

**Die Lösung, in drei Teilen:**
1. **Reden lernen aus Gesprächen:** Das Modell wird mit **Frage-Antwort- und Gesprächs-Beispielen** trainiert, nicht mit Lexikon-Text. So lernt es: Frage → kurze, passende Antwort.
2. **Wissen nachschlagen statt auswendig lernen:** Fakten stehen in einer Wissens-Datenbank. Vor jeder Antwort sucht das Spiel die passenden Fakten heraus und gibt sie dem Modell mit. Dann antwortet es „Berlin.“ statt eines Romans.
3. **Ingame-Wikipedia:** Du hast gesagt, Wikipedia ist okay als Wissen im Spiel. Also gibt es ein **Lexikon im Spiel** (auf den Ingame-PCs und Handys lesbar), und die KI darf darin **nachschlagen**. So wird Wikipedia nützlich, ohne das Modell kaputt zu machen.

Wir trainieren trotzdem ein **eigenes Modell von null** (dein „von 0 auf“).

| | Eigenes Modell von 0 |
|---|---|
| ✅ | Wirklich deins. Wissen kommt kontrolliert über das Nachschlagen, nicht durcheinander gelernt |
| ✅ | Läuft direkt auf dem Spieler-PC, keine Kosten pro Nachricht, kein Internet nötig |
| ⚠️ | Ohne riesige Textmengen bleibt es einfacher als ChatGPT. Es wird kürzere, einfachere Sätze können, aber gut **über das Spiel reden**, wenn wir genug Spiel-Texte haben |
| ⚠️ | Die meiste Arbeit sind die **Trainingstexte**: zigtausende Gesprächs-Beispiele im Stil der Spielwelt, die wir selbst schreiben bzw. aus Vorlagen erzeugen |

**Plan für die KI (eigener Teilplan):**
1. **Lern-Modell:** Ein sehr kleines Modell von null, um den ganzen Weg einmal gründlich durchzugehen (Text → Training → Antworten).
2. **Spiel-Sprache:** Eigene Trainingstexte schreiben: Alltagsgespräche (Grüßen, Wetter, Arbeit, Familie, Einkaufen, Streit, Flirt …), auf Deutsch, auch mit österreichischen und Innviertler Ausdrücken. **Immer als Gespräch** (Frage → Antwort), nie als reiner Lexikon-Text.
3. **Gedächtnis und Nachschlagen:** Jede Person bekommt ihre Fakten (wer bin ich, was ist heute passiert, wie stehe ich zum Spieler) vor jeder Antwort mitgegeben. Allgemeines Wissen kommt aus dem Ingame-Lexikon. So muss das Modell selbst keine Fakten auswendig wissen.
   **Prüfung:** Die Frage „Was ist die Hauptstadt von Deutschland?“ muss mit „Berlin“ beantwortet werden. Das wird ein fester Test.
4. **Einbau ins Spiel:** Das Modell läuft lokal auf der Grafikkarte, neben dem Spiel.
5. **Austauschbar:** Die KI hängt hinter einer klaren Schnittstelle. Wenn du später **„ok“** sagst, kann man ein größeres Modell oder mehr Wissen anschließen, ohne das Spiel umzubauen.


### Teil B: Deine eigene KI (Nebenprojekt, nach dem Spiel)

**Was sie sein soll:** Eine richtige KI, die dir gehört. Man kann mit ihr chatten wie mit Claude, sie kann **im Internet suchen**, **Wikipedia lesen** und das Gefundene **gescheit auswerten**. Sie läuft **eigenständig, getrennt vom Spiel**. Später kann man sie zusätzlich ins Spiel holen, zum Beispiel als Assistent am Ingame-Handy.

**Aufbauend auf Teil A:** Was wir für die Spiel-KI lernen (Training von null, mit Gesprächen trainieren, Wissen nachschlagen statt auswendig lernen), ist genau das Fundament für diese KI. Darum kommt sie danach.

**Wie Internetsuche bei einer KI funktioniert:**
1. Du stellst eine Frage.
2. Die KI entscheidet: Weiß ich das, oder muss ich suchen? Wenn suchen: sie schreibt selbst einen Suchbegriff.
3. Ein Programm schickt den Suchbegriff an eine Suchmaschine und holt die besten Treffer (Seiten, Wikipedia-Artikel).
4. Die KI liest die Treffer, sucht die wichtigen Stellen heraus und antwortet kurz, **mit Quellen**.
5. Wenn nötig, sucht sie noch einmal genauer (mehrere Schritte, wie ich es mache).

**Ehrlich dazu:**
- **Google direkt** darf man nicht einfach automatisch abfragen. Es braucht eine **Such-Schnittstelle** (es gibt bezahlte Such-Dienste und eine freie Lösung zum Selbst-Betreiben, z. B. SearXNG). Das klären wir, wenn es so weit ist.
- **Wie klug sie wird, hängt an der Größe.** Ein kleines Modell von null auf deinem PC wird nicht so klug wie ich. Es kann aber gut genug werden, um Suchergebnisse zusammenzufassen, weil es die Fakten nicht selbst wissen muss, sondern nachliest.
- Dein Fehler von früher (Frage nach der Hauptstadt → Text über den Zweiten Weltkrieg) wird hier ein **fester Test**: Sie muss kurz und richtig antworten und darf nicht abschweifen.

**Fertig, wenn …** (M7)
- [ ] Eigenständige KI-App, getrennt vom Spiel, mit Chat-Fenster.
- [ ] Sucht selbst im Internet und in Wikipedia, wenn sie etwas nicht weiß.
- [ ] Antwortet kurz, richtig und mit Quellen; schweift nicht ab.
- [ ] Merkt, wenn sie etwas nicht sicher weiß, und sagt das.
- [ ] Läuft auf deinem PC.
- [ ] Optional: auch im Spiel als Assistent nutzbar.

#### Trainings-Regel (gilt für alle KI-Teile: A, B, C)

Der PC soll **nicht tagelang am Stück** trainieren. Darum wird jedes Training so gebaut:
1. **Pausierbar:** Regelmäßige Zwischenstände (Checkpoints). Training jederzeit stoppen und später genau dort weitermachen.
2. **In Etappen:** z. B. nur nachts ein paar Stunden oder am Wochenende. Ein Zeitlimit pro Etappe ist einstellbar.
3. **Grafikkarte gedrosselt:** Standard-Grenze z. B. 70 % Leistung. Etwas langsamer, aber deutlich weniger Strom, leiser und kühler.
4. **Klein anfangen:** Zuerst kleine Modelle, die in Stunden fertig sind. Große Trainings erst, wenn die Trainings-Daten wirklich gut sind.
5. **Erst Probelauf, dann lang:** Kurzer Test vor jedem längeren Training.
6. **Anzeige:** Wie weit das Training ist, wie lange es noch ungefähr dauert und wie viel Strom es bisher ungefähr gebraucht hat.

#### Teil A: Fertig, wenn …

- [ ] Eigenes Modell von 0 trainiert, mit Gesprächen statt Lexikon-Text (Liste aller Trainingstexte liegt im Repo, nachprüfbar).
- [ ] Einfache Wissensfragen werden kurz und richtig beantwortet (z. B. Hauptstadt-Test).
- [ ] Spielfiguren antworten passend zu ihrer Person, ihrer Laune und dem, was passiert ist.
- [ ] Sie erinnern sich an frühere Gespräche mit dem Spieler.
- [ ] Antwort kommt in unter 2 Sekunden, das Spiel ruckelt dabei nicht.

---

### Punkt 5 – Ingame-PCs, Handys usw.

**Vom Zettel:** Wie im echten Leben, auch mit Kaufen und so. Nicht von dir gebastelt. Reale Betriebssysteme.

**Kaufen:** Geräte gibt es in Ingame-Geschäften mit Ingame-Geld, mit Preisen, verschiedenen Modellen, Akku, Garantie, sie können kaputtgehen. Der Besitz ist ein echtes Ding (Punkt 1).

**„Reale Betriebssysteme, nicht gebastelt“ – ehrlich:**

| Betriebssystem | Darf man das ins Spiel einbauen? |
|---|---|
| Windows | ❌ Nein. Lizenz von Microsoft verbietet das Weitergeben |
| macOS / iOS | ❌ Nein. Läuft laut Apple nur auf Apple-Geräten |
| Android **mit** Google (Play Store, Chrome …) | ❌ Nein. Google-Apps brauchen eine Lizenz |
| **Linux** (z. B. Debian, Ubuntu) | ✅ **Ja!** Komplett frei und echt |
| **Android ohne Google** (AOSP, Open Source) | ✅ Ja, ist frei |

**Mein Vorschlag:**
- **Ingame-PCs** laufen mit einem **echten Linux**, das in einer kleinen „virtuellen Maschine“ läuft. Das Bild davon wird auf den Bildschirm im Spiel gezeichnet, Maus und Tastatur gehen hinein. Es ist also **wirklich ein echtes Betriebssystem**, nicht von mir nachgebaut.
- **Ingame-Handys** laufen mit **echtem Android ohne Google** (Open Source).
- Damit sie im Spiel erfunden aussehen dürfen, bekommen die Geräte erfundene Markennamen. Die Software darin ist trotzdem echt.
- Nur **das Gerät, das der Spieler gerade benutzt**, läuft wirklich. Die anderen zeigen ein gespeichertes Bild (sonst schafft das kein PC).

**Ingame-Internet: gemischt (entschieden)**
- **Erfundene Spiel-Seiten** für alles, was mit dem Spielleben zu tun hat: **Ingame-Bank** (Kontostand, Überweisungen mit Ingame-Geld), Shops, Jobsuche, Wohnungssuche, Nachrichten aus Mattighofen, Ingame-Lexikon.
- **Ein paar echte Seiten** sind erreichbar, aber nur ausgewählte.
- **Echtes Online-Banking (Sparkasse, Raiffeisen usw.) ist gesperrt.** Im Spiel verwaltet man nur sein Spielgeld, nie echtes Geld. Echte Bank- und Bezahlseiten kommen auf eine Sperrliste.

**Fertig, wenn …**
- [ ] PC und Handy können im Spiel gekauft werden und sind Besitz.
- [ ] Ein echtes Linux läuft auf dem Ingame-PC, mit Maus und Tastatur bedienbar.
- [ ] Ein echtes Android (ohne Google) läuft auf dem Ingame-Handy.
- [ ] Ein Gerät zu benutzen bremst das Spiel nicht spürbar aus.
- [ ] Ingame-Bank, Shops und Nachrichten an andere Spielfiguren funktionieren über die Geräte.
- [ ] Ausgewählte echte Seiten gehen, echte Bank-/Bezahlseiten sind gesperrt.

---

## 2b. Echt handeln statt „Drücke E“ (gilt für alles)

**Wunsch:** Man soll viele neue Situationen und sogar **Jobs ausprobieren** können. Darum keine Abkürzungen wie „hinstellen, E drücken, Gemüse ist geerntet“. Alles wird **so gemacht wie in echt**.

**So funktioniert Handeln im Spiel:**
- **Echte Hände:** Die Figur hat Hände, die man steuert. Man greift Dinge, hält sie, dreht sie, legt sie ab, wirft sie. Ein Gegenstand liegt so in der Hand, wie man ihn gegriffen hat.
- **Echte Schritte:** Jede Tätigkeit besteht aus den Schritten, die sie auch in echt hat. Kein Fortschrittsbalken ersetzt die Arbeit.
- **Echtes Werkzeug:** Was man braucht, muss man haben, holen und richtig benutzen (Messer, Schaufel, Schraubenschlüssel, Kassa, Traktor).
- **Physik:** Dinge haben Gewicht, fallen um, gehen kaputt, werden schmutzig. Ein voller Sack ist schwer, ein Teller zerbricht.
- **Können wächst mit Übung:** Am Anfang ist man langsam und macht Fehler, mit Übung wird man besser und schneller. Fehler haben Folgen (kaputte Ernte, Kunde beschwert sich, Chef ist sauer).
- **Hinweise ja, Abkürzungen nein:** Wer etwas zum ersten Mal macht, kann sich zeigen lassen, wie es geht (z. B. vom Kollegen im Spiel). Machen muss man es aber selbst.

**Beispiel Bauer, Gemüse ernten:**
1. In der Früh aufstehen, Arbeitskleidung und Stiefel anziehen.
2. Kiste und Messer aus der Scheune holen.
3. Zum Feld gehen, sich hinknien.
4. Reifes Gemüse erkennen (Farbe, Größe). Unreifes bleibt stehen.
5. Mit der Hand halten, mit dem Messer abschneiden oder aus der Erde ziehen.
6. In die Kiste legen. Die volle Kiste ist schwer, tragen oder auf den Anhänger.
7. Zum Hof fahren, waschen, sortieren, verkaufen oder liefern.
8. Zu viel kaputt gemacht oder zu spät geerntet → weniger Geld.

**Jobs, ehrlich:** Jeder Job, der wirklich echt sein soll, ist viel Arbeit. Darum:
- **Entschieden 12.11.: Alle Jobs, die es in Mattighofen gibt, sollen echt spielbar werden** (siehe Frage 41). Gebaut wird trotzdem der Reihe nach: zuerst **Bauer**, **Supermarkt (Regale, Kassa)**, **Kfz-Mechaniker**, dann Job für Job weiter.
- Danach kommen Job für Job weitere dazu (Koch, Büro am echten Linux-PC, Polizist, Arzt, Lehrer, Handwerker …).
- Die anderen Menschen arbeiten in allen Jobs, auch die, die der Spieler noch nicht selbst machen kann.

**Fertig, wenn …** (wird Teil von M1 und M3)
- [ ] Es gibt im ganzen Spiel keine „Drücke E für …“-Abkürzung.
- [ ] Greifen, Halten, Tragen, Benutzen mit den Händen funktioniert mit Physik.
- [ ] Die 3 ersten Jobs sind Schritt für Schritt echt spielbar, mit Lohn, Chef, Fehlern und Übung.

---

## 2c. Spielregeln

| Thema | Regel |
|---|---|
| **Zeit** | **Fest: 1 Spieltag = 1 echte Stunde** (ein Arbeitstag ≈ 20 echte Minuten). Nicht einstellbar |
| **Überspringen** | Nur **Schlafen** und **Warten** (z. B. auf den Bus, eine Stunde fernsehen) dürfen vorgespult werden. Alles andere spielt man selbst |
| **Tod der Spielfigur** | **Nicht** als Familienmitglied weiter. Man fängt als **neue, fremde Person in derselben Welt** an. Die alte Figur bleibt tot, ihre Familie trauert, das Erbe geht an die Familie (nicht an den Spieler). Die Welt läuft immer weiter |
| **Startalter** | Frei wählbar, von der Geburt bis zum Erwachsenen |
| **Speichern** | **Automatisch, kein Zurück.** Das Spiel speichert laufend, Fehler kann man nicht durch Neuladen rückgängig machen. Wie im echten Leben |
| **Geld** | **Echte österreichische Preise:** Löhne nach echten Kollektivverträgen, echte Mieten, Lohnsteuer und Sozialversicherung, Supermarkt-Preise wie in echt. Die Preise brauchen eine Liste, die regelmäßig aktualisiert wird |
| **Auto** | **Echter Führerschein:** Fahrschule, Theorie- und Fahrprüfung im Spiel, L17 ab 17. Ohne Führerschein fahren geht, ist aber strafbar (Polizei, Strafe) |
| **Schule** | **Echte Schule:** hingehen, Unterricht, Hausaufgaben, Noten, Zeugnis. Schwänzen hat Folgen |

### Reden mit den Menschen

| Thema | Regel |
|---|---|
| **Du redest** | Mit **Mikrofon** (Spracherkennung) oder durch **Tippen** |
| **Sie antworten** | **Mit Stimme**: Jede Person hat ihre eigene Stimme, dazu Untertitel |
| **Sprache** | **Gemischt wie in echt:** Ältere eher Innviertler Dialekt, Jüngere eher österreichisches Umgangsdeutsch, manche Hochdeutsch |

Dafür braucht die KI (Punkt 4) zusätzlich:
- **Spracherkennung**, die auch Dialekt versteht.
- **Sprachausgabe** mit vielen verschiedenen Stimmen (alt, jung, Mann, Frau, Dialekt).
- ✅ **Entschieden: auch Spracherkennung und Stimmen werden von 0 selbst gebaut.**

### Teil C: Eigene Spracherkennung und eigene Stimmen (von 0)

Das ist ein **eigenes großes Teilprojekt**, ähnlich groß wie das Sprachmodell.

| Teil | Was es macht | Was es zum Lernen braucht |
|---|---|---|
| **Spracherkennung** | Hört dein Mikrofon und macht daraus Text | Viele Stunden Sprache **mit** dem passenden Text dazu, von vielen verschiedenen Menschen, auch im Dialekt |
| **Sprachausgabe** | Macht aus der Antwort-Text eine Stimme | Pro Stimme mehrere Stunden saubere Aufnahmen einer Person, mit Text |

**Woher die Aufnahmen kommen (Vorschlag):**
- **Freie Sprach-Sammlungen**, die man ausdrücklich zum Trainieren verwenden darf (z. B. Mozilla Common Voice, Deutsch, gemeinfrei). Das Modell bleibt trotzdem **von 0 selbst trainiert**, nur die Aufnahmen kommen von dort.
- **Eigene Aufnahmen** für Dialekt und für die Stimmen der Spielfiguren: du, Familie, Freunde. **Nur mit Erlaubnis** der Person, und es wird aufgeschrieben, wer zugestimmt hat.
- Keine Stimmen von echten bekannten Personen nachmachen.

**Ehrlich dazu:**
- Am Anfang werden die eigenen Stimmen roboterhaft klingen und die Erkennung wird Fehler machen, vor allem beim Dialekt. Das wird mit mehr Aufnahmen und Training Schritt für Schritt besser.
- Training dauert auf der 3060 Ti lange (Tage bis Wochen pro Modell). Das passt zur 1. Regel.
- **Bis Teil C gut genug ist, funktioniert das Spiel mit Tippen und Untertiteln.** So blockiert Teil C den Rest nicht.

**Fertig, wenn …**
- [ ] Eigene Spracherkennung von 0, versteht Hochdeutsch und österreichisches Umgangsdeutsch zuverlässig, Innviertler Dialekt gut genug.
- [ ] Eigene Sprachausgabe von 0 mit mindestens 10 verschiedenen Stimmen (alt, jung, Mann, Frau, Dialekt).
- [ ] Antwort mit Stimme kommt so schnell, dass ein Gespräch flüssig wirkt.
- [ ] Liste aller Aufnahmen und Zustimmungen liegt im Repo.

---

## 2d. Weitere Entscheidungen (Fragerunde 11.11.2026)

### Spielen
| Thema | Entscheidung |
|---|---|
| Steuerung | Erst einmal **Maus + Tastatur**. Controller/VR vielleicht später |
| Anzeige am Bildschirm | **Fast nichts.** Uhrzeit auf Uhr oder Handy, Geld in Brieftasche oder Banking-App, Hunger merkt man an Bauchknurren und Figur |
| Mitspieler | **Erst allein, später online.** Von Anfang an so bauen, dass Online später möglich ist |
| Für wen | **Erst für dich, vielleicht später verkaufen.** Darum rechtlich von Anfang an sauber (Lizenzen, Marken, Musik) |
| Leistung | **Flüssig vor schön.** Grafik-Einstellungen im Menü |
| Name | Später entscheiden, bis dahin „Echtleben“ |

### Altersfreigabe: einstellbar
- **Voller Modus (ab 18):** Waffen für alle (nur mit echter Waffenbesitzkarte, Missbrauch hat schwere Folgen), echte Gewalt, Alkohol, Rauchen, **illegale Drogen** (mit Polizei, Strafen, Sucht, Gesundheitsfolgen).
- **Jugendmodus:** schaltet Waffen, Blut, Drogen und Glücksspiel aus.
- Die echte Freigabe vergibt am Ende eine Prüfstelle (z. B. PEGI), erst wenn verkauft wird.

### Inhalts-Einstellungen (12.11.2026)
Heikle Inhalte lassen sich **einzeln** ein- und ausschalten, nicht nur über den Jugendmodus. Der **Jugendmodus ist nur eine Voreinstellung**, die alles unten auf „aus“ stellt. Jeder Schalter einzeln:

| Schalter | Wenn aus |
|---|---|
| Blut | Keine Blutspuren, Verletzungen nur angedeutet |
| Waffen | Keine Waffen für den Spieler, nur bei Polizei/Jägern sichtbar |
| Gewalt gegen Menschen | Streit nur mit Worten |
| Illegale Drogen | Kommen nicht vor |
| Alkohol und Rauchen | Kommen nicht vor |
| Glücksspiel | Kein Casino, keine Wetten, kein Lotto |
| Schlachten | Ausgeblendet |
| Erbrechen, Ekel | Nur angedeutet |
| Geburt | Ausgeblendet |
| Sterben anderer Menschen | Nur erfahren, nicht dabei sein |
| Psychische Krankheiten | Kommen nicht vor |
| Suizid als Thema | Kommt nicht vor |
| Liebe und Romantik | Nur Freundschaft |
| Belästigung, Stalking | Kommt nicht vor |
| Schmerz- und Rausch-Effekte (Wackeln usw.) | Schwächer (Stufen statt nur an/aus) |

Hinweis: Was aus ist, passiert in der Welt auch den Menschen im Spiel nicht sichtbar, die Welt bleibt aber sonst gleich.

### Leben
| Thema | Entscheidung |
|---|---|
| Liebe | Flirten, Beziehung, Heiraten, Trennung, Scheidung. **Intimes wird ausgeblendet** (Bildschirm schwarz) |
| Kinder | **Komplett:** Schwangerschaft, Geburt, Baby versorgen, großziehen, Kindergeld, Karenz |
| Gefängnis | **Wird gespielt:** Alltag, Arbeit, Kontakte. Lange Strafen laufen schneller, werden aber **nicht ganz übersprungen**. **Ausbrechen ist möglich**, aber schwer und echt: planen, Lücken finden, Werkzeug besorgen, Helfer. Wer erwischt wird, bekommt eine längere Strafe; wer entkommt, wird gesucht (Fahndung, Polizei kontrolliert, Leben auf der Flucht) |
| Krankheit | **Echt:** echte Krankheiten, Arzt, Diagnose, Krankenstand, Medikamente; manche heilbar, manche nicht |
| Körper | **Verändert sich sichtbar:** zunehmen, abnehmen, Muskeln, Haare, Bart, Falten, langsam wie in echt |
| Gesicht | Nur über den **Editor**, keine Fotos |
| Haustiere | **Mit echter Pflege:** kaufen oder Tierheim, füttern, Gassi, Tierarzt, werden alt und sterben |
| Wohnen | **Alles, was geht:** einrichten, Möbel frei stellen, ausmalen, renovieren, umbauen, Grundstück kaufen, mit Baugenehmigung ein Haus bauen (selbst oder mit Firma) |

### Welt
| Thema | Entscheidung |
|---|---|
| Kalender | **Echt:** österreichische Feiertage, Ferien, Weihnachten, Ostern, Silvester, Fasching, Feste im Ort. Geschäfte an Feiertagen zu |
| Naturereignisse | **Selten, wie in echt:** Unwetter, Hagel, Hochwasser an der Mattig, Stromausfall, mit Schäden und Versicherung |
| Reisen | Zuerst nur Mattighofen und Umgebung, **später Nachbarorte**, weitere Orte (z. B. Salzburg) als Erweiterungen |
| Social Media | **Erfundene Apps** auf dem Ingame-Handy (Messenger, Foto-App …). Die Menschen im Spiel posten, liken, schreiben dir |
| Musik | Freie und selbst gemachte Musik, **dazu eigene MP3s** des Spielers im Ingame-Radio. Echte bekannte Lieder nicht eingebaut (Lizenz) |
| Marken | **Leicht veränderte Namen**, die an echte erinnern. Keine echten Logos |

---

## 2e. Gefühle und Empfindungen spüren

**Wunsch:** Man soll **sehen und spüren**, wie es der Figur geht: Schmerzen, Sucht, Müdigkeit, Angst usw. Weil es fast keine Anzeigen gibt (2d), passiert das **über Bild, Ton, Steuerung und Gedanken**, nicht über Balken.

**Vier Wege, wie man es spürt:**
1. **Bild:** Farben, Schärfe, Ränder, Wackeln.
2. **Ton:** Herzschlag, Atmen, Rauschen, gedämpfte Geräusche.
3. **Körper und Steuerung:** Die Figur bewegt sich anders, die Hände zittern, Greifen wird ungenauer, man wird langsamer.
4. **Gedanken:** kurze innere Sätze als Untertitel, z. B. „Mein Knie tut voll weh.“ oder „Ich brauch jetzt eine Zigarette.“

| Zustand | Was man sieht, hört und spürt |
|---|---|
| **Schmerz** | Bildränder pulsieren rot, man humpelt oder hält sich die Stelle, Stöhnen, die betroffene Hand oder das Bein ist schwächer. Je nachdem, **wo** es weh tut, anders |
| **Hunger / Durst** | Bauchknurren, man wird schwächer und unkonzentrierter, Gedanken ans Essen |
| **Müdigkeit** | Bild wird kurz schwarz (Blinzeln), Gähnen, alles langsamer, Fehler bei der Arbeit |
| **Kälte / Hitze** | Zittern, sichtbarer Atem, Schwitzen, Hände ungeschickt |
| **Krankheit** | Je nach Krankheit: Husten, Fieber (Bild flimmert leicht), Übelkeit, Schwindel |
| **Betrunken** | Bild schwankt, Steuerung verzögert, Sprache lallt, man stolpert |
| **Unter Drogen** (nur voller Modus) | Je nach Droge: Farben, Wahrnehmung und Zeitgefühl verändert, danach der Absturz |
| **Sucht / Entzug** | Zitternde Hände (Greifen wird schwer), Schwitzen, Unruhe, Gereiztheit, **Gedanken kreisen immer wieder um die Sucht**, schlechter Schlaf |
| **Angst / Stress** | Herzschlag wird lauter, Tunnelblick, schneller Atem, Hände zittern |
| **Traurigkeit** | Farben werden blasser, Musik leiser und langsamer, weniger Lust auf Dinge |
| **Freude / Verliebt** | Farben wärmer und heller, beschwingte Bewegungen |
| **Wut** | Bildränder dunkler, Figur angespannt, kurze Antworten im Gespräch |

**Auch bei den anderen Menschen:** Man sieht ihre Gefühle **an Gesicht und Körpersprache** (traurig, wütend, verliebt, krank, betrunken) und an ihrer Stimme. Und sie reagieren auf deinen Zustand („Du schaust aber fertig aus.“).

**Einstellungen:** Die Stärke der Effekte ist im Menü einstellbar, z. B. weniger Wackeln für Leute, denen schnell schlecht wird.

**Fertig, wenn …** (wird Teil von M1 und M3)
- [ ] Jeder Zustand aus der Tabelle ist ohne Anzeige-Balken klar spürbar.
- [ ] Zustände wirken auf die Steuerung und die Hände (z. B. Zittern beim Entzug).
- [ ] Die Gedanken passen zur Lage und wiederholen sich nicht dauernd.
- [ ] Die Menschen im Spiel zeigen Gefühle sichtbar und reagieren auf deinen Zustand.

---

## 2f. Weitere Entscheidungen (Fragerunde 2, 11.11.2026)

### Spielen
| Thema | Entscheidung |
|---|---|
| Pause | **Normale Pause:** Menü öffnen, alles steht still |
| Nichts tun (AFK) | Die Figur **steht einfach da**, bei Gefahr reagiert sie selbst (z. B. aus dem Weg gehen) |
| Klo, Duschen, Zähneputzen | **Echt, aber diskret:** muss man machen, sonst Folgen (Geruch, Leute reagieren, Krankheit). Kamera dreht beim Klo und Duschen weg |
| Erfolge | **Keine Erfolge.** Stattdessen ein **Tagebuch, das man selbst schreibt**, mit eigenen Fotos vom Ingame-Handy. Nichts passiert automatisch |

### Leben in Österreich
| Thema | Entscheidung |
|---|---|
| Bundesheer / Zivildienst | **Wie in echt:** Stellung, Tauglichkeit, dann Grundwehrdienst (6 Monate) oder Zivildienst (9 Monate). **Gespielt werden die ersten Wochen** (Grundausbildung bzw. Einschulung) und besondere Tage. **Der Rest läuft schneller** (wie beim Gefängnis), wird aber nicht ganz übersprungen |
| Ämter und Papierkram | **Komplett echt:** jedes Formular, jede Frist, jeder Termin (Meldezettel, Ausweis, AMS, Anmeldungen, Anträge), am Amt oder online, mit Wartezeiten. Verpasste Fristen haben Folgen |
| Eigene Firma | **Ja:** Gewerbe anmelden, Kredit, Lokal mieten, Mitarbeiter einstellen, Steuern, Buchhaltung. Kann pleitegehen |
| Politik | **Wahlen und selbst kandidieren:** Gemeinderatswahlen, einer erfundenen Partei beitreten, Bürgermeister werden. **Keine echten Parteien oder Politiker** |

### Welt über die Jahre
| Thema | Entscheidung |
|---|---|
| Zeit | Start **heute (2026)**, dann läuft die Zeit weiter: neue Handys, Autos, Mode usw. kommen mit den Spieljahren dazu |
| Wirtschaft | **Inflation und Krisen:** Preise und Löhne steigen langsam, ab und zu Krisen mit Jobverlusten und Firmenpleiten |
| Ruf | **Wie im echten Dorf:** Was du tust, spricht sich herum, auch falsch und übertrieben. Der Ruf beeinflusst Jobs, Freunde und Liebe |
| Glücksspiel | **Ab 18, mit Spielsucht:** Lotto, Wettbüro, Casino, mit echten Gewinnchancen (meistens verliert man). **Nur Spielgeld, nie echtes Geld.** Im Jugendmodus aus |

---

## 2g. Weitere Entscheidungen (Fragerunde 3, 11.11.2026)

| Thema | Entscheidung |
|---|---|
| Kochen | **Echt:** Zutaten einkaufen, schneiden, kochen, würzen, echte Rezepte. Kann anbrennen, Essen verdirbt |
| Kleidung | **Echt:** wird schmutzig, muss gewaschen werden, geht kaputt, passt nicht mehr nach Zunehmen. Mode ändert sich über die Jahre |
| Verkehr | **Alles:** zu Fuß, Fahrrad (kann gestohlen werden, Platten), Moped/Motorrad mit Ausweis bzw. Führerschein, Bus und Zug mit echten Fahrplänen, Tickets und Verspätungen, Taxi, Mitfahren |
| Vereine | **Ja:** Freiwillige Feuerwehr, Fußballverein, Musikkapelle, Sportvereine. Mitmachen, Übungen, Feste, Einsätze |
| Angeln | **Mit echten Regeln:** Fischerkarte, Schonzeiten, Brittelmaß, echte Gewässer rund um Mattighofen. Wissen aus Austro Angler wird verwendet |
| Jagen | **Mit echten Regeln:** Jagdprüfung, Jagdkarte, Schonzeiten. Nur im vollen Modus |
| Zocken im Spiel | **Echte freie Spiele** auf dem Ingame-PC (echtes Linux, Open-Source-Spiele). Zu viel zocken hat Folgen (Schlaf, Noten, Job) |
| Religion | **Freie Wahl:** Menschen haben verschiedene oder keine Religion. Kirche, Feste und Zeremonien gibt es, mitmachen muss man nicht |
| Träume | **Manchmal:** kurze, verschwommene Traum-Szenen aus dem Erlebten, Albträume nach schlimmen Erlebnissen |

### Austro Angler im Spiel 🎣
**Die eigene App Austro Angler gibt es auch im Spiel**, auf dem Ingame-Handy. Weil sie dir gehört, ist das rechtlich kein Problem.
- Idee: Weil auf dem Ingame-Handy ein **echtes Android** läuft, kann dort die **echte Austro-Angler-App** (die APK) installiert werden.
- ⚠️ Muss getestet werden: Das Ingame-Android hat **keine Google-Dienste**. Teile der App, die Google/Firebase brauchen (z. B. Konto, Community, Benachrichtigungen), funktionieren dort vielleicht nicht. Die Teile ohne Konto (Gewässer, Fangbuch, Fischlexikon, Schonzeiten) sollten gehen.
- Im Spiel nützlich: Gewässer finden, Schonzeiten prüfen, Fänge ins Fangbuch eintragen.

---

## 2h. Weitere Entscheidungen (Fragerunde 4, 11.11.2026)

| Thema | Entscheidung |
|---|---|
| Bleibende Folgen | **Ja, mit Hilfen:** Schwere Unfälle oder Krankheiten können bleiben (Rollstuhl, Brille, Hörgerät). Das Leben geht weiter, mit Reha und Unterstützung |
| Pension | **Echt:** Höhe hängt davon ab, wie lange und wie viel man gearbeitet hat. Pensionsantritt wie in Österreich |
| Dir passiert etwas | **Selten, wie in echt:** Fahrrad gestohlen, Einbruch, Betrugs-Nachrichten am Ingame-Handy. Anzeige bei der Polizei, Versicherung |
| Nachrichten | **Spiel-Nachrichten:** Lokalzeitung, Radio und TV berichten über Mattighofen im Spiel (Unfälle, Wahlen, Feste), auch über dich, wenn du etwas Großes machst |
| Spiel lernen | **Von Menschen im Spiel:** Eltern, Lehrer, Kollegen, Fahrlehrer zeigen dir Dinge. Dazu ein kurzes Steuerungs-Training am Anfang |
| Gefahren in der Natur | **Wie in echt:** Zecken (FSME), Wespen, Allergien, Glatteis, Sonnenbrand. Mit Vorbeugung: Zeckenimpfung, Sonnencreme, Winterreifen |
| Schulden | **Komplett echt:** Kredite, Raten, Mahnungen, Inkasso, Gehaltspfändung, Privatkonkurs, Schuldnerberatung |
| Erben | **Testament selbst schreiben** möglich. Ohne Testament gesetzliche Erbfolge. Erbstreit in der Familie möglich |
| Urlaub | **Erst, wenn es echte Orte gibt**, die man bespielen kann |
| Wohnung finden | **Echter Wohnungsmarkt:** Inserate, Besichtigung, Kaution, Makler, Mietvertrag, Genossenschaft mit Wartezeit, WG, bei den Eltern wohnen. Gute Wohnungen sind schnell weg |
| Online bestellen | **Mit echten Paketen:** Spiel-Shopseiten, Bote bringt das Paket, manchmal nur ein Zettel und man muss zur Post. Rücksendungen möglich |
| Lebensdauer | **Wie in echt:** Lebenserwartung wie in Österreich, abhängig von Lebensstil, Gesundheit und Glück |

---

## 2i. Grundregel und Fragerunde 5 (11.11.2026)

> **Grundregel: Im Zweifel immer die echte Variante.** Wenn etwas nicht ausdrücklich anders entschieden ist, wird es so gebaut, wie es im echten Leben in Österreich ist. Gefragt wird nur noch, wo es wirklich zwei gute Möglichkeiten gibt.

### Jugend
| Thema | Entscheidung |
|---|---|
| Ausbildung | **Alle echten Wege:** Lehre mit Berufsschule, Poly, HTL, HAK, Gymnasium, Matura, Studium (Uni erst mit anderen Orten) |
| Geld für Jugendliche | Taschengeld von den Eltern, Ferialjob, Babysitten, Rasenmähen für Nachbarn |
| Jugendschutz | **Wie in Oberösterreich:** Ausgehzeiten nach Alter, Kontrollen. Eltern können strengere Regeln haben |
| Mobbing | Kann passieren (auch online), mit echten Gefühlen. Man kann sich wehren und Hilfe holen |

### Freizeit
| Thema | Entscheidung |
|---|---|
| Ausgehen | **Wie im Innviertel:** Wirtshaus, Café, Bar, Disco, Zeltfeste, Maifeste, Feuerwehrfeste. Türsteher, Ausweis, Heimfahrt-Problem |
| Sport | **Selbst spielen:** Fußball, Laufen, Schwimmen, Radfahren, Fitnessstudio wirklich steuern |
| Instrument | **Wirklich spielen** über die Tastatur, am Anfang klingt es schlecht. Musikschule, Musikkapelle |
| Bücher | **Echte freie Bücher** (Urheberrecht abgelaufen) wirklich lesbar, dazu Sachbücher zum Lernen |

### Auto
| Thema | Entscheidung |
|---|---|
| Pflichten | Pickerl, Service, Winterreifen, Reparaturen. Vergessen hat Folgen |
| Tanken | Tank wird leer, Spritpreise schwanken. Später auch E-Autos laden |
| Strafen | Falschparken, Radar, Polizeikontrolle, Alkotest, Führerschein-Entzug, Vormerksystem |
| Wildunfälle | Vor allem in der Dämmerung, mit Meldepflicht und Versicherung |

### Haushalt
| Thema | Entscheidung |
|---|---|
| Putzen und Müll | Wohnung wird dreckig. **Mülltrennung wie in Österreich**, Müllabfuhr-Tage |
| Garten | Säen, gießen, jäten, ernten, Obstbäume, Hühner. Wetter und Schnecken |
| Reparieren | Selbst, wenn man es kann, Schritt für Schritt. Sonst Handwerker |
| Geräte gehen kaputt | Durch Alter, Pech oder Fallenlassen. Garantie, Reparatur, neu kaufen |

### Spielgefühl
| Thema | Entscheidung |
|---|---|
| Wie viel passiert | **Echt ruhig.** Viele Tage sind normal, große Ereignisse sind selten |
| Schwierigkeit | **So hart wie in echt** |
| Hintergrundmusik | **Keine.** Musik nur, wenn wirklich etwas spielt (Radio, Handy, Disco) |
| Können anzeigen | **Nein, nur spüren:** man merkt es daran, dass es besser klappt, und an Noten, Chef, Zeugnissen |
| Persönlichkeit | **Kommt von Genen, Eltern und Kindheit**, wie in echt. Wer nicht als Baby startet, kann zusätzlich ein paar Charakterzüge festlegen. Alles kann sich langsam durch das, was man tut, ändern |
| Neue Person nach dem Tod | **Selbst aussuchen:** jemanden, der schon in der Welt lebt, oder eine neue Person, die zuzieht |
| Startdatum | **Selbst wählen** beim Anlegen einer Welt (Datum und Jahreszeit) |
| Welten | **Mehrere Welten**, die man parallel spielen kann, **und nicht nur Mattighofen** als Startort (siehe unten) |

**Mehrere Welten, andere Orte, ehrlich:** Mattighofen wird von Hand sehr genau gebaut. Jeder weitere Ort so genau wäre jedes Mal ein riesiges Projekt. Vorschlag: Ein **Ort-Baukasten**, der aus Kartendaten (OpenStreetMap, Geländedaten) einen Ort **automatisch vorbaut**, danach wird von Hand verbessert. Automatisch gebaute Orte sehen zuerst weniger echt aus als Mattighofen. Kommt erst nach M6.

### Ohne Vorliebe, nach Grundregel entschieden
| Thema | Entscheidung |
|---|---|
| Mods | Spiel wird so gebaut, dass Mods **später** möglich sind |
| Sprache | Deutsch, Menüs und Untertitel **später auch Englisch**. Die Menschen reden immer Deutsch/Dialekt |
| Lügen | **Ja, wie in echt:** Leute verschweigen, lügen, übertreiben |
| Berühmt werden | **Möglich, aber so selten wie in echt** |

---

## 2j. Offene Fragen (für den Sprach-Chat)

100 Fragen, bei denen es wirklich mehrere gute Möglichkeiten gibt. In Klammern stehen die Möglichkeiten. Die Grundregel „im Zweifel echt“ gilt weiter. **Antworten bitte als nummerierte Liste (1–100) in den Planungs-Chat zurückbringen.** Übersprungene Fragen werden nach der Grundregel entschieden.

### A. Zeit und Welt
1. Wenn das Spiel aus ist: Läuft die Welt weiter, oder bleibt sie stehen? (weiter / stehen)
2. Darf man jederzeit in eine andere Person der Welt schlüpfen, oder bleibt man bis zum Tod dieselbe? (jederzeit / erst nach dem Tod)
3. Nach dem Tod: Startet die neue Person sofort, oder vergeht vorher Zeit, z. B. man sieht noch das eigene Begräbnis? (sofort / Zeit vergeht)
4. Ein Spieljahr dauert bei 1 Tag = 1 Stunde **365 echte Stunden**. Ist das okay? (so lassen / Jahre laufen schneller, ein Tag bleibt eine Stunde)
5. Ein ganzes Leben wären rund **30.000 Spielstunden**. Altert man im echten Tempo? (echt / schneller altern als die Uhr / einstellbar)
6. Bei 1 Tag = 1 Stunde müsste man ca. alle 20 Minuten essen und oft aufs Klo. Bedürfnisse im echten Takt? (echter Takt / seltener, damit es nicht nervt)
7. Nachts: stockdunkel wie in echt, oder ein bisschen heller, damit man etwas sieht? (echt dunkel / etwas heller)
8. Wetter: Zufall nach dem echten Klima von Mattighofen, oder das echte Wetter vom selben Tag aus früheren Jahren? (Zufall nach Klima / echte alte Wetterdaten)
9. Verändert sich der Ort über die Jahre (neue Häuser, Abriss, Geschäfte sperren zu und auf)? (ja / bleibt gleich)
10. Echte Straßennamen und Hausnummern? (echt / erfunden)
11. Können alle Häuser von innen betreten werden? (alle, unwichtige einfacher gebaut / nur wichtige)
12. Am Land sind Haustüren oft offen. Im Spiel auch? (wie echt, manche offen / immer zugesperrt)
13. Mit wie vielen Menschen startet Mattighofen? (500 und dann mehr / gleich die echte Einwohnerzahl, dafür einfacher)
14. Gibt es Zuzug und Wegzug von außerhalb? (ja / nur Geburten und Tod)

### B. Steuerung und Bild
15. Hände steuern: Maus bewegt die Hand ganz frei, oder halb-automatisch (zielen + klicken, die Hand greift selbst richtig)? (ganz frei / halb-automatisch / umschaltbar)
16. Sieht man in der Ich-Sicht den eigenen Körper (Beine, Bauch)? (ja / nur Hände)
17. Kopfwackeln beim Gehen: echt, oder ruhiger? (echt / ruhig / einstellbar)
18. Ist das Handy auch das Menü (Einstellungen, Speichern über eine Handy-App)? (ja, Handy = Menü / normales Menü)
19. Karte: nur echte Karten (Papier, Karten-App am Handy), oder eine kleine Karte am Bildschirm? (nur echte / kleine Karte)
20. Wegfinden: Navi-App am Handy, oder muss man Leute fragen und sich merken? (Navi-App / fragen)
21. Wenn Leute in der Nähe miteinander reden: kann man mitlesen (Untertitel)? (ja / nur hören)
22. Untertitel bei Dialekt: so wie gesprochen, auf Hochdeutsch übersetzt, oder umschaltbar? (wie gesprochen / Hochdeutsch / umschaltbar)
23. Soll es einen Fotomodus mit freier Kamera geben? (ja / nur Fotos mit dem Ingame-Handy)
24. Häuser betreten ohne Ladebildschirm (schwerer zu bauen) oder mit kurzen Ladezeiten? (nahtlos / kurze Ladezeiten okay)
25. Gedanken-Untertitel in Ich-Form („Mir ist kalt“) oder als Beschreibung („Dir ist kalt“)? (Ich-Form / Du-Form)
26. Wie oft kommen Gedanken? (oft / selten / einstellbar)

### C. Menschen
27. Merken sich die Menschen alles für immer, oder vergessen sie langsam wie echt? (für immer / vergessen langsam)
28. Hält Groll ewig, oder verblasst er mit der Zeit? (ewig / verblasst)
29. Sprechen dich fremde Menschen von selbst an? (oft / selten wie in echt / nur Bekannte)
30. In Mattighofen leben auch Menschen, die zu Hause andere Sprachen sprechen. Im Spiel auch, und reden sie manchmal so? (ja / alle reden nur Deutsch)
31. Reden kleine Kinder im Spiel wie echte Kinder (mit Fehlern, einfachen Sätzen)? (ja / normal)
32. Schreiben dir Menschen von selbst am Handy? (oft / selten / nur enge Leute)
33. Adoption und Pflegekinder möglich? (ja / nein)
34. Wenn man als Erwachsener startet: Hat die Figur schon eine Vergangenheit (Freunde, Ex, Schulden, Erinnerungen)? (ja, automatisch / leer, alles neu)
35. Gerichtsverhandlung selbst erleben, oder zusammengefasst? (selbst erleben / zusammengefasst)
36. Kann die neue Person nach dem Tod das Erbe bekommen, wenn sie im Testament steht? (ja, erlaubt / nein, wäre Schummeln)
37. Kann man von Menschen gestalkt oder belästigt werden? (ja, selten mit Hilfe / nein)
38. Haben die Menschen Hobbys, bei denen man mitmachen kann (z. B. jemand nimmt dich zum Angeln mit)? (ja / nein)

### D. Arbeit und Geld
39. Arbeitstag (ca. 20 echte Minuten): ganz spielen, oder dürfen Teile vorgespult werden? (ganz / Teile vorspulbar)
40. Arbeitsweg: selbst fahren/gehen, oder vorspulbar? (selbst / vorspulbar)
41. Die ersten 3 Jobs: Bauer, Supermarkt, Kfz-Mechaniker. Passt das, oder andere? (passt / andere: welche?)
42. Bewerbung: selbst schreiben (die KI im Spiel liest sie), oder auswählen? (selbst schreiben / auswählen)
43. Vorstellungsgespräch per Mikrofon wirklich führen? (ja / nein, Text)
44. Eine Ingame-Plattform für Kleinanzeigen (wie willhaben, erfundener Name) zum Kaufen und Verkaufen? (ja / nein)
45. Aktien und Krypto im Spiel (nur Spielgeld)? (ja / nein)
46. Lohnzettel mit allen Abzügen im Detail? (ja / nur Netto)
47. Preise: einmal heutige echte Preise und dann Inflation im Spiel, oder per Update an echte Preise anpassen? (Inflation im Spiel / echte Updates)
48. Kann man schwarzarbeiten oder schwarz Geld verdienen (mit Risiko)? (ja / nein)
49. Trinkgeld, Spenden, Betteln, Straßenmusik? (ja / nein)
50. Kann man Lotto gewinnen und Millionär werden (sehr selten, wie echt)? (ja / nein)

### E. Wohnen und Besitz
51. Startwohnung als Erwachsener: zufällig oder selbst aussuchen? (Zufall / aussuchen)
52. Möbel: im Möbelhaus kaufen und **selbst zusammenbauen** (Schritt für Schritt)? (ja / werden fertig geliefert / beides)
53. Nachbarn: Lärm, Hausordnung, Streit? (ja / nein)
54. Kann man alles stehlen, was nicht festgemacht ist? (ja, mit Folgen / nur bestimmte Dinge)
55. Bauernhof mit Tieren: Schlachten zeigen oder ausblenden? (zeigen / ausblenden / nur im vollen Modus)
56. Smart Home, Solaranlage, Wärmepumpe? (ja / später)

### F. Gesundheit und schwere Themen
57. Wie oft wird man krank? (wie echt / seltener)
58. Psychische Krankheiten (Depression, Burnout, Angst) mit Therapie? (ja, vorsichtig / nein)
59. Sehr schwere Themen wie Suizid: komplett weglassen, oder nur sehr vorsichtig mit Hilfe-Infos? (weglassen / vorsichtig mit Hilfe)
60. Schwangerschaft selbst spielen, mit Beschwerden, die man spürt? (ja / nur nebenbei)
61. Geburt zeigen oder ausblenden? (zeigen, nicht blutig / ausblenden)
62. Demenz im Alter möglich (Figur vergisst Dinge)? (ja / nein)
63. Sieht man andere Menschen sterben (z. B. Großeltern im Krankenhaus)? (ja, ruhig / ausblenden)
64. Erbrechen und ekelige Dinge zeigen? (ja / ausblenden)
65. Wie viel Blut im vollen Modus? (realistisch / wenig)
66. Narben und bleibende Spuren am Körper sichtbar? (ja / nein)

### G. Verbrechen und Polizei
67. Wie gut ist die Polizei? (wie echt, manches wird nie aufgeklärt / strenger, man wird fast immer erwischt)
68. Erkennt die Polizei dich später an Gesicht, Kleidung, Auto, Kameras? (ja / einfacher)
69. Kann man selbst Polizist werden und echt ermitteln? (ja, als Job / später)
70. Hacken am Ingame-PC (in der Spielwelt, z. B. Ingame-Bank)? (ja / nein)
71. Wie viele Verbrechen begehen die anderen Menschen? (wie echte Statistik / etwas mehr)
72. Anwalt nehmen, Pflichtverteidiger? (ja / nein)

### H. Geräte und Internet
73. Welche echten Websites dürfen im Ingame-Internet gehen? (keine / nur Wissen wie Wikipedia / eine Liste, die du festlegst)
74. Am Ingame-PC wirklich programmieren lernen können (echtes Linux)? (ja / egal)
75. Fotos und Videos aus dem Spiel auf die echte Festplatte speichern können? (ja / nein)
76. Ingame-PC so langsam wie ein echter alter PC, wenn er alt ist? (ja / immer gleich)
77. Ingame-Handy: Akku leer, Display kaputt, Updates? (ja / nur Akku)
78. Ab wann kommt der Handy-Assistent (deine eigene KI)? (mit M7 / früher als einfache Version)

### I. Feste, Natur, Kleinigkeiten
79. Brauchtum wie Krampuslauf, Perchten, Maibaum? (ja / nein)
80. Gelsen, Fliegen, Wespen, die nerven? (ja / nein)
81. Gerüche über Gedanken („Riecht nach Gülle“)? (ja / nein)
82. Wildtiere, die gefährlich werden können (z. B. Wildschwein)? (ja, selten / nein)
83. Gewitter und Stromausfall, sodass Geräte und Licht ausgehen? (ja / nein)
84. Schnee räumen, Streuen, Rasenmähen als echte Arbeiten? (ja / läuft nebenbei)

### J. Anfang und Ende
85. Erste Szene beim Start eines neuen Lebens: Geburt, Aufwachen im Bett, oder direkt im Alltag? (Geburt / Aufwachen / Alltag)
86. Kindheit: ganz spielen oder schneller durchlaufen? (ganz / schneller)
87. Was sieht man im Moment des Todes? (schwarz / langsames Ausblenden / kurzer Rückblick aufs Leben)
88. Gibt es nach einem ganzen Leben eine Zusammenfassung (Lebenslauf, Fotos)? (ja / nein)
89. Spielstände haben kein Zurück. Dürfen trotzdem Sicherheitskopien gemacht werden (Absturz)? (ja / nein)

### K. Projekt und Veröffentlichung
90. Was soll man in der allerersten spielbaren Version machen können? (Tag als Bauer / Schultag / einfach durch Mattighofen gehen / etwas anderes)
91. Andere Orte: wenige, die so genau sind wie Mattighofen, oder viele aus dem Baukasten? (wenige genau / viele automatisch)
92. Online später: Freunde kommen in deine Welt, oder eine gemeinsame Welt für alle? (deine Welt / gemeinsame Welt)
93. Online später: Sprachchat mit Freunden im Spiel? (ja / nein)
94. Wer darf testen? (nur du / Familie und Freunde / öffentliche Testversion)
95. Falls verkauft: früh als „Early Access“ oder erst fertig? (früh / fertig)
96. Wo veröffentlichen? (Steam / itch.io / beides)
97. Code öffentlich (Open Source) oder privat? (öffentlich / privat)
98. Entwicklungs-Tagebuch (Devlog, z. B. Videos), damit andere zusehen können? (ja / nein)
99. Namensideen für das Spiel? (Echtleben behalten / Vorschläge sammeln)
100. Wie soll das Logo bzw. der Stil der Menüs aussehen? (schlicht / österreichisch / wie ein Handy)

---

## 2k. Antworten aus dem Sprach-Chat (11.11.2026)

### Welt, Personen, Tod
| Thema | Entscheidung |
|---|---|
| Spiel aus | **Die Welt bleibt stehen**, solange nicht gespielt wird |
| Person wechseln | **Jederzeit** in eine andere Person der Welt wechselbar. Die bisherige Person **lebt danach ganz normal weiter**, gesteuert wie alle anderen Menschen (nach Grundregel entschieden, passt zu Punkt 3) |
| Nach dem Tod | **Kurze Cutscene**, auch wenn kein Begräbnis stattfindet. Danach bekommt man eine **zufällige bestehende Person** oder **erstellt eine neue** (geändert 12.11., siehe Frage 36: so kann man sich das Erbe nicht gezielt zuschieben) |

### Speichern
| Thema | Entscheidung |
|---|---|
| Autosave | **Alle 2 Minuten** (fest, nicht einstellbar) und **beim Beenden**. Es gibt **nur einen Spielstand pro Welt**, jeder Autosave überschreibt den alten. Keine extra Sicherheitskopien |
| Beim Vorspulen | Gespeichert wird **erst am Ende** des Vorspulens |
| Gespräch beim Beenden | Nur der Satz, der gerade gesprochen wird, geht verloren. Der Rest des Gesprächs bleibt erhalten |
| Technik-Hinweis | Damit ein Absturz beim Speichern den Spielstand nicht kaputt macht: zuerst in eine neue Datei schreiben, dann die alte ersetzen. Für den Spieler bleibt es ein einziger Spielstand |

### Sprache und Untertitel
| Thema | Entscheidung |
|---|---|
| Untertitel bei Dialekt | **Umschaltbar** (wie gesprochen / Hochdeutsch) |
| Dialekt | Lässt sich **ganz an- und ausschalten**. Aus = alle Menschen reden Hochdeutsch bzw. Umgangsdeutsch |

### Innenleben der Figur
| Thema | Entscheidung |
|---|---|
| Innere Stimme | Die Figur hat eine **hörbare innere Stimme**, die kommentiert und reagiert. Dazu **Gedanken- und Gefühls-Untertitel**: seelische Gefühle und Körperschmerz **mit Ort** („Mein linkes Knie …“) |
| Eigene Vorlieben | Die Figur hat **eigene Vorlieben, unabhängig vom Spieler** (Essen, Musik, Menschen, Hobbys). Tut man etwas, das sie nicht mag, merkt man das an Stimmung und innerer Stimme |
| Schlafen | **Einschlafen und Aufwachen** werden selbst erlebt, dazwischen wird vorgespult |
| Schlaf und Stimmung | Zu wenig Schlaf wirkt sich aus: beim Aufwachen müde und schlecht gelaunt, tagsüber unkonzentriert |
| Liebe | Liebe hat **echte Folgen**, z. B. Leid nach einer Trennung. **Unerwiderte Liebe** gibt es auch, mit Leid und Folgen |

### Klargestellt
- **Altersfreigabe:** Einstellbar, wie in 2d: **voller Modus ab 18**, dazu ein **Jugendmodus**. Die alte Angabe „ab 16/18“ wurde korrigiert.
- **Intimität:** Laut 2d entschieden: Flirten, Beziehung, Heiraten ja, **Intimes wird ausgeblendet** (Bildschirm schwarz). Gilt in beiden Modi, bis es anders entschieden wird.

Die übrigen Fragen aus 2j sind noch offen.

---

## 2l. Antworten zu den 100 Fragen (Teil 1, 12.11.2026)

Beantwortet im Planungs-Chat. Nummern = Fragen aus 2j.

| Nr. | Thema | Entscheidung |
|---|---|---|
| 1 | Spiel aus | Welt bleibt stehen (siehe 2k) |
| 2 | Person wechseln | Jederzeit (siehe 2k) |
| 3 | Nach dem Tod | Cutscene, dann Liste (siehe 2k) |
| 4 | Spieljahr | **Bleibt:** 1 Tag = 1 echte Stunde, ein Jahr = 365 Stunden |
| 5 | Altern | **Echtes Tempo**, passend zur Spielzeit |
| 6 | Bedürfnisse | **Echter Takt**, bezogen auf die Spielzeit |
| 7 | Nacht | **Stockdunkel wie echt**, Licht nötig |
| 8 | Wetter | **Zufall nach dem echten Klima** von Mattighofen |
| 9 | Ort verändert sich | **Ja**, neue Häuser, Abriss, Geschäfte sperren zu und auf |
| 10 | Adressen | **Echte Straßennamen und Hausnummern** (Bewohner sind erfunden) |
| 11 | Innenräume | **Alle Häuser** betretbar, unwichtige einfacher gebaut |
| 12 | Haustüren | **Wie echt:** manche sperren nicht ab |
| 13 | Einwohner | **500 zum Start**, dann schrittweise bis zur echten Zahl |
| 14 | Zuzug/Wegzug | **Ja** |
| 15 | Hände | **Umschaltbar:** ganz frei oder halb-automatisch |
| 16 | Eigener Körper | **Sichtbar** in der Ich-Sicht |
| 17 | Kopfwackeln | **Echt** (Einstellung für Reisekrankheit siehe 2e) |
| 18 | Menü | **Normales Menü** (nicht über das Handy) |
| 19 | Karte | **Nur echte Karten:** Papier oder Karten-App |
| 20 | Navi | **Navi-App** am Handy und im Auto |
| 21 | Gespräche anderer | **Hören und mitlesen**, aber je weiter weg, desto **leiser und verschwommener** (Untertitel unscharf/unvollständig) |
| 22 | Dialekt-Untertitel | Umschaltbar, Dialekt ganz abschaltbar (siehe 2k) |
| 23 | Fotomodus | **Ja**, mit freier Kamera |
| 24 | Laden | Kurze Ladezeiten erlaubt, **höchstens 5 Sekunden** |
| 25 | Gedanken | **Ich-Form** („Mir ist kalt.“) |
| 26 | Häufigkeit | **Oft** |
| 27 | Gedächtnis | **Vergessen langsam:** Unwichtiges geht, Wichtiges bleibt |
| 89 | Sicherheitskopien | Keine, ein einziger Autosave (siehe 2k) |

---

## 2m. Antworten zu den 100 Fragen (Teil 2, 12.11.2026)

| Nr. | Thema | Entscheidung |
|---|---|---|
| 28 | Groll | **Verblasst** mit der Zeit und mit Entschuldigungen |
| 29 | Fremde sprechen dich an | **Selten, wie echt** |
| 30 | Andere Sprachen | **Ja, und manche Menschen können kein oder kaum Deutsch.** Verständigung ist dann schwer (Hände, Füße, Übersetzer-App, jemand übersetzt). Die eigene KI und die Stimmen müssen dafür auch andere Sprachen können (später) |
| 31 | Kleine Kinder | Reden **kindlich**, je nach Alter |
| 32 | Nachrichten aufs Handy | **Selten** |
| 33 | Adoption, Pflegekinder | **Ja**, mit echtem Ablauf über das Amt |
| 34 | Vorgeschichte als Erwachsener | **Wählbar:** man legt die Vorgeschichte fest (Freunde, Ex, Schulden …) oder lässt sie würfeln |
| 35 | Gericht | **Selbst erleben**, im Gerichtssaal, selbst reden |
| 36 | Erbe nach dem Tod | **Ja, erlaubt**, wenn es im Testament steht. **Aber:** nach dem Tod bekommt man eine **zufällige** Person oder erstellt eine **neue**, man kann sich also nicht gezielt den Erben aussuchen |
| 37 | Belästigung, Stalking | **Ja, selten**, mit Polizei, Anzeige, Hilfe |
| 38 | Zu Hobbys eingeladen werden | **Ja** |
| 39, 40 | Arbeitstag und Arbeitsweg | **Am Anfang selbst spielen.** Später **überspringt das Spiel zufällig einzelne Arbeitstage und Arbeitswege** automatisch, damit es nicht immer gleich ist. Neue und besondere Tage spielt man immer selbst |
| 41 | Jobs | **Alle Jobs, die es in Mattighofen gibt**, echt spielbar (siehe Hinweis unten) |
| 42 | Bewerbung | **Selbst schreiben**, die Spiel-KI liest und bewertet sie |
| 43 | Vorstellungsgespräch | **Wirklich führen**, per Mikrofon oder Tippen |
| 44 | Kleinanzeigen | **Ja**, Ingame-Plattform mit erfundenem Namen, mit Handeln und Betrügern |
| 45 | Aktien, Krypto | **Ja**, erfundene Firmen und Coins, nur Spielgeld |
| 46 | Lohnzettel | **Mit allen Abzügen** im Detail |
| 47 | Preise | **Echte Updates:** Preise werden regelmäßig an die echten angepasst |

**Ehrlicher Hinweis zu Frage 41:** Jeder Job, der Schritt für Schritt echt sein soll, ist viel Arbeit (Werkzeug, Abläufe, Fehler, Können). „Alle Jobs in Mattighofen“ sind sehr viele. Darum: Alle Jobs **existieren** von Anfang an (die Menschen arbeiten dort), und **spielbar** werden sie der Reihe nach. M3 ist fertig, sobald die ersten 3 komplett sind. Danach kommt Job für Job dazu, auch nach M6 noch.

### Echte PC-Spiele im Spiel: „Bildschirm-Durchreiche“ (wird Teil von M5)
- Im **Ingame-PC** (echtes Linux) laufen **freie Linux-Spiele**. Weil dieser PC keinen Zugriff auf die Grafikkarte hat, laufen vor allem **2D-Spiele** gut, 3D-Spiele eher langsam oder gar nicht.
- **Steam und Epic werden nicht eingebaut** (Lizenz: darf man nicht mitliefern, auch nicht gratis an Freunde; Epic gibt es für Linux nicht offiziell; Spiele würden ohne Grafikkarte kaum laufen).
- **Bildschirm-Durchreiche:** Man startet ein **echtes Spiel auf dem echten PC** (z. B. über Steam). Echtleben zeigt es auf dem **Ingame-Monitor**, die Figur sitzt davor, gesteuert wird mit Maus und Tastatur. So gehen alle eigenen Spiele, rechtlich sauber, weil nichts mitgeliefert wird.
- Haken: zwei Spiele gleichzeitig sind für die 3060 Ti schwer. Echtleben schraubt währenddessen die eigene Grafik stark herunter. Leichte Spiele gehen gut, große eher ruckelig.

**Freie Spiele für den Ingame-PC (Ideen, Lizenzen jeweils prüfen):**
| Spiel | Art | Im Ingame-PC |
|---|---|---|
| SuperTux | Jump'n'Run | gut (2D) |
| Battle for Wesnoth | Runden-Strategie | gut (2D) |
| OpenTTD (mit freier Grafik OpenGFX) | Transport-Aufbau | gut (2D) |
| Mindustry | Fabrik/Tower-Defense | gut (2D) |
| Frozen Bubble | Puzzle | gut (2D) |
| Pingus | Puzzle | gut (2D) |
| Schach, Solitär, Minesweeper, Mahjongg (z. B. GNOME-Spiele) | Klassiker | gut |
| SuperTuxKart | Kart-Rennen | langsam (3D) |
| Luanti (früher Minetest) | Klötzchen-Bauen | langsam (3D) |
| 0 A.D. | Echtzeit-Strategie | wahrscheinlich zu langsam (3D) |

---

## 2n. Antworten zu den 100 Fragen (Teil 3, 12.11.2026)

| Nr. | Thema | Entscheidung |
|---|---|---|
| 48 | Schwarzarbeit | **Ja**, mit Risiko (Kontrollen, Strafen, keine Versicherung) |
| 49 | Trinkgeld, Spenden, Betteln, Straßenmusik | **Ja** |
| 50 | Lotto-Millionär | **Ja**, mit echten Gewinnchancen (fast nie) |
| 51 | Startwohnung | **Teil der Vorgeschichte** (gewählt oder gewürfelt) |
| 52 | Möbel | **Beides:** selbst aufbauen oder gegen Aufpreis aufbauen lassen |
| 53 | Nachbarn | **Ja:** Lärm, Hausordnung, Streit, aber auch Hilfe |
| 54 | Stehlen | **Alles, was man tragen kann**, mit Folgen |
| 55 | Schlachten | **Nur im vollen Modus** zeigen, im Jugendmodus ausgeblendet |
| 56, 57 | Haustechnik, Krankwerden | Nach Grundregel: **wie echt** |
| 58 | Psychische Krankheiten | **Ja, vorsichtig** und respektvoll, mit Arzt, Therapie, Freunden |
| 59 | Suizid als Thema | **Kommt vor, aber nur mit festen Regeln:** nie gezeigt, keine Methode, die Spielfigur kann es nicht als Handlung ausführen. Nur über Menschen im Spiel (Trauer, Hinterbliebene), Schwerpunkt auf Hilfe holen. Echte Hilfe-Nummern im Spiel: Telefonseelsorge 142, Rat auf Draht 147. Im Jugendmodus aus |
| 60, 62, 66 | Schwangerschaft, Demenz, Narben | Nach Grundregel: **wie echt** |
| 61 | Geburt | **Zeigen, nicht blutig** |
| 63 | Andere sterben sehen | **Ja, ruhig**, man kann Abschied nehmen |
| 64 | Erbrechen, Ekel | **Zeigen**, kurz und echt |
| 65 | Blut (voller Modus) | **Realistisch** |
| 67–69, 71, 72, 74, 76, 77, 79–84 | Polizei, Anwalt, Brauchtum, Natur usw. | Nach Grundregel: **wie echt** |

---

## 3. Meilensteine (Reihenfolge)

Jeder Meilenstein darf so lange dauern, wie er braucht. Der nächste beginnt erst, wenn die „Fertig, wenn …“-Liste vollständig abgehakt ist.

| # | Meilenstein | Inhalt |
|---|---|---|
| **M0** | Fundament | PC einrichten, Unreal installieren, leeres Projekt im Repo, Git LFS, erste Testszene. Technik-Tests: MetaHuman altern, eine Linux-VM auf einem Bildschirm im Spiel, Mini-KI-Training. **Damit wissen wir früh, ob die schwierigen Teile gehen.** |
| **M1** | Charakter | Punkt 1 komplett |
| **M2** | Welt | Punkt 2 komplett (Mattighofen) |
| **M3** | Andere Menschen | Punkt 3 komplett, inklusive Wirtschaft (Jobs, Geld, Geschäfte, Wohnungen) |
| **M4** | **Eine KI für alles** ⭐ kommt direkt nach M0 | **Spiel-KI und deine eigene KI werden gemeinsam gebaut** (12.11. entschieden): ein gemeinsamer KI-Kern von 0, der (a) im Spiel die Menschen sprechen lässt und (b) als eigenständige KI-App mit Internetsuche und Wikipedia läuft. Siehe „Eine KI für alles“ unten |
| **M4b** | Eigene Stimmen | Punkt 4 Teil C: Spracherkennung und Sprachausgabe von 0. Kann nebenher laufen, das Spiel geht bis dahin mit Tippen |
| **M5** | Geräte | Punkt 5 komplett (PCs, Handys, echtes Betriebssystem) |
| **M6** | Alles zusammen | Spielstart-Menü, Speichern, Einstellungen, langes Testspielen, Fehler beheben |
| ~~M7~~ | ~~Deine eigene KI~~ | **In M4 aufgegangen** (12.11.) |

**Reihenfolge (geändert 12.11.):** M0 → **M4 (Eine KI für alles)** → M1 → M2 → M3 → M4b → M5 → M6

### Eine KI für alles (M4)
- **Ein gemeinsamer Kern:** Ein eigenes Sprachmodell von 0 lernt Deutsch reden (Gespräche, Frage → Antwort) und Wissen **nachschlagen** statt auswendig lernen.
- **Zwei Anwendungen auf demselben Kern:**
  - **Deine KI-App:** eigenständig, mit Internetsuche und Wikipedia, mit Quellen. Abgeschottet vom Spiel.
  - **Spiel-KI:** dieselbe KI, aber jede Person im Spiel bekommt ihre eigene Rolle (wer bin ich, was ist heute passiert, wie stehe ich zum Spieler) und schlägt nur im Ingame-Lexikon und in der Spielwelt nach, **nicht** im echten Internet.
- **Warum zuerst:** Die KI braucht **kein Unreal**. Sie wird mit Python auf dem PC trainiert und kann sofort losgehen. Die längste Rechenzeit (Training) läuft so früh, während später an der Welt gebaut wird.
- **Ehrlich:** Am Anfang wird die KI einfach und manchmal dumm antworten. Mit besseren Trainings-Gesprächen und mehr Training wird sie Schritt für Schritt besser. Der Einbau ins Spiel kommt erst, wenn es Figuren gibt (ab M1/M3).
- Trainings-Regel (pausierbar, in Etappen, gedrosselt) gilt.
- **Fertig, wenn …** die Listen von Teil A und Teil B oben abgehakt sind, mit Ausnahme von „läuft im Spiel“ (das kommt mit M3).

### Nicht jeder weiß alles (12.11.2026)
„Nachschlagen“ heißt bei der Spiel-KI **nicht**, dass jede Person das ganze Lexikon kennt. Jede Person hat **ihr eigenes Wissen**, und die KI darf nur darin nachschlagen:

| Wissen | Beispiel |
|---|---|
| **Eigene Erinnerungen** | Was sie selbst erlebt, gesehen und gehört hat |
| **Gerüchte** | Was ihr erzählt wurde, auch falsch oder übertrieben |
| **Ausbildung und Beruf** | Der Mechaniker kennt sich mit Autos aus, die Ärztin mit Krankheiten, der Bauer mit Feldern |
| **Alter** | Kleine Kinder wissen wenig, Ältere kennen die Geschichte des Ortes |
| **Allgemeinwissen** | Unterschiedlich viel, je nach Person (Schule, Interessen) |
| **Interessen und Hobbys** | Wer angelt, kennt Schonzeiten. Wer Fußball schaut, kennt die Tabelle |

- Weiß jemand etwas nicht, sagt er „Keine Ahnung“, rät, oder liegt **falsch**, wie echte Menschen.
- Menschen im Spiel können selbst **am Ingame-Handy nachschauen**. Das dauert dann sichtbar ein bisschen, wie in echt.
- **Lernen:** Was eine Person neu erfährt (von dir, von anderen, aus den Nachrichten), kommt in ihr Wissen. Unwichtiges vergisst sie langsam (Frage 27).
- **Deine KI-App** ist anders: Die darf alles nachschlagen, auch im Internet.

Warum **M0** davor: Bei drei Dingen (Altern, echtes Betriebssystem im Spiel, eigene KI) ist nicht sicher, wie gut sie gehen. Das testen wir am Anfang klein, statt nach einem Jahr Arbeit draufzukommen.

---

## Für den PC (Claude Code am PC)

Dieser Plan wurde in einem eigenen Planungs-Chat gemacht. **Gebaut wird am PC.** Wer dort codet, hält sich an:
1. **1. Regel: Beeile dich niemals. Mach gründlich.**
2. Mit **M0** anfangen. Ein Meilenstein ist erst fertig, wenn seine „Fertig, wenn …“-Liste vollständig abgehakt ist.
3. **„Zeig, wie, was, wo“:** zu jedem Schritt eine Erklär-Seite in `plaene/echtleben/erklaert/`.
4. **Keine „Drücke E“-Abkürzungen** (Abschnitt 2b).
5. Bei Unklarheit lieber nachfragen als raten. Größere Änderungen am Plan zuerst im Planungs-Chat besprechen.

---

## 4. Entscheidungen

| Frage | Entscheidung |
|---|---|
| Grafikkarte / Arbeitsspeicher | RTX 3060, 16 GB (Aufrüsten auf 32 GB empfohlen, siehe 1.3) |
| KI Teil B (50 %) | Eigene, richtige KI mit Internetsuche und Wikipedia, abgeschottet vom Spiel, als Nebenprojekt nach dem Spiel (M7); darf später auch ins Spiel |
| „Zeig, wie, was, wo“ | Gilt für **alles**, nicht nur für die KI |
| Spielwelt | Echter Ort: **Mattighofen** |
| Sicht | Umschaltbar (erste und dritte Person) |
| Ingame-Internet | Gemischt: Spiel-Seiten (inkl. Ingame-Bank) und einige echte Seiten; echtes Online-Banking gesperrt |
| Wikipedia | Als Ingame-Lexikon erlaubt, die KI darf darin nachschlagen. Trainiert wird sie aber mit Gesprächen |
| Harte Themen | Volles Programm: Krankheit, Tod, Verbrechen und Polizei, Unfälle. Freigabe **einstellbar**: voller Modus ab 18, Jugendmodus (siehe 2d) |
| Engine | Unreal Engine 5 (kein Einspruch) |
| Spielregeln | Siehe Abschnitt 2c: 1 Spieltag = 1 Stunde fest, Schlafen + Warten vorspulbar, nach dem Tod als neue fremde Person weiter, Startalter frei, automatisch speichern ohne Zurück, echte Preise, echter Führerschein, echte Schule |
| Reden | Mikrofon + Tippen, Antworten mit Stimme, Dialekt gemischt wie in echt |
| Spracherkennung + Stimmen | Auch von 0 selbst gebaut (Teil C, M4b); Aufnahmen aus freien Sammlungen und eigenen Aufnahmen mit Erlaubnis |
| Handeln | Alles echt, keine „Drücke E“-Abkürzungen; Jobs ausprobieren, zuerst 3 Jobs komplett |
| Arbeitsweise | Dieser Chat plant, gebaut wird am PC. Der Plan kommt als Artefakt zum PC |

## 5. Noch offen (hat Zeit)

- Eigener Name für das Spiel?

**Nächster Schritt:** M0 (Fundament) im Detail ausarbeiten, Schritt für Schritt.
