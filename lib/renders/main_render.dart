import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';
import 'package:f_b_kline/k_text_painter.dart';

class MainRender extends IRender {
  final Path linePath = Path();
  final Paint fillPaint = Paint();

  final Paint crossLineVerticalPaint = Paint();

  late TextSpan _textSpan;

  MainRender(super.config, super.adapter) {
    crossLineVerticalPaint
      ..color = Colors.white
      ..shader = ui.Gradient.linear(
          const Offset(0, 0), Offset(0, config.height), [
        Colors.transparent,
        Colors.white30,
        Colors.white30,
        Colors.transparent
      ], [
        0.1,
        0.3,
        0.7,
        0.9
      ]);
  }

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    var halfWidth = itemWidth / 2;
    double x = c[0] + halfWidth;
    double lX = l[0] + halfWidth;
    double open = c[KMainIndex.open * 3 + 1];
    double close = c[KMainIndex.close * 3 + 1];

    double low = c[KMainIndex.low * 3 + 1];
    double high = c[KMainIndex.high * 3 + 1];

    if (open < close) {
      open += 1;
      config.chartColor = KStaticConfig().chartColors['increase']!;
      paint.color = config.chartColor;
    } else if (open > close) {
      close -= 1;
      config.chartColor = KStaticConfig().chartColors['decrease']!;
      paint.color = config.chartColor;
    } else {
      open += 1;
      close -= 1;
    }

