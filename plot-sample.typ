/* plot-sample - Sample function */

/// Sample function
///
/// ## Example
/// ```example
/// let data = sample(
///   x => calc.sin(x),
///   min: 0,
///   max: 2 * calc.pi)
/// ```
#let sample(fn, min: -1, max: 1, samples: 25) = {
  let data = ()

  let delta = max - min
  for t in range(0, samples+1) {
    let x = min + t * delta/samples
    let p = fn(x)

    if type(p) == "array" {
      data.push(p)
    } else {
      data.push((x, p))
    }
  }

  return data
}
