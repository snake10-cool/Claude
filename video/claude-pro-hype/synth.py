"""Hype-Beat (150 BPM, f-Moll): Kick, Clap, Hi-Hat-Rolls, 808 mit Slides, Cowbell-Melodie, Saw-Stabs
plus alle Effekte und Voice-Drops.   python3 synth.py timeline.json audio.wav"""
import json
import subprocess
import sys
import wave

import numpy as np

SR = 44100
B = .4
STEP = B / 4
tl = json.load(open(sys.argv[1]))
END = tl["end"]
N = int((END + 2) * SR)
rng = np.random.default_rng(42)
here = sys.argv[3] if len(sys.argv) > 3 else "."


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


def filt(x, lo=None, hi=None):
    X = np.fft.rfft(x, axis=-1)
    f = np.fft.rfftfreq(x.shape[-1], 1 / SR)
    H = np.ones_like(f)
    if hi:
        H /= np.sqrt(1 + (f / hi) ** 4)
    if lo:
        H *= (f / lo) ** 2 / np.sqrt(1 + (f / lo) ** 4)
    return np.fft.irfft(X * H, n=x.shape[-1], axis=-1)


def saw(f, t):
    return 2 * ((f * t) % 1) - 1


def noise(d):
    return rng.standard_normal(int(d * SR))


# ------------------------------------------------------------------ Drums
def kick(hard=1.0):
    t = t_arr(.5)
    f = 42 + 150 * np.exp(-t * 32)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 6)
    click = filt(noise(.5), lo=2000) * np.exp(-t * 300) * .4
    return np.tanh((s + click) * (2.2 * hard))


def clap():
    t = t_arr(.35)
    env = np.exp(-t * 16)
    for k in (0, .01, .021):
        env += np.exp(-np.maximum(t - k, 0) * 140) * (t >= k) * .7
    return filt(noise(.35) * env, lo=1000, hi=7000) * .9


def hat(op=False):
    t = t_arr(.22 if op else .05)
    return filt(noise(.22 if op else .05), lo=7000) * np.exp(-t * (16 if op else 90))


def cowbell(f, d=.16):
    t = t_arr(d)
    sq = np.sign(np.sin(2 * np.pi * f * t)) + np.sign(np.sin(2 * np.pi * f * 1.48 * t))
    return filt(sq * np.exp(-t * 18), lo=700, hi=4000) * .5


KICK, KICK_SOFT, CLAP, HATC, HATO = kick(1), kick(.6), clap(), hat(), hat(True)

# f-Moll
F1, AB1, BB1, C2, DB2, EB2 = 43.65, 51.91, 58.27, 65.41, 69.30, 77.78
RIFF = [F1, 0, F1, 0, 0, AB1, 0, C2, DB2, 0, DB2, 0, C2, 0, AB1, 0]          # Achtel über 2 Takte
BELL = [1046.5, 0, 1046.5, 830.6, 0, 830.6, 698.5, 0, 830.6, 0, 1046.5, 0, 1244.5, 1108.7, 1046.5, 0,
        1046.5, 0, 1046.5, 830.6, 0, 830.6, 698.5, 0, 932.3, 0, 830.6, 0, 698.5, 0, 622.3, 0]  # 16tel über 2 Takte
STAB_CH = [[349.2, 415.3, 523.3], [277.2, 349.2, 415.3]]  # Fm, Db

drums = np.zeros((2, N)); bass = np.zeros((2, N)); bell = np.zeros((2, N)); stabs = np.zeros((2, N)); pad = np.zeros((2, N))


def mode_at(t):
    for m in tl["music"]:
        if m["t0"] <= t < m["t1"]:
            return m["mode"]
    return "end"


