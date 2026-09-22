#!/usr/bin/env bash
# 构建《扩圈》/ Expanding the Circle：EPUB / HTML / 印刷级 PDF（含封面）
#
# 用法：
#   ./build/build.sh                # 中文版：EPUB + HTML
#   ./build/build.sh pdf            # 中文版：额外生成印刷级 PDF
#   ./build/build.sh en             # 英文版：EPUB + HTML
#   ./build/build.sh en pdf         # 英文版：额外生成 PDF
#   ./build/build.sh all pdf        # 中英双语：全部生成
#
# 依赖：pandoc、python3、inkscape；生成 PDF 还需 chromium（或 google-chrome）与 pdfunite。
# 若 pandoc 缺少数据文件，可用 PANDOC_DATA_DIR=/path/to/pandoc/data 指定。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/build"
CHROME="${CHROME:-$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)}"

LANG_SEL=zh
WANT_PDF=0
for a in "$@"; do
  case "$a" in
    zh|en|all) LANG_SEL="$a" ;;
    pdf|--pdf) WANT_PDF=1 ;;
    *) echo "未知参数：$a" >&2; exit 2 ;;
  esac
done

PANDOC_OPTS=()
if [[ -n "${PANDOC_DATA_DIR:-}" ]]; then
  PANDOC_OPTS+=(--data-dir="$PANDOC_DATA_DIR")
fi

echo "==> 生成封面"
python3 "$OUT/make_cover.py"

rasterize_cover() {
  local base="$1"
  inkscape "$OUT/$base.svg" --export-type=png \
    --export-filename="$OUT/$base.png" --export-width=1500 >/dev/null 2>&1
  inkscape "$OUT/$base.svg" --export-type=pdf \
    --export-filename="$OUT/$base.pdf" >/dev/null 2>&1
}

build_edition() {
  local lang="$1" srcdir meta name cover
  if [[ "$lang" == "zh" ]]; then
    srcdir="$ROOT/book"; meta="$OUT/metadata.yaml"; name="扩圈"; cover="cover-zh"
  else
    srcdir="$ROOT/en"; meta="$OUT/metadata-en.yaml"; name="Expanding-the-Circle"; cover="cover-en"
  fi

  mapfile -t FILES < <(find "$srcdir" -maxdepth 1 -name '*.md' ! -name 'GLOSSARY.md' | sort)
  if [[ ${#FILES[@]} -eq 0 ]]; then echo "找不到 $srcdir 下的章节" >&2; exit 1; fi

  rasterize_cover "$cover"

  echo "==> [$lang] EPUB"
  pandoc "${FILES[@]}" "${PANDOC_OPTS[@]}" \
    --metadata-file="$meta" \
    --toc --toc-depth=2 \
    --epub-cover-image="$OUT/$cover.png" \
    --from=markdown+pipe_tables \
    -o "$OUT/$name.epub"

  echo "==> [$lang] HTML"
  pandoc "${FILES[@]}" "${PANDOC_OPTS[@]}" \
    --metadata-file="$meta" \
    --toc --toc-depth=2 \
    --css="$OUT/style.css" \
    --standalone --embed-resources \
    --from=markdown+pipe_tables \
    -o "$OUT/$name.html"

  if [[ "$WANT_PDF" == "1" ]]; then
    if [[ -z "$CHROME" ]]; then echo "找不到 chromium/google-chrome，跳过 PDF" >&2; return; fi
    echo "==> [$lang] PDF（chromium 排版）"
    "$CHROME" --headless=new --no-sandbox --disable-gpu \
      --no-pdf-header-footer \
      --print-to-pdf="$OUT/$name.body.pdf" \
      "file://$OUT/$name.html" >/dev/null 2>&1
    if command -v pdfunite >/dev/null 2>&1 && [[ -f "$OUT/$cover.pdf" ]]; then
      pdfunite "$OUT/$cover.pdf" "$OUT/$name.body.pdf" "$OUT/$name.pdf"
      rm -f "$OUT/$name.body.pdf"
    else
      mv "$OUT/$name.body.pdf" "$OUT/$name.pdf"
    fi
  fi
}

case "$LANG_SEL" in
  zh) build_edition zh ;;
  en) build_edition en ;;
  all) build_edition zh; build_edition en ;;
esac

echo "==> 完成，输出在 $OUT"
ls -1 "$OUT"/*.epub "$OUT"/*.html "$OUT"/*.pdf 2>/dev/null || true
