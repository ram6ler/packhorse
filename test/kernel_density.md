# Kernel & Gaussian Density Estimation

`NumericColumn.kernelDensity` returns a nonparametric probability density function estimated from the data in the column instance.

## Test

The *sepal_length* data is roughly normal; expect the cumulative kernel density to approximately match the relative cumulative frequency and the cumulative probability assuming a Gaussian distribution.

```dart
final s = iris.numericColumns["sepal_length"]!,
    f = s.kernelDensityFunction,
    g = s.densityFunctionIfNormal,
    from = s.least - 0.1 * s.range,
    to = s.greatest + 0.1 * s.range,
    n = 20,
    dx = (to - from) / n,
    columnWidth = 12,
    cell = (String value) => value.padLeft(columnWidth),
    plot = (num p) => ("|" + "=" * (p * 10).toInt()).padRight(columnWidth);

var kernel = 0.0, normal = 0.0;
print(["s_len", "crf", "", "kernel", "", "gauss"].map(cell).join());
for (var i = 0; i <= n; i++) {
  final x = from + dx * i, p = s.values.where((t) => t < x).length / s.length;
  kernel += f(x) * dx;
  normal += g(x) * dx;
  print([
    x.toStringAsFixed(3),
    p.toStringAsFixed(3),
    plot(p),
    kernel.toStringAsFixed(3),
    plot(kernel),
    normal.toStringAsFixed(3),
    plot(normal),
  ].map(cell).join());
  
}
```

```text
       s_len         crf                  kernel                   gauss
       3.940       0.000|                  0.001|                  0.007|           
       4.156       0.000|                  0.009|                  0.020|           
       4.372       0.007|                  0.032|                  0.042|           
       4.588       0.033|                  0.075|                  0.074|           
       4.804       0.107|=                 0.147|=                 0.122|=          
       5.020       0.213|==                0.240|==                0.185|=          
       5.236       0.300|===               0.320|===               0.265|==         
       5.452       0.347|===               0.400|====              0.358|===        
       5.668       0.433|====              0.490|====              0.460|====       
       5.884       0.533|=====             0.574|=====             0.564|=====      
       6.100       0.593|=====             0.657|======            0.664|======     
       6.316       0.720|=======           0.744|=======           0.753|=======    
       6.532       0.800|========          0.820|========          0.826|========   
       6.748       0.867|========          0.880|========          0.883|========   
       6.964       0.913|=========         0.919|=========         0.925|=========  
       7.180       0.927|=========         0.944|=========         0.953|=========  
       7.396       0.953|=========         0.962|=========         0.971|=========  
       7.612       0.967|=========         0.980|=========         0.981|=========  
       7.828       0.993|=========         0.994|=========         0.987|=========  
       8.044       1.000|==========        0.999|=========         0.990|=========  
       8.260       1.000|==========        1.000|=========         0.992|=========  

[3869 μs]
```

## Potential Issues

* The pdf goes through a list of normal distributions generated from each point in the column to accumulate their weighted input, and is thus pretty inefficient. Efficiency could be improved by storing values and setting up interpolation if necessary.

* Possibly the result can be cached inside the `NumericColumn` instance so that the function can be called directly on the object and guaranteed to be up to date if data inside the column is changed.
