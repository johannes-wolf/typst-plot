/* typst-plot line plot - point coordinates connected by straight lines */
#import "plot-util.typ": *

#let paths-for-points(data) = {
  let in-range(p) = {
    return (p != none and p.at(0) >= 0
                      and p.at(0) <= 1
                      and p.at(1) >= 0
                      and p.at(1) <= 1)
  }

  let lin-interpolated-pt(a, b) = {
    let x1 = a.at(0)
    let y1 = a.at(1)
    let x2 = b.at(0)
    let y2 = b.at(1)

    /* Special case for vertical lines */
    if x2 - x1 == 0 {
      return (x2, calc.min(1, calc.max(y2, 0)))
    }

    if y2 - y1 == 0 {
      return (calc.min(1, calc.max(x2, 0)), y2)
    }

    let m = (y2 - y1) / (x2 - x1)
    let n = y1 - m * x1

    let x = if m > 0 { x2 } else { x1 }
    let y = if m > 0 { y2 } else { y1 }

    if y > 1 {
      x = (1 - n) / m
      y = 1
    } else if y < 0 {
      x = x + (0 - n) / m
      y = 0
    }

    if x > 1 {
      y = m + n
      x = 1
    } else if x < 0 {
      y = 0 + n
      x = 0
    }

    return (x, y)
  }

  let paths = ()

  let path = ()
  let prev-p = none
  for p in data {
    if in-range(p) {
      if not in-range(prev-p) and prev-p != none {
        path.push(lin-interpolated-pt(prev-p, p))
      }

      path.push(p)
    } else {
      if path.len() > 0 {
        path.push(lin-interpolated-pt(prev-p, p))
        paths.push(path)
      }
      path = ()
    }

    prev-p = p
  }

  if path.len() > 0 {
    paths.push(path)
  }
  return paths
}

#let render(data, stroke) = {
  for p in paths-for-points(data) {
    place(dx: 0cm, dy: 0cm, path(..p.map(pt => {
      return (pt.at(0) * 100%, 100% - pt.at(1) * 100%)
    }), stroke: stroke))
  }
}
