# Products

```dart
print(petals.toMarkdown());
```

```text
|  id   | petal_length | petal_width |  species   |
| :---: | :----------: | :---------: | :--------: |
|   1   |     1.4      |     0.2     |   setosa   |
|   2   |     1.4      |     0.2     |   setosa   |
|   3   |     1.3      |     0.2     |   setosa   |
|   4   |     1.5      |     0.2     |   setosa   |
|  51   |     4.7      |     1.4     | versicolor |
|  52   |     4.5      |     1.5     | versicolor |
|  53   |     4.9      |     1.5     | versicolor |
|  54   |     4.0      |     1.3     | versicolor |
|  101  |     6.0      |     2.5     | virginica  |
|  102  |     5.1      |     1.9     | virginica  |
|  103  |     5.9      |     2.1     | virginica  |
|  104  |     5.6      |     1.8     | virginica  |

```

```dart
print(petals.toCsv());
```

```text
id,petal_length,petal_width,species
1,1.4,0.2,setosa
2,1.4,0.2,setosa
3,1.3,0.2,setosa
4,1.5,0.2,setosa
51,4.7,1.4,versicolor
52,4.5,1.5,versicolor
53,4.9,1.5,versicolor
54,4.0,1.3,versicolor
101,6.0,2.5,virginica
102,5.1,1.9,virginica
103,5.9,2.1,virginica
104,5.6,1.8,virginica

```

```dart
print(petals.toHtml());
```

```text
<table>
<tr><th>id</th><th>petal_length</th><th>petal_width</th><th>species</th></tr>
<tr><td>1</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
<tr><td>2</td><td>1.4</td><td>0.2</td><td>setosa</td></tr>
<tr><td>3</td><td>1.3</td><td>0.2</td><td>setosa</td></tr>
<tr><td>4</td><td>1.5</td><td>0.2</td><td>setosa</td></tr>
<tr><td>51</td><td>4.7</td><td>1.4</td><td>versicolor</td></tr>
<tr><td>52</td><td>4.5</td><td>1.5</td><td>versicolor</td></tr>
<tr><td>53</td><td>4.9</td><td>1.5</td><td>versicolor</td></tr>
<tr><td>54</td><td>4.0</td><td>1.3</td><td>versicolor</td></tr>
<tr><td>101</td><td>6.0</td><td>2.5</td><td>virginica</td></tr>
<tr><td>102</td><td>5.1</td><td>1.9</td><td>virginica</td></tr>
<tr><td>103</td><td>5.9</td><td>2.1</td><td>virginica</td></tr>
<tr><td>104</td><td>5.6</td><td>1.8</td><td>virginica</td></tr>
</table>

```

```dart
print(sepals.withHead(2).toJsonAsMapOfLists());
```

```text
{"id":["3","4"],"sepal_length":[4.7,4.6],"sepal_width":[3.2,3.1]}
```

