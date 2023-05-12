

<img src="[https://github.com/icechao/KlineChart/blob/master/1565013719576.gif](https://github.com/icechao/f_b_kline/blob/master/image.png)" width="320" hegiht="480" align=center/>

### 使用
持续更新中请尽量使用库依赖

Adapter不需要重新初始化 只需要一个adapter请做好内存管理

```dart

    final DataAdapter adapter = DataAdapter();

    ......

   return Container(
          margin: const EdgeInsets.only(top: 100),
          width: double.maxFinite,
          ///max height
          height: 400, 
          child: KChartWidget(
            /// data adapter 
            adapter,
            /// static config
            config: KRunConfig(
              dateFormatter: (int? value) {
                return formatDate(
                    DateTime.fromMillisecondsSinceEpoch(value ?? 0));
              },
              mainValueFormatter: (number) {
                return number?.toStringAsFixed(3) ?? '--';
              },
              volValueFormatter: (number) {
                return number?.toStringAsFixed(3) ?? '--';
              },
            ),
          ),
        )
```
### 修改指数参数及配置信息   
    KStaticConfig 静态配置信息不
```dart

    KStaticConfig()
      ..mainMa1 = 10
      ..mainMa2 = 30
      ....

```
### 常用API
```dart
  ///重置数据 当数据发生变化时调用
  ///[KLineEntity]数据模型
  resetData(List<KLineEntity>? data, {bool resetTranslate = false})
```


```dart
  ///chart display type 
  /// [ChartGroupType]  main display area
  /// [ChartSenType]    second type
  /// [ChartDisplayType]  time/kline
  /// [MainDisplayType]   boll / ma /none
  changeType(dynamic type) 
```

```dart
  /// change chart display location
  changeTranslate(double translate)
```


