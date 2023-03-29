#let plot-fn(fn, min: -1, max: 1, steps: 100) = {
   let data = ()
   for n in range(0, steps + 1) {
     let x = min + (max - min) / steps * n
     data.push((x, fn(x)))
   }
   return data
}
