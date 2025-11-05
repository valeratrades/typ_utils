# v_utils

Shared settings and presets for Typst projects.

## Usage

Import the library directly in your Typst documents. It's recommended to use the `@preview` namespace with a specific version or `latest`:

```typst
#import "@preview/v_utils:0.1.0": *

#show: math_notes

// Your document content here
```

Or use the latest version automatically:

```typst
#import "@preview/v_utils": *

#show: math_notes
```

This allows you to update to the latest standards across all your projects by simply bumping the version number.

## Available Presets

### `test()`
Basic test preset demonstrating the structure.

### `math_notes()`
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
```
