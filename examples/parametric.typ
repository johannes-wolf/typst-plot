#import "../plot.typ": plot
#import "../plot-sample.typ": *

#set page(width: 12cm, height: 10cm)

#plot(y-axis: (range: (-1, 1)),
      x-axis: (range: (-1, 1)),
      sample(t => (0 + calc.cos(t) * t/40, -1 + calc.sin(t) * t/40),
             min: 0, max: 5*2 * calc.pi, samples: 400),
      sample(t => (0 + calc.cos(t) * t/40,  1 + calc.sin(t) * t/40),
             min: 0, max: 5*2 * calc.pi, samples: 400),
      sample(t => ( 1 + calc.cos(t) * t/40, 0 + calc.sin(t) * t/40),
             min: 0, max: 5*2 * calc.pi, samples: 400),
      sample(t => (-1 + calc.cos(t) * t/40, 0 + calc.sin(t) * t/40),
             min: 0, max: 5*2 * calc.pi, samples: 400),
      /* Horizontal and vertical lines */
      sample(t => (t, 0), min: -2, max: 2, samples: 2),
      sample(t => (0, t), min: -2, max: 2, samples: 2),
      width: 8cm,
      height: 6cm)
