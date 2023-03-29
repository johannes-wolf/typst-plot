#import "util.typ": plot-fn
#import "../plot.typ": plot, plot-data

#set page(width: 10cm, height: 7cm)

#plot(plot-data(plot-fn(x => calc.sin(x), min: 0, max: 2*calc.pi, steps: 50)),
      y-axis: (range: (-1, 1)),
      width: 100%,
      height: 100%)
