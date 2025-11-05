# v_utils

Shared settings and presets for Typst projects.

## Installation

This package is installed locally (not published to Typst Universe).

```sh
mkdir -p ~/.local/share/typst/packages/local/v_utils/
git clone https://github.com/valeratrades/typ_utils.git ~/.local/share/typst/packages/local/v_utils/0.1.0
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
#import "@local/v_utils:0.1.0": *

#show: math_notes_prelude
```

## Available Presets

### `math_notes_prelude(doc)`
Optimized settings for mathematical note-taking:
- Zero vertical margins
- Breakable math equations
- Strict text fallback disabled

## Adding New Presets

Edit `lib.typ` and add new functions following the existing pattern:

```typst
#let your_preset() = {
  // Your settings here
}
