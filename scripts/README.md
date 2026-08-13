# Scripts

Small utility scripts for working with the reMarkable tablet.
Each script is a single file documented in-file and below.

## Install

Install any script by symlinking it into a directory on `PATH` and dropping the `.sh`
extension:

```sh
mkdir -p ~/.local/bin
ln -sf "$(pwd)/SCRIPT.sh" ~/.local/bin/SCRIPT
```


## text2png

Render a text/code file to PNG for dropping into reMarkable notebooks as a code snippet.
Syntax highlighting via pygments falling back to magick grayscale.

Requires at least one of the following to be installed:

- `pygmentize` + Pillow
- ImageMagick (`magick` or `convert` both work)

### Usage

```
text2png [-l LANG] [-s SIZE] [-f FONT] INPUT [OUTPUT.png]
```

| Option | Meaning | Default |
|---|---|---|
| `-l LANG` | language for highlighting. List all: `pygmentize -L lexers` | guessed from file extension |
| `-s SIZE` | font size in pixels | `22` |
| `-f FONT` | font file path | Maple Mono NF Medium |
| `OUTPUT.png` | output name | `INPUT` + `.png` |

Examples:

```sh
text2png snippet.py            # → snippet.py.png, auto-highlighted
text2png -l c notes.txt        # force C highlighting for an extensionless/.txt file
text2png -s 30 big.py          # larger text (renders a larger canvas)
```

### Notes

- To change pygments colorscheme add e.g. `style=tango` to `-O` options.
- Default font file is hardcoded as Maple Mono.
  Override with `-f FONT` or replace in file.
