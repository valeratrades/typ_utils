// v_utils - Shared settings and presets for Typst projects

/// Test preset - basic example to demonstrate the structure
#let test() = {
  set text(size: 12pt)
  set page(paper: "a4")
}

/// Math notes preset - optimized settings for mathematical note-taking
#let math_notes() = {
  set page(margin: (y: 0cm))
  show math.equation: set block(breakable: true)
  set text(fallback: false)
}
