#set page(width: auto, height: auto)
#import "../../standalone.typ": plot
#import "../../plot-sample.typ": sample

#box(stroke: 2pt + red, {
  plot(sample(x => calc.sin(x), min: 0, max: 2 * calc.pi, samples: 50),
       width: 8cm,
       height: 6cm)
})
