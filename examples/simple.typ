#import "../plot.typ": plot, plot-data
#import "../plot-sample.typ": *

#set page(width: 10cm, height: 7cm)

#plot(sample(x => calc.sin(x), min: 0, max: 2*calc.pi, samples: 50),
      y-axis: (range: (-1, 1)),
      width: 8cm,
      height: 4.5cm)
