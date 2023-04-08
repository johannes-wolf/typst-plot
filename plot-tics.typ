#import "plot-util.typ": *


/// Get tick label content
///
/// @param tic   dictionary  Tick dictionary
/// @param value any         Tick value
/// @return content 
#let plot-tic-get-label(tic, value) = {
  if "format" in tic {
    return p-format-number(value, format: tic.format)
  }
  return [$#str(value).replace("-", sym.minus)$]
}

/// Compute list of ticks + relative position on axis
///
/// @param axis dictionary  Axis
/// @param tics array       List of fixed ticks
/// @param length length    Length of the axis
/// @return array
#let tic-list(axis, tics, length) = {
  let a-range = axis.range
  let a-delta = a-range.at(1) - a-range.at(0)
  let a-off = a-range.at(0)
  if a-delta == 0 { a-delta = 1 }

  let pos = ()

  if "every" in tics and tics.every != none {
    let scale = 1 / tics.every
    let r = int(a-range.at(1) * scale + .5) - int(a-range.at(0) * scale)
    for t in range(int(a-range.at(0) * scale),
                   int(a-range.at(1) * scale + 1.5)) {
      let v = ((t / scale) - a-off) / a-delta
      if v >= 0 and v <= 1 {
        pos.push((v, plot-tic-get-label(tics, t / scale)))
      }
    }
  }

  let fixed = if "tics" in tics { tics.tics } else { () }
  for t in fixed {
    let value = t
    let label = t
    if type(value) == "array" {
      value = t.at(0)
      label = t.at(1)
    } else {
      label = plot-tic-get-label(tics, label)
    }

    let v = (value - a-off) / a-delta
    if v >= 0 and v <= 1 {
      pos.push((v, label))
    }
  }

  return pos
}

/// Render tic labels
///
/// @param tics array    List of tics (see tic-list)
/// @param side side     Axis side
/// @param lenght lenght Axis length
#let render-labels(tics, side, length) = style(st => {
  if tics == none or tics.len() == 0 { return none }

  let labels = tics
    .map(t => {
      let label = [#t.at(1)]
      return (pos: t.at(0), label: label, bounds: measure(label, st))
    })

  let max-width = labels
    .map(t => t.bounds.width)
    .sorted()
    .last()

  let max-height = labels
    .map(t => t.bounds.height)
    .sorted()
    .last()
  
  if side == left or side == right {
    box(width: max-width, height: length, {
      for t in labels {
        place(dx: 0cm,
              dy: length - t.pos * length - t.bounds.height / 2,
              box(width: 100%, align(side, t.label)))
      }
    })
  } else {
    box(width: length, height: max-height, {
      for t in labels {
        place(dx: t.pos * length - t.bounds.width / 2,
              dy: max-height / 2 - t.bounds.height / 2,
              box(height: 100%, t.label))
      }
    })
  }
})

/// Render ticmarks on frame border
///
/// @param tics array  List of tics (see tic-list)
/// @param frame rect  Bounds to render into
#let render-marks(tics, frame) = {
  let width = frame.width
  let height = frame.height

  let other-side = (
    left: "right", right: "left",
    top: "bottom", bottom: "top",
  )
  
  for (name, t) in tics {
    for p in t.tics {
      let render(side, angle) = {
        let x = 0; let y = 0; let full-length = 0;
        if side == "right" { x = 1 }
        if side == "left" or side == "right" {
          y = p.at(0)
          full-length = frame.width
        }
        if side == "top" { y = 1 }
        if side == "top" or side == "bottom" {
          x = p.at(0)
          full-length = frame.height
        }

        place(dx: 0cm, dy: 0cm,
          line(start: (width * x, height - height * y),
               length: if t.grid { full-length } else { 10pt },
               angle: angle,
               stroke: p-dict-get(t, "stroke", .5pt)))
      }

      render(t.side, t.angle)
      if t.mirror {
        render(other-side.at(t.side), t.angle + 180deg)
      }
    }
  }
}

