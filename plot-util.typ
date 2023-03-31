/**
 * Inset `rect` by length `d`.
 * @param d length|dictionary
 * @return dictionary
 */
#let rect-inset(rect, d) = {
  if type(d) == "dictionary" {
    return (
      x: rect.x + d.left,
      y: rect.y + d.top,
      width: rect.width - d.left - d.right,
      height: rect.height - d.top - d.bottom,
    )
  }
  
  return rect-inset(rect, (left: d, right: d, top: d, bottom: d))
}

/**
 * Returns point at side `v` + `h` of rect `rect`.
 * @param v string  "left"|"right"|"center"
 * @param h string  "tob"|"bottom"|"center"
 * @return array
 */
#let rect-get-point(rect, v: "center", h: "center") = {
  let x = rect.x
  let y = rect.y

  if h == "center" {
    x += rect.width / 2
  } else if h == "right" {
    x += rect.width
  }
  if v == "center" {
    y += rect.height / 2	  
  } else if v == "bottom" {
    y += rect.height	  
  }

  return (x, y)
}

/**
 * private: Format scientific notation
 * @param factor   number Factor
 * @param exponent number Exponent
 * @return content
 */
#let p-format-sci(factor, exponent) = {
  if exponent <= -1 or exponent >= 1 {
    [$#factor times 10^#exponent$]
  } else {
    [$#factor$]
  }
}

/**
 * private: Format number
 * @param value number   Number
 * @param format string  Format specifier ("sci")
 * @return content 
 */
#let p-format-number(value, format: auto) = {
  if type(format) == "function" {
    return format(value)
  }

  if format == "sci" {
    let exponent = if value != 0 {
      calc.floor(calc.log(calc.abs(value))/calc.log(10))
    } else {
      0
    }

    let ee = calc.pow(10, calc.abs(exponent + 1))
    if exponent > 0 {
      value = value / ee * 10
    } else if exponent < 0 {
      value = value * ee * 10
    }
    p-format-sci(value, exponent)
  } else {
    [$#value$]  
  }
} 

/**
 * private: Get tic label content
 * @param tic   dict  Tic dictionary
 * @param value any   Tic value
 * @return content 
 */ 
#let p-tic-get-label(tic, value) = {
  if "format" in tic {
    return p-format-number(value, format: tic.format)
  }
  return value
}

/**
 * private: Get dictionary value or return fallback
 * @param d dictionary  Dictionary
 * @param key string    Key
 * @param fallback any  Fallback value
 * @return any
 */
#let p-dict-get(d, key, fallback) = {
  if d != none and key in d {
    return d.at(key)
  }
  return fallback
}

/**
 * Returns interpolated endpoints of line
 * between `points` inside `x-range` and `y-range` or none
 *
 * TODO: REFACTOR: Return line-strips start-*n-end points
 */
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
