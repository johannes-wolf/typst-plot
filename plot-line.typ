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
    let n = y2 - m * x2

    let x = x2
    let y = y2

    y = calc.min(1, calc.max(y, 0))
    x = (y - n) / m

    x = calc.min(1, calc.max(x, 0))
    y = m * x + n

    return (x, y)
  }

  let paths = ()

  let path = ()
  let prev-p = none
  for p in data {
    if in-range(p) {
      if not in-range(prev-p) and prev-p != none {
        path.push(lin-interpolated-pt(p, prev-p))
      }

      path.push(p)
    } else {
      if in-range(prev-p) {
        path.push(lin-interpolated-pt(prev-p, p))
      }

      if path.len() > 0 {
        paths.push(path)
        path = ()
      }
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
