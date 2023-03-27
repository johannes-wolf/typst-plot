# Typst Plotting Library
A simple [Typst](https://typst.app) library for plotting line charts.

## Getting Started

```typst
#import "plot.ty": plot, plot-axis, plot-data, plot-tics

#let my-data = (...)
#plot(plot-data(my-data),
      x-axis: plot-axis(range: (0, 100)),
      y-axis: plot-axis(range: (0, 1)))
```

## Examples
![Simple](examples/simple.png)
![Multiple Axes](examples/multi.png)
