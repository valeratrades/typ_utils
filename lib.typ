#import "@preview/quick-maths:0.2.1": shorthands

/// Custom math functions
#let rw(x) = $op("rw") [#x]$
#let rel(x) = $op("rel") [#x]$
#let simp(x) = $op("simp") [#x]$
#let ball(x,y) = $op("ball") [#x, #y]$
#let DL = math.op("DL")
#let Met = math.op([*Met*]) // for metric space
#let LD = math.op("LD")
#let False = math.op("False")
#let True = math.op("True")
#let Prop = math.op("Prop")
#let sorry = math.op("sorry")
#let tab = $wide$
#let goal = $tack.r$
#let thus = $therefore$
#let hence = $therefore$
#let smul = $circle.filled.small$
#let span = math.op("span")
#let use = math.op("use")
#let ring = math.op("ring")
#let Im = math.op("Im") // by default they use a symbol for this, which is not commonly used in practice
#let self = $bold("self")$
#let grad = $attach(limits("grad"), t: stretch(arrow,size:#2.5em))$ // black magic to have a larger arrow
#let rank = math.op("rank") //Q: not sure we need this when we have `rg` defined
#let rg = math.op("rg")
#let eps = $epsilon$
#let surj = $arrow.r.twohead$
#let inj = $arrow.r.hook$
#let after = $space circle.small space$
#let Maj(x) = $op("Maj") (#x)$
#let Sub(x) = $op("Sub") (#x)$
#let ch(x) = $cosh(#x)$
#let sh(x) = $sinh(#x)$
//#let End(x) = $op("End") (#x)$
#let End(x) = $cal(L)(#x, #x)$
#let Open(x) = $op("Open") (#x)$
#let el(x,y) = $(#x#h(0pt):#h(0pt)#y)$
#let meq(x) = $eq.triple^(mod #x)$
#let mne(x) = $eq.triple.not^(mod #x)$
#let gcd(x,y) = $op("gcd") (#x, #y)$
#let dist(x,y) = $op("dist") (#x, #y)$
#let def(x) = $space^(#x:=)$
#let match(..args) = $"match" #{math.cases(..args)}$
#let ang(..a) = math.lr($chevron.l #a.pos().join($, $) chevron.r$) // explicit `lr`: auto-scaling doesn't reach into a nested equation

#let ig(body, var, lo: none, hi: none) = {
  let sym = math.integral
  if lo != none or hi != none {
    sym = math.attach(sym, b: lo, t: hi)
  }
  $#sym #body dif #var$
}

#let box(..lines) = rect(
  stroke: 0.5pt,
  radius: 3pt,
  inset: 6pt,
  stack(
    dir: ttb,
    spacing: 0.4em,
    ..lines.pos().map(x => math.equation(x, block: false))
  )
)


/// Recursively extract plain text from content
#let to-string(content) = {
  if type(content) == str {
    content
  } else if content.func() == math.equation {
    "mb"
  } else if content.has("text") {
    content.text
  } else if content.has("children") {
    str(content.children.map(to-string).join(""))
  } else if content.has("body") {
    to-string(content.body)
  } else if content == [ ] {
    " "
  } else {
    ""
  }
}

/// Check if content contains a math equation
#let has-math(content) = {
  if content.func() == math.equation { return true }
  if content.has("children") {
    return content.children.any(c => has-math(c))
  }
  if content.has("body") {
    return has-math(content.body)
  }
  false
}

/// Sanitize heading text into a valid label segment:
/// lowercase, spaces→`-`, strip trailing non-alnum, remove invalid label chars
#let sanitize-key(s) = {
  let s = lower(s.trim())
  let chars = s.clusters()
  while chars.len() > 0 {
    if chars.last().match(regex("^[a-z0-9]$")) != none { break }
    chars = chars.slice(0, -1)
  }
  let s = chars.join("")
  let s = s.replace(" ", "-")
  s.replace(regex("[^a-z0-9._:-]"), "")
}

/// Build hierarchical label key by querying previous headings.
/// Headings containing math get `mb1`, `mb2`, ... segments (counted among same-level siblings).
#let heading-key(it) = {
  let is-mb = has-math(it.body)
  let prev = query(selector(heading).before(here()))
  let seg = if is-mb {
    let mb-count = 0
    for h in prev.rev().slice(1) {
      if h.level < it.level { break }
      if h.level == it.level and has-math(h.body) { mb-count += 1 }
    }
    "mb" + str(mb-count + 1)
  } else {
    sanitize-key(to-string(it.body))
  }

  let prefix = ()
  let level = it.level
  for h in prev.rev().slice(1) {
    if level <= 1 { break }
    if h.level >= level { continue }
    prefix = (if has-math(h.body) { "mb" } else { sanitize-key(to-string(h.body)) },) + prefix
    level = h.level
  }
  (..prefix, seg).join(".")
}

