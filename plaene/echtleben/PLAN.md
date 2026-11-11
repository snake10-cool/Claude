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
- **Zuerst 3 Jobs komplett echt**, passend zu Mattighofen (Vorschlag): **Bauer**, **Supermarkt (Regale, Kassa)**, **Kfz-Mechaniker**.
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
- **Jugendmodus:** schaltet Waffen, Blut und Drogen aus.
- Die echte Freigabe vergibt am Ende eine Prüfstelle (z. B. PEGI), erst wenn verkauft wird.

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

## 3. Meilensteine (Reihenfolge)

Jeder Meilenstein darf so lange dauern, wie er braucht. Der nächste beginnt erst, wenn die „Fertig, wenn …“-Liste vollständig abgehakt ist.

| # | Meilenstein | Inhalt |
|---|---|---|
| **M0** | Fundament | PC einrichten, Unreal installieren, leeres Projekt im Repo, Git LFS, erste Testszene. Technik-Tests: MetaHuman altern, eine Linux-VM auf einem Bildschirm im Spiel, Mini-KI-Training. **Damit wissen wir früh, ob die schwierigen Teile gehen.** |
| **M1** | Charakter | Punkt 1 komplett |
| **M2** | Welt | Punkt 2 komplett (Mattighofen) |
| **M3** | Andere Menschen | Punkt 3 komplett, inklusive Wirtschaft (Jobs, Geld, Geschäfte, Wohnungen) |
| **M4** | KI | Punkt 4 komplett (eigenes Modell, Gespräche) |
| **M4b** | Eigene Stimmen | Punkt 4 Teil C: Spracherkennung und Sprachausgabe von 0. Kann nebenher laufen, das Spiel geht bis dahin mit Tippen |
| **M5** | Geräte | Punkt 5 komplett (PCs, Handys, echtes Betriebssystem) |
| **M6** | Alles zusammen | Spielstart-Menü, Speichern, Einstellungen, langes Testspielen, Fehler beheben |
| **M7** | Deine eigene KI (Nebenprojekt) | Punkt 4 Teil B: eigenständige KI mit Internetsuche und Wikipedia, getrennt vom Spiel. Erst wenn das Spiel einigermaßen fertig ist |

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
| Harte Themen | Volles Programm: Krankheit, Tod, Verbrechen und Polizei, Unfälle (Freigabe ab 16/18) |
| Engine | Unreal Engine 5 (kein Einspruch) |
| Spielregeln | Siehe Abschnitt 2c: 1 Spieltag = 1 Stunde fest, Schlafen + Warten vorspulbar, nach dem Tod als neue fremde Person weiter, Startalter frei, automatisch speichern ohne Zurück, echte Preise, echter Führerschein, echte Schule |
| Reden | Mikrofon + Tippen, Antworten mit Stimme, Dialekt gemischt wie in echt |
| Spracherkennung + Stimmen | Auch von 0 selbst gebaut (Teil C, M4b); Aufnahmen aus freien Sammlungen und eigenen Aufnahmen mit Erlaubnis |
| Handeln | Alles echt, keine „Drücke E“-Abkürzungen; Jobs ausprobieren, zuerst 3 Jobs komplett |
| Arbeitsweise | Dieser Chat plant, gebaut wird am PC. Der Plan kommt als Artefakt zum PC |

## 5. Noch offen (hat Zeit)

- Eigener Name für das Spiel?

**Nächster Schritt:** M0 (Fundament) im Detail ausarbeiten, Schritt für Schritt.
