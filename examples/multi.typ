#import "util.typ": plot-fn
#import "../plot.typ": plot, plot-data

#set page(width: 10cm, height: 7cm)

#plot((plot-data(plot-fn(min: 0, max: 2*calc.pi, steps: 40, { x => calc.sin(x) }), x-axis: "x"), 
       plot-data(plot-fn(min: 0, max: 2*calc.pi, steps: 40, { x => calc.cos(x) }), x-axis: "x2")), 
  multi:true,
  width: 8cm,
  height: 4.5cm, 

  x-axis: (range: (-1, calc.pi * 2 + 1)),
  x-tics: (stroke: black, every: calc.pi, tics: (calc.pi/2,),
           mirror: false,
           format: v => {return str(v/calc.pi) + math.pi}),

  y-axis: (range: (-2, 2)),
  y-tics: (stroke: green + .5pt, tics: (0, 1, 2)),

  x2-axis: (range: (0, calc.pi * 2 )),
  x2-tics: (stroke: red + .5pt, every: 1.5, mirror: false),
 )
