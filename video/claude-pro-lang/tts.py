"""Sprecherstimme für das Video (Piper TTS, Stimme „Thorsten“, läuft komplett offline).

    python3 tts.py voice_in.json voice_cache/ voice_out.json

voice_in.json:  [{"id": "...", "text": "..."}]
voice_out.json: {"<id>": {"file": "...wav", "dur": 2.31}}
Fertige Sätze werden nach Text-Hash zwischengespeichert.
"""
import hashlib
import json
import os
import re
import sys
import unicodedata
import urllib.request
import wave
import tarfile

HERE = os.path.dirname(os.path.abspath(__file__))
MODEL = os.path.join(HERE, "voice", "de-thorsten-low.onnx")
MODEL_URL = "https://github.com/rhasspy/piper/releases/download/v0.0.2/voice-de-thorsten-low.tar.gz"

# Aussprache-Hilfen: Untertitel zeigen den Originaltext, die Stimme spricht diese Variante
SAY = [
    (r"\bClaude Code\b", "Klohd Kohd"),
    (r"\bClaude\b", "Klohd"),
    (r"\bAnthropic\b", "Änn-thropik"),
    (r"\bKI\b", "Ka-I"),
    (r"\bPDF\b", "Pe De Ef"),
    (r"\bE-Mail\b", "Iemäil"),
    (r"\bPython\b", "Peisen"),
    (r"\bJavaScript\b", "Dschawa-Skript"),
    (r"\bJava\b", "Dschawa"),
    (r"\bDart\b", "Dahrt"),
    (r"\bApps\b", "Äpps"),
    (r"\bWebsites\b", "Webseits"),
    (r"\bCowork\b", "Kou-Wörk"),
    (r"\bResearch\b", "Ri-Sörtsch"),
    (r"\bCode\b", "Kohd"),
    (r"\bPro\b", "Proh"),
    (r"\bTerminal\b", "Törminel"),
    (r"\bBrowser\b", "Brauser"),
    (r"\bEditor\b", "Editor"),
]


def say_text(text):
    for pat, rep in SAY:
        text = re.sub(pat, rep, text)
    return text


def ensure_model():
    if os.path.exists(MODEL):
        return
    os.makedirs(os.path.dirname(MODEL), exist_ok=True)
    tgz = MODEL + ".tar.gz"
    print("Lade Stimme herunter …")
    urllib.request.urlretrieve(MODEL_URL, tgz)
    with tarfile.open(tgz) as tf:
        tf.extractall(os.path.dirname(MODEL), filter="data")
    os.remove(tgz)


def main():
    items = json.load(open(sys.argv[1]))
    cache = sys.argv[2]
    os.makedirs(cache, exist_ok=True)
    out = {}
    voice = None
    for it in items:
        spoken = say_text(it["text"])
        key = hashlib.sha1(("v2|" + spoken).encode()).hexdigest()[:16]
        path = os.path.join(cache, key + ".wav")
        if not os.path.exists(path):
            if voice is None:
                ensure_model()
                from piper import PiperVoice, SynthesisConfig
                from piper.phoneme_ids import phonemes_to_ids
                voice = PiperVoice.load(MODEL)
                # Neuere espeak-Versionen zerlegen „ç“ (ich-Laut) in c + Cedille – wieder zusammenfügen
                voice.phonemes_to_ids = lambda ph: phonemes_to_ids(
                    list(unicodedata.normalize("NFC", "".join(ph))), voice.config.phoneme_id_map)
                cfg = SynthesisConfig(length_scale=1.06, noise_scale=0.6, noise_w_scale=0.7)
            with wave.open(path, "wb") as w:
                voice.synthesize_wav(spoken, w, syn_config=cfg)
        with wave.open(path) as w:
            out[it["id"]] = {"file": os.path.abspath(path), "dur": round(w.getnframes() / w.getframerate(), 3)}
    json.dump(out, open(sys.argv[3], "w"), indent=1)
    print(f"Stimme: {len(items)} Sätze, {sum(v['dur'] for v in out.values()):.1f} s gesprochen")


if __name__ == "__main__":
    main()
