"""Ton für die lange Version: Musik (je Szene ein Stil), Soundeffekte und – falls vorhanden – Sprecherstimme.

    python3 synth.py timeline.json audio.wav

timeline.json kommt aus render.mjs (window.build in index.html):
  end, music[{t0,t1,mode}], sfx[{type,t,...}], clips[{t0,t1,file}]
"""
import json
import subprocess
import sys
import wave

import numpy as np

SR = 44100
BEAT = .5  # 120 BPM; alle Szenen starten auf einem Taktanfang (2 s)

tl = json.load(open(sys.argv[1]))
END = tl["end"]
N = int((END + 2) * SR)
rng = np.random.default_rng(1234)


def t_arr(d):
    return np.arange(int(d * SR)) / SR


def add(buf, sig, at, gain=1.0, pan=0.0):
    i = int(round(at * SR))
    if i >= buf.shape[-1] or i + len(sig) <= 0:
        return
    if i < 0:
        sig, i = sig[-i:], 0
    sig = sig[: buf.shape[-1] - i]
    l, r = np.cos((pan + 1) * np.pi / 4), np.sin((pan + 1) * np.pi / 4)
    buf[0, i:i + len(sig)] += sig * gain * l * 1.414
    buf[1, i:i + len(sig)] += sig * gain * r * 1.414


def fft_filter(x, lo=None, hi=None):
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
    if n_a:
        env[:n_a] = np.linspace(0, 1, len(env[:n_a]), endpoint=False)
    env[n_a:n_a + n_d] = np.linspace(1, s, len(env[n_a:n_a + n_d]))
    if n_r:
        env[-n_r:] *= np.linspace(1, 0, len(env[-n_r:]))
    return env


# ------------------------------------------------------------------ Instrumente (vorberechnet)
def make_kick(hard):
    t = t_arr(.45)
    f = 45 + 95 * np.exp(-t * 28)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 7) + .25 * rng.standard_normal(len(t)) * np.exp(-t * 120)
    return np.tanh(s * (1.4 + hard))


def make_hat(open_):
    t = t_arr(.25 if open_ else .06)
    n = np.diff(np.diff(rng.standard_normal(len(t)), prepend=0), prepend=0)
    return n * np.exp(-t * (14 if open_ else 70)) * .35


def make_clap():
    t = t_arr(.3)
    env = np.exp(-t * 18)
    for k in (0.0, .012, .024):
        env += np.exp(-np.maximum(t - k, 0) * 120) * (t >= k) * .6
    return fft_filter(rng.standard_normal(len(t)) * env, lo=900, hi=6000) * .8 + np.sin(2 * np.pi * 190 * t) * np.exp(-t * 30) * .3


KICK = {1: make_kick(1.0), 0: make_kick(.6), 2: make_kick(.3)}
HAT_C, HAT_O, CLAP = make_hat(False), make_hat(True), make_clap()


def bass_note(freq, d, soft=False):
    t = t_arr(d)
    s = (saw(freq, t) * (.25 if soft else .6) + np.sin(2 * np.pi * freq * t) * .8)
    return s * adsr(len(t), .004 if not soft else .02, .15, .55, .05)


def pad_note(freq, d, detune):
    t = t_arr(d)
    return sum(saw(freq * 2 ** (c / 1200), t) for c in (-detune, 0, detune)) / 3 * adsr(len(t), .25, .4, .8, .5)


def pluck(freq, d=.22):
    t = t_arr(d)
    return (saw(freq, t) * .5 + np.sin(2 * np.pi * freq * t)) * np.exp(-t * 16)


PROG_A = [(55.00, [220.00, 261.63, 329.63]), (43.65, [174.61, 220.00, 261.63]), (65.41, [196.00, 261.63, 329.63]), (49.00, [196.00, 246.94, 293.66])]
PROG_B = [(43.65, [174.61, 220.00, 261.63]), (49.00, [196.00, 246.94, 293.66]), (41.20, [164.81, 196.00, 246.94]), (55.00, [220.00, 261.63, 329.63])]


