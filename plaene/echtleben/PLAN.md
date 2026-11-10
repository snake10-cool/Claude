# 🌍 Echtleben – Spielplan (Arbeitsname)

> **Stand:** 10.11.2026 · **Status:** nur Planung, es wird noch nichts gebaut
> **1. Regel:** Beeile dich niemals. Mach gründlich.
> **Grundsatz:** Ein Meilenstein soll dauern. Erst wenn einer wirklich fertig ist, kommt der nächste.

Dieser Plan arbeitet die zwei Zettel „Ein Spiel“ aus. Alles, was auf den Zetteln steht, ist hier drin.
Wo ich etwas **ehrlich als schwierig oder rechtlich problematisch** sehe, steht das dabei, zusammen mit einem Vorschlag.
Wo ich deine Schrift oder Idee **nicht sicher verstanden** habe, ist das mit ❓ markiert (Liste ganz unten).

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

| Was | Mindestens | Besser |
|---|---|---|
| Grafikkarte | RTX 3060 (8 GB) | RTX 4070 oder stärker |
| Arbeitsspeicher | 32 GB | 64 GB |
| Speicherplatz | 300 GB freie SSD | 1 TB SSD |
| Prozessor | 6 Kerne | 8+ Kerne |

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

**Erste Spielwelt (Vorschlag):** eine **erfundene österreichische Kleinstadt** mit Umgebung, ca. 2 × 2 km Stadt plus Land rundherum:
- Altstadt, Wohnsiedlung, Gewerbegebiet, Schule, Supermarkt, Arzt, Bahnhof
- Felder, Wiesen, ein Wald, ein Fluss, ein Teich (passt übrigens gut zu deinem Angel-Wissen 🎣)
- Später kann man weitere Orte anschließen.

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

**Größe:** Start mit ca. **500 Einwohnern** in der Kleinstadt. Wenn das stabil läuft, auf 2.000+ erhöhen.

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
| **B) Klassische KI (50 %)** ❓ | Entweder (1) die **Verhaltens-KI**: wie Menschen und Tiere entscheiden, was sie tun und wohin sie gehen; oder (2) eine **Assistenten-KI** im Spiel, z. B. auf den Ingame-Handys, wie ein eingebauter Chat-Assistent. Bitte sagen, was gemeint ist. |

**„Von 0 auf, keine Wikipedia“ – was das ehrlich bedeutet:**

Ein Sprachmodell lernt nur aus den Texten, die man ihm gibt. Fertige Modelle (ChatGPT, Claude, Llama …) haben fast alle Wikipedia und große Teile des Internets gelernt. **Die darf man nach deiner Regel also nicht nehmen.** Das heißt, wir trainieren ein **eigenes kleines Modell von null**.

| | Eigenes Modell von 0 |
|---|---|
| ✅ | Wirklich deins. Weiß nur das, was in deiner Welt existiert. Kein „Internetwissen“, das die Spielwelt kaputt macht |
| ✅ | Läuft direkt auf dem Spieler-PC, keine Kosten pro Nachricht, kein Internet nötig |
| ⚠️ | Ohne riesige Textmengen bleibt es einfacher als ChatGPT. Es wird kürzere, einfachere Sätze können, aber gut **über das Spiel reden**, wenn wir genug Spiel-Texte haben |
| ⚠️ | Die meiste Arbeit sind die **Trainingstexte**: zigtausende Gesprächs-Beispiele im Stil der Spielwelt, die wir selbst schreiben bzw. aus Vorlagen erzeugen |

**Plan für die KI (eigener Teilplan):**
1. **Lern-Modell:** Ein sehr kleines Modell von null, um den ganzen Weg einmal gründlich durchzugehen (Text → Training → Antworten).
2. **Spiel-Sprache:** Eigene Trainingstexte schreiben: Alltagsgespräche (Grüßen, Wetter, Arbeit, Familie, Einkaufen, Streit, Flirt …), auf Deutsch, auch mit österreichischen Ausdrücken.
3. **Gedächtnis:** Jede Person bekommt ihre Fakten (wer bin ich, was ist heute passiert, wie stehe ich zum Spieler) vor jeder Antwort mitgegeben. So muss das Modell selbst keine Fakten auswendig wissen.
4. **Einbau ins Spiel:** Das Modell läuft lokal auf der Grafikkarte, neben dem Spiel.
5. **Austauschbar:** Die KI hängt hinter einer klaren Schnittstelle. Wenn du später **„ok“** sagst, kann man ein größeres Modell oder mehr Wissen anschließen, ohne das Spiel umzubauen.

