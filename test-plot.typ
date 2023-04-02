#import "plot.typ": plot, plot-data

#let plot-fn(fn, min: -1, max: 1, steps: 100) = {
   let data = ()
   for n in range(0, steps + 1) {
     let x = min + (max - min) / steps * n
     data.push((x, fn(x)))
   }
   return data
}

#figure(caption: [Simple plot])[
  #plot(plot-data(plot-fn(min: -10, max: 10, x => { return calc.pow(x, 3) }), stroke: 1cm),
    y-tics: (every: 250, format: "sci"),
    width: 10cm,
    height: 10cm)
  ]

#figure(caption: [Multiple Axes])[
  #plot(plot-data(plot-fn(min: 0, max: 2*calc.pi, steps: 40, { x => calc.sin(x) }), x-axis: "x"), 
         plot-data(plot-fn(min: 0, max: 2*calc.pi, steps: 40, { x => calc.cos(x) }), x-axis: "x2"), 
    width: 10cm, height: 5cm, 

    x-axis: (range: (-1, calc.pi * 2 + 1)),
    x-tics: (stroke: black, every: calc.pi, tics: (calc.pi/2,),
	              mirror: false,
		      format: v => {return str(v/calc.pi) + math.pi}),

    y-axis: (range: (-2, 2)),
    y-tics: (stroke: green + .5pt, tics: (0, 1, 2)),

    x2-axis: (range: (0, calc.pi * 2 )),
    x2-tics: (stroke: red + .5pt, every: 1.5, mirror: false),)
]

