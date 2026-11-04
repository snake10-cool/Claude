"""Synthetisiert den kompletten Ton des Videos aus Code (nur numpy).

    python3 synth.py sfx.json audio.wav

Musik: 120 BPM, Am – F – C – G, Kick/Hi-Hat/Clap, Bass, Pad, Arpeggio.
Effekte: Tippen, Pops, Whooshes, Riser, Impacts, Glocken – alle Zeitpunkte
kommen aus window.SFX in index.html (render.mjs schreibt sie nach sfx.json).
"""
import json
import sys
import wave

import numpy as np

SR = 44100
BPM = 120
BEAT = 60 / BPM
GRID0 = 25.4          # Beat-Raster ist auf den „Warum Claude Pro?“-Impact ausgerichtet
MUSIC_START = 1.4

cfg = json.load(open(sys.argv[1]))
DUR = cfg["duration"] + 1.5
N = int(DUR * SR)
rng = np.random.default_rng(1234)


def t_arr(d):
    return np.arange(int(d * SR)) / SR


def add(buf, sig, at, gain=1.0, pan=0.0):
    """Mono-Signal in Stereo-Puffer mischen (pan -1..1)."""
    i = int(round(at * SR))
    if i >= N or i + len(sig) <= 0:
        return
    if i < 0:
        sig, i = sig[-i:], 0
    sig = sig[: N - i]
    l, r = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
    buf[0, i:i + len(sig)] += sig * gain * l * 1.414
    buf[1, i:i + len(sig)] += sig * gain * r * 1.414


def fft_filter(x, lo=None, hi=None):
    """Statischer Hoch-/Tiefpass im Frequenzbereich (sanfte Flanken)."""
    X = np.fft.rfft(x, axis=-1)
    f = np.fft.rfftfreq(x.shape[-1], 1 / SR)
    H = np.ones_like(f)
    if hi:
        H /= np.sqrt(1 + (f / hi) ** 4)
    if lo:
        H *= (f / lo) ** 2 / np.sqrt(1 + (f / lo) ** 4)
    return np.fft.irfft(X * H, n=x.shape[-1], axis=-1)


def saw(freq, t):
    return 2 * ((freq * t) % 1) - 1


def adsr(n, a=.005, d=.1, s=.7, r=.1):
    n_a, n_d, n_r = int(a * SR), int(d * SR), int(r * SR)
    env = np.full(n, s)
    env[:n_a] = np.linspace(0, 1, n_a, endpoint=False) if n_a else env[:n_a]
    env[n_a:n_a + n_d] = np.linspace(1, s, len(env[n_a:n_a + n_d]))
    if n_r:
        env[-n_r:] *= np.linspace(1, 0, len(env[-n_r:]))
    return env


# ------------------------------------------------------------------ Instrumente
def kick(hard=1.0):
    t = t_arr(.45)
    f = 45 + 95 * np.exp(-t * 28)
    ph = 2 * np.pi * np.cumsum(f) / SR
    s = np.sin(ph) * np.exp(-t * 7) + .25 * rng.standard_normal(len(t)) * np.exp(-t * 120)
    return np.tanh(s * (1.4 + hard))


def hat(open_=False):
    t = t_arr(.25 if open_ else .06)
    n = rng.standard_normal(len(t))
    n = np.diff(np.diff(n, prepend=0), prepend=0)
    return n * np.exp(-t * (14 if open_ else 70)) * .35


def clap():
    t = t_arr(.3)
    n = rng.standard_normal(len(t))
    env = np.exp(-t * 18)
    for k in (0.0, .012, .024):  # kleine Mehrfach-Anschläge
        env += np.exp(-np.maximum(t - k, 0) * 120) * (t >= k) * .6
    s = fft_filter(n * env, lo=900, hi=6000)
    return s * .8 + np.sin(2 * np.pi * 190 * t) * np.exp(-t * 30) * .3


def bass_note(freq, d):
    t = t_arr(d)
    s = saw(freq, t) * .6 + np.sin(2 * np.pi * freq * t) * .8
    return s * adsr(len(t), .004, .15, .55, .05)


def pad_note(freq, d, detune):
    t = t_arr(d)
    s = sum(saw(freq * 2 ** (c / 1200), t) for c in (-detune, 0, detune)) / 3
    return s * adsr(len(t), .25, .4, .8, .5)


def pluck(freq, d=.22):
    t = t_arr(d)
    s = (saw(freq, t) * .5 + np.sin(2 * np.pi * freq * t)) * np.exp(-t * 16)
    return s


# Akkorde je Takt (2 s): Am – F – C – G
CHORDS = [
    (55.00, [220.00, 261.63, 329.63]),
    (43.65, [174.61, 220.00, 261.63]),
    (65.41, [196.00, 261.63, 329.63]),
    (49.00, [196.00, 246.94, 293.66]),
]

drums = np.zeros((2, N))
bass = np.zeros((2, N))
pad = np.zeros((2, N))
arp = np.zeros((2, N))
kick_times = []

