# Quantiles

`NumericColumn.quantiles` returns the sample quantiles associated with the values stored in the column; `NumericColumn.quantilesIfNormal` returns the theoretical quantiles under the assumption that the sampled population is normal.

## Test

The *sepal_length* data is roughly normal; expect the sample quantiles and theoretical quantiles to roughly match.

```dart
final s = iris.numericColumns["sepal_length"]!,
    xs = s.quantilesIfNormal,
    ys = s.quantiles,
    width = 50,
    height = 20,
    screen = [for (var _ = 0; _ < height; _++) [for (var i = 0; i < width; i++) i == 0 ? "|": " "]];

for (var i = 0; i < s.length; i++) {
  final x = (xs[i] * width).toInt(), y = height - 1 - (ys[i] * height).toInt();
  screen[y][x] = "o";
}

print("Sample Quantiles\n^\n|");
print(screen.map((row) => row.join("")).join("\n"));
print("+" + ">".padLeft(width, "-"));
print("Theoretical Quantiles".padLeft(width));
```

```text
Sample Quantiles
^
|
|                                               oo
|                                           oooo  
|                                         ooo     
|                                       o o       
|                                    o o          
|                                  o o            
|                                o o              
|                              o o                
|                         o o  o                  
|                      o  o                       
|                    o o                          
|                  o o                            
|               o  o                              
|           o o                                   
|        oo                                       
|      o o                                        
|      o                                          
|    oo                                           
|  ooo                                            
|ooo                                              
+------------------------------------------------->
                             Theoretical Quantiles

[3663 μs]
```