**„Zeig, wie, was, wo“** ❓: Ich habe das so gelesen, dass du bei der KI **jeden Schritt gezeigt und erklärt** haben willst (wie sie funktioniert, was sie lernt, wo es im Code steht). Das machen wir so: jeder KI-Schritt bekommt eine eigene Erklär-Seite im Repo.

**Fertig, wenn …**
- [ ] Eigenes Modell von 0 trainiert, ohne Wikipedia/Internet-Texte (Liste aller Trainingstexte liegt im Repo, nachprüfbar).
- [ ] Spielfiguren antworten passend zu ihrer Person, ihrer Laune und dem, was passiert ist.
- [ ] Sie erinnern sich an frühere Gespräche mit dem Spieler.
- [ ] Antwort kommt in unter 2 Sekunden, das Spiel ruckelt dabei nicht.
- [ ] Teil B (klassische KI) fertig, sobald geklärt ist, was gemeint ist.

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
- **Offene Frage:** Soll das Ingame-Internet echt sein (echte Websites) oder eine eigene Spiel-Welt-Seiten haben? Echtes Internet würde die Spielwelt „aufbrechen“ und widerspricht vermutlich der Regel „keine Wikipedia“.

**Fertig, wenn …**
- [ ] PC und Handy können im Spiel gekauft werden und sind Besitz.
- [ ] Ein echtes Linux läuft auf dem Ingame-PC, mit Maus und Tastatur bedienbar.
- [ ] Ein echtes Android (ohne Google) läuft auf dem Ingame-Handy.
- [ ] Ein Gerät zu benutzen bremst das Spiel nicht spürbar aus.
- [ ] Geräte verbinden sich mit der Spielwelt (z. B. Ingame-Bank, Nachrichten an andere Spielfiguren) ❓ (gewünscht?)

---

## 3. Meilensteine (Reihenfolge)

Jeder Meilenstein darf so lange dauern, wie er braucht. Der nächste beginnt erst, wenn die „Fertig, wenn …“-Liste vollständig abgehakt ist.

| # | Meilenstein | Inhalt |
|---|---|---|
| **M0** | Fundament | PC einrichten, Unreal installieren, leeres Projekt im Repo, Git LFS, erste Testszene. Technik-Tests: MetaHuman altern, eine Linux-VM auf einem Bildschirm im Spiel, Mini-KI-Training. **Damit wissen wir früh, ob die schwierigen Teile gehen.** |
| **M1** | Charakter | Punkt 1 komplett |
| **M2** | Welt | Punkt 2 komplett (die Kleinstadt) |
| **M3** | Andere Menschen | Punkt 3 komplett, inklusive Wirtschaft (Jobs, Geld, Geschäfte, Wohnungen) |
| **M4** | KI | Punkt 4 komplett (eigenes Modell, Gespräche) |
| **M5** | Geräte | Punkt 5 komplett (PCs, Handys, echtes Betriebssystem) |
| **M6** | Alles zusammen | Spielstart-Menü, Speichern, Einstellungen, langes Testspielen, Fehler beheben |

Warum **M0** davor: Bei drei Dingen (Altern, echtes Betriebssystem im Spiel, eigene KI) ist nicht sicher, wie gut sie gehen. Das testen wir am Anfang klein, statt nach einem Jahr Arbeit draufzukommen.

---

## 4. Offene Fragen an dich ❓

1. **Klassische KI (Punkt 4):** Ist mit „50 % als klassische KI“ die **Verhaltens-KI** der Menschen gemeint oder eine **Assistenten-KI** (wie ChatGPT) im Spiel, z. B. am Ingame-Handy?
2. **„Zeig, wie, was, wo“:** Habe ich richtig gelesen, dass du jeden KI-Schritt erklärt bekommen willst? Oder soll die KI im Spiel dem Spieler etwas zeigen (z. B. den Weg)?
3. **Engine:** Passt Unreal Engine 5?
4. **Dein PC:** Welche Grafikkarte, wie viel Arbeitsspeicher hast du?
5. **Spielwelt:** Passt eine erfundene österreichische Kleinstadt als erste Welt?
6. **Sicht:** Erste Person (durch die Augen), dritte Person (Figur von hinten) oder umschaltbar?
7. **Alleine oder mit Freunden:** Nur Einzelspieler, oder später auch online zusammen?
8. **Ingame-Internet:** Echte Websites oder nur erfundene Spiel-Seiten?
9. **Grenzen:** Gibt es Dinge aus dem echten Leben, die **nicht** ins Spiel sollen (z. B. Verbrechen, Krankheit, Tod)? Davon hängt auch die Altersfreigabe ab.
10. **Name:** „Echtleben“ ist nur ein Arbeitsname. Hast du einen eigenen?

Sobald die Fragen beantwortet sind, arbeite ich als Nächstes **M0 (Fundament)** im Detail aus, Schritt für Schritt.
