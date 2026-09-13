#!/usr/bin/env python3
"""Composes App Store screenshots (6.9-inch, 1320x2868) from the raw captures
the integration test writes to build/screenshots/.

    flutter drive --driver=test_driver/integration_test.dart \
        --target=integration_test/screens_test.dart -d "iPhone 17 Pro Max"
    python3 tool/compose_screenshots.py

Output: fastlane/screenshots/en-GB/iphone69_NN_<name>.png
"""
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "build" / "screenshots"
OUT = ROOT / "fastlane" / "screenshots" / "en-GB"
FONTS = ROOT / "assets" / "fonts"
W, H = 1320, 2868

SHOTS = [
    ("home", "Pay once.\nBreathe forever.", "No subscription. No account. Every technique included."),
    ("session", "A guide you can\nfollow without thinking.", "Breathe in, hold, breathe out — always in plain words."),
    ("session_paused", "Life happens.\nPause. Resume.", "Leave the app and your session waits for you."),
    ("settings", "Nothing collected.\nNothing to protect.", "No analytics, no cloud, no tracking. Works offline."),
]


def hexc(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


BG1, BG2 = hexc("0F1726"), hexc("090D14")
TEAL, IND, TEXT, MUTED = hexc("7FD1C4"), hexc("5B6CFF"), hexc("E8ECF1"), hexc("8A94A3")


def background(index):
    yy, xx = np.mgrid[0:H, 0:W].astype(np.float32)
    t = (yy / H)[..., None]
    img = (np.array(BG1) * (1 - t) + np.array(BG2) * t).astype(np.float32)
    # Alternate bloom placement so the set doesn't look stamped out.
    blooms = [
        ((W * 0.95, H * 0.05), W * 0.9, TEAL, 0.30),
        ((W * 0.0, H * 0.55), W * 0.9, IND, 0.26),
    ] if index % 2 == 0 else [
        ((W * 0.05, H * 0.05), W * 0.9, IND, 0.24),
        ((W * 1.0, H * 0.6), W * 0.9, TEAL, 0.28),
    ]
    for (cx, cy), r, col, a in blooms:
        d = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2) / r
        m = np.clip(1 - d, 0, 1) ** 2 * a
        img = img * (1 - m[..., None]) + np.array(col, np.float32) * m[..., None]
    return Image.fromarray(np.clip(img, 0, 255).astype(np.uint8), "RGB").convert("RGBA")


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.width - 1, img.height - 1], radius=radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def compose(index, name, headline, sub):
    src = SRC / f"{name}.png"
    if not src.exists():
        raise SystemExit(f"missing {src} — run the integration test first")
    canvas = background(index)
    draw = ImageDraw.Draw(canvas)
    head_font = ImageFont.truetype(str(FONTS / "Geist-Medium.ttf"), 104)
    sub_font = ImageFont.truetype(str(FONTS / "Geist-Regular.ttf"), 44)

    y = 200
    for line in headline.split("\n"):
        draw.text((100, y), line, font=head_font, fill=TEXT)
        y += 118
    y += 24
    draw.text((100, y), sub, font=sub_font, fill=MUTED)

    shot = Image.open(src).convert("RGB")
    scale = 0.80
    shot = shot.resize((int(W * scale), int(H * scale)), Image.LANCZOS)
    shot = rounded(shot, 110)
    x = (W - shot.width) // 2
    top = 640

    # Soft glow under the device so it lifts off the background.
    glow = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(glow).rounded_rectangle([x - 6, top - 6, x + shot.width + 6, top + shot.height + 6], radius=116, fill=TEAL + (70,))
    canvas = Image.alpha_composite(canvas, glow.filter(ImageFilter.GaussianBlur(60)))
    # Hairline bezel.
    frame = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(frame).rounded_rectangle([x - 3, top - 3, x + shot.width + 3, top + shot.height + 3], radius=113, outline=(255, 255, 255, 40), width=3)
    canvas = Image.alpha_composite(canvas, frame)
    canvas.alpha_composite(shot, (x, top))

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"iphone69_{index + 1:02d}_{name}.png"
    canvas.convert("RGB").save(path)
    print(f"wrote {path}")


if __name__ == "__main__":
    for i, (name, headline, sub) in enumerate(SHOTS):
        compose(i, name, headline, sub)
