#import "@local/typst-plot:0.0.1": plot, sample, axis

#set page(width: 12cm, height: 10cm)

#plot(left: axis(min: -1, max: 1),
      bottom: axis(tics: (step: calc.pi,
        format: v => if v == 0 {[0]} else {
          $#{if v > calc.pi {v/calc.pi} else {[]}} pi$})),
      sample(x =>        calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>   .5 + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>  -.5 + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>   1  + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      sample(x =>  -1  + calc.sin(x), min: 0, max: 2*calc.pi, samples: 100),
      width: 8cm,
      height: 6cm)
