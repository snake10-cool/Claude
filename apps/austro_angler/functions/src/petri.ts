// Petri-KI: Prompts, Antwortformat und Eingabeprüfung (ohne Netz – testbar).
import { ARTEN } from "./arten";

/** Grenzen, damit niemand riesige Anfragen schickt. */
export const GRENZEN = {
  nachrichten: 20,
  zeichenProNachricht: 2000,
  zeichenKontext: 20000,
  bildBytes: 4_000_000,
};

export const BILD_TYPEN = ["image/jpeg", "image/png", "image/webp"] as const;
export type BildTyp = (typeof BILD_TYPEN)[number];

export const SYSTEM_CHAT = `Du bist Petri, der KI-Angelguide der App „Austro Angler“ für Österreich. Du hilfst bei Fragen zu Fischarten, Ködern, Techniken und Montagen, Gewässern, Wetter und Beißzeiten, Ausrüstung, der Fischerprüfung und den Regeln zum Angeln in Österreich.

So antwortest du:
- Auf Deutsch, per du, freundlich und knapp. Die Antworten werden am Handy gelesen: meist 2 bis 6 Sätze oder eine kurze Liste.
- Konkret und praxisnah: welcher Köder, welche Uhrzeit, welche Stelle, welche Montage.
- Österreichische Begriffe passen gut (Brittelmaß, Revier, Lizenz, Fischerkarte).
- Formatierung nur sparsam: Aufzählungen mit „• “ und höchstens ein, zwei Wörter **fett**.

Regeln und Recht:
- Für Schonzeiten, Brittelmaße und geschützte Arten verwendest du ausschließlich die Angaben im Block <app_daten>. Steht etwas nicht drin, sag das ehrlich und verweise auf die Revierordnung oder den Landesfischereiverband. Erfinde keine Daten, Maße oder Paragraphen.
- Sag bei Regelfragen kurz dazu, dass die Revierordnung strenger sein kann.
- In Österreich braucht man zum Fischen eine gültige Fischerkarte und eine Lizenz für das Gewässer. Hilf nie dabei, Regeln zu umgehen (geschonte oder untermaßige Fische mitnehmen, Schwarzfischen, verbotene Methoden).
- Tierschutz: empfiehl waidgerechten Umgang – richtig betäuben und töten, schonend zurücksetzen.

Sicherheit: Bei Hochwasser, Eis, Gewitter oder starker Strömung rätst du klar zur Vorsicht.

Die Angaben in <app_daten> kommen aus der App (Datum, Bundesland, Heimatort, Wetter und Beißindex, Lieblingsfische, Fangbuch). Nutze sie, wenn sie zur Frage passen, und sag nicht jedes Mal, woher du sie hast.

Fragen ohne Bezug zum Angeln, zu Fischen oder zur Natur am Wasser beantwortest du nicht ausführlich, sondern lenkst freundlich zurück zum Angeln.`;

export const SYSTEM_FOTO = `Du bestimmst Fischarten auf Fotos für die App „Austro Angler“ (Österreich).

- Wähle die Art ausschließlich aus der Artenliste unten und gib ihre id an.
- Ist kein Fisch zu sehen oder das Foto zu unscharf: erkannt = false und fisch_id = null.
- sicherheit: „hoch“ nur, wenn die typischen Merkmale klar zu sehen sind. Bei ähnlichen Arten (z. B. Forellen und Saiblinge, Weißfische, Renken) eher „mittel“ oder „niedrig“, und nenne bis zu zwei Alternativen mit kurzem Grund.
- merkmale: bis zu 4 kurze, auf dem Foto sichtbare Merkmale auf Deutsch, die für deine Wahl sprechen.
- hinweis: ein kurzer Satz auf Deutsch, z. B. worauf man achten soll, um ganz sicherzugehen.
- Schätze keine Länge und kein Gewicht und gib keine Auskunft zu Schonzeiten – das übernimmt die App.

Artenliste (id – Name – Familie – Merkmale):
${ARTEN.map((a) => `${a.id} – ${a.name} – ${a.familie} – ${a.merkmale}`).join("\n")}`;

const ART_IDS = ARTEN.map((a) => a.id);

/** JSON-Schema für die Foto-Antwort (Structured Outputs). */
export const FOTO_SCHEMA = {
  type: "object",
  properties: {
    erkannt: { type: "boolean" },
    fisch_id: { type: ["string", "null"], enum: [...ART_IDS, null] },
    sicherheit: { type: "string", enum: ["hoch", "mittel", "niedrig"] },
    merkmale: { type: "array", items: { type: "string" } },
    alternativen: {
      type: "array",
      items: {
        type: "object",
        properties: {
          fisch_id: { type: "string", enum: ART_IDS },
          grund: { type: "string" },
        },
        required: ["fisch_id", "grund"],
        additionalProperties: false,
      },
    },
    hinweis: { type: "string" },
  },
  required: ["erkannt", "fisch_id", "sicherheit", "merkmale", "alternativen", "hinweis"],
  additionalProperties: false,
} as const;

export interface FotoErgebnis {
  erkannt: boolean;
  fisch_id: string | null;
  sicherheit: "hoch" | "mittel" | "niedrig";
  merkmale: string[];
  alternativen: { fisch_id: string; grund: string }[];
  hinweis: string;
}