def mode_at(t):
    for m in tl["music"]:
        if m["t0"] <= t < m["t1"]:
            mode = m["mode"]
            if mode == "breakbig":
                return "break" if t < m["t0"] + 2 else "big"
            return mode
    return "outro"


drums = np.zeros((2, N)); bass = np.zeros((2, N)); pad = np.zeros((2, N)); arp = np.zeros((2, N))
kick_times = []
music_end = END - 1.0
outro_start = next((m["t0"] for m in tl["music"] if m["mode"] == "outro"), END)
for k in range(int(music_end / BEAT)):
    tb = k * BEAT
    bar, bib = k // 4, k % 4
    mode = mode_at(tb)
    prog = PROG_B if mode == "chill2" else PROG_A
    chord = prog[bar % 4]
    if bib == 0:
        d = 4 * BEAT + .5
        for f in chord[1]:
            add(pad, pad_note(f, d, 8), tb, .15, -.5)
            add(pad, pad_note(f, d, 11), tb, .15, .5)
    if mode == "break":
        continue
    tail = mode == "outro" and tb > outro_start + 6
    if mode in ("groove", "big") or (mode == "outro" and not tail):
        add(drums, KICK[1 if mode == "big" else 0], tb, .9); kick_times.append(tb)
        if bib in (1, 3):
            add(drums, CLAP, tb, .5 if mode == "big" else .38)
        for q in (0, .25, .75):
            add(drums, HAT_C, tb + q * BEAT, .22, -.2)
        for e in (0, .5):
            add(bass, bass_note(chord[0] * (2 if (e == .5 and bib % 2) else 1), BEAT / 2 * .9), tb + e * BEAT, .5)
    elif mode in ("chill", "chill2"):
        if bib in (0, 2):
            add(drums, KICK[2], tb, .7); kick_times.append(tb)
        if bib == 0:
            add(bass, bass_note(chord[0], 4 * BEAT * .95, soft=True), tb, .45)
    if mode != "intro" or tb > 2:
        add(drums, HAT_O, tb + BEAT / 2, .35 if mode in ("chill", "chill2", "intro") else .45, .25)
    if mode in ("big", "outro") or (mode == "chill2" and bib % 2 == 0):
        notes = [chord[1][0] * 2, chord[1][1] * 2, chord[1][2] * 2, chord[1][1] * 4]
        steps = 4 if mode != "chill2" else 2
        for s in range(steps):
            add(arp, pluck(notes[(bib * 4 + s) % 4]), tb + s * BEAT / steps, .14 if mode != "chill2" else .1, -.6 if s % 2 else .6)

pad = fft_filter(pad, hi=1400); bass = fft_filter(bass, hi=900); arp = fft_filter(arp, hi=3500)
duck = np.ones(N)
seg = 1 - .5 * np.exp(-t_arr(.35) * 9)
for kt in kick_times:
    i = int(kt * SR); duck[i:i + len(seg)] = np.minimum(duck[i:i + len(seg)], seg[: N - i])
music = drums + (pad + bass + arp) * duck
t_all = np.arange(N) / SR
music *= np.clip(t_all / .3, 0, 1) * np.clip((END - .2 - t_all) / 3.0, 0, 1) ** 1.5


# ------------------------------------------------------------------ Effekte
def s_type(v):
    t = t_arr(.07); r = np.random.default_rng(v)
    n = fft_filter(r.standard_normal(len(t)), lo=250, hi=1600) * np.exp(-t * 160)
    tone = np.sin(2 * np.pi * (330 + r.random() * 120) * t) * np.exp(-t * 90) * .7
    return (n * .8 + tone) * (.6 + .4 * r.random()), (r.random() - .5) * .5


def s_tick(v, hi=0):
    t = t_arr(.06); f = 700 + v * 30 if hi else 520 + (v % 5) * 40
    return (np.sin(2 * np.pi * f * t) + .4 * np.sin(4 * np.pi * f * t)) * np.exp(-t * 80)


