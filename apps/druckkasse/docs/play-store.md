# Druckkasse – Play Store

Paket-ID: `com.snake10.druckkasse` · Kategorie: **Business** (alternativ: Produktivität)

## Store-Eintrag (Deutsch)

**Titel (max. 30):** `Druckkasse: 3D-Druck Kosten`

**Kurzbeschreibung (max. 80):**
`3D-Druck Kosten berechnen, Preise festlegen, Verkäufe zählen. Für Bambu & Co.`

**Beschreibung (max. 4000):**

```
Was kostet dein 3D-Druck wirklich? Und was verdienst du daran?

Druckkasse ist die Kasse für alle, die 3D-Drucke verkaufen: Flexi Dragons, Klicker, Infinity Cubes, Fidget Stars, Deko oder Auftragsarbeiten. Die App rechnet Filament, Strom und Abnutzung deines Druckers pro Stück und schlägt dir einen Preis vor.

🧮 KOSTEN GENAU BERECHNEN
• Drucker anlegen mit Vorlagen für Bambu Lab A1, A1 mini, P1S, X1C, Creality Ender 3 und mehr
• Filamente mit Kilopreis, Material (PLA, PETG, TPU, Silk …) und Farbe
• Mehrfarbige Drucke mit AMS inklusive Spülabfall
• Mehrere Teile pro Druckplatte
• Verpackung und Extras, Handarbeit mit Stundenlohn, Fehldruck-Zuschlag

💶 PREIS VORSCHLAGEN
• Aufschlag in Prozent, Preis automatisch auf 0,50 € oder 1 € aufgerundet
• Gewinn pro Stück und echte Marge auf einen Blick

👆 VERKAUFEN MIT EINEM TIPP
• Große Knöpfe für den Verkauf am Markt, in der Schule oder unter Freunden
• Rückgängig, falls du dich vertippt hast
• Sonderpreis und Menge per langem Drücken („3 für 10 €“)
• Bar, Karte oder online, mit Gebühren für SumUp oder PayPal

📋 AUFTRÄGE
• Wer hat was bestellt, Wunschfarbe, Abholtermin
• Status offen → gedruckt → abgeholt, Häkchen für bezahlt

🎯 SPARZIEL
• Sparst du auf einen neuen Drucker? Die App zeigt, wie viele Stück noch fehlen

📊 ÜBERSICHT
• Umsatz, Kosten und Gewinn pro Monat, Bestseller, Verlauf
• Export als CSV für Excel (Pro)

🔒 DEINE DATEN BLEIBEN BEI DIR
Kein Konto, keine Werbung, kein Tracking. Alles wird nur auf deinem Handy gespeichert. Sicherung als Datei jederzeit möglich.

PRO (Abo)
Unbegrenzt Produkte und Drucker, CSV-Export, 12-Monats-Verlauf, mehrere Sparziele. Die Gratis-Version reicht für 15 Produkte und 2 Drucker.
```

**Suchbegriffe, die in Titel und Text vorkommen:** 3D-Druck, Kosten, Rechner, Filament, Preis, Verkauf, Bambu Lab, Kasse, Gewinn, Flexi Dragon.

## Store-Eintrag (Englisch, später)

- Titel: `Print Till: 3D Print Costs`
- Kurz: `Calculate 3D print costs, set prices and track sales. For Bambu & more.`

## Grafiken

- Icon: `assets/icon/icon.png` (512 × 512 exportieren)
- Feature-Grafik 1024 × 500: Orange (#E8622A), Icon links, Text „Was kostet dein Druck wirklich?“
- Screenshots (mit Beispieldaten, hell): 1. Verkaufen mit Sparziel, 2. Produkt-Editor mit Kostenaufschlüsselung, 3. Übersicht mit Diagramm, 4. Aufträge, 5. Dunkelmodus

## Datensicherheit (Formular in der Play Console)

| Frage | Antwort |
|---|---|
| Erhebt oder teilt die App Nutzerdaten? | **Nein.** Alle Daten bleiben auf dem Gerät. |
| Verschlüsselung bei Übertragung | Nicht zutreffend (keine Übertragung) |
| Kann man das Löschen der Daten beantragen? | Ja: Einstellungen → Alle Daten löschen, oder App deinstallieren |
| Käufe | Laufen über Google Play Billing. Das muss nicht als „erhobene Daten“ angegeben werden. |

Werbe-ID: **Nein** (keine Werbung in dieser App).

## Inhaltsbewertung (IARC-Fragebogen)

Keine Gewalt, keine Sexualität, kein Glücksspiel, keine Kommunikation zwischen Nutzern, keine Standortfreigabe. Ergebnis: **PEGI 3 / USK 0**. Zielgruppe: **18+** (Business-App, keine Kinder-Zielgruppe → keine Familien-Richtlinien nötig).

## Abo in der Play Console anlegen

1. Monetarisieren → Produkte → Abos → **Abo erstellen**
2. Produkt-ID **`pro_monat`**, Basis-Abo monatlich, **2,99 €**, automatisch verlängernd
3. Optional: Produkt-ID **`pro_jahr`**, jährlich **19,99 €** (ca. 45 % Rabatt)
4. Danach in `lib/dienste.dart` `kaufPflicht: true` setzen und neue Version hochladen

## Geschlossener Test (12 Tester, 14 Tage)

Warum Tester die App täglich öffnen:
- **Druck-Tipp des Tages** auf dem Startbildschirm (24 verschiedene Tipps)
- **Beispieldaten**: Wer selbst nicht druckt, kann trotzdem „verkaufen“ und das Sparziel wachsen sehen
- Bitte an die Tester: „Tippe jeden Tag ein paar Verkäufe und schau in die Übersicht“

## Antrag auf Produktionszugriff (Vorlage)

> **Wie hast du Tester gefunden?** Freunde, Familie und Leute aus 3D-Druck-Gruppen, die selbst Drucke verkaufen.
>
> **Wie haben die Tester die App genutzt?** Sie haben Drucker und Filamente angelegt, Produkte kalkuliert, Verkäufe gebucht (auch mit Beispieldaten) und die Monatsübersicht angesehen. Der tägliche Druck-Tipp hat sie zum täglichen Öffnen motiviert.
>
> **Feedback und Änderungen:** *(hier eintragen, was Tester gemeldet haben und was du geändert hast, z. B. „Wunsch nach Mengenrabatt → Sonderpreis per langem Drücken“)*
>
> **Zielgruppe:** Hobby-Maker und Kleinunternehmer, die 3D-Drucke direkt verkaufen.
>
> **Was macht die App besonders?** Echte Kostenrechnung (inkl. Strom, Abnutzung, AMS-Spülabfall), Verkauf mit einem Tipp, Sparziel, komplett offline ohne Konto.
>
> **Ist die App bereit?** Ja: alle Funktionen getestet, Datenschutzerklärung vorhanden, keine bekannten Abstürze.
