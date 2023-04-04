/* typst-plot line plot - point coordinates connected by straight lines */
#import "plot-util.typ": *

/**
 * Returns interpolated endpoints of line
 */
#let lines-for-points(points) = {
  let line-crosses-range(a, b) = {
    // Returns if point p is inside min/max ranges
    let in-range(p) = {
      return p.at(0) >= 0 and p.at(0) <= 1 and p.at(1) >= 0 and p.at(1) <= 1
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
    if crosses-x(a.at(0), b.at(0), 0) { num-crossings += 1 }
    if crosses-x(a.at(0), b.at(0), 1) { num-crossings += 1 }
    if crosses-x(a.at(1), b.at(1), 0) { num-crossings += 1 }
    if crosses-x(a.at(1), b.at(1), 1) { num-crossings += 1 }

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
    
    if y > 1 {
      x = x + (1 - x) / m
      y = 1
    } else if y < 0 {
      x = x + (0 - y) / m
      y = 0
    }

    if x > 1 {
      y = y + m * (1 - x)
      x = 1
    } else if x < 0 {  
      y = y + m * (0 - x)
      x = 0
    }
    
    return (x, y)
  }

  let lines = ()
  let prev-p = none
  for p in points {
    p = p.map(parse-data)
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

#let render(data, stroke) = {
  let plot-line-segment(a, b) = {
    line(start: a, end: b, stroke: stroke)
  }

  for l in lines-for-points(data) {
    let x1 = l.at(0).at(0)
    let y1 = l.at(0).at(1)
    let a = (x1 * 100%, 100% - y1 * 100%)

    let x2 = l.at(1).at(0)
    let y2 = l.at(1).at(1)
    let b = (x2 * 100%, 100% - y2 * 100%)
    place(dx: 0cm, dy: 0cm, plot-line-segment(a, b))
  }
}
