![Image](https://github.com/icechao/f_b_kline/blob/master/image.png)

![Image](https://github.com/icechao/f_b_kline/blob/master/wxGroup.png)

## 使用
[安卓原生K线](https://github.com/icechao/KlineChart)


[完整使用DEMO](https://github.com/icechao/f_b_kline/blob/master/lib/example/f_b_kline.dart)

持续更新中请尽量使用库依赖

DataAdapter不需要重新初始化 只需要一个adapter请做好内存管理

```dart

  import 'package:f_b_kline/chart/export_k_chart.dart';

```

```dart
    
    final DataAdapter adapter = DataAdapter();

    ......
    
    retutrn Container(
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
                infoBuilder: (klineEntry) {
                return <TextSpan, TextSpan>{
                    const TextSpan(text: 'Date'): TextSpan(
                    text: formatDate2(
                    DateTime.fromMillisecondsSinceEpoch(klineEntry.time ?? 0),
                    )),
                    const TextSpan(text: 'open'):
                     TextSpan(text: klineEntry.open.toStringAsFixed(3)),
                    const TextSpan(text: 'high'):
                      TextSpan(text: klineEntry.high.toStringAsFixed(3)),
                    const TextSpan(text: 'low'):
                      TextSpan(text: klineEntry.low.toStringAsFixed(3)),
                    const TextSpan(text: 'close'):
                      TextSpan(text: klineEntry.close.toStringAsFixed(3)),
                    const TextSpan(text: 'vol'):
                      TextSpan(text: klineEntry.vol.toStringAsFixed(3)),
                    };
                    },
                ),
            ),
        ),
    )

    ......


    adapter.resetData(data);
```

### 修改指数参数及配置信息

    KStaticConfig 静态配置信息
...dart

...

```dart

    KStaticConfig()
    ..mainMa1 = 10
    ..mainMa2 = 30
    ......
    

```

### 常用API

```dart
    ///重置数据 当数据发生变化时调用
    ///[KLineEntity]数据模型
    ///更多API查看 [DataAdapter]
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