def s_pop(f):
    t = t_arr(.22); f = f * 2
    ph = 2 * np.pi * np.cumsum(f * (1.5 - .5 * np.exp(-t * 70))) / SR
    body = (np.sin(ph) + .25 * np.sin(2 * ph) + .12 * np.sin(3.01 * ph)) * np.exp(-t * 22)
    click = fft_filter(rng.standard_normal(len(t)), lo=3000) * np.exp(-t * 400) * .25
    return (body + click) * np.minimum(t / .003, 1)


def s_send():
    t = t_arr(.25); ph = 2 * np.pi * np.cumsum(400 + 1400 * (t / .25) ** 2) / SR
    return (np.sin(ph) * .6 + fft_filter(rng.standard_normal(len(t)), lo=2000) * .3) * np.sin(np.pi * t / .25)


def s_whoosh(soft=0):
    d = .8; t = t_arr(d); n = rng.standard_normal(len(t)); x = t / d
    s = fft_filter(n, hi=700) * (1 - x) * 1.6 + fft_filter(n, lo=2500) * x * .9 + fft_filter(n, lo=600, hi=3000) * .8
    return s * np.sin(np.pi * x) ** 2 * (.45 if soft else .9)


def s_riser(d, big=0):
    t = t_arr(d); x = t / d
    n = fft_filter(rng.standard_normal(len(t)), lo=400)
    ph = 2 * np.pi * np.cumsum(180 * 2 ** (x * (3 if big else 2))) / SR
    return fft_filter((n * .6 + saw(1, ph / (2 * np.pi)) * .25 + np.sin(ph * 2) * .3) * x ** 2.2, hi=5000) * (1.0 if big else .6)


def s_impact(big=0):
    t = t_arr(2.2)
    sub = np.sin(2 * np.pi * np.cumsum(32 + 70 * np.exp(-t * 10)) / SR) * np.exp(-t * (1.6 if big == 1 else 2.6))
    n = fft_filter(rng.standard_normal(len(t)), hi=2500) * np.exp(-t * 7)
    return np.tanh((sub * 1.6 + n * .8) * 1.5) * {1: 1.0, 2: .75, 3: .45}.get(big, .75)


def s_chime(big=0):
    t = t_arr(2.0); s = np.zeros(len(t))
    for j, f in enumerate([1046.5, 1318.5, 1568.0] if big else [880.0, 1318.5]):
        dl = int(j * .06 * SR)
        for ratio, amp, dec in ((1, 1, 3), (2.01, .4, 5), (3.0, .2, 8), (4.2, .12, 11)):
            s[dl:] += (amp * np.sin(2 * np.pi * f * ratio * t) * np.exp(-t * dec))[: len(t) - dl]
    return s * .35


def s_sweep(d):
    t = t_arr(d); x = t / d; ph = 2 * np.pi * np.cumsum(300 * 2 ** (x * 1.6)) / SR
    return (np.sin(ph) + .3 * np.sin(3 * ph)) * np.sin(np.pi * x) * (.7 + .3 * np.sin(2 * np.pi * 14 * t)) * .5


def s_coin(v):
    t = t_arr(.3); f = 988 * 2 ** ((v % 4) / 12)
    s = np.where(t < .07, np.sin(2 * np.pi * f * t), np.sin(2 * np.pi * f * 1.335 * t))
    return s * np.exp(-t * 9) * .7


def s_error():
    t = t_arr(.5)
    s = np.sign(np.sin(2 * np.pi * np.where(t < .2, 220, 165) * t)) * .3
    return fft_filter(s, hi=1800) * np.exp(-t * 4) * (t < .45)


def s_scan(d):
    t = t_arr(d); x = t / d
    return np.sin(2 * np.pi * np.cumsum(600 + 900 * x) / SR) * .25 * np.sin(np.pi * x) * (.6 + .4 * np.sin(2 * np.pi * 22 * t))


def s_confetti():
    t = t_arr(1.2); s = np.zeros(len(t)); r = np.random.default_rng(7)
    for _ in range(26):
        dl = int(r.random() * .8 * SR); f = 2000 + r.random() * 3000; tt = t_arr(.08)
        part = np.sin(2 * np.pi * f * tt) * np.exp(-tt * 60) * (.3 + .7 * r.random())
        s[dl:dl + len(part)] += part[: len(t) - dl]
    return s * .25


