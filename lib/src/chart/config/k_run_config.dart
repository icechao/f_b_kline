import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/data_adapter.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_render.dart';
import 'package:f_b_kline/src/chart/k_matrix_util.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:f_b_kline/src/chart/renders/main_render.dart';
import 'package:f_b_kline/src/chart/renders/sen/cci_render.dart';
import 'package:f_b_kline/src/chart/renders/sen/kdj_render.dart';
import 'package:f_b_kline/src/chart/renders/sen/macd_render.dart';
import 'package:f_b_kline/src/chart/renders/sen/rsi_render.dart';
import 'package:f_b_kline/src/chart/renders/sen/wr_render.dart';
import 'package:f_b_kline/src/chart/renders/vol_render.dart';
import 'package:f_b_kline/src/chart/renders/x_axis_render.dart';
import 'package:flutter/material.dart';

///日期格式化
typedef DateFormatter = String Function(int?);

///数值格式化
typedef ValueFormatter = String Function(num?);

///价格信息构建
typedef TextBuilder = Function(double?);

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

  late IRender mainRender, xAxisRender;
  IRender? volRender;
  IRender? senRender;
  late int screenLeft, screenRight;

  ChartGroupType? chartGroupType = ChartGroupType.withVol;
  ChartDisplayType chartDisplayType = ChartDisplayType.kline;
  MainDisplayType mainDisplayType = MainDisplayType.boll;
  ChartSenType chartSenType = ChartSenType.kdj;
  CrossType crossType = CrossType.followAll;
  XAxisType xAxisType = XAxisType.flow;

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
    mainRender = MainRender(this, adapter, matrixUtils)
      ..axisPainter.add(KTextPainter(width, padding));
    switch (chartGroupType!) {
      case ChartGroupType.withVolSen:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 2) + padding);
        for (int i = 1; i < rowCount - 1; i++) {
          mainRender.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volBaseY = mainRect!.bottom;
        volRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * (rowCount - 1) + padding);
        volRender = VolRender(this, adapter, matrixUtils)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 2)),
            KTextPainter(width, padding + item * (rowCount - 1)),
          ]);
        senBaseY = volRect!.bottom;
        senRect =
            Rect.fromLTRB(0, volRect!.bottom, width, item * rowCount + padding);
        senRender = getSenRender(adapter)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);
        break;
      case ChartGroupType.withSen:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 1) + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRender.axisPainter.add(KTextPainter(width, padding + item * i));
        }

        volRect = null;
        volRender = null;
        senBaseY = mainRect!.bottom;
        senRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * rowCount + padding);
        senRender = getSenRender(adapter)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);
        break;
      case ChartGroupType.withNone:
        mainRect = Rect.fromLTRB(0, padding, width, item * 5 + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRender.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volRect = null;
        volRender = null;
        senRect = null;
        senRender = null;
        break;
      case ChartGroupType.withVol:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 1) + padding);
        for (int i = 1; i < rowCount; i++) {
          mainRender.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volBaseY = mainRect!.bottom;
        volRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * rowCount + padding);
        volRender = VolRender(this, adapter, matrixUtils)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);

        senRect = null;
        senRender = null;
        break;
    }

    xAxisRender = XAxisRender(this, adapter, matrixUtils);
    var columnCount = kStaticConfig.xAxisCount;
    double xSpace = width / (columnCount);
    switch (xAxisType) {
      case XAxisType.flow:
        for (int i = -rowCount ~/ 2 - 1; i <= rowCount ~/ 2 + 1; i++) {
          xAxisRender.axisPainter.add(KTextPainter(xSpace * i, height,
              boxHeight: kStaticConfig.xAxisHeight, xParser: (x) {
            return translateX % width + x;
          }));
        }
        break;
      default:
        for (int i = 0; i <= rowCount + 1; i++) {
          xAxisRender.axisPainter.add(KTextPainter(xSpace * i, height,
              boxHeight: kStaticConfig.xAxisHeight));
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
    mainRender.displayValueMax = double.minPositive;
    mainRender.chartAsiaMax = double.minPositive;
    mainRender.displayValueMin = double.maxFinite;
    mainRender.chartAsiaMin = double.maxFinite;

    volRender?.displayValueMax = double.minPositive;
    volRender?.displayValueMin = double.maxFinite;

    senRender?.displayValueMax = double.minPositive;
    senRender?.displayValueMin = double.maxFinite;

    for (int i = screenLeft; i <= screenRight; i++) {
      KLineEntity item = adapter.data[i];
      double xIndex = (i.toDouble());
      double zIndex = 0;
      if (mainRender.maxValueIndex == i) {
        zIndex++;
      }
      if (mainRender.minValueIndex == i) {
        zIndex++;
      }
      addToMainPoints(adapter, xIndex, item, zIndex);

      addToVolPoints(adapter, xIndex, item, i);

      addToSecPoints(adapter, xIndex, item, i);
      mainRender.calcMaxMin(item, i);
    }

    calcMaxMin(KStaticConfig().displayFactor);

    mapPoints(adapter);
  }

  /// map points
  /// [adapter] data adapter  [DataAdapter]
  void mapPoints(DataAdapter adapter) {
    KMatrixUtils().exeMainMatrix(
        translateX,
        -mainRender.chartAsiaMax,
        chartScaleWidth,
        mainRect!.height / (mainRender.chartAsiaMax - mainRender.chartAsiaMin),
        adapter.mainDisplayPoints,
        preTranslateY: -KStaticConfig().topPadding);
    if (volRect != null) {
      KMatrixUtils().exeVolMatrix(
          translateX,
          -volRender!.chartAsiaMax,
          chartScaleWidth,
          volRect!.height /
              (volRender!.chartAsiaMax - (volRender?.chartAsiaMin)!),
          adapter.volDisplayPoints,
          preTranslateY: -volBaseY);
    }
    if (senRect != null) {
      KMatrixUtils().exeSenMatrix(
          translateX,
          -senRender!.chartAsiaMax,
          chartScaleWidth,
          senRect!.height / (senRender!.chartAsiaMax - senRender!.chartAsiaMin),
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
      senRender?.calcMaxMin(item, i);
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

      volRender?.calcMaxMin(item, i);
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
    if (mainRender.displayValueMin == mainRender.displayValueMax) {
      mainRender.chartAsiaMax =
          mainRender.displayValueMax * (1 + displayFactor);
      mainRender.chartAsiaMin =
          mainRender.displayValueMin * (1 - displayFactor);
    }

    if (volRender?.displayValueMin == volRender?.displayValueMin) {
      volRender?.chartAsiaMax =
          (volRender?.displayValueMax ?? 0.0) * (1 + displayFactor);
      volRender?.chartAsiaMin =
          (volRender?.displayValueMin ?? 0.0) * (1 - displayFactor);
    }

    mainRender.chartAsiaMax = mainRender.displayValueMax +
        (mainRender.displayValueMax - mainRender.displayValueMin) *
            displayFactor;
    mainRender.chartAsiaMin = mainRender.displayValueMin -
        (mainRender.displayValueMax - mainRender.displayValueMin) *
            displayFactor;

    volRender?.chartAsiaMax = (volRender?.displayValueMax ?? 0.0) +
        ((volRender?.displayValueMax ?? 0.0) -
                (volRender?.displayValueMin ?? 0.0)) *
            displayFactor;
    volRender?.chartAsiaMin = (volRender?.displayValueMin ?? 0.0) -
        ((volRender?.displayValueMax ?? 0.0) -
                (volRender?.displayValueMin ?? 0.0)) *
            displayFactor;

    senRender?.chartAsiaMax = (senRender?.displayValueMax ?? 0.0) +
        ((senRender?.displayValueMax ?? 0.0) -
                (senRender?.displayValueMin ?? 0.0)) *
            displayFactor;
    senRender?.chartAsiaMin = (senRender?.displayValueMin ?? 0.0) -
        ((senRender?.displayValueMax ?? 0.0) -
                (senRender?.displayValueMin ?? 0.0)) *
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
  void renderChart(Canvas canvas, DataAdapter adapter) {
    for (int i = screenLeft; i <= screenRight; i++) {
      int startIndex = 3 * 10 * (i - screenLeft);
      int stopIndex = 3 * 10 * (i + 1 - screenLeft);

      int lastStartIndex = 3 * 10 * (i - screenLeft - 1);
      int lastStopIndex = 3 * 10 * (i - screenLeft);

      mainRender.renderChart(
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

      volRender?.renderChart(
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
      senRender?.renderChart(
          canvas,
          adapter.senDisplayPoints.sublist(startIndex, stopIndex),
          lastStartIndex < 0
              ? List.filled(stopIndex - startIndex, double.infinity)
              : adapter.senDisplayPoints.sublist(lastStartIndex, lastStopIndex),
          chartScaleWidth,
          i);
    }
    xAxisRender
      ..renderAxis(canvas)
      ..renderLine(canvas)
      ..renderText(canvas);
    mainRender
      ..renderAxis(canvas)
      ..renderLine(canvas, builder: selectedPriceBuilder)
      ..renderText(canvas);
    volRender
      ?..renderAxis(canvas)
      ..renderLine(canvas)
      ..renderText(canvas);
    senRender
      ?..renderAxis(canvas)
      ..renderLine(canvas)
      ..renderText(canvas);
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

  /// second render init
  /// [adapter] data adapter  [DataAdapter]
  IRender getSenRender(DataAdapter adapter) {
    switch (chartSenType) {
      case ChartSenType.macd:
        return MacdRender(this, adapter, matrixUtils);
      case ChartSenType.kdj:
        return KdjRender(this, adapter, matrixUtils);
      case ChartSenType.wr:
        return WrRender(this, adapter, matrixUtils);
      case ChartSenType.rsi:
        return RsiRender(this, adapter, matrixUtils);
      case ChartSenType.cci:
        return CciRender(this, adapter, matrixUtils);
    }
  }
}
