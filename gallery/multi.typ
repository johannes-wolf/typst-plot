#import "@local/typst-plot:0.0.1": plot, axis

#set page(width: 12cm, height: 10cm)

#let data-temperature = (
  (0, 2 ), (1, 8 ), (2, 7 ), (3, 5 ), (4, 6 ), (5, 7 ),
  (6, 7 ), (7, 8 ), (8, 7 ), (9, 6 ), (10, 5), (11, 7),
  (12, 1), (13, 5), (14, 5), (15, 1), (16, 3), (17, 8),
  (18, 1), (19, 3), (20, 4), (21, 2), (22, 3), (23, 3),
  (24, 3),
)
#let data-humidity = (
  (0, 6 ), (1, 6 ), (2, 6 ), (3, 6 ), (4, 5 ), (5, 6 ),
  (6, 6 ), (7, 6 ), (8, 6 ), (9, 6 ), (10, 6), (11, 6),
  (12, 6), (13, 7), (14, 7), (15, 6), (16, 5), (17, 4),
  (18, 4), (19, 4), (20, 4), (21, 4), (22, 3), (23, 3),
  (24, 3),
)

#let x = axis(tics: (step: 2), label:
  [Time in hours])
#let y = axis(tics: (step: 2), label:
  [Temp. in C#sym.degree])
#let y2 = axis(tics: (step: 1), label:
  [Humidity in %])

#plot(width: 8cm,
      height: 6cm, 
      bottom: x,
      left: y, right: y2,
      (data: data-temperature, axes: ("bottom", "left"), style: (stroke: red), mark: "square"),
      (data: data-humidity, axes: ("bottom", "right"), style: (stroke: blue)),
 )