    switch (config.chartDisplayType) {
      case ChartDisplayType.kline:
        canvas.drawLine(Offset(x, open), Offset(x, close),
            paint..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2);

        canvas.drawLine(Offset(x, high), Offset(x, low),
            paint..strokeWidth = KStaticConfig().lineWidth);

        switch (config.mainDisplayType) {
          case MainDisplayType.boll:
            renderBoll(c, l, canvas, x, open, close, itemWidth, lX);
            break;
          case MainDisplayType.ma:
            renderMa(c, l, canvas, x, open, close, itemWidth, lX);
            break;
          case MainDisplayType.none:
            break;
        }
        break;
      case ChartDisplayType.timeLine:
        renderTimeLine(l, close, lX, x, canvas);
        break;
    }
  }

  void renderTimeLine(
      List<double> l, double close, double lX, double x, ui.Canvas canvas) {
    Color chartColor = KStaticConfig().chartColors['timeLine'] as ui.Color;
    fillPaint.shader ??= LinearGradient(
            colors: [chartColor, (chartColor).withOpacity(0.05)],
            stops: const [0.05, 1.0],
            begin: Alignment.topCenter,
            tileMode: TileMode.clamp,
            end: Alignment.bottomCenter)
        .createShader(
            Rect.fromLTRB(0, 0, config.width, config.mainRect!.bottom));

    double lastClose = l[KMainIndex.close * 3 + 1];
    if (lastClose.isNaN) {
      lastClose = close;
    }
    var rectBottom = config.mainRect!.bottom;

    linePath
      ..reset()
      ..moveTo(lX, rectBottom)
      ..lineTo(lX, lastClose)
      ..lineTo(x, close)
      ..lineTo(x, rectBottom)
      ..close();

    canvas.drawLine(
        Offset(lX, lastClose), Offset(x, close), paint..color = chartColor);
    canvas.drawPath(linePath, fillPaint);
  }

  void renderMa(List<double> c, List<double> l, ui.Canvas canvas, double x,
      double open, double close, double itemWidth, double lX) {
    double maOne = c[KMainIndex.maOne * 3 + 1];
    double maTwo = c[KMainIndex.maTwo * 3 + 1];
    double maThree = c[KMainIndex.maThree * 3 + 1];

    double lastMaOne = l[KMainIndex.maOne * 3 + 1];
    double lastMaTwo = l[KMainIndex.maTwo * 3 + 1];
    double lastMaThree = l[KMainIndex.maThree * 3 + 1];

    paint.strokeWidth = KStaticConfig().lineWidth;
    if (!lastMaOne.isInfinite) {
      canvas.drawLine(Offset(x, maOne), Offset(lX, lastMaOne),
          paint..color = KStaticConfig().chartColors['maFir']!);
    }
    if (!lastMaTwo.isInfinite) {
      canvas.drawLine(Offset(x, maTwo), Offset(lX, lastMaTwo),
          paint..color = KStaticConfig().chartColors['maSen']!);
    }
    if (!maThree.isInfinite) {
      canvas.drawLine(Offset(x, maThree), Offset(lX, lastMaThree),
          paint..color = KStaticConfig().chartColors['maThr']!);
    }
  }

  void renderBoll(List<double> c, List<double> l, ui.Canvas canvas, double x,
      double open, double close, double itemWidth, double lX) {
    double mb = c[KMainIndex.mb * 3 + 1];
    double lastMb = l[KMainIndex.mb * 3 + 1];
    double up = c[KMainIndex.up * 3 + 1];
    double lastUp = l[KMainIndex.up * 3 + 1];
    double dn = c[KMainIndex.dn * 3 + 1];
    double lastDn = l[KMainIndex.dn * 3 + 1];

    paint.strokeWidth = KStaticConfig().lineWidth;
    if (!lastUp.isInfinite) {
      canvas.drawLine(Offset(x, up), Offset(lX, lastUp),
          paint..color = KStaticConfig().chartColors['ub']!);
    }
    if (!lastMb.isInfinite) {
      canvas.drawLine(Offset(x, mb), Offset(lX, lastMb),
          paint..color = KStaticConfig().chartColors['boll']!);
    }
    if (!lastDn.isInfinite) {
      canvas.drawLine(Offset(x, dn), Offset(lX, lastDn),
          paint..color = KStaticConfig().chartColors['lb']!);
    }
  }

  @override
  void renderLine(Canvas canvas) {
    if (config.selectedX != null) {
      config.selectedIndex =
          config.xToIndex(config.selectedX!, adapter.dataLength);
      int selectedIndex = config.selectedIndex!;

      KLineEntity data = adapter.data[selectedIndex];

      _buildInfoText(data);

      Map<String, String> marketInfo =
          config.getMarketInfo(adapter, selectedIndex);
      renderCross(canvas, selectedIndex, data);
      double left, right;

      if (config.selectedX! < config.width / 2) {
        left = config.width -
            KStaticConfig().infoWindowWidth -
            KStaticConfig().infoWindowWidthMarginHorizontal;
        right = config.width - KStaticConfig().infoWindowWidthMarginHorizontal;
      } else {
        left = KStaticConfig().infoWindowWidthMarginHorizontal;
        right = KStaticConfig().infoWindowWidthMarginHorizontal +
            KStaticConfig().infoWindowWidth;
      }

      canvas.drawRect(
          Rect.fromLTRB(
              left,
              KStaticConfig().infoWindowWidthMarginVertical,
              right,
              KStaticConfig().infoWindowItemHeight * marketInfo.length +
                  KStaticConfig().infoWindowWidthMarginVertical),
          paint..color = KStaticConfig().chartColors['infoWindowBackground']!);
      List<String> keyList = [...marketInfo.keys];
      for (int i = 0; i < marketInfo.length; i++) {
        var rowY = KStaticConfig().infoWindowItemHeight * i +
            KStaticConfig().infoWindowWidthMarginVertical;
        KTextPainter(left, rowY).renderText(canvas, TextSpan(text: keyList[i]));
        KTextPainter(right, rowY).renderText(
            canvas, TextSpan(text: marketInfo[keyList[i]]),
            align: KTextAlign.left);
      }
    } else {
      _buildInfoText(adapter.data.last);
    }
  }

  void _buildInfoText(KLineEntity data) {
    switch (config.mainDisplayType) {
      case MainDisplayType.boll:
        _textSpan = TextSpan(children: [
          buildTextSpan('BOOL:${data.mb?.toStringAsFixed(2) ?? '--'}',
              color: KStaticConfig().chartColors['boll']!),
          buildTextSpan('  UB:${data.up?.toStringAsFixed(2) ?? '--'}',
              color: KStaticConfig().chartColors['ub']!),
          buildTextSpan('  LB:${data.dn?.toStringAsFixed(2) ?? '--'}',
              color: KStaticConfig().chartColors['lb']!),
        ]);
        break;
      case MainDisplayType.ma:
        _textSpan = TextSpan(children: [
          buildTextSpan('MA5:${config.mainValueFormatter.call(data.ma1)}',
              color: KStaticConfig().chartColors['maFir']!),
          buildTextSpan('   MA10:${config.mainValueFormatter.call(data.ma2)}',
              color: KStaticConfig().chartColors['maSen']!),
          buildTextSpan('  MA20:${config.mainValueFormatter.call(data.ma3)}',
              color: KStaticConfig().chartColors['maThr']!),
        ]);
        break;
      case MainDisplayType.none:
        _textSpan = const TextSpan(children: []);
        break;
    }
  }

  @override
  void renderText(Canvas canvas) {
    KTextPainter(0, 10).renderText(canvas, _textSpan);
  }

  @override
  void renderAxis(Canvas canvas) {
    var diff = (chartAsiaMax - chartAsiaMin) / (axisPainter.length - 1);

    for (int i = 0; i < axisPainter.length; i++) {
      axisPainter[i].renderText(
          canvas,
          buildTextSpan(
              config.mainValueFormatter.call(chartAsiaMax - i * diff)),
          top: true,
          align: KTextAlign.left);
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    displayValueMax = max(displayValueMax, item.high);
    if (null != item.ma1) {
      displayValueMax = max(displayValueMax, item.ma1!);
    }
    if (null != item.ma2) {
      displayValueMax = max(displayValueMax, item.ma2!);
    }
    if (null != item.ma3) {
      displayValueMax = max(displayValueMax, item.ma3!);
    }
    if (null != item.up) {
      displayValueMax = max(displayValueMax, item.up!);
    }

    displayValueMin = min(displayValueMin, item.low);
    if (null != item.ma1) {
      displayValueMin = min(displayValueMin, item.ma1!);
    }
    if (null != item.ma2) {
      displayValueMin = min(displayValueMin, item.ma2!);
    }
    if (null != item.ma3) {
      displayValueMin = min(displayValueMin, item.ma3!);
    }
    if (null != item.dn) {
      displayValueMin = min(displayValueMin, item.dn!);
    }
  }

  ///绘制十字线
  void renderCross(Canvas canvas, int selectedIndex, KLineEntity data) {
    int startIndex = 3 * 10 * (selectedIndex - config.screenLeft);
    int stopIndex = 3 * 10 * (selectedIndex - config.screenLeft + 1);
    var selectedDisplay =
        adapter.mainDisplayPoints.sublist(startIndex, stopIndex);

    var dx = selectedDisplay[0] + config.chartScaleWidth / 2;
    var dy = selectedDisplay[KMainIndex.close * 3 + 1];
    canvas.drawLine(Offset(0, dy), Offset(config.width, dy),
        paint..color = KStaticConfig().chartColors['crossHorizontal']!);

    canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, config.height - KStaticConfig().xAxisHeight),
        crossLineVerticalPaint
          ..strokeWidth =
              config.chartScaleWidth - KStaticConfig().candleItemSpace * 2);

    KTextPainter(selectedDisplay[0], config.height,
            boxHeight: KStaticConfig().xAxisHeight)
        .renderText(canvas, buildTextSpan(config.dateFormatter.call(data.time)),
            top: true,
            align: KTextAlign.center,
            backGroundColor: KStaticConfig().chartColors['selectedTime']!);
  }
}
