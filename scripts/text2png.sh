#!/bin/sh
# text2png — render a text/code file as a small PNG for copying to a
# reMarkable notebook. Can apply syntax highlighting with pygmentize.
set -eu

help() { cat <<'EOF'
text2png — render a text/code file as a small PNG for reMarkable

Usage:
  text2png [-l LANG] [-s SIZE] [-f FONT] INPUT [OUTPUT.png]   default output: INPUT.png

Options:
  -l LANG      highlight as language LANG (e.g. -l c, -l fortran, -l python).
               Default: guessed from the file extension, so foo.f90 and
               foo.c highlight automatically with no flags needed.
               List available languages:  pygmentize -L lexers
  -s SIZE      font size in pixels (default 22; or set SIZE env var)
  -f FONT      use this font file (default: Maple Mono NF Medium; error if missing)

Output is white-background PNG auto-sized to fit the text.

Dependencies:
  imagemagick, pygments (with pillow)

If highlighting is unavailable uses plain grayscale.
EOF
}

die() { echo "text2png: $*" >&2; exit 1; }

lex=
sz=
font=$HOME/Library/Fonts/MapleMono-NF-Medium.ttf   # default; override with -f
while [ $# -gt 0 ]; do
    case "$1" in
        -l|--lang) lex=$2; shift 2;;
        -s|--size) sz=$2; shift 2;;
        -f|--font) font=$2; shift 2;;
        -h|--help) help; exit 0;;
        --) shift; break;;
        -*) die "unknown option: $1 (see --help)";;
        *) break;;
    esac
done
[ $# -ge 1 ] || { help >&2; exit 1; }
[ $# -le 2 ] || die "too many arguments"

in=$1
out=${2:-$in.png}
sz=${sz:-${SIZE:-22}}

# Some sanity safeguards
[ -r "$in" ] || die "cannot read: $in"
[ "$in" != "$out" ] || die "output would overwrite input"
case $sz in
    ''|*[!0-9]*) die "size must be a number: $sz";;
esac
[ -f "$font" ] || die "font not found: $font (override with -f FONT)"
echo "using font: $font" >&2

# Try a highlighted render to png using pygmentize.
highlighted=false
if command -v pygmentize >/dev/null 2>&1; then
    opts="font_name=$font,font_size=$sz,line_numbers=false"
    if [ -n "$lex" ]; then
        pygmentize -l "$lex" -f png -o "$out" -O "$opts" -- "$in" && highlighted=true
    else
        pygmentize -f png -o "$out" -O "$opts" -- "$in" && highlighted=true
    fi
    $highlighted || echo "highlighting failed; using plain render" >&2
fi

# If pygmentize absent or failed, fall back to magick with label to convert text to png.
if ! $highlighted; then
    # ImageMagick 7 ships `magick`; IM 6 (common on Linux distros) only `convert`
    if command -v magick >/dev/null 2>&1; then
        magick=magick
    elif command -v convert >/dev/null 2>&1; then
        magick=convert
    else
        die "ImageMagick not found (needed for plain rendering)"
    fi

    # grayscale + strip metadata + max PNG compression = tiny file
    "$magick" -background white -fill black \
        -font "$font" \
        -pointsize "$sz" \
        label:@"$in" \
        -bordercolor white -border 20 \
        -colorspace Gray -strip -quality 95 \
        "$out"
fi

echo "$out ($(wc -c < "$out" | tr -d ' ') bytes)"
