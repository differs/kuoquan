#!/usr/bin/env python3
"""生成《扩圈》封面 SVG（中/英两版）。"""
import pathlib

BG = "#0f141b"
INK = "#f3f0e8"
MUTED = "#9fb0c3"
ACCENT = "#c8a24a"
CIRCLE = "#3d5670"


def cover(lang: str) -> str:
    if lang == "zh":
        title_lines = ["扩", "圈"]
        title_size = 260
        big = False
    else:
        title_lines = ["EXPANDING", "THE CIRCLE"]
        title_size = 96
        big = True

    parts = []
    parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="1200" height="1800" '
        f'viewBox="0 0 1200 1800">'
    )
    parts.append(f'<rect width="1200" height="1800" fill="{BG}"/>')

    # 同心圆：扩圈的意象
    for r, op in ((440, 0.20), (360, 0.28), (280, 0.4)):
        parts.append(
            f'<circle cx="600" cy="640" r="{r}" fill="none" '
            f'stroke="{CIRCLE}" stroke-width="2" opacity="{op}"/>'
        )

    # 主标题
    if big:
        y0 = 600
        for i, line in enumerate(title_lines):
            parts.append(
                f'<text x="600" y="{y0 + i * (title_size + 34)}" fill="{INK}" '
                f'font-family="Noto Serif CJK SC, Noto Serif, serif" '
                f'font-size="{title_size}" font-weight="700" '
                f'text-anchor="middle" letter-spacing="6">{line}</text>'
            )
    else:
        # 中文竖排两字横置
        parts.append(
            f'<text x="600" y="760" fill="{INK}" '
            f'font-family="Noto Serif CJK SC, serif" font-size="{title_size}" '
            f'font-weight="700" text-anchor="middle" '
            f'letter-spacing="30">扩圈</text>'
        )

    # 英文书名
    en_title = "EXPANDING THE CIRCLE"
    en_y = 940 if not big else 760
    parts.append(
        f'<text x="600" y="{en_y}" fill="{ACCENT}" '
        f'font-family="Noto Sans CJK SC, sans-serif" font-size="40" '
        f'font-weight="600" text-anchor="middle" letter-spacing="14">'
        f'{en_title}</text>'
    )

    # 分隔线
    parts.append(
        f'<line x1="440" y1="{en_y + 46}" x2="760" y2="{en_y + 46}" '
        f'stroke="{ACCENT}" stroke-width="1.5" opacity="0.7"/>'
    )

    # 副标题
    sub_zh = "AI 时代的长秩序原理"
    sub_en = "The Principles of Durable Order in the Age of AI"
    parts.append(
        f'<text x="600" y="{en_y + 120}" fill="{INK}" '
        f'font-family="Noto Serif CJK SC, serif" font-size="34" '
        f'opacity="0.92" text-anchor="middle">{sub_zh}</text>'
    )
    parts.append(
        f'<text x="600" y="{en_y + 174}" fill="{MUTED}" '
        f'font-family="Noto Serif CJK SC, serif" font-size="24" '
        f'opacity="0.85" text-anchor="middle">{sub_en}</text>'
    )

    # 底部
    parts.append(
        f'<line x1="480" y1="1560" x2="720" y2="1560" '
        f'stroke="{CIRCLE}" stroke-width="1" opacity="0.5"/>'
    )
    parts.append(
        f'<text x="600" y="1630" fill="{MUTED}" '
        f'font-family="Noto Sans CJK SC, sans-serif" font-size="26" '
        f'letter-spacing="8" text-anchor="middle">differs</text>'
    )
    parts.append(
        f'<text x="600" y="1685" fill="{MUTED}" opacity="0.7" '
        f'font-family="Noto Sans CJK SC, sans-serif" font-size="18" '
        f'letter-spacing="4" text-anchor="middle">CC BY-SA 4.0</text>'
    )

    parts.append("</svg>")
    return "\n".join(parts)


out = pathlib.Path(__file__).resolve().parent
(out / "cover-zh.svg").write_text(cover("zh"), encoding="utf-8")
(out / "cover-en.svg").write_text(cover("en"), encoding="utf-8")
print("wrote build/cover-zh.svg, build/cover-en.svg")
