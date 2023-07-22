#import "@preview/cetz:0.0.1"

#let plot(..args,
          style: "scientific",
          width: 1cm, height: 1cm) = {
  import "plot.typ"

  let size = (width / 1cm, height / 1cm)
  cetz.canvas(length: 1cm, {
    if style == "scientific" {
      plot.scientific-axes(size: size, ..args)
    } else {
      plot.school-book-axes(size: size, ..args)
    }
  })
}
