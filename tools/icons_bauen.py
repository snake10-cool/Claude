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


APPS = {
    "druckkasse": ((0xE8, 0x62, 0x2A, 255), druckkasse),
}

if __name__ == "__main__":
    import sys

    auswahl = sys.argv[1:] or list(APPS)
    for name in auswahl:
        farbe, zeichnen = APPS[name]
        speichern(name, farbe, zeichnen)