/// Markdown-style sugar: `> ` blockquotes, `---` section rules, `[label](url)` links, `![alt](path)` images, visible link styling.
/// Package code can't resolve paths relative to the caller, so images need `#show: md.with(img: p => image(p))`
#let md(doc, img: none) = {
  // `---` is already an em-dash shorthand by the time show rules run; alone in a paragraph it's a section split
  show regex("^—$"): _ => block(above: 1.4em, below: 1.4em, line(length: 100%, stroke: 0.5pt + luma(180)))

  let quote-block(body) = block(inset: (left: 1em), stroke: (left: 2pt + gray), text(fill: gray.darken(30%), body))
  // source newlines are lost by now (indistinguishable from spaces), so inside a quote any space-preceded `>` starts a new line
  show par: it => {
    let space = [ ].func()
    let ch = if it.body.func() == [].func() { it.body.children } else { (it.body,) }
    if ch.first().func() != text or not ch.first().text.starts-with("> ") { return it }
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
  // typst autolinks the bare URL, splitting the text node, so we stash the
  // [label] in state, graft it onto the autolink, and eat the trailing paren
  let md-lbl = state("md-lbl", none)
  let md-eat = state("md-eat", false)
  show regex("\\[[^\\]]+\\]\\("): it => md-lbl.update(it.text.slice(1, -2))
  show link: it => context {
    let l = md-lbl.get()
    // autolinks only (body text == dest); reconstructed links have body == label, breaking recursion
    if l == none or it.body.func() != text or it.body.text != str(it.dest) { it }
    else { md-lbl.update(none) + md-eat.update(true) + link(it.dest, l) }
  }
  // must not match a lone `)`: in math that's the closing delimiter, and any rule firing on it costs its stretchiness.
  // so a link ending a paragraph keeps its `)` - the two are indistinguishable at that point
  show regex("(?s)^\\)."): it => context {
    if md-eat.get() { md-eat.update(false) + it.text.slice(1) } else { it }
  }

  // non-URL dests aren't autolinked, so the whole [label](dest) survives as one
  // text node; defined after the stash rule to win the same-position tie
  show regex("\\[[^\\]]+\\]\\([^)]+\\)"): it => {
    let m = it.text.match(regex("\\[([^\\]]+)\\]\\(([^)]+)\\)"))
    link(m.captures.at(1), m.captures.at(0))
  }

  doc
}

/// Math notes preset - optimized settings for mathematical note-taking
#let math_notes_prelude(doc) = [
  #show: md
  #show: shorthands.with(($..=$, $..#h(0pt)=#h(0pt)$))
  #set page(margin: (y: 0.2cm)) //Q: was `0cm` before, but I'm trying to make a pagebreak not be less then literally space between line_1\n\nline_2
  #show math.equation: set block(breakable: true)
  // multi-line inline math sits on its last row's baseline by default; move it to the first row's
  #show math.equation.where(block: false): it => {
    let kids = if it.body.has("children") { it.body.children } else { (it.body,) }
    let i = kids.position(k => k.func() == linebreak)
    if i == none { return it }
    context {
      // depth below baseline: a 100pt box pins the ascent, text edges at baseline contribute nothing
      let desc = c => measure(text(top-edge: "baseline", bottom-edge: "baseline", [#c#std.box(height: 100pt)])).height - 100pt
      let first = math.equation(block: false, kids.slice(0, i).join())
      std.box(baseline: measure(it).height - desc(it) - (measure(first).height - desc(first)), it)
    }
  }
  #set text(fallback: false)

  // auto-gen hierarchical heading labels:
  // `= Ex I` / `== 1.` / `=== a)` becomes `@ex-i.1.a`
  #show figure.where(kind: "heading"): none
  #show heading: it => context {
    let key = heading-key(it)
    [
      #it
      #figure(kind: "heading", supplement: none, numbering: "1", caption: it.body)[] #label(key)
    ]
  }
  #show ref: it => {
    let el = it.element
    if el != none and el.func() == figure and el.kind == "heading" {
      link(el.location(), el.caption.body)
    } else {
      it
    }
  }

  #doc

  // trailing blank page so zathura doesn't jump on edits at the tip.
  // Will still step forward when new page is created, but at least if I scroll below the current pos at the bottom manually, it won't jerk back on every save.
  #pagebreak()
  #hide[.]
]

