// Firebase Cloud Function „petri“: KI-Angelguide (Chat) und Foto-Fischerkennung
// mit Claude. Die App ruft sie mit dem Firebase-ID-Token des Nutzers auf.
// Einrichtung und Kosten: siehe functions/README.md.
import Anthropic from "@anthropic-ai/sdk";
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { defineInt, defineSecret, defineString } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";

import {
  Eingabefehler,
  FOTO_SCHEMA,
  SYSTEM_CHAT,
  SYSTEM_FOTO,
  chatPruefen,
  fotoAntwortPruefen,
  fotoPruefen,
  mitFallback,
  tagSchluessel,
} from "./petri";

const ANTHROPIC_API_KEY = defineSecret("ANTHROPIC_API_KEY");
/** Modell – in .env änderbar (KI_MODELL=...), ohne Code anzufassen. */
const KI_MODELL = defineString("KI_MODELL", { default: "claude-opus-5-5" });
/** KI-Anfragen pro Nutzer und Tag. */
const KI_LIMIT_TAG = defineInt("KI_LIMIT_TAG", { default: 20 });

initializeApp();

/** Zählt eine Anfrage. Gibt die restlichen Anfragen für heute zurück oder null (Limit erreicht). */
async function zaehlen(uid: string, limit: number): Promise<number | null> {
  const db = getFirestore();
  const ref = db.collection("ki_nutzung").doc(uid);
  const tag = tagSchluessel(new Date());
  return db.runTransaction(async (t) => {
    const d = (await t.get(ref)).data();
    const bisher = d && d["tag"] === tag ? Number(d["anzahl"]) || 0 : 0;
    if (bisher >= limit) return null;
    t.set(ref, { tag, anzahl: bisher + 1, zuletzt: FieldValue.serverTimestamp() });
    return limit - bisher - 1;
  });
}

/** Gibt eine Anfrage zurück, wenn die KI nicht antworten konnte. */
async function zurueckgeben(uid: string): Promise<void> {
  try {
    await getFirestore()
      .collection("ki_nutzung")
      .doc(uid)
      .update({ anzahl: FieldValue.increment(-1) });
  } catch (e) {
    logger.warn("Zurückgeben fehlgeschlagen", e);
  }
}

function textAus(antwort: Anthropic.Beta.Messages.BetaMessage): string {
  return antwort.content
    .map((b) => (b.type === "text" ? b.text : ""))
    .join("")
    .trim();
}

/** Anfrage-Optionen, die für jedes Modell gleich sind. */
function grundlage(modell: string) {
  return mitFallback(modell)
    ? { betas: ["server-side-fallback-2026-07-01"], fallbacks: "default" as const }
    : {};
}

async function chat(client: Anthropic, modell: string, body: unknown): Promise<object> {
  const { verlauf, kontext } = chatPruefen(body);
  const messages: Anthropic.Beta.Messages.BetaMessageParam[] = verlauf.map((n, i) => ({
    role: n.rolle === "nutzer" ? "user" : "assistant",
    // Die App-Daten stehen vor der ersten Frage und bleiben im ganzen Chat gleich –
    // so kann der Anfang des Gesprächs im Cache bleiben.
    content:
      i === 0 && kontext
        ? [
            { type: "text", text: `<app_daten>\n${kontext}\n</app_daten>` },
            { type: "text", text: n.text },
          ]
        : n.text,
  }));
  const antwort = await client.beta.messages.create({
    ...grundlage(modell),
    model: modell,
    max_tokens: 4000,
    system: [{ type: "text", text: SYSTEM_CHAT }],
    messages,
    output_config: { effort: "low" },
    cache_control: { type: "ephemeral" },
  });
  if (antwort.stop_reason === "refusal") {
    return { antwort: "Dazu kann ich dir leider nichts sagen. Frag mich gern etwas anderes rund ums Angeln!" };
  }
  const text = textAus(antwort);
  if (!text) throw new Error(`Leere Antwort (${antwort.stop_reason})`);
  return { antwort: text };
}

async function foto(client: Anthropic, modell: string, body: unknown): Promise<object> {
  const { bild, typ } = fotoPruefen(body);
  const antwort = await client.beta.messages.create({
    ...grundlage(modell),
    model: modell,
    max_tokens: 4000,
    system: [{ type: "text", text: SYSTEM_FOTO, cache_control: { type: "ephemeral" } }],
    messages: [
      {
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: typ, data: bild } },
          { type: "text", text: "Welche Fischart ist auf dem Foto?" },
        ],
      },
    ],
    output_config: {
      effort: "medium",
      format: { type: "json_schema", schema: FOTO_SCHEMA as unknown as Record<string, unknown> },
    },
  });
  if (antwort.stop_reason === "refusal") {
    return { ergebnis: fotoAntwortPruefen({ erkannt: false }) };
  }
  let roh: unknown;
  try {
    roh = JSON.parse(textAus(antwort));
  } catch {
    throw new Error(`Foto-Antwort ist kein JSON (${antwort.stop_reason})`);
  }
  return { ergebnis: fotoAntwortPruefen(roh) };
}

export const petri = onRequest(
  {
    region: "europe-west3",
    secrets: [ANTHROPIC_API_KEY],
    timeoutSeconds: 120,
    memory: "512MiB",
    maxInstances: 5,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ fehler: "nur POST" });
      return;
    }
    const token = (req.get("Authorization") ?? "").replace(/^Bearer\s+/i, "");
    let uid: string;
    try {
      uid = (await getAuth().verifyIdToken(token)).uid;
    } catch {
      res.status(401).json({ fehler: "anmelden" });
      return;
    }

    const modus = (req.body ?? {})["modus"];
    const ablauf = modus === "chat" ? chat : modus === "foto" ? foto : null;
    if (ablauf === null) {
      res.status(400).json({ fehler: "modus" });
      return;
    }
    // Eingaben vor dem Zählen prüfen, damit Fehler kein Kontingent kosten.
    try {
      if (modus === "chat") chatPruefen(req.body);
      else fotoPruefen(req.body);
    } catch (e) {
      if (e instanceof Eingabefehler) {
        res.status(400).json({ fehler: e.message });
        return;
      }
      throw e;
    }

    const rest = await zaehlen(uid, KI_LIMIT_TAG.value());
    if (rest === null) {
      res.status(429).json({ fehler: "limit", rest: 0 });
      return;
    }

    try {
      const client = new Anthropic({ apiKey: ANTHROPIC_API_KEY.value(), maxRetries: 2, timeout: 100_000 });
      const ergebnis = await ablauf(client, KI_MODELL.value(), req.body);
      res.json({ ...ergebnis, rest });
    } catch (e) {
      await zurueckgeben(uid);
      if (e instanceof Anthropic.AuthenticationError || e instanceof Anthropic.PermissionDeniedError) {
        logger.error("KI-Schlüssel ungültig", e);
        res.status(503).json({ fehler: "nicht eingerichtet" });
      } else if (e instanceof Anthropic.RateLimitError) {
        res.status(503).json({ fehler: "ausgelastet" });
      } else if (e instanceof Anthropic.APIError && (e.status ?? 0) >= 500) {
        res.status(503).json({ fehler: "ausgelastet" });
      } else {
        logger.error("KI-Fehler", e);
        res.status(502).json({ fehler: "ki" });
      }
    }
  },
);
