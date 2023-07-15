#import "@local/typst-plot:0.0.1"

#box(stroke: 2pt + red, {
  typst-plot.plot(((0,0), (1,1)),
                  width: 8cm,
                  height: 6cm)
})
