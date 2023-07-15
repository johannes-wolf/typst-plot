#import "@local/typst-plot:0.0.1": plot, sample

#set page(width: 12cm, height: 10cm)

#plot(sample(x => calc.sin(x), min: 0, max: 2*calc.pi, samples: 50),
      width: 8cm,
      height: 6cm)
