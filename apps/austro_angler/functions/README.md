# Petri-KI – Cloud Function `petri`

Die KI-Funktionen der App laufen über diese Firebase Cloud Function:

- **Chat** („Frag Petri“) – KI-Angelguide mit den Regeln des Bundeslands, dem Fangbuch und dem heutigen Tag
- **Foto-Bestimmung** – erkennt die Fischart auf einem Foto. Das Modell wählt nur aus der Artenliste der App, Schonzeit und Brittelmaß ergänzt die App selbst

Das Modell ist Claude von Anthropic. Der API-Schlüssel liegt **nur am Server** im Secret Manager, nie in der App. Nur angemeldete Nutzer kommen durch, mit einem Tageslimit pro Nutzer.

Solange die Funktion nicht eingerichtet ist, bleibt alles unsichtbar. Der Fern-Schalter `ki` ist standardmäßig **aus**.

## Einrichten (einmalig)

1. **Firebase-Tarif Blaze**: Cloud Functions brauchen den Blaze-Tarif (mit Gratis-Kontingent). Firebase-Konsole → ⚙️ → Nutzung und Abrechnung. Am besten gleich einen **Budget-Alarm** setzen, z. B. 10 €.
2. **API-Schlüssel**: Auf console.anthropic.com einen Schlüssel anlegen und dort ein **Ausgabenlimit** pro Monat einstellen.
3. **Schlüssel als Secret speichern** (im Ordner `apps/austro_angler`):
   ```
   firebase functions:secrets:set ANTHROPIC_API_KEY
   ```
   Schlüssel einfügen, wenn danach gefragt wird. Nicht in Dateien oder Chats kopieren.
4. **Hochladen**:
   ```
   cd functions && npm ci && npm test && cd ..
   firebase deploy --only functions
   ```
5. **Einschalten**: In der App als Admin unter Wünsche → Fern-Steuerung „Petri-KI“ einschalten. Das schreibt `an: ["ki"]` in `konfig/app`. Ausschalten geht genauso, sofort und ohne Update.

## Modell, Limit und Kosten

Standard ist `claude-opus-5-5`, das stärkste aktuelle Modell (4 $ / 20 $ pro Million Token Ein-/Ausgabe). Grob geschätzt:

| Anfrage | ungefähre Kosten |
|---|---|
| Chat-Frage | 2–3 Cent |
| Foto-Bestimmung | 2–4 Cent |

Bei 20 Anfragen pro Nutzer und Tag sind das höchstens rund 0,50–0,80 € pro sehr aktivem Nutzer und Tag.

Günstiger geht es mit `claude-haiku-5-5` (0,10 $ / 0,50 $ pro Million Token, etwa 40-mal billiger). Diese Variante beantwortet einfache Fragen gut, ist bei Fotos und kniffligen Fragen aber schwächer.

Umstellen ohne Code-Änderung über die Datei `functions/.env`:

```
KI_MODELL=claude-haiku-5-5
KI_LIMIT_TAG=20
KI_LIMIT_GESAMT=1000
```

`KI_LIMIT_GESAMT` ist die Kostenbremse: höchstens so viele Anfragen gibt es pro Tag für alle Nutzer zusammen. Ist sie erreicht, sagt Petri „ausgelastet“. Mit dem Standardmodell kostet das am Tag höchstens etwa 20–40 €.

Danach `firebase deploy --only functions`.

Bei Ablehnungen durch die Sicherheitsfilter springt bei Opus und Sonnet automatisch ein anderes Modell ein (`fallbacks: "default"`).

## Technik

- `src/index.ts`: HTTP-Funktion (Region `europe-west3`, Frankfurt). Sie prüft das Firebase-ID-Token, zählt das Tageslimit in `ki_nutzung/{uid}` und für alle zusammen in `ki_nutzung/_gesamt` (nur der Server schreibt dort) und ruft Claude auf
- `src/petri.ts`: Prompts, JSON-Schema für die Foto-Antwort und Eingabeprüfung
- `src/arten.ts`: Artenliste, automatisch erzeugt mit `dart run tool/arten_export.dart`. Nach Änderungen an `lib/data/fische.dart` neu erzeugen
- Tests ohne Netz und ohne Kosten: `npm test`