export class Eingabefehler extends Error {}

export interface ChatNachricht {
  rolle: "nutzer" | "petri";
  text: string;
}

/** Prüft den Chat-Verlauf aus der App und macht daraus Claude-Nachrichten. */
export function chatPruefen(body: unknown): { verlauf: ChatNachricht[]; kontext: string } {
  const b = (body ?? {}) as Record<string, unknown>;
  const verlauf = b["verlauf"];
  if (!Array.isArray(verlauf) || verlauf.length === 0) {
    throw new Eingabefehler("verlauf fehlt");
  }
  if (verlauf.length > GRENZEN.nachrichten) {
    throw new Eingabefehler("zu viele Nachrichten");
  }
  const sauber: ChatNachricht[] = verlauf.map((n, i) => {
    const m = (n ?? {}) as Record<string, unknown>;
    const rolle = m["rolle"];
    const text = m["text"];
    if ((rolle !== "nutzer" && rolle !== "petri") || typeof text !== "string") {
      throw new Eingabefehler(`Nachricht ${i} ungültig`);
    }
    const t = text.trim();
    if (t.length === 0 || t.length > GRENZEN.zeichenProNachricht) {
      throw new Eingabefehler(`Nachricht ${i} leer oder zu lang`);
    }
    return { rolle, text: t };
  });
  // Abwechselnd, beginnend und endend mit der Frage des Nutzers.
  sauber.forEach((n, i) => {
    if (n.rolle !== (i % 2 === 0 ? "nutzer" : "petri")) {
      throw new Eingabefehler("Reihenfolge ungültig");
    }
  });
  if (sauber[sauber.length - 1].rolle !== "nutzer") {
    throw new Eingabefehler("letzte Nachricht muss vom Nutzer sein");
  }
  const kontext = typeof b["kontext"] === "string" ? (b["kontext"] as string) : "";
  if (kontext.length > GRENZEN.zeichenKontext) {
    throw new Eingabefehler("kontext zu lang");
  }
  return { verlauf: sauber, kontext };
}

/** Prüft ein Foto (Base64) aus der App. */
export function fotoPruefen(body: unknown): { bild: string; typ: BildTyp } {
  const b = (body ?? {}) as Record<string, unknown>;
  const bild = b["bild"];
  const typ = b["typ"];
  if (typeof bild !== "string" || bild.length < 100) {
    throw new Eingabefehler("bild fehlt");
  }
  if (!/^[A-Za-z0-9+/=]+$/.test(bild)) {
    throw new Eingabefehler("bild ist kein Base64");
  }
  if ((bild.length * 3) / 4 > GRENZEN.bildBytes) {
    throw new Eingabefehler("bild zu groß");
  }
  if (typeof typ !== "string" || !(BILD_TYPEN as readonly string[]).includes(typ)) {
    throw new Eingabefehler("typ ungültig");
  }
  return { bild, typ: typ as BildTyp };
}

/** Prüft die Foto-Antwort des Modells und kürzt sie aufs Nötige. */
export function fotoAntwortPruefen(roh: unknown): FotoErgebnis {
  const r = (roh ?? {}) as Record<string, unknown>;
  const gueltig = (id: unknown): id is string =>
    typeof id === "string" && ART_IDS.includes(id);
  const sicherheit = ["hoch", "mittel", "niedrig"].includes(r["sicherheit"] as string)
    ? (r["sicherheit"] as FotoErgebnis["sicherheit"])
    : "niedrig";
  const fischId = gueltig(r["fisch_id"]) ? r["fisch_id"] : null;
  const merkmale = Array.isArray(r["merkmale"])
    ? (r["merkmale"] as unknown[])
        .filter((m): m is string => typeof m === "string" && m.trim().length > 0)
        .map((m) => m.trim().slice(0, 160))
        .slice(0, 4)
    : [];
  const alternativen = Array.isArray(r["alternativen"])
    ? (r["alternativen"] as unknown[])
        .map((a) => (a ?? {}) as Record<string, unknown>)
        .filter((a) => gueltig(a["fisch_id"]) && a["fisch_id"] !== fischId)
        .map((a) => ({
          fisch_id: a["fisch_id"] as string,
          grund: typeof a["grund"] === "string" ? (a["grund"] as string).trim().slice(0, 160) : "",
        }))
        .slice(0, 2)
    : [];
  const hinweis = typeof r["hinweis"] === "string" ? (r["hinweis"] as string).trim().slice(0, 240) : "";
  return {
    erkannt: r["erkannt"] === true && fischId !== null,
    fisch_id: fischId,
    sicherheit,
    merkmale,
    alternativen,
    hinweis,
  };
}

/** Schlüssel für das Tageslimit (Wiener Zeit). */
export function tagSchluessel(jetzt: Date): string {
  return new Intl.DateTimeFormat("sv-SE", { timeZone: "Europe/Vienna" }).format(jetzt);
}

/**
 * Server-seitiger Fallback bei einer Ablehnung durch die Sicherheitsfilter.
 * Nur Modelle, die ihn kennen, bekommen ihn (sonst antwortet die API mit 400).
 */
export function mitFallback(modell: string): boolean {
  return /^claude-(opus-5|fable-5|sonnet-5-5)/.test(modell);
}
