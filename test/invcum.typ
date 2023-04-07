#import "../plot.typ": plot

#let data = csv("../doc/data/invcum.dat").map(r => r.map(c => float(c)))

#plot((stroke: blue, data: data),
      x-tics: (every: .2),
      y-tics: (every: 2))
