import 'package:f_b_kline/chart/renders/sen/cci_render.dart';
import 'package:f_b_kline/chart/renders/sen/kdj_render.dart';
import 'package:f_b_kline/chart/renders/sen/rsi_render.dart';
import 'package:f_b_kline/chart/renders/sen/wr_render.dart';
import 'package:flutter/material.dart';
import 'package:f_b_kline/chart/data_adapter.dart';
import 'package:f_b_kline/chart/entity/index.dart';
import 'package:f_b_kline/chart/i_render.dart';
import 'package:f_b_kline/chart/k_matrix_util.dart';
import 'package:f_b_kline/chart/k_static_config.dart';
import 'package:f_b_kline/chart/k_text_painter.dart';
import 'package:f_b_kline/chart/renders/main_render.dart';
import 'package:f_b_kline/chart/renders/sen/macd_render.dart';
import 'package:f_b_kline/chart/renders/vol_render.dart';
import 'package:f_b_kline/chart/renders/x_axis_render.dart';

///日期格式化
typedef DateFormatter = String Function(int?);

///数值格式化
typedef ValueFormatter = String Function(num?);

///单例类,K线运行时类库
///不需要修改运行时配置
class KRunConfig {
  final DateFormatter dateFormatter;
  final ValueFormatter mainValueFormatter;
  final ValueFormatter volValueFormatter;
  final CrossType crossType;

  late double height, width;
  Rect? mainRect, volRect, senRect;

  double translateX = double.nan;
  double scaleX = 1, scaleY = 1;
  double volBaseY = 0.0, senBaseY = 0.0;
  double kRightSpace = 100;
  double chartScaleWidth = KStaticConfig().candleItemWidth;

  late IRender mainRender, xAxisRender;
  IRender? volRender;
  IRender? senRender;
  late int screenLeft, screenRight;

  ChartGroupType? type;
  ChartDisplayType chartDisplayType = ChartDisplayType.kline;
  MainDisplayType mainDisplayType = MainDisplayType.boll;
  ChartSenType chartSenType = ChartSenType.kdj;

  late Color chartColor;

  /// 手势触发时按住的位置
  double? selectedX, selectedY;
  int? selectedIndex;

  KRunConfig(
      {required this.dateFormatter,
      required this.mainValueFormatter,
      required this.volValueFormatter,
      this.crossType = CrossType.followAll});

  ///max length of data
  double calcDataLength(int count) {
    return count * chartScaleWidth;
  }

  /// storage size in memory
  void setSize(Size size) {
    width = size.width;
    height = size.height;
  }

