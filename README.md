### 使用
```dart

    final DataAdapter adapter = DataAdapter();

    ......

   return Container(
          margin: const EdgeInsets.only(top: 100),
          width: double.maxFinite,
          height: 400,
          child: KChartWidget(
            adapter,
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
    KStaticConfig
```dart
KStaticConfig().mainMa1 = 10;
adapter.resetData(data)

```
### 常用API
```dart
  ///重置数据 当数据发生变化时调用
  ///[KLineEntity]数据模型
  resetData(List<KLineEntity>? data, {bool resetTranslate = false})
```


```dart
  ///chart显示组合类型 会自动根据类型切换对应的类型
  /// [ChartGroupType]  主图成交量指标视图显示
  /// [ChartSenType]    附图类型显示
  /// [ChartDisplayType]  K线还是折线图
  /// [MainDisplayType]  主图指标显示
  changeType(dynamic type) 
```

```dart
  ///X轴平移变化
  changeTranslate(double translate)
```
