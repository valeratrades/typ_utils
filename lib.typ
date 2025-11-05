/// Math notes preset - optimized settings for mathematical note-taking
#let math_notes_prelude(doc) = [
  #set page(margin: (y: 0cm))
  #show math.equation: set block(breakable: true)
  #set text(fallback: false)
  #doc
]

