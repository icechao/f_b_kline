import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/data_adapter.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_renderer.dart';
import 'package:f_b_kline/src/chart/k_matrix_util.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:f_b_kline/src/chart/renderers/main_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/sen/cci_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/sen/kdj_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/sen/macd_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/sen/rsi_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/sen/wr_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/vol_renderer.dart';
import 'package:f_b_kline/src/chart/renderers/x_axis_renderer.dart';
import 'package:flutter/material.dart';

///日期格式化
typedef DateFormatter = String Function(int?);

///数值格式化
typedef ValueFormatter = String Function(num?);

///价格信息构建
typedef TextBuilder = TextSpan? Function(double?);

typedef InfoBuilder = Map<TextSpan, TextSpan> Function(KLineEntity);

///单例类,K线运行时类库
///不需要修改运行时配置
class KRunConfig {
  final KMatrixUtils matrixUtils = KMatrixUtils();

  final DateFormatter dateFormatter;
  final ValueFormatter mainValueFormatter;
  final ValueFormatter volValueFormatter;

  final InfoBuilder infoBuilder;

  final TextBuilder selectedPriceBuilder;

  late double height, width;
  Rect? mainRect, volRect, senRect;

  double translateX = double.nan;
  double scaleX = 1, scaleY = 1;
  double volBaseY = 0.0, senBaseY = 0.0;
  double kRightSpace = KStaticConfig().kRightSpace;
  double chartScaleWidth = KStaticConfig().candleItemWidth;

  late IRenderer mainRenderer, xAxisRenderer;
  IRenderer? volRenderer;
  IRenderer? senRenderer;
  late int screenLeft, screenRight;

  /// K线显示类型
  ChartGroupType? chartGroupType = ChartGroupType.withVol;

  /// K线显示类型
  ChartDisplayType chartDisplayType = ChartDisplayType.kline;

  /// 主图指标类型
  MainDisplayType mainDisplayType = MainDisplayType.boll;

  /// 附图类型
  ChartSenType chartSenType = ChartSenType.kdj;

  /// 十字线显示模式
  CrossType crossType = CrossType.followAll;

  /// Y轴显示模式
  XAxisType xAxisType = XAxisType.pin;

  /// 点击模式
  TapType tapType = TapType.continuous;

  ///主图与量图颜色同步
  late Color chartColor;

  /// 手势触发时按住的位置
  double? selectedX, selectedY;
  int? selectedIndex;

  /// constructor
  /// [dateFormatter] data formatter
  /// [mainValueFormatter] main value formatter
  /// [volValueFormatter] vol value formatter
  KRunConfig(
      {required this.dateFormatter,
      required this.mainValueFormatter,
      required this.volValueFormatter,
      required this.selectedPriceBuilder,
      required this.infoBuilder});

  ///max length of data
  double calcDataLength(int count) {
    return count * chartScaleWidth;
  }

  /// storage size in memory
  /// [size] size
  void setSize(Size size) {
    width = size.width;
    height = size.height;
  }

