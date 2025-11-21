/// Math notes preset - optimized settings for mathematical note-taking
#let math_notes_prelude(doc) = [
  #set page(margin: (y: 0cm))
  #show math.equation: set block(breakable: true)
  #set text(fallback: false)
  #doc

  // auto-gen headings
  //NB: with this, <include>s should be _*above*_ the line sourcing this prelude, - otherwise this will apply inside them too
  #show heading: it => {
    if it.level == 1 {
      let label-text = lower(it.body.text.replace(" ", ""))
      [#it #label(label-text)]
    } else {
      it
    }
  }
]

