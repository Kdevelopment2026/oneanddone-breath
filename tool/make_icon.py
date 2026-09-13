#!/usr/bin/env python3
"""Renders the Night Tide app icon (assets/icon/app_icon.png, 1024x1024).

Pure Python/PIL so the icon is reproducible from source — no design-tool
export step. Re-run after tweaking, then `dart run flutter_launcher_icons`.
"""
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

S = 1024
SS = 2  # supersample
N = S * SS
OUT = Path(__file__).resolve().parent.parent / "assets" / "icon" / "app_icon.png"


def hexc(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


BG1, BG2 = hexc("0F1726"), hexc("090D14")
TEAL, MINT, IND = hexc("7FD1C4"), hexc("B8F5E9"), hexc("5B6CFF")
DISC_IN, DISC_OUT = hexc("1B2632"), hexc("0C1219")

yy, xx = np.mgrid[0:N, 0:N].astype(np.float32)
c = N / 2
R = N * 0.30          # track radius
rd = R * 0.66         # disc radius


def layer():
    return Image.new("RGBA", (N, N), (0, 0, 0, 0))


def bloom(img, cx, cy, r, col, a):
    d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r
    m = np.clip(1 - d, 0, 1) ** 2 * a
    return img * (1 - m[..., None]) + np.array(col, np.float32) * m[..., None]


# Background: vertical gradient with three aurora blooms.
t = (yy / N)[..., None]
img = (np.array(BG1) * (1 - t) + np.array(BG2) * t).astype(np.float32)
img = bloom(img, N * 0.88, N * 0.08, N * 0.75, TEAL, 0.42)
img = bloom(img, N * 0.05, N * 0.85, N * 0.80, IND, 0.40)
img = bloom(img, N * 0.5, N * 0.5, N * 0.38, TEAL, 0.22)
base = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB").convert("RGBA")

# Central glow behind the disc.
glow = layer()
ImageDraw.Draw(glow).ellipse([c - R * 0.95, c - R * 0.95, c + R * 0.95, c + R * 0.95], fill=TEAL + (120,))
base = Image.alpha_composite(base, glow.filter(ImageFilter.GaussianBlur(N * 0.09)))

# Disc with a radial gradient.
d = np.sqrt((xx - c) ** 2 + (yy - c) ** 2) / rd
tt = np.clip(d, 0, 1)[..., None]
dcol = np.array(DISC_IN, np.float32) * (1 - tt) + np.array(DISC_OUT, np.float32) * tt
disc = Image.fromarray(np.dstack([np.clip(dcol, 0, 255).astype(np.uint8), (d <= 1).astype(np.uint8) * 255]), "RGBA")
base = Image.alpha_composite(base, disc)

# Hairlines: disc edge, track, echo ring — on a layer so alpha blends.
lines = layer()
ld = ImageDraw.Draw(lines)
ld.ellipse([c - rd, c - rd, c + rd, c + rd], outline=(255, 255, 255, 28), width=int(N * 0.003))
ld.ellipse([c - R, c - R, c + R, c + R], outline=(255, 255, 255, 30), width=int(N * 0.006))
ld.ellipse([c - R * 1.2, c - R * 1.2, c + R * 1.2, c + R * 1.2], outline=TEAL + (48,), width=int(N * 0.003))
base = Image.alpha_composite(base, lines)

# Progress arc, mint → teal, with a soft halo underneath.
arc = layer()
ad = ImageDraw.Draw(arc)
w = int(N * 0.022)
start, sweep, steps = -90, 252, 240
for i in range(steps):
    a0 = start + sweep * i / steps
    a1 = start + sweep * (i + 1) / steps + 0.6
    k = i / steps
    col = tuple(int(MINT[j] * (1 - k) + TEAL[j] * k) for j in range(3))
    ad.arc([c - R, c - R, c + R, c + R], a0, a1, fill=col + (255,), width=w)
for ang, col in ((start, MINT), (start + sweep, TEAL)):
    x = c + R * math.cos(math.radians(ang))
    y = c + R * math.sin(math.radians(ang))
    ad.ellipse([x - w / 2, y - w / 2, x + w / 2, y + w / 2], fill=col + (255,))
halo = arc.filter(ImageFilter.GaussianBlur(N * 0.02))
halo = Image.fromarray((np.array(halo) * np.array([1, 1, 1, 0.75])).astype(np.uint8), "RGBA")
base = Image.alpha_composite(base, halo)
base = Image.alpha_composite(base, arc)

OUT.parent.mkdir(parents=True, exist_ok=True)
base.convert("RGB").resize((S, S), Image.LANCZOS).save(OUT)
print(f"wrote {OUT}")


# --- Launch mark -----------------------------------------------------------
# The ring alone on a transparent background, for the iOS launch screen
# (ios/Runner/Assets.xcassets/LaunchImage.imageset). Base size 140pt.
def launch_mark(size_pt, scale):
    n = size_pt * scale * SS
    img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    cc = n / 2
    rr = n * 0.42
    rdisc = rr * 0.66
    yy2, xx2 = np.mgrid[0:n, 0:n].astype(np.float32)
    dd = np.sqrt((xx2 - cc) ** 2 + (yy2 - cc) ** 2) / rdisc
    tt2 = np.clip(dd, 0, 1)[..., None]
    col = np.array(DISC_IN, np.float32) * (1 - tt2) + np.array(DISC_OUT, np.float32) * tt2
    disc_img = Image.fromarray(np.dstack([np.clip(col, 0, 255).astype(np.uint8), (dd <= 1).astype(np.uint8) * 255]), "RGBA")
    glow_img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    ImageDraw.Draw(glow_img).ellipse([cc - rr * 0.9, cc - rr * 0.9, cc + rr * 0.9, cc + rr * 0.9], fill=TEAL + (90,))
    img = Image.alpha_composite(img, glow_img.filter(ImageFilter.GaussianBlur(n * 0.08)))
    img = Image.alpha_composite(img, disc_img)
    lines_img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    ld2 = ImageDraw.Draw(lines_img)
    ld2.ellipse([cc - rdisc, cc - rdisc, cc + rdisc, cc + rdisc], outline=(255, 255, 255, 28), width=max(1, int(n * 0.003)))
    ld2.ellipse([cc - rr, cc - rr, cc + rr, cc + rr], outline=(255, 255, 255, 30), width=max(1, int(n * 0.006)))
    img = Image.alpha_composite(img, lines_img)
    arc_img = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    ad2 = ImageDraw.Draw(arc_img)
    w2 = max(2, int(n * 0.022))
    for i in range(steps):
        a0 = start + sweep * i / steps
        a1 = start + sweep * (i + 1) / steps + 0.6
        k = i / steps
        col2 = tuple(int(MINT[j] * (1 - k) + TEAL[j] * k) for j in range(3))
        ad2.arc([cc - rr, cc - rr, cc + rr, cc + rr], a0, a1, fill=col2 + (255,), width=w2)
    for ang, col2 in ((start, MINT), (start + sweep, TEAL)):
        x = cc + rr * math.cos(math.radians(ang))
        y = cc + rr * math.sin(math.radians(ang))
        ad2.ellipse([x - w2 / 2, y - w2 / 2, x + w2 / 2, y + w2 / 2], fill=col2 + (255,))
    halo2 = arc_img.filter(ImageFilter.GaussianBlur(n * 0.02))
    halo2 = Image.fromarray((np.array(halo2) * np.array([1, 1, 1, 0.75])).astype(np.uint8), "RGBA")
    img = Image.alpha_composite(img, halo2)
    img = Image.alpha_composite(img, arc_img)
    return img.resize((size_pt * scale, size_pt * scale), Image.LANCZOS)


LAUNCH = Path(__file__).resolve().parent.parent / "ios" / "Runner" / "Assets.xcassets" / "LaunchImage.imageset"
for scale, suffix in ((1, ""), (2, "@2x"), (3, "@3x")):
    path = LAUNCH / f"LaunchImage{suffix}.png"
    launch_mark(140, scale).save(path)
    print(f"wrote {path}")
