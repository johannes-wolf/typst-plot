#import "util.typ": plot-fn
#import "../plot.typ": plot, plot-data

#set page(width: 10cm, height: 7cm)

#let data-temperature = csv("temp.csv")
#let data-humidity = csv("humidity.csv")

#plot(width: 8cm,
      height: 4.5cm, 
      x-tics: (every: 2),
      x-label: [Time in hours],
      y-tics: (every: 2, mirror: false),
      y-label: [Temp. in C#sym.degree],
      y2-tics: (every: 1, mirror: false),
      y2-label: [Humidity in %],
      plot-data(data-temperature, y-axis: "y", stroke: red),
      plot-data(data-humidity, y-axis: "y2", stroke: blue),
 )

