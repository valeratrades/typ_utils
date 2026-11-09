/// Markdown-style sugar: `> ` blockquotes, `---` section rules, `[label](url)` links, `![alt](path)` images, visible link styling.
/// Package code can't resolve paths relative to the caller, so images need `#show: md-parity-prelude.with(img: p => image(p))`
#let md-parity-prelude(doc, img: none) = {
  // `---` is already an em-dash shorthand by the time show rules run; alone in a paragraph it's a section split
  show regex("^—$"): _ => block(above: 1.4em, below: 1.4em, line(length: 100%, stroke: 0.5pt + luma(180)))

  let quote-block(body) = block(inset: (left: 1em), stroke: (left: 2pt + gray), text(fill: gray.darken(30%), body))
  // source newlines are lost by now (indistinguishable from spaces), so inside a quote any space-preceded `>` starts a new line
  show par: it => {
    let space = [ ].func()
    let ch = if it.body.func() == [].func() { it.body.children } else { (it.body,) }
    // `> $x$` splits into `>`, space, equation, so a bare `>` must also open a quote
    let head = ch.first()
    if head.func() != text or not (head.text.starts-with("> ") or (head.text == ">" and ch.len() > 1)) { return it }
    let lines = ()
    let prev-space = true
    for c in ch {
      if prev-space and c.func() == text and (c.text == ">" or c.text.starts-with("> ")) {
        lines.push(if c.text == ">" { () } else { (text(c.text.slice(2)),) })
      } else if not (c.func() == space and lines.last().len() == 0) {
        lines.at(-1).push(c)
      }
      prev-space = c.func() == space
    }
    // markdown semantics: `- ` lines group into a list, consecutive plain lines merge into one paragraph
    let out = ()
    let items = ()
    let para = ()
    for l in lines {
      let head = l.at(0, default: none)
      if head != none and head.func() == text and (head.text == "-" or head.text.starts-with("- ")) {
        if para.len() > 0 { out.push(para.join([ ])); para = () }
        let rest = if head.text == "-" { l.slice(1) } else { (text(head.text.slice(2)),) + l.slice(1) }
        while rest.len() > 0 and rest.first().func() == space { rest = rest.slice(1) }
        items.push(rest.join())
      } else {
        if items.len() > 0 { out.push(list(..items)); items = () }
        para.push(l.join())
      }
    }
    if para.len() > 0 { out.push(para.join([ ])) }
    if items.len() > 0 { out.push(list(..items)) }
    quote-block(out.join(parbreak()))
  }

  show link: set text(fill: blue.darken(20%))
  show link: underline

  // math mode drops `super`, so the raise is explicit; the inner rule strips the one text mode adds
  set footnote(numbering: n => text(size: 0.7em, baseline: -0.35em, fill: blue.darken(20%), str(n)))
  show footnote: it => { show super: s => s.body; it }

  show regex("!\\[[^\\]]*\\]\\([^)]+\\)"): it => {
    let path = it.text.match(regex("\\(([^)]+)\\)$")).captures.first()
    if img == none { panic("md: pass `img: p => image(p)` to render " + it.text) }
    img(path)
  }
  // typst autolinks the bare URL (and parses `@ref`), splitting `[label](dest)` into sibling nodes no show rule sees together,
  // so the stash rule stores the label, the link/ref grafts it, and the trailing paren gets eaten.
  // Every update is unconditional: one conditioned on a `get()` reads the previous layout iteration, and leftovers then graft onto unrelated refs.
  let md = state("md", (lbl: none, eat: false))
  show regex("\\[[^\\]]+\\]\\("): it => md.update((lbl: it.text.slice(1, -2), eat: false))
  // autolinks only (body text == dest); grafted links have body == label, so they pass untouched
  show link: it => if it.body.func() != text or it.body.text != str(it.dest) { it } else {
    context { let l = md.get().lbl; if l == none { it } else { link(it.dest, l) } } + md.update(s => (lbl: none, eat: s.lbl != none))
  }
  show ref: it => context { let l = md.get().lbl; if l == none { it } else { link(it.target, l) } } + md.update(s => (lbl: none, eat: s.lbl != none))
  show regex("^\\)"): it => context { if md.get().eat { none } else { it } } + md.update(s => (..s, eat: false))

  // non-URL dests aren't autolinked, so the whole [label](dest) survives as one
  // text node; defined after the stash rule to win the same-position tie
  show regex("\\[[^\\]]+\\]\\([^)]+\\)"): it => {
    let m = it.text.match(regex("\\[([^\\]]+)\\]\\(([^)]+)\\)"))
    link(m.captures.at(1), m.captures.at(0))
  }

  doc
}
