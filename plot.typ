#import "plot-util.typ": *

/* Default settings */
#let plot-defaults = (
  tic-length: .4em,
  tic-stroke: .5pt + black,
  tic-mirror: true,
)

/* Data settings */
#let plot-data(data, x-axis: "x", y-axis: "y", label: "data", stroke: "auto") = (
  data: data, stroke: stroke, x-axis: x-axis, y-axis: y-axis
)

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

          /* Labels */
          x-label:  [$x$],
          x2-label: [],
          y-label:  [$y$],
          y2-label: [],
          
          width: 10cm,
          height: 10cm,
          border-stroke: black + .5pt,

          /* Padding */
          padding: (left: 2.4em, right: 2.4em, top: 1.4em, bottom: 1.6em),
  ) = {
  style(st => {
    /* Plot viewport size */
    let data-width = width - padding.left - padding.right
    let data-height = height - padding.top - padding.bottom
    let data-x = padding.left
    let data-y = padding.top

    let frame = (x: 0cm, y: 0cm, width: width, height: height)
    let data-frame = rect-inset(frame, padding)

    /* Relative axis coordinates */
    let left-axis-x = 0cm
    let right-axis-x = data-frame.width
    let top-axis-y = 0cm
    let bottom-axis-y = data-frame.height

    // Translate data point pt to relative plot coordinates
    let point-to-plot(pt, x-range, y-range) = {
      let x-scale = data-frame.width / (x-range.at(1) - x-range.at(0))
      let y-scale = data-frame.height / (y-range.at(1) - y-range.at(0))
    
      return (x-scale * (pt.at(0) - x-range.at(0)),
              data-frame.height - y-scale * (pt.at(1) - y-range.at(0)))
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
        pt = (left-axis-x - offset, data-frame.height - length-on-range(range, data-frame.height, value))
        angle = 0deg
      } else if side == "right" {
        pt = (right-axis-x + offset, data-frame.height - length-on-range(range, data-frame.height, value))
        angle = 180deg
      } else if side == "bottom" {
        pt = (length-on-range(range, data-frame.width, value), bottom-axis-y + offset)
        angle = 270deg
      } else if side == "top" {
        pt = (length-on-range(range, data-frame.width, value), top-axis-y - offset)
        angle = 90deg
      }

      return (position: pt, angle: angle)
    }

    let render-tic-mark(axis, tics, pt, angle) = {
      place(dx: data-frame.x,
            dy: data-frame.y, {
    	    line(start: pt, angle: angle,
    	         length: p-dict-get(tics, "lengts", plot-defaults.tic-length),
    		 stroke: p-dict-get(tics, "stroke", plot-defaults.tic-stroke))
    	  })
    }

    let render-tic-label(tics, pt, value, side) = {
      if type(value) == "array" {
        value = value.at(1)
      } else {
        value = p-tic-get-label(tics, value)
      }

      let label = rotate(origin: center + horizon, p-dict-get(tics, "angle", 0deg), [#value])
      let bounds = measure(label, st)

      let offset = (0cm, 0cm)
      if side == "left" { offset = (-.5em - bounds.width, -bounds.height / 2) }
      if side == "right" { offset = (.5em, -bounds.height / 2) }
      if side == "top" { offset = (-bounds.width / 2, -bounds.height - .5em) }
      if side == "bottom" { offset = (-bounds.width / 2, .5em) }

      place(dx: pt.at(0) + offset.at(0) + data-frame.x,
            dy: pt.at(1) + offset.at(1) + data-frame.y, label)
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

    let content = block(width: width, height: height, {
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
          place(dx: data-frame.x, dy: data-frame.y)[ #plot-line-segment(a, b) ]
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

      /* Render border */
      place(dx: data-frame.x,
            dy: data-frame.y, {
        rect(width: data-frame.width, height: data-frame.height,
             stroke: border-stroke) })
    })

    grid(columns: (auto, auto, auto), rows: (auto, auto, auto), gutter: 1pt,
      /* Row 1 */
      [], align(center, x2-label), [],
      /* Row 2 */
      align(center + horizon, rotate(y-label, -90deg)),
      content,
      align(center + horizon, rotate(y2-label, - 90deg)),
      /* Row 3 */
      [], align(center, x-label), [])
  })
}
