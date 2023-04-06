# Typst Plotting Library
A simple [Typst](https://typst.app) library for plotting line charts.

## Getting Started

```typst
#import "plot.typ": plot
#import "plot-sample.typ": *

#plot(sample(x => calc.sin(x), min: 0, max: 2 * calc.pi))
```

## Examples
[![Simple](examples/simple.png)](examples/simple.typ)
[![Multiple Axes](examples/multi.png)](examples/multi.typ)
[![Tic labels](examples/tic-label.png)](examples/tic-label.typ)
[![Parametric plot](examples/parametric.png)](examples/parametric.typ)
