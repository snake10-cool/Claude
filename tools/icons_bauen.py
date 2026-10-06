"""Zeichnet die App-Icons für alle Apps (Pillow).

Aufruf:  python3 tools/icons_bauen.py
Erzeugt pro App in apps/<app>/assets/icon/:
  icon.png             – volles Icon (Hintergrund + Motiv), 1024 px
  icon_vordergrund.png – nur das Motiv, transparent, für adaptive Icons

Danach in der App:  dart run flutter_launcher_icons
"""
from pathlib import Path

from PIL import Image, ImageDraw

GROESSE = 1024
FAKTOR = 4  # Supersampling für glatte Kanten
WURZEL = Path(__file__).resolve().parent.parent


def neu():
    g = GROESSE * FAKTOR
    return Image.new("RGBA", (g, g), (0, 0, 0, 0))


def s(*werte):
    """Koordinaten von 0..1024 auf die Supersampling-Größe."""
    return [int(w * FAKTOR) for w in werte]


def speichern(app, farbe, zeichnen):
    ordner = WURZEL / "apps" / app / "assets" / "icon"
    ordner.mkdir(parents=True, exist_ok=True)

    # Vordergrund: Motiv in der sicheren Zone (Mitte ~66 %).
    vorder = neu()
    zeichnen(ImageDraw.Draw(vorder), skala=0.62)
    vorder.resize((GROESSE, GROESSE), Image.LANCZOS).save(ordner / "icon_vordergrund.png")

    voll = Image.new("RGBA", vorder.size, farbe)
    motiv = neu()
    zeichnen(ImageDraw.Draw(motiv), skala=0.8)
    voll.alpha_composite(motiv)
    voll.resize((GROESSE, GROESSE), Image.LANCZOS).convert("RGB").save(ordner / "icon.png")
    print("✓", app)


class Leinwand:
    """Zeichnet in einem 1024er-Raster, skaliert um die Mitte."""

    def __init__(self, d, skala):
        self.d = d
        self.k = skala

    def p(self, x, y):
        m = GROESSE / 2
        return s(m + (x - m) * self.k, m + (y - m) * self.k)

    def box(self, x0, y0, x1, y1):
        return self.p(x0, y0) + self.p(x1, y1)

    def r(self, w):
        return int(w * self.k * FAKTOR)


WEISS = (255, 255, 255, 255)


def druckkasse(d, skala):
    """Druckdüse, die eine Münze „druckt“."""
    l = Leinwand(d, skala)
    dunkel = (120, 40, 10, 255)
    # Heizblock
    d.rounded_rectangle(l.box(300, 120, 724, 380), radius=l.r(48), fill=WEISS)
    # Kühlrippen
    for x in (360, 450, 540, 630):
        d.rounded_rectangle(l.box(x, 165, x + 34, 335), radius=l.r(14), fill=dunkel)
    # Düse
    d.polygon([*l.p(410, 380), *l.p(614, 380), *l.p(540, 500), *l.p(484, 500)], fill=WEISS)
    # Filament-Tropfen
    d.ellipse(l.box(492, 520, 532, 560), fill=WEISS)
    # Münze (Kreis, Mitte 512/770)
    d.ellipse(l.box(322, 580, 702, 960), fill=WEISS)
    d.ellipse(l.box(356, 614, 668, 926), outline=dunkel, width=l.r(16))
    # Euro-Zeichen
    d.arc(l.box(430, 680, 600, 860), start=45, end=315, fill=dunkel, width=l.r(30))
    d.rounded_rectangle(l.box(405, 742, 545, 762), radius=l.r(10), fill=dunkel)
    d.rounded_rectangle(l.box(405, 780, 545, 800), radius=l.r(10), fill=dunkel)


def codekarten(d, skala):
    """Zwei gestapelte Karteikarten mit </> darauf."""
    l = Leinwand(d, skala)
    violett = (76, 45, 190, 255)
    hell = (220, 210, 255, 255)
    # hintere Karte (leicht versetzt)
    d.rounded_rectangle(l.box(290, 230, 790, 640), radius=l.r(48), fill=hell)
    # vordere Karte
    d.rounded_rectangle(l.box(230, 330, 730, 760), radius=l.r(48), fill=WEISS)
    # </>
    w = l.r(44)
    d.line([*l.p(400, 450), *l.p(320, 545), *l.p(400, 640)], fill=violett, width=w, joint="curve")
    d.line([*l.p(560, 450), *l.p(640, 545), *l.p(560, 640)], fill=violett, width=w, joint="curve")
    d.line([*l.p(510, 430), *l.p(450, 660)], fill=violett, width=w)
    for x, y in [(400, 450), (320, 545), (400, 640), (560, 450), (640, 545), (560, 640), (510, 430), (450, 660)]:
        r = 22
        d.ellipse(l.box(x - r, y - r, x + r, y + r), fill=violett)


def teilbar(d, skala):
    """Abgehakte Liste und eine halbierte Münze."""
    l = Leinwand(d, skala)
    gruen = (18, 110, 74, 255)
    hell = (190, 240, 215, 255)
    d.rounded_rectangle(l.box(240, 200, 700, 800), radius=l.r(56), fill=WEISS)
    for i, y in enumerate((320, 470, 620)):
        d.rounded_rectangle(l.box(300, y - 40, 380, y + 40), radius=l.r(16),
                            fill=gruen if i < 2 else WEISS, outline=gruen, width=l.r(10))
        if i < 2:
            d.line([*l.p(318, y), *l.p(336, y + 22), *l.p(366, y - 22)], fill=WEISS, width=l.r(14), joint="curve")
        d.rounded_rectangle(l.box(420, y - 16, 640, y + 16), radius=l.r(16), fill=hell if i < 2 else gruen)
    # Münze, in zwei Hälften geteilt
    d.pieslice(l.box(560, 560, 820, 820), 90, 270, fill=(255, 200, 60, 255))
    d.pieslice(l.box(580, 560, 840, 820), 270, 90, fill=(255, 220, 110, 255))


def raetseltag(d, skala):
    """3×3 Rätselfelder (grün/gelb/weiß) mit einer Lücke."""
    l = Leinwand(d, skala)
    gruen = (22, 163, 74, 255)
    gelb = (234, 179, 8, 255)
    muster = [gruen, gelb, WEISS, WEISS, gruen, gelb, gelb, WEISS, None]
    kante, abstand = 170, 30
    start = 512 - (3 * kante + 2 * abstand) / 2
    for i, farbe in enumerate(muster):
        if farbe is None:
            continue
        x = start + (i % 3) * (kante + abstand)
        y = start + (i // 3) * (kante + abstand)
        d.rounded_rectangle(l.box(x, y, x + kante, y + kante), radius=l.r(30), fill=farbe)


APPS = {
    "druckkasse": ((0xE8, 0x62, 0x2A, 255), druckkasse),
    "codekarten": ((0x6C, 0x4D, 0xE6, 255), codekarten),
    "teilbar": ((0x1F, 0x9D, 0x6B, 255), teilbar),
    "raetseltag": ((0x25, 0x63, 0xEB, 255), raetseltag),
}

if __name__ == "__main__":
    import sys

    auswahl = sys.argv[1:] or list(APPS)
    for name in auswahl:
        farbe, zeichnen = APPS[name]
        speichern(name, farbe, zeichnen)
