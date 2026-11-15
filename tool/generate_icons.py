#!/usr/bin/env python3
"""Genera el ícono de GameTracker para Android, iOS y web.

Uso (desde la raíz del proyecto):  python3 tool/generate_icons.py
Requiere Pillow (pip install pillow).

Diseño original: control de videojuego sobre degradado azul oscuro, con los
botones en los colores de las categorías de la app.
"""
import json
import os
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SS = 3  # supersampling para bordes suaves

# Colores de lib/core/constants/app_colors.dart
BG_TOP = (0x1E, 0x35, 0x70)
BG_BOTTOM = (0x08, 0x0C, 0x18)
PRIMARY = (0x4A, 0x7D, 0xFF)
BODY_TOP = (0xF4, 0xF7, 0xFF)
BODY_BOTTOM = (0xBF, 0xCC, 0xF0)
DARK = (0x13, 0x1A, 0x2E)
PLAYING = (0xF5, 0x9E, 0x0B)
COMPLETED = (0x10, 0xB9, 0x81)
PENDING = (0x8B, 0x5C, 0xF6)


def vgrad(n, top, bottom):
    col = Image.new("RGB", (1, n))
    for y in range(n):
        t = y / max(1, n - 1)
        col.putpixel((0, y), tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)))
    return col.resize((n, n))


def bg_layer(n):
    """Fondo opaco: degradado + brillo azul detrás del control."""
    bg = vgrad(n, BG_TOP, BG_BOTTOM).convert("RGBA")
    glow = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    r = int(n * 0.30)
    c = n // 2
    d.ellipse([c - r, c - r, c + r, c + r], fill=PRIMARY + (110,))
    glow = glow.filter(ImageFilter.GaussianBlur(n * 0.10))
    return Image.alpha_composite(bg, glow)


def _shapes(n, gw):
    """Devuelve (máscara del cuerpo, lista de piezas de detalle) en px."""
    g = n * gw  # ancho del control
    # el bbox del control va de y=-0.26 a y=+0.38 (en unidades de g): centrarlo
    cx, cy = n / 2, n / 2 - 0.06 * g

    def P(x, y):
        return cx + x * g, cy + y * g

    body = Image.new("L", (n, n), 0)
    d = ImageDraw.Draw(body)
    x0, y0 = P(-0.5, -0.26)
    x1, y1 = P(0.5, 0.14)
    d.rounded_rectangle([x0, y0, x1, y1], radius=0.2 * g, fill=255)
    for gx in (-0.31, 0.31):
        px, py = P(gx, 0.18)
        r = 0.2 * g
        d.ellipse([px - r, py - r, px + r, py + r], fill=255)

    details = []
    # D-pad
    px, py = P(-0.26, -0.06)
    arm, th = 0.115 * g, 0.038 * g
    details.append(("rect", [px - arm, py - th, px + arm, py + th], DARK))
    details.append(("rect", [px - th, py - arm, px + th, py + arm], DARK))
    # Botones (colores de las categorías)
    bx, by = P(0.26, -0.06)
    off, r = 0.085 * g, 0.052 * g
    for dx, dy, color in ((0, -off, PLAYING), (off, 0, COMPLETED),
                          (-off, 0, PENDING), (0, off, PRIMARY)):
        details.append(("circle", [bx + dx - r, by + dy - r, bx + dx + r, by + dy + r], color))
    # Select / Start
    for sx in (-0.075, 0.075):
        qx, qy = P(sx, 0.045)
        details.append(("rect", [qx - 0.04 * g, qy - 0.012 * g, qx + 0.04 * g, qy + 0.012 * g], DARK))
    return body, details