# 808 als durchgehende Linie mit Slides (pro Achtel ein Zielton)
b808_f = np.zeros(N); b808_env = np.zeros(N)
nsteps = int(END / STEP)
for s in range(nsteps):
    t0 = s * STEP
    mode = mode_at(t0 + 1e-4)
    bar, st = int(t0 / 1.6), s % 16          # Schritt im Takt (16tel)
    two = (bar % 2) * 16 + st                # Schritt in 2 Takten
    i0 = int(t0 * SR)
    drop = mode in ("drop", "drop2")
    if mode == "silence":
        continue
    # Kick / Clap / Hats
    if drop or mode in ("groove", "meme"):
        if st in (0, 6, 10) or (mode == "drop2" and st == 13):
            add(drums, KICK, t0, .95); b808_env[i0:i0 + 10] = 0
        if st in (4, 12):
            add(drums, CLAP, t0, .55 if drop else .45)
        if st % 2 == 0:
            add(drums, HATC, t0, .22, .3)
        if (bar % 2 == 1 and st >= 12) or (drop and st % 4 == 3):   # Hi-Hat-Rolls
            add(drums, HATC, t0, .16, -.3); add(drums, HATC, t0 + STEP / 2, .12, -.3)
        if st == 8 and mode != "meme":
            add(drums, HATO, t0, .2)
    elif mode == "intro":
        if st % 4 == 0:
            add(drums, HATC, t0, .18)
        if st == 0 and bar >= 1:
            add(drums, KICK_SOFT, t0, .5)
    elif mode == "build":
        if st % 4 == 0:
            add(drums, KICK, t0, .7)
    elif mode == "end":
        if st == 0 and bar == int(tl["music"][-1]["t0"] / 1.6):
            add(drums, KICK, t0, 1.0)
    # 808
    if st % 2 == 0 and (drop or mode in ("groove", "meme")):
        n = RIFF[(two // 2) % 16]
        if n:
            b808_f[i0:] = n; b808_env[i0:i0 + int(STEP * 2 * SR * 2.2)] = 1
    # Cowbell-Melodie
    if mode in ("drop", "drop2", "meme"):
        f = BELL[two % 32]
        if f:
            add(bell, cowbell(f * (1 if mode != "meme" else .5)), t0, .32 if drop else .26, (-.4 if st % 2 else .4))
    # Saw-Stabs im großen Drop
    if mode == "drop2" and st in (2, 6, 10, 14):
        t = t_arr(.18)
        for f in STAB_CH[bar % 2]:
            for d in (-12, 0, 12):
                add(stabs, saw(f * 2 ** (d / 1200), t) * np.exp(-t * 14), t0, .05, d / 20)
    # Pad im Intro/Build
    if mode in ("intro", "build", "end") and st == 0:
        t = t_arr(1.7)
        for f in STAB_CH[0]:
            add(pad, saw(f / 2, t) * np.minimum(t / .3, 1) * np.exp(-t * .6), t0, .08, -.4)
            add(pad, saw(f / 2 * 1.006, t) * np.minimum(t / .3, 1) * np.exp(-t * .6), t0, .08, .4)

# 808 rendern: glatte Frequenz (Slide), Hüllkurve, Sättigung
k = int(.03 * SR)
fs = np.convolve(b808_f, np.ones(k) / k, mode="same")
env = np.convolve(b808_env, np.ones(int(.006 * SR)) / int(.006 * SR), mode="same")
ph = 2 * np.pi * np.cumsum(fs) / SR
s808 = np.tanh(np.sin(ph) * 2.2 * env) * .8
bass[0] += s808; bass[1] += s808

pad = filt(pad, hi=1800); stabs = filt(stabs, hi=5000); bell = filt(bell, hi=6000)
# Sidechain auf Kicks
duck = np.ones(N)
seg = 1 - .6 * np.exp(-t_arr(.3) * 12)
for s in range(nsteps):
    t0 = s * STEP; st = s % 16; mode = mode_at(t0 + 1e-4)
    if mode in ("drop", "drop2", "groove", "meme") and st in (0, 6, 10):
        i = int(t0 * SR); duck[i:i + len(seg)] = np.minimum(duck[i:i + len(seg)], seg[: N - i])
music = drums * 1.0 + bass * .9 * duck + (bell + stabs + pad) * duck
t_all = np.arange(N) / SR
music *= np.clip((END - .3 - t_all) / 1.4, 0, 1)


# ------------------------------------------------------------------ Effekte
def s_hit(big=0):
    t = t_arr(1.6)
    sub = np.sin(2 * np.pi * np.cumsum(38 + 110 * np.exp(-t * 14)) / SR) * np.exp(-t * (2.0 if big else 3.5))
    crash = filt(noise(1.6), lo=3000) * np.exp(-t * (3 if big else 7)) * .5
    return np.tanh((sub * 1.8 + crash + filt(noise(1.6), hi=1500) * np.exp(-t * 20) * .6) * 1.6)


def s_boom(big=0):
    t = t_arr(2.2)
    f = 55 * (1 + .9 * np.exp(-t * 6))
    s = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.exp(-t * 1.6)
    return np.tanh(s * 3) * (1 if big else .8)


def s_whoosh():
    d = .5; t = t_arr(d); x = t / d; n = noise(d)
    return (filt(n, hi=900) * (1 - x) + filt(n, lo=2500) * x) * np.sin(np.pi * x) ** 2 * 1.3


def s_riser(d, big=0):
    t = t_arr(d); x = t / d
    ph = 2 * np.pi * np.cumsum(150 * 2 ** (x * 3.2)) / SR
    return (filt(noise(d), lo=600) * .5 + saw(1, ph / (2 * np.pi)) * .25 + np.sin(ph * 2) * .25) * x ** 2.4 * (1 if big else .7)


def s_snareroll(d):
    out = np.zeros(int(d * SR) + SR)
    t = 0.0
    while t < d:
        x = t / d
        step = B / 2 if x < .35 else B / 4 if x < .65 else B / 8 if x < .9 else B / 16
        c = clap()[: int(.12 * SR)] * (.3 + .7 * x)
        i = int(t * SR); out[i:i + len(c)] += c
        t += step
    return out


def s_pop(f):
    t = t_arr(.18); f = f * 2
    ph = 2 * np.pi * np.cumsum(f * (1.5 - .5 * np.exp(-t * 70))) / SR
    return (np.sin(ph) + .25 * np.sin(2 * ph)) * np.exp(-t * 24) * np.minimum(t / .003, 1)


def s_type(v):
    t = t_arr(.07); r = np.random.default_rng(v)
    return (filt(r.standard_normal(len(t)), lo=250, hi=1600) * np.exp(-t * 160) * .8 + np.sin(2 * np.pi * (330 + r.random() * 120) * t) * np.exp(-t * 90) * .7)


def s_beep(f):
    t = t_arr(.18); return np.sign(np.sin(2 * np.pi * f * t)) * .3 * (t < .15)


def s_glitch():
    t = t_arr(.35); r = np.random.default_rng(3)
    s = np.zeros(len(t))
    for k in range(10):
        i = int(r.random() * len(t) * .9); L = int(.02 * SR)
        s[i:i + L] += np.sign(np.sin(2 * np.pi * (200 + r.random() * 2000) * t[:L])) * .4
    return s


def s_scratch():
    t = t_arr(.45)
    f = 600 + 900 * np.sin(2 * np.pi * 5 * t)
    return filt(noise(.45), lo=500, hi=4000) * (.5 + .5 * np.sin(2 * np.pi * np.cumsum(f) / SR)) * np.exp(-t * 3) * .8


def s_static(d):
    return filt(noise(d), lo=1500) * .25


def s_chime(big=0):
    t = t_arr(1.6); s = np.zeros(len(t))
    for j, f in enumerate([1046.5, 1318.5, 1568.0] if big else [880.0, 1318.5]):
        dl = int(j * .05 * SR)
        for ratio, amp, dec in ((1, 1, 3), (2.01, .4, 5), (3.0, .2, 8)):
            s[dl:] += (amp * np.sin(2 * np.pi * f * ratio * t) * np.exp(-t * dec))[: len(t) - dl]
    return s * .35


def s_coin(v):
    t = t_arr(.25); f = 988 * 2 ** ((v % 4) / 12)
    return np.where(t < .06, np.sin(2 * np.pi * f * t), np.sin(2 * np.pi * f * 1.335 * t)) * np.exp(-t * 10) * .6


def s_stamp():
    t = t_arr(.3)
    return np.tanh((np.sin(2 * np.pi * np.cumsum(80 + 200 * np.exp(-t * 40)) / SR) * np.exp(-t * 18) + filt(noise(.3), hi=3000) * np.exp(-t * 40) * .6) * 2)


def s_shutter():
    t = t_arr(.12); n = filt(noise(.12), lo=2000)
    return n * (np.exp(-t * 80) + np.exp(-np.maximum(t - .05, 0) * 80) * (t > .05)) * .6


def s_sad():  # absteigendes „wah wah“
    t = t_arr(1.4); s = np.zeros(len(t))
    for k, f in enumerate([392, 370, 349, 311]):
        i = int(k * .3 * SR); tt = t_arr(.32 if k < 3 else .5)
        ff = f * (1 + .02 * np.sin(2 * np.pi * 6 * tt))
        part = filt(saw(1, np.cumsum(ff) / SR), hi=1400) * np.minimum(tt / .03, 1) * np.exp(-tt * 3)
        s[i:i + len(part)] += part[: len(s) - i]
    return s * .5


def s_clock():
    t = t_arr(.08); return filt(noise(.08), lo=2500, hi=6000) * np.exp(-t * 120) + np.sin(2 * np.pi * 1800 * t) * np.exp(-t * 90) * .4


def s_cash():
    t = t_arr(1.0)
    bellp = sum(np.sin(2 * np.pi * f * t) * np.exp(-t * d) for f, d in ((2093, 4), (2637, 5), (3136, 6))) * .3
    rattle = filt(noise(1.0), lo=3000) * np.exp(-t * 12) * .4
    return bellp + rattle


def s_sweep(d):
    t = t_arr(d); x = t / d; ph = 2 * np.pi * np.cumsum(300 * 2 ** (x * 2)) / SR
    return np.sin(ph) * np.sin(np.pi * x) * .5


fxb = np.zeros((2, N)); wetb = np.zeros((2, N))
for e in tl["sfx"]:
    ty, at = e["type"], e["t"]
    if ty == "hit":
        s = s_hit(e.get("big", 0)); add(fxb, s, at, .8); add(wetb, s, at, .35)
    elif ty == "boom":
        add(fxb, s_boom(e.get("big", 0)), at, .7); add(wetb, s_boom(0), at, .25)
    elif ty == "whoosh":
        add(fxb, s_whoosh(), at - .2, .45)
    elif ty == "zig":
        add(fxb, s_whoosh(), at, .55); add(fxb, s_whoosh(), at + .15, .4, .5)
    elif ty == "riser":
        add(fxb, s_riser(e["dur"], e.get("big", 0)), at, .45)
    elif ty == "snareroll":
        add(fxb, s_snareroll(e["dur"]), at, .55)
    elif ty == "pop":
        add(fxb, s_pop(e["f"]), at, .3); add(wetb, s_pop(e["f"]), at, .1)
    elif ty == "type":
        add(fxb, s_type(e["v"]), at, .45, (e["v"] % 3 - 1) * .3)
    elif ty == "beep":
        add(fxb, s_beep(e["f"]), at, .4)
    elif ty == "glitch":
        add(fxb, s_glitch(), at, .5)
    elif ty == "scratch":
        add(fxb, s_scratch(), at, .6)
    elif ty == "static":
        add(fxb, s_static(e["dur"]), at, .6)
    elif ty == "chime":
        s = s_chime(e.get("big", 0)); add(fxb, s, at, .5); add(wetb, s, at, .4)
    elif ty == "coin":
        add(fxb, s_coin(e["v"]), at, .3, .3)
    elif ty == "stamp":
        add(fxb, s_stamp(), at, .55)
    elif ty == "shutter":
        add(fxb, s_shutter(), at, .5)
    elif ty == "sad":
        add(fxb, s_sad(), at, .5); add(wetb, s_sad(), at, .3)
    elif ty == "clock":
        add(fxb, s_clock(), at, .6)
    elif ty == "cash":
        add(fxb, s_cash(), at, .5); add(wetb, s_cash(), at, .3)
    elif ty == "sweep":
        add(fxb, s_sweep(e["dur"]), at, .3)

# Voice-Drops
voice = np.zeros((2, N)); venv = np.zeros(N)
for v in tl["voice"]:
    raw = subprocess.run(["ffmpeg", "-loglevel", "error", "-i", v["file"], "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True, check=True).stdout
    x = np.frombuffer(raw, "<f4").astype(np.float64); x = x / (np.max(np.abs(x)) + 1e-9) * .85
    add(voice, x, v["t0"], 1.0)
    i0, i1 = int((v["t0"] - .1) * SR), int((v["t0"] + len(x) / SR + .2) * SR)
    venv[max(0, i0):min(N, i1)] = 1
kk = int(.08 * SR); venv = np.convolve(venv, np.ones(kk) / kk, mode="same")
music *= 1 - .5 * venv


def reverb(x, rt=1.8):
    t = t_arr(rt)
    ir = np.stack([rng.standard_normal(len(t)), rng.standard_normal(len(t))]) * np.exp(-t * 6.9 / rt)
    ir = filt(ir, hi=5000); ir /= np.sqrt((ir ** 2).sum(axis=1, keepdims=True))
    n = 1 << int(np.ceil(np.log2(x.shape[1] + ir.shape[1])))
    return np.fft.irfft(np.fft.rfft(x, n) * np.fft.rfft(ir, n), n)[:, : x.shape[1]]


wet = reverb(wetb + voice * .15 + pad * .6)
mix = music * .62 + fxb + wet * .3 + voice * 1.05
mix = filt(mix, lo=28)
mix = np.tanh(mix * 1.25) / np.tanh(1.25)
mix *= .9 / np.max(np.abs(mix))
end = int(END * SR); mix = mix[:, :end]
mix[:, -int(.05 * SR):] *= np.linspace(1, 0, int(.05 * SR))
with wave.open(sys.argv[2], "wb") as w:
    w.setnchannels(2); w.setsampwidth(2); w.setframerate(SR)
    w.writeframes((np.clip(mix.T, -1, 1) * 32767).astype("<i2").tobytes())
print(f"Ton fertig: {END:.1f} s, {len(tl['sfx'])} Effekte, {len(tl['voice'])} Voice-Drops")