first_beat = int(np.ceil((MUSIC_START - GRID0) / BEAT - 1e-6))
last_beat = int(np.floor((cfg["duration"] - .6 - GRID0) / BEAT))
for k in range(first_beat, last_beat + 1):
    tb = GRID0 + k * BEAT
    bar = int(np.floor((k) / 4))
    chord = CHORDS[bar % 4]
    beat_in_bar = k % 4

    # Abschnitte
    intro = tb < 5.4
    breakdown = 23.9 <= tb < 25.4
    big = 25.4 <= tb < 36.4
    outro_tail = tb >= 48.4

    # Pad: ein Akkord pro Takt
    if beat_in_bar == 0 or k == first_beat:
        bar_end = GRID0 + (bar + 1) * 4 * BEAT
        d = bar_end - tb + .5
        for i, f in enumerate(chord[1]):
            add(pad, pad_note(f, d, 8), tb, .16, pan=-.5)
            add(pad, pad_note(f, d, 11), tb, .16, pan=.5)

    if breakdown or outro_tail:
        continue

    # Kick & Clap
    if not intro:
        add(drums, kick(1.0 if big else .6), tb, .9)
        kick_times.append(tb)
        if beat_in_bar in (1, 3):
            add(drums, clap(), tb, .55 if big else .4)
    # Hi-Hats
    add(drums, hat(open_=True), tb + BEAT / 2, .5 if not intro else .3, pan=.25)
    if big or not intro:
        for q in (0, .25, .75):
            add(drums, hat(), tb + q * BEAT, .25, pan=-.2)
    # Bass in Achteln
    if not intro:
        for e in (0, .5):
            oct_ = 2 if (e == .5 and beat_in_bar % 2 == 1) else 1
            add(bass, bass_note(chord[0] * oct_, BEAT / 2 * .9), tb + e * BEAT, .55)
    # Arpeggio im „Pro“-Teil und im Outro
    if big or tb >= 44.4:
        notes = [chord[1][0] * 2, chord[1][1] * 2, chord[1][2] * 2, chord[1][1] * 4]
        for s in range(4):
            add(arp, pluck(notes[(beat_in_bar * 4 + s) % 4]), tb + s * BEAT / 4, .16, pan=(-.6 if s % 2 else .6))

pad = fft_filter(pad, hi=1400)
bass = fft_filter(bass, hi=900)
arp = fft_filter(arp, hi=3500)

# Sidechain-„Pumpen“ auf Pad/Bass/Arp
duck = np.ones(N)
for kt in kick_times:
    i = int(kt * SR)
    t = t_arr(.35)
    seg = 1 - .55 * np.exp(-t * 9)
    duck[i:i + len(seg)] = np.minimum(duck[i:i + len(seg)], seg[: N - i])
music = drums + (pad + bass + arp) * duck

# Musik-Lautstärkekurve: Ein-/Ausblenden
t_all = np.arange(N) / SR
fade = np.clip((t_all - MUSIC_START + .05) / .05, 0, 1)
fade *= np.clip((cfg["duration"] - t_all) / 2.2, 0, 1) ** 1.5
music *= fade


# ------------------------------------------------------------------ Effekte
def s_type(v):
    """Weicher, tiefer Tastenanschlag („thock“ statt hohem Klicken)."""
    t = t_arr(.07)
    r = np.random.default_rng(v)
    n = fft_filter(r.standard_normal(len(t)), lo=250, hi=1600) * np.exp(-t * 160)
    tone = np.sin(2 * np.pi * (330 + r.random() * 120) * t) * np.exp(-t * 90) * .7
    return (n * .8 + tone) * (.6 + .4 * r.random()), (r.random() - .5) * .5


def s_tick(v, hi=0):
    t = t_arr(.06)
    f = 700 + v * 30 if hi else 520 + (v % 5) * 40
    return (np.sin(2 * np.pi * f * t) + .4 * np.sin(4 * np.pi * f * t)) * np.exp(-t * 80)


def s_pop(f):
    """Heller, luftiger „Blub“: kurzer Aufwärts-Chirp mit Glanz statt dumpfem Abwärts-Ton."""
    t = t_arr(.22)
    f = f * 2
    fr = f * (1.5 - .5 * np.exp(-t * 70))
    ph = 2 * np.pi * np.cumsum(fr) / SR
    body = (np.sin(ph) + .25 * np.sin(2 * ph) + .12 * np.sin(3.01 * ph)) * np.exp(-t * 22)
    click = fft_filter(rng.standard_normal(len(t)), lo=3000) * np.exp(-t * 400) * .25
    return (body + click) * np.minimum(t / .003, 1)


def s_send():
    t = t_arr(.25)
    fr = 400 + 1400 * (t / .25) ** 2
    ph = 2 * np.pi * np.cumsum(fr) / SR
    n = fft_filter(rng.standard_normal(len(t)), lo=2000) * .3
    return (np.sin(ph) * .6 + n) * np.sin(np.pi * t / .25)