  /// init area rest
  /// [type] show type  [ChartGroupType]
  /// [adapter] data adapter  [DataAdapter]
  void initRect(ChartGroupType? type, DataAdapter adapter) {
    type ??= ChartGroupType.withVol;
    var kStaticConfig = KStaticConfig();
    var padding = kStaticConfig.topPadding;
    chartGroupType = type;
    var rowCount = kStaticConfig.gridRowCount;
    double item = (height - padding - kStaticConfig.xAxisHeight) / rowCount;
    mainRenderer = MainRenderer(this, adapter, matrixUtils)
      ..axisPainter.add(KTextPainter(width, padding));
    switch (chartGroupType!) {
      case ChartGroupType.withVolSen:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 2) + padding);
        for (int i = 1; i < rowCount - 1; i++) {
          mainRenderer.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volBaseY = mainRect!.bottom;
        volRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * (rowCount - 1) + padding);
        volRenderer = VolRenderer(this, adapter, matrixUtils)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 2)),
            KTextPainter(width, padding + item * (rowCount - 1)),
          ]);
        senBaseY = volRect!.bottom;
        senRect =
            Rect.fromLTRB(0, volRect!.bottom, width, item * rowCount + padding);
        senRenderer = getSenRenderer(adapter)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);
        break;
      case ChartGroupType.withSen:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 1) + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRenderer.axisPainter.add(KTextPainter(width, padding + item * i));
        }

        volRect = null;
        volRenderer = null;
        senBaseY = mainRect!.bottom;
        senRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * rowCount + padding);
        senRenderer = getSenRenderer(adapter)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);
        break;
      case ChartGroupType.withNone:
        mainRect = Rect.fromLTRB(0, padding, width, item * 5 + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRenderer.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volRect = null;
        volRenderer = null;
        senRect = null;
        senRenderer = null;
        break;
      case ChartGroupType.withVol:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 1) + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRenderer.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volBaseY = mainRect!.bottom;
        volRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * rowCount + padding);
        volRenderer = VolRenderer(this, adapter, matrixUtils)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);

        senRect = null;
        senRenderer = null;
        break;
    }

    xAxisRenderer = XAxisRenderer(this, adapter, matrixUtils);
    var columnCount = kStaticConfig.xAxisCount;
    double xSpace = width / (columnCount + 1);
    switch (xAxisType) {
      case XAxisType.flow:
        for (int i = -rowCount ~/ 2 - 1; i <= rowCount ~/ 2 + 1; i++) {
          xAxisRenderer.axisPainter.add(
            KTextPainter(xSpace * i, height,
                boxHeight: kStaticConfig.xAxisHeight,
                xParser: (x) => translateX % width + x),
          );
        }
        break;
      default:
        for (int i = 0; i <= rowCount; i++) {
          if (kStaticConfig.fitXAxis) {
            if (i == 0) {
              xAxisRenderer.axisPainter.add(KTextPainter(xSpace * i, height,
                  boxHeight: kStaticConfig.xAxisHeight, align: KAlign.right));
            } else if (i == rowCount) {
              xAxisRenderer.axisPainter.add(KTextPainter(xSpace * i, height,
                  boxHeight: kStaticConfig.xAxisHeight, align: KAlign.left));
            } else {
              xAxisRenderer.axisPainter.add(KTextPainter(xSpace * i, height,
                  boxHeight: kStaticConfig.xAxisHeight, align: KAlign.center));
            }
          } else {
            xAxisRenderer.axisPainter.add(KTextPainter(xSpace * i, height,
                boxHeight: kStaticConfig.xAxisHeight, align: KAlign.center));
          }
        }
    }
  }

  ///index of screen left & right
  void calcScreenIndex(DataAdapter adapter) {
    double dataLength = calcDataLength(adapter.dataLength);

    if (translateX.isNaN) {
      translateX = calcMinTranslateX(adapter.dataLength);
    }
    if (dataLength < width) {
      screenLeft = 0;
      screenRight = adapter.dataLength - 1;
    } else {
      int windowItemCount = (width / chartScaleWidth).ceil();

      screenLeft = (translateX.abs() / chartScaleWidth).ceil() - 1;
      screenRight = screenLeft + windowItemCount;

      if (screenLeft < 0) {
        screenLeft = 0;
      }
      if (screenRight >= adapter.dataLength) {
        screenRight = adapter.dataLength - 1;
      }
    }
  }

  ///calc data witch need display
  /// [adapter] data adapter  [DataAdapter]
  void calcShowValues(DataAdapter adapter) {
    if (adapter.data.isEmpty) {
      return;
    }
    adapter.mainDisplayPoints = [];
    adapter.volDisplayPoints = [];
    adapter.senDisplayPoints = [];
    mainRenderer.displayValueMax = double.minPositive;
    mainRenderer.chartAsiaMax = double.minPositive;
    mainRenderer.displayValueMin = double.maxFinite;
    mainRenderer.chartAsiaMin = double.maxFinite;

    volRenderer?.displayValueMax = double.minPositive;
    volRenderer?.displayValueMin = double.maxFinite;

    senRenderer?.displayValueMax = double.minPositive;
    senRenderer?.displayValueMin = double.maxFinite;

    for (int i = screenLeft; i <= screenRight; i++) {
      KLineEntity item = adapter.data[i];
      double xIndex = (i.toDouble());
      double zIndex = 0;
      if (mainRenderer.maxValueIndex == i) {
        zIndex++;
      }
      if (mainRenderer.minValueIndex == i) {
        zIndex++;
      }
      addToMainPoints(adapter, xIndex, item, zIndex);

      addToVolPoints(adapter, xIndex, item, i);

      addToSecPoints(adapter, xIndex, item, i);
      mainRenderer.calcMaxMin(item, i);
    }

    calcMaxMin(KStaticConfig().displayFactor);

    mapPoints(adapter);
  }

  /// map points
  /// [adapter] data adapter  [DataAdapter]
  void mapPoints(DataAdapter adapter) {
    KMatrixUtils().exeMainMatrix(
        translateX,
        -mainRenderer.chartAsiaMax,
        chartScaleWidth,
        mainRect!.height /
            (mainRenderer.chartAsiaMax - mainRenderer.chartAsiaMin),
        adapter.mainDisplayPoints,
        preTranslateY: -KStaticConfig().topPadding);
    if (volRect != null) {
      KMatrixUtils().exeVolMatrix(
          translateX,
          -volRenderer!.chartAsiaMax,
          chartScaleWidth,
          volRect!.height /
              (volRenderer!.chartAsiaMax - (volRenderer?.chartAsiaMin)!),
          adapter.volDisplayPoints,
          preTranslateY: -volBaseY);
    }
    if (senRect != null) {
      KMatrixUtils().exeSenMatrix(
          translateX,
          -senRenderer!.chartAsiaMax,
          chartScaleWidth,
          senRect!.height /
              (senRenderer!.chartAsiaMax - senRenderer!.chartAsiaMin),
          adapter.senDisplayPoints,
          preTranslateY: -senBaseY);
    }
  }

  void addToSecPoints(
      DataAdapter adapter, double xIndex, KLineEntity item, int i) {
    if (senRect != null) {
      adapter.senDisplayPoints
        ..add(xIndex)
        ..add(item.macd ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.dif ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.dea ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.k ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.d ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.j ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.r ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.rsi ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.cci ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(0.0)
        ..add(0.0);
      senRenderer?.calcMaxMin(item, i);
    }
  }

  void addToVolPoints(
      DataAdapter adapter, double xIndex, KLineEntity item, int i) {
    if (volRect != null) {
      adapter.volDisplayPoints
        ..add(xIndex)
        ..add(item.vol)
        ..add(0.0)
        ..add(0.0)
        ..add(item.maVolume1 ?? double.infinity)
        ..add(0.0)
        ..add(0.0)
        ..add(item.maVolume2 ?? double.infinity)
        ..add(0.0);

      volRenderer?.calcMaxMin(item, i);
    }
  }

  void addToMainPoints(
      DataAdapter adapter, double xIndex, KLineEntity item, double zIndex) {
    adapter.mainDisplayPoints
      ..add(xIndex)
      ..add(item.open)
      ..add(zIndex)
      ..add(0.0)
      ..add(item.close)
      ..add(0.0)
      ..add(0.0)
      ..add(item.low)
      ..add(0.0)
      ..add(0.0)
      ..add(item.high)
      ..add(0.0)
      ..add(0.0)
      ..add(item.ma1 ?? double.infinity)
      ..add(0.0)
      ..add(0.0)
      ..add(item.ma2 ?? double.infinity)
      ..add(0.0)
      ..add(0.0)
      ..add(item.ma3 ?? double.infinity)
      ..add(0.0)
      ..add(0.0)
      ..add(item.mb ?? double.infinity)
      ..add(0.0)
      ..add(0.0)
      ..add(item.up ?? double.infinity)
      ..add(0.0)
      ..add(0.0)
      ..add(item.dn ?? double.infinity)
      ..add(0.0);
  }

  ///calc max & min value
  /// [displayFactor] display factor
  void calcMaxMin(double displayFactor) {
    if (mainRenderer.displayValueMin == mainRenderer.displayValueMax) {
      mainRenderer.displayValueMax =
          mainRenderer.displayValueMax * (1 + displayFactor);
      mainRenderer.displayValueMin =
          mainRenderer.displayValueMin * (1 - displayFactor);
    }

    if (volRenderer?.displayValueMin == volRenderer?.displayValueMin) {
      volRenderer?.displayValueMax =
          (volRenderer?.displayValueMax ?? 0.0) * (1 + displayFactor);
      volRenderer?.displayValueMin =
          (volRenderer?.displayValueMin ?? 0.0) * (1 - displayFactor);
    }

    if (senRenderer?.displayValueMin == senRenderer?.displayValueMin) {
      senRenderer?.displayValueMax =
          (senRenderer?.displayValueMax ?? 0.0) * (1 + displayFactor);
      senRenderer?.displayValueMin =
          (senRenderer?.displayValueMin ?? 0.0) * (1 - displayFactor);
    }

    mainRenderer.chartAsiaMax = mainRenderer.displayValueMax +
        (mainRenderer.displayValueMax - mainRenderer.displayValueMin) *
            displayFactor;
    mainRenderer.chartAsiaMin = mainRenderer.displayValueMin -
        (mainRenderer.displayValueMax - mainRenderer.displayValueMin) *
            displayFactor;

    volRenderer?.chartAsiaMax = (volRenderer?.displayValueMax ?? 0.0) +
        ((volRenderer?.displayValueMax ?? 0.0) -
                (volRenderer?.displayValueMin ?? 0.0)) *
            displayFactor;
    volRenderer?.chartAsiaMin = (volRenderer?.displayValueMin ?? 0.0) -
        ((volRenderer?.displayValueMax ?? 0.0) -
                (volRenderer?.displayValueMin ?? 0.0)) *
            displayFactor;

    senRenderer?.chartAsiaMax = (senRenderer?.displayValueMax ?? 0.0) +
        ((senRenderer?.displayValueMax ?? 0.0) -
                (senRenderer?.displayValueMin ?? 0.0)) *
            displayFactor;
    senRenderer?.chartAsiaMin = (senRenderer?.displayValueMin ?? 0.0) -
        ((senRenderer?.displayValueMax ?? 0.0) -
                (senRenderer?.displayValueMin ?? 0.0)) *
            displayFactor;
  }

  /// calc min translate
  /// [itemCount] data length
  double calcMinTranslateX(int itemCount) {
    var length = -calcDataLength(itemCount);
    if (kRightSpace - length > width) {
      return length - kRightSpace + width;
    } else {
      return 0.0;
    }
  }

  /// change scale
  /// [scale] new scale
  /// [length] data length
  void updateScale(double scale, int length) {
    var dataLength = calcDataLength(length);
    var halfWidth = width / 2;
    double rate = (halfWidth - translateX) / dataLength;
    scaleX = scale.clamp(0.2, 5);
    chartScaleWidth = KStaticConfig().candleItemWidth * scaleX;
    dataLength = calcDataLength(length);
    updateTranslate(halfWidth - (dataLength * rate), length);
  }

  ///change translate to new translate
  /// [translate] new translate
  /// [length] data length
  void updateTranslate(double translate, int length) {
    var min = calcMinTranslateX(length);
    translateX = translate.clamp(min, 0);
  }

  ///update translate with diff
  /// [dx] diff  x
  /// [length] data length
  void updateTranslateWithDx(double dx, int length) {
    var min = calcMinTranslateX(length);
    translateX = (translateX + dx).clamp(min, 0);
  }

  /// x to index
  /// [x] translate x
  /// [length] data length
  ///  return index of x
  int xToIndex(double x, int length) {
    var ceil = ((x - translateX) / chartScaleWidth).floor();
    return ceil.clamp(0, length - 1);
  }

  ///paint
  ///[canvas]
  ///[canvas]
  /// [adapter] data adapter  [DataAdapter]
  void rendererChart(Canvas canvas, DataAdapter adapter) {
    for (int i = screenLeft; i <= screenRight; i++) {
      int startIndex = 3 * 10 * (i - screenLeft);
      int stopIndex = 3 * 10 * (i + 1 - screenLeft);

      int lastStartIndex = 3 * 10 * (i - screenLeft - 1);
      int lastStopIndex = 3 * 10 * (i - screenLeft);

      mainRenderer.rendererChart(
          canvas,
          adapter.mainDisplayPoints.sublist(startIndex, stopIndex),
          lastStartIndex < 0
              ? List.filled(stopIndex - startIndex, double.infinity)
              : adapter.mainDisplayPoints
                  .sublist(lastStartIndex, lastStopIndex),
          chartScaleWidth,
          i);

      startIndex = 3 * 3 * (i - screenLeft);
      stopIndex = 3 * 3 * (i + 1 - screenLeft);

      lastStartIndex = 3 * 3 * (i - screenLeft - 1);
      lastStopIndex = 3 * 3 * (i - screenLeft);

      volRenderer?.rendererChart(
          canvas,
          adapter.volDisplayPoints.sublist(startIndex, stopIndex),
          lastStartIndex < 0
              ? List.filled(stopIndex - startIndex, double.infinity)
              : adapter.volDisplayPoints.sublist(lastStartIndex, lastStopIndex),
          chartScaleWidth,
          i);

      startIndex = 3 * 10 * (i - screenLeft);
      stopIndex = 3 * 10 * (i + 1 - screenLeft);

      lastStartIndex = 3 * 10 * (i - screenLeft - 1);
      lastStopIndex = 3 * 10 * (i - screenLeft);
      senRenderer?.rendererChart(
          canvas,
          adapter.senDisplayPoints.sublist(startIndex, stopIndex),
          lastStartIndex < 0
              ? List.filled(stopIndex - startIndex, double.infinity)
              : adapter.senDisplayPoints.sublist(lastStartIndex, lastStopIndex),
          chartScaleWidth,
          i);
    }
    xAxisRenderer
      ..rendererAxis(canvas)
      ..rendererLine(canvas)
      ..rendererText(canvas);
    mainRenderer
      ..rendererAxis(canvas)
      ..rendererLine(canvas, builder: selectedPriceBuilder)
      ..rendererText(canvas);
    volRenderer
      ?..rendererAxis(canvas)
      ..rendererLine(canvas)
      ..rendererText(canvas);
    senRenderer
      ?..rendererAxis(canvas)
      ..rendererLine(canvas)
      ..rendererText(canvas);
  }

  /// the selected x point
  /// [dx] diff x
  void updateSelectedX(double? dx) {
    if (dx == null) {
      selectedIndex = null;
    }
    selectedX = dx;
  }

  /// the selected x point
  /// [dy] diff y
  void updateSelectedY(double? dy) {
    selectedY = dy;
  }

  /// build selected info
  /// [adapter] data adapter  [DataAdapter]
  /// [selectedIndex] selected index
  Map<TextSpan, TextSpan> getMarketInfo(
      DataAdapter adapter, int selectedIndex) {
    KLineEntity data = adapter.data[selectedIndex];
    return infoBuilder.call(data);
  }

  /// second renderer init
  /// [adapter] data adapter  [DataAdapter]
  IRenderer getSenRenderer(DataAdapter adapter) {
    switch (chartSenType) {
      case ChartSenType.macd:
        return MacdRenderer(this, adapter, matrixUtils);
      case ChartSenType.kdj:
        return KdjRenderer(this, adapter, matrixUtils);
      case ChartSenType.wr:
        return WrRenderer(this, adapter, matrixUtils);
      case ChartSenType.rsi:
        return RsiRenderer(this, adapter, matrixUtils);
      case ChartSenType.cci:
        return CciRenderer(this, adapter, matrixUtils);
    }
  }
}
