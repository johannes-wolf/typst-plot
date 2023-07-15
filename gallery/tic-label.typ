#import "@local/typst-plot:0.0.1": plot, sample

#set page(width: 12cm, height: 10cm)

#plot(sample(x =>        calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>   .5 + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>  -.5 + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>   1  + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>  -1  + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      y-axis: (range: (-1, 1)),
      x-tics: (every: calc.pi, format: v => if v == 0 {[0]} else {
        $#{if v > calc.pi {v/calc.pi} else {[]}} pi$}),
      width: 8cm,
      height: 6cm)