def glyph_layer(n, gw):
    """Control de videojuego sobre fondo transparente (con sombra suave)."""
    body, details = _shapes(n, gw)
    layer = Image.new("RGBA", (n, n), (0, 0, 0, 0))

    shadow = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    sh = Image.new("RGBA", (n, n), (0, 0, 0, 110))
    shadow.paste(sh, (0, int(n * 0.012)), body)
    shadow = shadow.filter(ImageFilter.GaussianBlur(n * 0.012))
    layer = Image.alpha_composite(layer, shadow)

    fill = vgrad(n, BODY_TOP, BODY_BOTTOM).convert("RGBA")
    fill.putalpha(body)
    layer = Image.alpha_composite(layer, fill)

    d = ImageDraw.Draw(layer)
    for kind, box, color in details:
        if kind == "rect":
            d.rounded_rectangle(box, radius=(box[3] - box[1]) / 2 if (box[3] - box[1]) < (box[2] - box[0]) / 4 else 0, fill=color)
        else:
            d.ellipse(box, fill=color)
    return layer


def monochrome_layer(n, gw):
    """Silueta blanca (ícono temático de Android 13+)."""
    body, details = _shapes(n, gw)
    mask = body.copy()
    d = ImageDraw.Draw(mask)
    for kind, box, _ in details:
        if kind == "rect":
            d.rectangle(box, fill=0)
        else:
            d.ellipse(box, fill=0)
    out = Image.new("RGBA", (n, n), (255, 255, 255, 0))
    out.putalpha(mask)
    return out


def icon_full(size, gw=0.62):
    """Ícono cuadrado a sangre (fondo + control)."""
    n = size * SS
    img = Image.alpha_composite(bg_layer(n), glyph_layer(n, gw))
    return img.resize((size, size), Image.LANCZOS)


def rounded(img, ratio=0.22):
    s = img.size[0]
    n = s * SS
    mask = Image.new("L", (n, n), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, n - 1, n - 1], radius=int(n * ratio), fill=255)
    mask = mask.resize((s, s), Image.LANCZOS)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def save(img, rel, rgb=False):
    path = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    (img.convert("RGB") if rgb else img).save(path, optimize=True)


def main():
    # ── Android ──
    res = "android/app/src/main/res"
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    layers = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
    for d, s in legacy.items():
        save(rounded(icon_full(s)), f"{res}/mipmap-{d}/ic_launcher.png")
    for d, s in layers.items():
        n = s * SS
        gw = 0.46  # dentro de la zona segura (círculo de 66/108)
        save(glyph_layer(n, gw).resize((s, s), Image.LANCZOS), f"{res}/mipmap-{d}/ic_launcher_foreground.png")
        save(bg_layer(n).resize((s, s), Image.LANCZOS), f"{res}/mipmap-{d}/ic_launcher_background.png", rgb=True)
        save(monochrome_layer(n, gw).resize((s, s), Image.LANCZOS), f"{res}/mipmap-{d}/ic_launcher_monochrome.png")
    xml = os.path.join(ROOT, res, "mipmap-anydpi-v26/ic_launcher.xml")
    os.makedirs(os.path.dirname(xml), exist_ok=True)
    with open(xml, "w") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '    <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>\n'
            '</adaptive-icon>\n'
        )

    # ── iOS (sin canal alfa, sin esquinas redondeadas: iOS las aplica) ──
    ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    with open(os.path.join(ROOT, ios, "Contents.json")) as f:
        contents = json.load(f)
    master = icon_full(1024)
    done = set()
    for item in contents["images"]:
        fn = item["filename"]
        if fn in done:
            continue
        done.add(fn)
        px = round(float(item["size"].split("x")[0]) * int(item["scale"].rstrip("x")))
        save(master.resize((px, px), Image.LANCZOS), f"{ios}/{fn}", rgb=True)

    # ── Web ──
    save(rounded(icon_full(192)), "web/icons/Icon-192.png")
    save(rounded(icon_full(512)), "web/icons/Icon-512.png")
    save(icon_full(192, gw=0.46), "web/icons/Icon-maskable-192.png", rgb=True)
    save(icon_full(512, gw=0.46), "web/icons/Icon-maskable-512.png", rgb=True)
    save(rounded(icon_full(32)).resize((16, 16), Image.LANCZOS), "web/favicon.png")
    print("Íconos generados.")


if __name__ == "__main__":
    main()
