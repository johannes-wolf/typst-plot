/* Default settings */
#let plot-defaults = (
  tic-length: .4em,
  tic-stroke: .5pt + black,
  tic-mirror: true,
)

/* Data settings */
#let plot-data(data, x-axis: "x", y-axis: "y", label: "data", stroke: "auto") = (
  data: data, label: label, stroke: stroke, x-axis: x-axis, y-axis: y-axis
)

/* private: Get dictionary value or return fallback */
#let p-dict-get(d, key, fallback) = {
  if d != none and key in d {
    return d.at(key)
  }
  return fallback
}

// Returns interpolated endpoints of line between `points` inside `x-range` and `y-range` or none
#let lines-for-points(points, x-range, y-range) = {
  let min-x = x-range.at(0)
  let max-x = x-range.at(1)
  let min-y = y-range.at(0)
  let max-y = y-range.at(1)

  let line-crosses-range(a, b) = {
    // Returns if point p is inside min/max ranges
    let in-range(p) = {
      return p.at(0) >= min-x and p.at(0) <= max-x and p.at(1) >= min-y and p.at(1) <= max-y
    }

    // Returns true if min(v1, v2) < x < max(v1, v2) => if v1 and v2 "cross" x
    let crosses-x(v1, v2, x) = {
      return ((v2 - x) * (v1 - x)) <= 0
    }

    // If one point is in the range, return true
    if in-range(a) or in-range(b) {
      return true
    }

    // Count edge crossing, if == 2, return true
    let num-crossings = 0
    if crosses-x(a.at(0), b.at(0), min-x) { num-crossings += 1 }
    if crosses-x(a.at(0), b.at(0), max-x) { num-crossings += 1 }
    if crosses-x(a.at(1), b.at(1), min-y) { num-crossings += 1 }
    if crosses-x(a.at(1), b.at(1), max-y) { num-crossings += 1 }

    return num-crossings >= 2
  }

  // Return linear interpolated point p on line ab
  let lin-interpolated-point(p, a, b) = {
    let m = (a.at(1) - b.at(1)) / (a.at(0) - b.at(0))
    let x = p.at(0)
    let y = p.at(1)

    if not line-crosses-range(a, b) {
      return none
    }
    
    if y > max-y {
      x = x + (max-y - y) / m
      y = max-y
    } else if y < min-y {
      x = x + (min-y - y) / m
      y = min-y
    }

    if x > max-x {
      y = y + m * (max-x - x)
      x = max-x
    } else if x < min-x {  
      y = y + m * (min-x - x)
      x = min-x
    }
    
    return (x, y)
  }

  let lines = ()
  let prev-p = none
  for p in points {
    if prev-p != none {
      let a = lin-interpolated-point(prev-p, prev-p, p)
      let b = lin-interpolated-point(p, prev-p, p)
      if a != none and b != none and a != b {
        lines.push((a, b))
      }
    }
    prev-p = p
  }
  return lines
}