fx = np.zeros((2, N)); fx_wet = np.zeros((2, N))
for e in tl["sfx"]:
    ty, at = e["type"], e["t"]
    if ty == "type":
        s, pan = s_type(e["v"]); add(fx, s, at, .42, pan)
    elif ty == "tick":
        add(fx, s_tick(e["v"], e.get("hi", 0)), at, .2 if e.get("hi") else .16)
    elif ty == "pop":
        add(fx, s_pop(e["f"]), at, .26); add(fx_wet, s_pop(e["f"]), at, .12)
    elif ty == "send":
        add(fx, s_send(), at, .35)
    elif ty == "whoosh":
        add(fx, s_whoosh(e.get("soft", 0)), at - .35, .5)
    elif ty == "riser":
        add(fx, s_riser(e["dur"], e.get("big", 0)), at, .5)
    elif ty == "impact":
        s = s_impact(e.get("big", 0)); add(fx, s, at, .9); add(fx_wet, s, at, .45)
        i = int(at * SR); dk = 1 - .5 * np.exp(-t_arr(1.0) * 4); music[:, i:i + len(dk)] *= dk[: N - i]
    elif ty == "chime":
        s = s_chime(e.get("big", 0)); add(fx, s, at, .5); add(fx_wet, s, at, .5)
    elif ty == "sweep":
        add(fx, s_sweep(e["dur"]), at, .3)
    elif ty == "coin":
        add(fx, s_coin(e["v"]), at, .3, .3); add(fx_wet, s_coin(e["v"]), at, .15)
    elif ty == "error":
        add(fx, s_error(), at, .45)
    elif ty == "scan":
        add(fx, s_scan(e["dur"]), at, .4)
    elif ty == "confetti":
        add(fx, s_confetti(), at, .5); add(fx_wet, s_confetti(), at, .3)

# ------------------------------------------------------------------ Sprecherstimme (falls Dateien vorhanden)
voice = np.zeros((2, N)); venv = np.zeros(N)
for c in tl["clips"]:
    if not c.get("file"):
        continue
    raw = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", c["file"], "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    v = np.frombuffer(raw, "<f4").astype(np.float64)
    v = v / (np.max(np.abs(v)) + 1e-9) * .8
    add(voice, v, c["t0"], 1.0)
    i0, i1 = int((c["t0"] - .15) * SR), int((c["t1"] + .3) * SR)
    venv[max(0, i0):min(N, i1)] = 1
if venv.any():
    k = int(.15 * SR); venv = np.convolve(venv, np.ones(k) / k, mode="same")
    music *= 1 - .55 * venv
    fx *= 1 - .25 * venv


def reverb(x, rt=2.2):
    t = t_arr(rt)
    ir = np.stack([rng.standard_normal(len(t)), rng.standard_normal(len(t))]) * np.exp(-t * 6.9 / rt)
    ir = fft_filter(ir, hi=4500); ir /= np.sqrt((ir ** 2).sum(axis=1, keepdims=True))
    n = 1 << int(np.ceil(np.log2(x.shape[1] + ir.shape[1])))
    return np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[:, : x.shape[1]]


wet = reverb(fx_wet + pad * .5 + arp * .8 + voice * .12)
mix = music * .6 + fx + wet * .35 + voice
mix = fft_filter(mix, lo=25)
mix = np.tanh(mix * 1.1) / np.tanh(1.1)
mix *= .89 / np.max(np.abs(mix))
end = int(END * SR); mix = mix[:, :end]
mix[:, -int(.05 * SR):] *= np.linspace(1, 0, int(.05 * SR))
with wave.open(sys.argv[2], "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((np.clip(mix.T, -1, 1) * 32767).astype("<i2").tobytes())
print(f"Ton fertig: {END:.1f} s, {len(tl['sfx'])} Effekte, {sum(1 for c in tl['clips'] if c.get('file'))} Sprachclips")
