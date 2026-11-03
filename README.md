# v_utils

Shared settings and presets for Typst projects.

## Installation

This package is installed locally (not published to Typst Universe).

```sh
mkdir -p ~/.local/share/typst/packages/local/v_utils/
rm -rf ~/.local/share/typst/packages/local/v_utils/0.1.0
git clone https://github.com/valeratrades/typ_utils.git ~/.local/share/typst/packages/local/v_utils/0.1.0 # atm typst requires version provision when importing a package, so we always install as 0.1.0, irregardless of the actual version. 
```

### Add to your project

In your project's `typst.toml`:

```toml
[dependencies]
v_utils = { version = "0.1.0", registry = "local" }
```

## Usage

Import the library in your Typst documents:

```typst
#import("@local/v_utils:0.1.0"): *; #show: prelude
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
