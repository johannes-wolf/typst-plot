/* typst-plot mark */

#let plot-mark(mark, fill: white, stroke: .5pt + black) = {
  let circle(fill: none) = {
    ellipse(width: 100%, height: 100%, fill: fill, stroke: stroke)
  }

  let x() = {
    place(dx: 0cm, dy: 0cm, {
      line(stroke: stroke, start: (0%, 0%), end: (100%, 100%))})
    place(dx: 0cm, dy: 0cm, {
      line(stroke: stroke, start: (0%, 100%), end: (100%, 0%))})
  }

  let horiz() = {
      place(dx: 0cm, dy: 0cm, {
        line(stroke: stroke, start: (0%, 50%), end: (100%, 50%))})
  }

  let vert() = {
      place(dx: 0cm, dy: 0cm, {
        line(stroke: stroke, start: (50%, 0%), end: (50%, 100%))})
  }

  let cross() = {
    horiz()
    vert()
  }

  let square(fill: none) = {
    rect(width: 100%, height: 100%, fill: fill, stroke: stroke)
  }

  let triangle(fill: none) = {
    polygon((0%, 93%), (50%, 7%), (100%, 93%), fill: fill, stroke: stroke)
  }

  let render = (
    "x": x,
    "+": cross,
    "-": horiz,
    "|": vert,
    "o": () => { circle() },
    "*": () => { circle(fill: fill) },
    "square": () => { square() },
    "square*": () => { square(fill: fill) },
    "triangle": () => { triangle() },
    "triangle*": () => { triangle(fill: fill) },
  )

  if type(mark) == "string" {
    if mark in render {
      render.at(mark)()
    } else {
      panic("Invalid mark type '" + mark + "'")
    }
  } else if type(mark) == "function" {
    mark()
  } else if mark != none {
    panic("Invalid marker type: " + type(mark))
  }
}
