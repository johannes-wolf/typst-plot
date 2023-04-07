#import "plot-util.typ": *
#import "plot-mark.typ": *
#import "plot-tics.typ"
#import "plot-line.typ"

#let defaults = (
  data-x-axis: "x",
  data-y-axis: "y",
  colors: (blue, red, green, yellow, black),
)

/* Returns the stroke color if set, or the nth default color */
#let get-plot-color(data, n) = {
  if "stroke" in data and data.stroke != auto {
    return data.stroke
  }
  return defaults.colors.at(calc.mod(n, defaults.colors.len()))
}

/// Plot a line chart
///
/// Data: Set positional to array or dictionary:
///   - data   array   Array of data points
///   - mark   string  Mark type (see plot-mark.typ)
///   - x-axis string  X axis to use (x)
///   - y-axis string  Y axis to use (y)
///   - stroke stroke  Custom stroke
///
/// Tics: Set {x,y,x2,y2}-tics to dictionary:
///   - every  number  Draw tic every n values
///   - tics   array   Place tics at values
///   - mirror bool    Mirror tics to opposite side
///   - grid   bool    Draw tics as grid lines
///   - stroke stroke  Tic stroke
///
/// Axis: Set {x,y,x2,y2}-axis to dictionary:
///   - range array    Range from low to high (low, high)
///
#let plot(x-axis: (:),
          y-axis: (:),
          x2-axis: (:),
          y2-axis: (:),
          /* Labels */
          x-label:  [$x$],
          x2-label: [],
          y-label:  [$y$],
          y2-label: [],
          
          width: 8cm,
          height: 8cm,
          border-stroke: black + .5pt,

          /* Padding */
          padding: (left: 0em, right: 0em, top: 0em, bottom: 0em),

          ..data,
  ) = {
  let plots = data.pos().map(v => {
    let r = (
      x-axis: defaults.data-x-axis,
      y-axis: defaults.data-y-axis,
    )
    if type(v) == "dictionary" {
      r = r + v
    } else if type(v) == "array" {
      r.data = v
    }
    return r
  })

  style(st => {
    let frame = (x: 0cm, y: 0cm, width: width, height: height)
    let axis-frame = rect-inset(frame, padding)
    let data-frame = axis-frame

    /* All axes */
    let axes = (
      x: x-axis, x2: x2-axis,
      y: y-axis, y2: y2-axis,
    )

    /* Default axis side */
    let tic-side = (
      x: "bottom", x2: "top",
      y: "left", y2: "right",
    )

    /* Map side to opposite side */
    let other-side = (
      left: "right", right: "left",
      top: "bottom", bottom: "top",
    )

    /* Calculate unset axis ranges.
     * Returns new range as tuple (x-range, y-range)
     */
    let autorange-axes(d) = {
      let x-axis = p-dict-get(axes, d.x-axis, (:))
      let y-axis = p-dict-get(axes, d.y-axis, (:))
      let x-range = p-dict-get(x-axis, "range", auto)
      let y-range = p-dict-get(y-axis, "range", auto)
      if x-range == auto or y-range == auto {
        let min-x = none; let max-x = none
        let min-y = none; let max-y = none

        for pt in d.data {
          pt = pt.map(parse-data)
          if min-x == none or min-x > pt.at(0) { min-x = pt.at(0) }
          if max-x == none or max-x < pt.at(0) { max-x = pt.at(0) }
          if min-y == none or min-y > pt.at(1) { min-y = pt.at(1) }
          if max-y == none or max-y < pt.at(1) { max-y = pt.at(1) }
        }

        if x-range == auto {
          let x-offset = (max-x - min-x) / 10
          if max-x - min-x == 0 { min-x = -.1; max-x = .1 }
          x-range = (min-x - x-offset, max-x + x-offset)
        }
        if y-range == auto {
          let y-offset = (max-y - min-y) / 10
          if max-y - min-y == 0 { min-y = -.1; max-y = .1 }
          y-range = (min-y - y-offset, max-y + y-offset)
        }

        return (x: x-range, y: y-range)
      }

      return (x: x-range, y: y-range)
    }
    
    /* Compute range */
    {
      let computed-range = (:) 
      for sub-data in plots {
        let x-axis = sub-data.x-axis
        let y-axis = sub-data.y-axis

        let ranges = autorange-axes(sub-data)

        if not x-axis in computed-range {
          computed-range.insert(x-axis, (ranges.x.at(0), ranges.x.at(1)))
        } else {
          computed-range.at(x-axis).at(0) = (calc.min(computed-range.at(x-axis).at(0), ranges.x.at(0)))
          computed-range.at(x-axis).at(1) = (calc.max(computed-range.at(x-axis).at(1), ranges.x.at(1)))
        }
        if not y-axis in computed-range {
          computed-range.insert(y-axis, (ranges.y.at(0), ranges.y.at(1)))
        } else {
          computed-range.at(y-axis).at(0) = (calc.min(computed-range.at(y-axis).at(0), ranges.y.at(0)))
          computed-range.at(y-axis).at(1) = (calc.max(computed-range.at(y-axis).at(1), ranges.y.at(1)))
        }
      }

      for name, r in computed-range {
        axes.at(name).range = r
      }
    }

    /* All tics */
    let tics = (
      x:  (side: "bottom", angle: 270deg, tics: (), grid: false, mirror: true, every: 1),
      y:  (side: "left",   angle:   0deg, tics: (), grid: false, mirror: true, every: 1),
      x2: (side: "top",    angle:  90deg, tics: (), grid: false, mirror: true),
      y2: (side: "right",  angle: 180deg, tics: (), grid: false, mirror: true),
    )

    /* Compute tic positions */
    for name, t in tics {
      if t != none {
        let key = name + "-tics"
        if key in data.named() {
          tics.at(name) += data.named().at(key)
          t = tics.at(name) // t seems to be a copy!
        }

        let length = if (t.side == "left" or t.side == "right") {
          axis-frame.height
        } else {
          axis-frame.width
        }

        let axis = axes.at(name)
        if "range" in axis {
          tics.at(name).tics = plot-tics.tic-list(axes.at(name), t, length)
        } else {
          tics.at(name).tics = ()
        }
      }
    }

    let render-tics() = {
      for name, t in tics {
        for p in t.tics {
          let render(side, angle) = {
            let x = 0; let y = 0; let full-length = 0;
            if side == "right" { x = 1 }
            if side == "left" or side == "right" {
              y = p.at(0)
              full-length = axis-frame.width
            }
            if side == "top" { y = 1 }
            if side == "top" or side == "bottom" {
              x = p.at(0)
              full-length = axis-frame.height
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

    let content = box(width: width, height: height, {
      /* Plot point array */
      let stroke-data(data, stroke, n) = {
        let x-range = axes.at(data.x-axis).range
        let y-range = axes.at(data.y-axis).range
        let x-delta = x-range.at(1) - x-range.at(0)
        let y-delta = y-range.at(1) - y-range.at(0)
        let x-off = x-range.at(0)
        let y-off = y-range.at(0)

        if x-delta == 0 { x-delta = 1 }
        if y-delta == 0 { y-delta = 1 }

        let norm-data = data.data.map(pt => {
          return ((pt.at(0) - x-off) / x-delta,
                  (pt.at(1) - y-off) / y-delta)
        })

        plot-line.render(norm-data, stroke)
      }

      let mark-data(data, mark, n) = {
        let mark-size = p-dict-get(data, "mark-size", .5em)
        let mark-stroke = p-dict-get(data, "mark-stroke", auto)
        if mark-stroke == auto {
          mark-stroke = get-plot-color(data, n) + .5pt
        }

        let mark-fill = p-dict-get(data, "mark-fill", auto)
        if mark-fill == auto {
          mark-fill = get-plot-color(data, n)
        }

        let x-range = axes.at(data.x-axis).range
        let y-range = axes.at(data.y-axis).range
        let x-off = x-range.at(0)
        let y-off = y-range.at(0)

        for p in data.data {
          let delta-x = x-range.at(1) - x-range.at(0)
          let delta-y = y-range.at(1) - y-range.at(0)

          let x = (p.at(0) - x-off) / delta-x * 100%
          let y = 100% - (p.at(1) - y-off) / delta-y * 100%

          /* Skip out of range points */
          if x < 0% or x > 100% or y < 0% or y > 100% { continue }

          place(dx: x - mark-size/2,
                dy: y - mark-size/2,
                box(width: mark-size, height: mark-size, {
                  plot-mark(mark, stroke: mark-stroke, fill: mark-fill)
                }))
        }
      }

      /* Render axes */
      place(dx: axis-frame.x, dy: axis-frame.y, {
        box(width: axis-frame.width, height: axis-frame.height, {
          render-tics()

          /* Render border */
          place(dx: 0cm, dy: 0cm, {
            rect(width: axis-frame.width, height: axis-frame.height,
                 stroke: border-stroke)
          })
        })
      })

      /* Plot graph(s) */
      place(dx: data-frame.x, dy: data-frame.y, {
        box(width: data-frame.width, height: data-frame.height, clip: false, {
          let n = 0
          for sub-plot in plots {
            let stroke = p-dict-get(sub-plot, "stroke", auto)
            if stroke == auto {
              stroke = get-plot-color(sub-plot, n) + .5pt
            }

            if stroke != none {
              stroke-data(sub-plot, stroke, n)
            }

            let mark = p-dict-get(sub-plot, "mark", none)
            if mark != none {
              mark-data(sub-plot, mark, n)
            }

            n += 1
          }
        })
      })
    })

    let x-tic-labels  = plot-tics.render-labels(tics.x.tics,  bottom, data-frame.width)
    let x2-tic-labels = plot-tics.render-labels(tics.x2.tics, top, data-frame.width)
    let y-tic-labels  = plot-tics.render-labels(tics.y.tics,  right, data-frame.height)
    let y2-tic-labels = plot-tics.render-labels(tics.y2.tics, left, data-frame.height)

    grid(columns: (auto, auto, auto, auto, auto),
         rows: (auto, auto, auto, auto, auto),
         gutter: .5em,
      /* X2 Label */
      [], [], align(center, x2-label), [], [],

      /* X2 Tics */
      [], [], x2-tic-labels, [], [],

      /* Y Label */
      align(center + horizon, rotate-bbox(y-label, -90deg)),

      y-tic-labels,
      content,
      y2-tic-labels,

      /* Y2 Label */
      align(center + horizon, rotate-bbox(y2-label, -90deg)),

      /* X Tics */
      [], [], x-tic-labels, [], [],

      /* X Label */
      [], [], align(center, x-label), [], [])
  })
}
