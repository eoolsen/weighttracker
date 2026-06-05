#!/usr/bin/env python3
"""Generate a 1024x1024 App Store icon for WeightTracker."""

from PIL import Image, ImageDraw
import os

SIZE = 1024
OUT = os.path.join(
    os.path.dirname(__file__),
    "../WeightTracker/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
)

# Work in RGBA for alpha compositing, flatten to RGB at save
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 255))
draw = ImageDraw.Draw(img)

# Gradient background — top blue to bottom deep blue
bg_top = (31, 119, 229)
bg_bot = (17, 73, 180)
for y in range(SIZE):
    t = y / SIZE
    r = int(bg_top[0] + (bg_bot[0] - bg_top[0]) * t)
    g = int(bg_top[1] + (bg_bot[1] - bg_top[1]) * t)
    b = int(bg_top[2] + (bg_bot[2] - bg_top[2]) * t)
    draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

# Chart area margins
mx, my = 140, 190
chart_w = SIZE - mx * 2
chart_h = SIZE - my * 2 - 60

# Data points — downward trend with natural variation
points_norm = [
    (0.00, 0.10),
    (0.13, 0.17),
    (0.25, 0.08),
    (0.38, 0.30),
    (0.50, 0.26),
    (0.63, 0.44),
    (0.75, 0.54),
    (0.88, 0.63),
    (1.00, 0.76),
]

def pt(nx, ny):
    return (mx + nx * chart_w, my + ny * chart_h)

points = [pt(nx, ny) for nx, ny in points_norm]

# Subtle fill under the line — draw on separate layer for real alpha
fill_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
fill_draw = ImageDraw.Draw(fill_layer)
fill_poly = [pt(0.00, 1.0)] + points + [pt(1.00, 1.0)]
fill_draw.polygon(fill_poly, fill=(180, 210, 255, 45))
img = Image.alpha_composite(img, fill_layer)
draw = ImageDraw.Draw(img)

# Subtle grid lines
for i in range(1, 4):
    gy = my + (chart_h * i // 4)
    grid_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    grid_draw = ImageDraw.Draw(grid_layer)
    grid_draw.line([(mx, gy), (mx + chart_w, gy)], fill=(255, 255, 255, 38), width=3)
    img = Image.alpha_composite(img, grid_layer)

draw = ImageDraw.Draw(img)

# Trend line
for i in range(len(points) - 1):
    draw.line([points[i], points[i + 1]], fill=(255, 255, 255, 255), width=20)

# Dots at each data point
for p in points:
    r = 15
    draw.ellipse([p[0]-r, p[1]-r, p[0]+r, p[1]+r], fill=(255, 255, 255, 255))

# Larger accent dot at last (lowest) point
lp = points[-1]
ar = 30
draw.ellipse([lp[0]-ar, lp[1]-ar, lp[0]+ar, lp[1]+ar],
             fill=(255, 255, 255, 255), outline=(160, 210, 255, 255), width=7)

# Flatten to RGB — App Store requires no alpha channel
final = Image.new("RGB", (SIZE, SIZE), (0, 0, 0))
final.paste(img, mask=img.split()[3])

os.makedirs(os.path.dirname(OUT), exist_ok=True)
final.save(OUT, "PNG")
print(f"Saved: {OUT}")
