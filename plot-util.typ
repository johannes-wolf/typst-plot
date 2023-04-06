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
 * Rotate content and affect layout.
 * https://github.com/typst/typst/issues/528 by @Enivex
 */
#let rotate-bbox(body, angle) = style(styles => {
  let size = measure(body,styles)
  box(inset: (x: -size.width/2+(size.width*calc.abs(calc.cos(angle))+size.height*calc.abs(calc.sin(angle)))/2,
              y: -size.height/2+(size.height*calc.abs(calc.cos(angle))+size.width*calc.abs(calc.sin(angle)))/2),
      rotate(body, angle))
})

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
 * Parse plot data to float
 */
#let parse-data(data) = {
  if type(data) == "string" {
    return float(data.trim())

    // TODO: Support other types (date, time, ...)
    panic("Could not parse value " + repr(data))
  }

  return float(data)
}
