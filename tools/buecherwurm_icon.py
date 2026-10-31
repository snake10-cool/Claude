"""Zeichnet das Bücherwurm-Icon (offenes Buch, aus dem ein Wurm mit Brille schaut).

Aufruf: python tools/buecherwurm_icon.py
Danach in apps/buecherwurm: dart run flutter_launcher_icons && dart run flutter_native_splash:create
"""
from pathlib import Path

from PIL import Image, ImageDraw

ZIEL = Path(__file__).resolve().parent.parent / 'apps/buecherwurm/assets/icon'
GRUEN = (46, 125, 107)
PAPIER = (255, 248, 231)
RAND = (214, 196, 160)
WURM = (139, 195, 74)
WURM_DUNKEL = (104, 159, 56)
DUNKEL = (55, 55, 55)
S = 1024
GLATT = 2  # doppelt so groß zeichnen und verkleinern = glatte Kanten


def bild(hintergrund, m, groesse=S):
    """m = Maßstab des Motivs (1 = füllt die Fläche gut aus)."""
    img = Image.new('RGBA', (S * GLATT, S * GLATT), hintergrund or (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    def p(x, y):
        return ((512 + (x - 512) * m) * GLATT, (532 + (y - 512) * m) * GLATT)

    def kreis(x, y, r, **k):
        d.ellipse([p(x - r, y - r), p(x + r, y + r)], **k)

    def breite(w):
        return int(w * m * GLATT)

    # Wurm zuerst, damit das Buch sein Ende verdeckt.
    for i, (x, y, r) in enumerate([(430, 520, 70), (440, 410, 74), (490, 340, 78), (570, 310, 84)]):
        kreis(x, y, r, fill=WURM if i % 2 else WURM_DUNKEL)
    kreis(600, 290, 105, fill=WURM)
    for ax in (565, 650):
        kreis(ax, 281, 26, fill='white')
        kreis(ax + 2, 286, 13, fill=DUNKEL)
        kreis(ax, 281, 40, outline=DUNKEL, width=breite(10))  # Brille
    d.line([p(605, 281), p(610, 281)], fill=DUNKEL, width=breite(10))
    d.arc([p(570, 300), p(660, 360)], 20, 160, fill=(40, 80, 30), width=breite(12))

    # Offenes Buch
    d.polygon([p(120, 470), p(512, 525), p(904, 470), p(904, 805), p(512, 860), p(120, 805)], fill=RAND)
    d.polygon([p(140, 470), p(500, 520), p(500, 830), p(140, 780)], fill=PAPIER)
    d.polygon([p(524, 520), p(884, 470), p(884, 780), p(524, 830)], fill=PAPIER)
    for i in range(4):
        y = 575 + i * 55
        d.line([p(190, y - 10), p(450, y + 25)], fill=RAND, width=breite(16))
        d.line([p(574, y + 25), p(834, y - 10)], fill=RAND, width=breite(16))

    return img.resize((groesse, groesse), Image.LANCZOS)


ZIEL.mkdir(parents=True, exist_ok=True)
bild(GRUEN, 1.0).save(ZIEL / 'icon.png')
# Adaptive Icons schneiden außen ab: Motiv in die sichere Mitte.
bild(None, 0.62).save(ZIEL / 'icon_vordergrund.png')
bild(None, 0.8, groesse=512).save(ZIEL / 'splash.png')
print('Icons gespeichert in', ZIEL)