  /// init area rest
  void initRect(ChartGroupType? type, DataAdapter adapter) {
    type ??= ChartGroupType.withVol;
    if (this.type == type) {
      return;
    }
    var padding = KStaticConfig().topPadding;
    this.type = type;
    var rowCount = KStaticConfig().gridRowCount;
    double item = (height - padding - KStaticConfig().xAxisHeight) / rowCount;
    mainRender = MainRender(this, adapter)
      ..axisPainter.add(KTextPainter(width, padding));
    switch (this.type!) {
      case ChartGroupType.withVolSen:
        mainRect =
            Rect.fromLTRB(0, padding, width, item * (rowCount - 2) + padding);
        for (int i = 1; i < rowCount - 1; i++) {
          mainRender.axisPainter.add(KTextPainter(width, padding + item * i));
        }
        volBaseY = mainRect!.bottom;
        volRect = Rect.fromLTRB(
            0, mainRect!.bottom, width, item * (rowCount - 1) + padding);
        volRender = VolRender(this, adapter)
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
        volRender = VolRender(this, adapter)
          ..axisPainter.addAll([
            KTextPainter(width, padding + item * (rowCount - 1)),
            KTextPainter(width, padding + item * rowCount),
          ]);

        senRect = null;
        senRender = null;
        break;
    }

    xAxisRender = XAxisRender(this, adapter);
    var columnCount = KStaticConfig().gridRowCount;
    double xSpace = width / (columnCount);
    for (int i = 0; i <= rowCount; i++) {
      xAxisRender.axisPainter.add(KTextPainter(xSpace * i, height,
          boxHeight: KStaticConfig().xAxisHeight));
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
  void calcShowValues(DataAdapter adapter) {
    adapter.mainDisplayPoints = [];
    adapter.volDisplayPoints = [];
    adapter.senDisplayPoints = [];
    mainRender.displayValueMax = double.minPositive;
    mainRender.displayValueMin = double.maxFinite;

    volRender?.displayValueMax = double.minPositive;
    volRender?.displayValueMin = double.maxFinite;

    senRender?.displayValueMax = double.minPositive;
    senRender?.displayValueMin = double.maxFinite;

    for (int i = screenLeft; i <= screenRight; i++) {
      KLineEntity item = adapter.data[i];
      double xIndex = (i.toDouble());
      adapter.mainDisplayPoints
        ..add(xIndex)
        ..add(item.open)
        ..add(0.0)
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
      mainRender.calcMaxMin(item, i);
    }
    mainRender.chartAsiaMax = mainRender.displayValueMax * 1.02;
    mainRender.chartAsiaMin = mainRender.displayValueMin * 0.98;

    volRender?.chartAsiaMax = (volRender?.displayValueMax ?? 0.0) * 1.05;
    volRender?.chartAsiaMin = (volRender?.displayValueMin ?? 0.0) * 0.95;

    if ((senRender?.displayValueMax ?? 0.0) > 0) {
      senRender?.chartAsiaMax = (senRender?.displayValueMax ?? 0.0) * 1.2;
    } else {
      senRender?.chartAsiaMax = (senRender?.displayValueMax ?? 0.0) * 0.8;
    }
    if ((senRender?.displayValueMin ?? 0.0) > 0) {
      senRender?.chartAsiaMin = (senRender?.displayValueMin ?? 0.0) * 0.8;
    } else {
      senRender?.chartAsiaMin = (senRender?.displayValueMin ?? 0.0) * 1.2;
    }

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

  /// calc min translate
  double calcMinTranslateX(int itemCount) {
    var length = -calcDataLength(itemCount);
    if (kRightSpace - length > width) {
      return length - kRightSpace + width;
    } else {
      return 0.0;
    }
  }

  /// change sacle
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
  void updateTranslate(double translate, int length) {
    var min = calcMinTranslateX(length);
    translateX = translate.clamp(min, 0);
  }

  ///update translate with diff
  void updateTranslateWithDx(double dx, int length) {
    var min = calcMinTranslateX(length);
    translateX = (translateX + dx).clamp(min, 0);
  }

  /// x to index
  int xToIndex(double x, int length) {
    var ceil = ((x - translateX) / chartScaleWidth).floor();
    return ceil.clamp(0, length - 1);
  }

  ///paint
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
      ..renderLine(canvas)
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

  /// change selected x
  void updateSelectedX(double? dx) {
    if (dx == null) {
      selectedIndex = null;
    }
    selectedX = dx;
  }

  /// change selected x
  void updateSelectedY(double? dy) {
    selectedY = dy;
  }

  /// get market info
  Map<String, String> getMarketInfo(DataAdapter adapter, int selectedIndex) {
    KLineEntity data = adapter.data[selectedIndex];

    return <String, String>{}
      ..['data'] = dateFormatter.call(data.time)
      ..['open'] = mainValueFormatter.call(data.open)
      ..['high'] = mainValueFormatter.call(data.high)
      ..['low'] = mainValueFormatter.call(data.low)
      ..['close'] = mainValueFormatter.call(data.close)
      ..['vol'] = mainValueFormatter.call(data.vol);
  }

  /// second render init
  IRender getSenRender(DataAdapter adapter) {
    switch (chartSenType) {
      case ChartSenType.macd:
        return MacdRender(this, adapter);

      case ChartSenType.kdj:
        return KdjRender(this, adapter);
      case ChartSenType.wr:
        return WrRender(this, adapter);

      case ChartSenType.rsi:
        return RsiRender(this, adapter);

      case ChartSenType.cci:
        return CciRender(this, adapter);
    }
  }
}