/* Plot a line chart */
#let plot(data,
          multi: false,

          /* Tics Dictionary
	   * - every: number   Draw tic every n values
	   * - tics: array     Place tic at values
	   * - mirror: bool    Mirror tics to opposite side
	   * - side: string    Side (left, right, top, bottom)
	   * - length: length  Line length
	   * - offset: length  Offset (outset) 
	   * - angle: length   Label rotation
	   * - stroke: stroke  Tic stroke
	   */
          x-tics: (every: 1),
          y-tics: (every: 1),
          x2-tics: none,
          y2-tics: none,
          
          /* Axis Dictionary
	   * - range: array|none  Range to plot `(min, max)`
	   */
          x-axis: (:),
          y-axis: (:),
          x2-axis: (:),
          y2-axis: (:),
          
          width: 10cm,
          height: 10cm,
          border-stroke: black + .5pt,

          /* Padding */
          padding: (left: 2.4em, right: 2.4em, top: 1.4em, bottom: 1.4em),
  ) = {
  style(st => {
    /* Plot viewport size */
    let data-width = width - padding.left - padding.right
    let data-height = height - padding.top - padding.bottom
    let data-x = padding.left
    let data-y = padding.top

    /* Relative axis coordinates */
    let left-axis-x = 0cm
    let right-axis-x = data-width
    let top-axis-y = 0cm
    let bottom-axis-y = data-height

    // Translate data point pt to relative plot coordinates
    let point-to-plot(pt, x-range, y-range) = {
      let x-scale = data-width / (x-range.at(1) - x-range.at(0))
      let y-scale = data-height / (y-range.at(1) - y-range.at(0))
    
      return (x-scale * (pt.at(0) - x-range.at(0)),
              data-height - y-scale * (pt.at(1) - y-range.at(0)))
    }

    /* All axes */
    let axes = (
      x: x-axis, x2: x2-axis,
      y: y-axis, y2: y2-axis,
    )

    /* All tics */
    let tics = (
      x: x-tics, x2: x2-tics,
      y: y-tics, y2: y2-tics,
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
      let x-axis = axes.at(d.x-axis)
      let y-axis = axes.at(d.y-axis)

      let x-range = p-dict-get(x-axis, "range", none)
      let y-range = p-dict-get(y-axis, "range", none)
      if x-range == none or y-range == none {
        let min-x = none; let max-x = none
        let min-y = none; let max-y = none

        for pt in d.data {
          if min-x == none or min-x > pt.at(0) { min-x = pt.at(0) }
          if max-x == none or max-x < pt.at(0) { max-x = pt.at(0) }
          if min-y == none or min-y > pt.at(1) { min-y = pt.at(1) }
          if max-y == none or max-y < pt.at(1) { max-y = pt.at(1) }
        }

        if x-range == none { x-range = (min-x, max-x) }
        if y-range == none { y-range = (min-y, max-y) }

        return (x: x-range, y: y-range)
      }

      return (x: x-axis.range, y: y-axis.range)
    }
    
    if multi {
      for sub-data in data {
        let ranges = autorange-axes(sub-data)
        axes.at(sub-data.x-axis).range = ranges.x
        axes.at(sub-data.y-axis).range = ranges.y
      }
    } else {
      let ranges = autorange-axes(data)
      axes.at(data.x-axis).range = ranges.x
      axes.at(data.y-axis).range = ranges.y
    }

    // Returns a length on `range` scaled to `size`
    let length-on-range(range, size, value) = {
      let scale = size / (range.at(1) - range.at(0))
      return (value - range.at(0)) * scale
    }

    let tic-position(axis, tics, value, side) = {
      let pt = none
      let angle = 0deg
      let range = axis.range
      if range.at(0) > value or value > range.at(1) {
        return none
      }

      let offset = p-dict-get(tics, "offset", 0cm)    
      if side == "left" {
        pt = (left-axis-x - offset, data-height - length-on-range(range, data-height, value))
        angle = 0deg
      } else if side == "right" {
        pt = (right-axis-x + offset, data-height - length-on-range(range, data-height, value))
        angle = 180deg
      } else if side == "bottom" {
        pt = (length-on-range(range, data-width, value), bottom-axis-y + offset)
        angle = 270deg
      } else if side == "top" {
        pt = (length-on-range(range, data-width, value), top-axis-y - offset)
        angle = 90deg
      }

      return (position: pt, angle: angle)
    }

    let render-tic-mark(axis, tics, pt, angle) = {
      place(dx: data-x,
            dy: data-y, {
    	    line(start: pt, angle: angle,
    	         length: p-dict-get(tics, "lengts", plot-defaults.tic-length),
    		 stroke: p-dict-get(tics, "stroke", plot-defaults.tic-stroke))
    	  })
    }

    let render-tic-label(tics, pt, value, side) = {
      let format = p-dict-get(tics, "format", none)
      if format == none {
        format = (v => str(int(v*100)/100.0))
      }

      if type(value) == "array" {
        value = value.at(1)
      }

      let label = rotate(origin: center + horizon, p-dict-get(tics, "angle", 0deg))[ #format(value) ]
      let bounds = measure(label, st)

      let offset = (0cm, 0cm)
      if side == "left" { offset = (-.5em - bounds.width, -bounds.height / 2) }
      if side == "right" { offset = (.5em, -bounds.height / 2) }
      if side == "top" { offset = (-bounds.width / 2, -bounds.height - .5em) }
      if side == "bottom" { offset = (-bounds.width / 2, .5em) }

      place(dx: pt.at(0) + offset.at(0) + data-x,
            dy: pt.at(1) + offset.at(1) + data-y, label)
    }

    let render-tics(axis, tics, side, mirror: false) = {
      /* Render calculated ticks */
      let every = p-dict-get(tics, "every", 1)
      if every != 0 {
        let scale = 1 / every
        for t in range(int(axis.range.at(0) * scale), int(axis.range.at(1) * scale + 1.5)) {
          let v = t / scale
          let pos = tic-position(axis, tics, v, side)
          if pos == none { continue }
          
          render-tic-mark(axis, tics, pos.position, pos.angle)

          if not mirror {
            render-tic-label(tics, pos.position, v, side)
          }
        }
      }

      /* Render fixed tics */
      for v in p-dict-get(tics, "tics", ()) {
        let value = v
        let label = v
        if type(value) == "array" {
          value = v.at(0)
          label = v.at(1)
        }
        
        let pos = tic-position(axis, tics, value, side)
        render-tic-mark(axis, tics, pos.position, pos.angle)

        if not mirror {
          render-tic-label(tics, pos.position, label, side)
        }
      }
    }

    block(width: width, height: height, {
      /* Plot point array */
      let plot-data(data, n) = {
        let colors = (black, red, blue, green)
        
        let stroke = p-dict-get(data, "stroke", "auto")
        if stroke == "auto" {
          stroke = colors.at(calc.mod(n, colors.len())) + .5pt
        }
        
        let plot-line-segment(a, b) = {
          line(start: a, end: b, stroke: stroke)
        }
        
        let x-range = axes.at(data.x-axis).range
        let y-range = axes.at(data.y-axis).range
        for l in lines-for-points(data.data, x-range, y-range) {
          let a = point-to-plot(l.at(0), x-range, y-range)
          let b = point-to-plot(l.at(1), x-range, y-range)
          place(dx: data-x, dy: data-y)[ #plot-line-segment(a, b) ]
        }
      }

      /* Plot graph(s) */
      if multi {
        let n = 0
        for d in data {
          plot-data(d, n)
          n += 1
        }
      } else {
        plot-data(data, 0)
      }

      /* Render tics */
      for name, tic in tics {
        if tic != none {
          let side = p-dict-get(tic, "side", none)
          if side == none {
            side = tic-side.at(name)
          }
    
          let axis = axes.at(name)
          render-tics(axis, tic, side, mirror: false)

          if p-dict-get(tic, "mirror", plot-defaults.tic-mirror) {
            side = other-side.at(side)
            render-tics(axis, tic, side, mirror: true)
          }
        }
      }

      /* Render axis labels */
      for name, axis in axes {
        let label = p-dict-get(axis, "label", none)
        if label != none {
          // TODO: Render label
        }
      }

      /* Render border */
      place(dx: data-x,
            dy: data-y, { rect(width: data-width, height: data-height, stroke: border-stroke) })
    })
  })
}
