#!/usr/bin/env bash
# 构建《扩圈》多格式版本
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOK="$ROOT/book"
OUT="$ROOT/build"
META="$OUT/metadata.yaml"

# 若 pandoc 的数据文件不在默认位置，可用 PANDOC_DATA_DIR 指定。
PANDOC_OPTS=()
if [[ -n "${PANDOC_DATA_DIR:-}" ]]; then
  PANDOC_OPTS+=(--data-dir="$PANDOC_DATA_DIR")
fi

FILES=(
  "$BOOK/00-preface.md"
  "$BOOK/01-circle.md"
  "$BOOK/02-credibility.md"
  "$BOOK/03-reciprocity.md"
  "$BOOK/04-rules.md"
  "$BOOK/05-moral-superiority.md"
  "$BOOK/06-stationary-bandit.md"
  "$BOOK/07-purging.md"
  "$BOOK/08-radius-cost.md"
  "$BOOK/09-inclusion.md"
  "$BOOK/10-dividend.md"
  "$BOOK/11-ai-frontier.md"
  "$BOOK/12-self-governance.md"
  "$BOOK/13-ownership.md"
  "$BOOK/99-epilogue.md"
)

echo "==> 构建 EPUB"
pandoc "${FILES[@]}" \
  "${PANDOC_OPTS[@]}" \
  --metadata-file="$META" \
  --toc --toc-depth=2 \
  --from=markdown+pipe_tables \
  -o "$OUT/扩圈.epub"

echo "==> 构建 HTML（单文件）"
pandoc "${FILES[@]}" \
  "${PANDOC_OPTS[@]}" \
  --metadata-file="$META" \
  --toc --toc-depth=2 \
  --standalone --embed-resources \
  --from=markdown+pipe_tables \
  -o "$OUT/扩圈.html"

if [[ "${1:-}" == "pdf" ]]; then
  echo "==> 构建 PDF（需要 xelatex + 中文字体）"
  pandoc "${FILES[@]}" \
    "${PANDOC_OPTS[@]}" \
    --metadata-file="$META" \
    --toc --toc-depth=2 \
    --pdf-engine=xelatex \
    -V CJKmainfont="Noto Sans CJK SC" \
    -V geometry:margin=2.5cm \
    --from=markdown+pipe_tables \
    -o "$OUT/扩圈.pdf"
fi

echo "==> 完成，输出在 $OUT"
