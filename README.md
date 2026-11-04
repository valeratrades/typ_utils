# v_utils

Shared settings and presets for Typst projects.

## Installation

This package is installed locally (not published to Typst Universe).

Each tag is installed as a frozen snapshot (typst rejects a package whose `typst.toml` version differs from the imported one):

```sh
V=0.2.0; D=~/.local/share/typst/packages/local/v_utils/$V
mkdir -p $D && git archive v$V | tar -x -C $D
```

## Usage

```typst
#import "@local/v_utils:0.2.0": *; #show: prelude
```

## Available Presets

### `prelude(doc, img: none)` - `lib.typ`
Everything below, plus auto-generated hierarchical heading labels (`= Ex I` / `== 1.` / `=== a)` → `@ex-i.1.a`) and a trailing blank page.

### `math_notes_prelude(doc)` - `math.typ`
Math shorthands, breakable equations, multi-line inline math on its first row's baseline. Custom math functions live in the same file.

### `md_parity_prelude(doc, img: none)` - `md.typ`
Markdown-style sugar: `> ` quotes, `---` rules, `[label](url)` links, `![alt](path)` images (needs `img: p => image(p)`).

## Scripts

### `scripts/list_titles.py FILE.typ...`
Show rules can't tell a newline from a space, so this rewrites source in place: a list item's first line gets a trailing `\` when indented content follows it, keeping the title on its own line.

## Adding New Presets

Edit `lib.typ` and add new functions following the existing pattern:

```typst
#let your_preset() = {
  // Your settings here
}