def s_whoosh(soft=0):
    d = .8
    t = t_arr(d)
    n = rng.standard_normal(len(t))
    lowp, highp = fft_filter(n, hi=700), fft_filter(n, lo=2500)
    x = t / d
    s = lowp * (1 - x) * 1.6 + highp * x * .9 + fft_filter(n, lo=600, hi=3000) * .8
    env = np.sin(np.pi * np.clip(x, 0, 1)) ** 2
    return s * env * (.45 if soft else .9)


def s_riser(d, big=0):
    t = t_arr(d)
    x = t / d
    n = fft_filter(rng.standard_normal(len(t)), lo=400 + 0 * x[0])
    fr = 180 * 2 ** (x * (3 if big else 2))
    ph = 2 * np.pi * np.cumsum(fr) / SR
    tone = saw(1, ph / (2 * np.pi)) * .25 + np.sin(ph * 2) * .3
    s = (n * .6 + tone) * x ** 2.2
    return fft_filter(s, hi=5000) * (1.0 if big else .6)


def s_impact(big=0):
    d = 2.2
    t = t_arr(d)
    f = 32 + 70 * np.exp(-t * 10)
    sub = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * (1.6 if big else 2.6))
    n = fft_filter(rng.standard_normal(len(t)), hi=2500) * np.exp(-t * 7)
    s = np.tanh((sub * 1.6 + n * .8) * 1.5)
    return s * (1.0 if big == 1 else .75)


def s_chime(big=0):
    t = t_arr(2.0)
    roots = [1046.5, 1318.5, 1568.0] if big else [880.0, 1318.5]
    s = np.zeros(len(t))
    for j, f in enumerate(roots):
        dl = int(j * .06 * SR)
        for ratio, amp, dec in ((1, 1, 3), (2.01, .4, 5), (3.0, .2, 8), (4.2, .12, 11)):
            part = amp * np.sin(2 * np.pi * f * ratio * t) * np.exp(-t * dec)
            s[dl:] += part[: len(t) - dl]
    return s * .35


def s_sweep(d):
    t = t_arr(d)
    x = t / d
    fr = 300 * 2 ** (x * 1.6)
    ph = 2 * np.pi * np.cumsum(fr) / SR
    return (np.sin(ph) + .3 * np.sin(3 * ph)) * np.sin(np.pi * x) * (.7 + .3 * np.sin(2 * np.pi * 14 * t)) * .5


fx = np.zeros((2, N))
fx_wet = np.zeros((2, N))  # Anteil, der durch den Hall geht
for e in cfg["events"]:
    ty, at = e["type"], e["t"]
    if ty == "type":
        s, pan = s_type(e["v"])
        add(fx, s, at, .42, pan)
    elif ty == "tick":
        add(fx, s_tick(e["v"], e.get("hi", 0)), at, .16 if not e.get("hi") else .2)
    elif ty == "pop":
        add(fx, s_pop(e["f"]), at, .26)
        add(fx_wet, s_pop(e["f"]), at, .12)
    elif ty == "send":
        add(fx, s_send(), at, .35)
    elif ty == "whoosh":
        add(fx, s_whoosh(e.get("soft", 0)), at - .35, .55)
    elif ty == "riser":
        add(fx, s_riser(e["dur"], e.get("big", 0)), at, .5)
    elif ty == "impact":
        add(fx, s_impact(e.get("big", 0)), at, .9)
        add(fx_wet, s_impact(e.get("big", 0)), at, .5)
        # Musik kurz unter dem Impact ducken
        i = int(at * SR)
        t = t_arr(1.0)
        seg = 1 - .5 * np.exp(-t * 4)
        music[:, i:i + len(seg)] *= seg[: N - i]
    elif ty == "chime":
        add(fx, s_chime(e.get("big", 0)), at, .5)
        add(fx_wet, s_chime(e.get("big", 0)), at, .5)
    elif ty == "sweep":
        add(fx, s_sweep(e["dur"]), at, .35)

# ------------------------------------------------------------------ Hall
def reverb(x, rt=2.2):
    t = t_arr(rt)
    ir = np.stack([rng.standard_normal(len(t)), rng.standard_normal(len(t))]) * np.exp(-t * 6.9 / rt)
    ir = fft_filter(ir, hi=4500)
    ir /= np.sqrt((ir ** 2).sum(axis=1, keepdims=True))
    n = 1 << int(np.ceil(np.log2(x.shape[1] + ir.shape[1])))
    y = np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[:, : x.shape[1]]
    return y


wet = reverb(fx_wet + pad * .5 + arp * .8)
mix = music * .6 + fx + wet * .35

# Master: sanftes Limiting + Normalisieren
mix = fft_filter(mix, lo=25)
mix = np.tanh(mix * 1.1) / np.tanh(1.1)
mix *= .89 / np.max(np.abs(mix))
end = int((cfg["duration"]) * SR)
mix = mix[:, :end]
mix[:, -int(.05 * SR):] *= np.linspace(1, 0, int(.05 * SR))

pcm = (np.clip(mix.T, -1, 1) * 32767).astype("<i2")
with wave.open(sys.argv[2], "wb") as w:
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes(pcm.tobytes())
print(f"Ton fertig: {sys.argv[2]} ({end / SR:.1f} s, {len(cfg['events'])} Effekte)")
