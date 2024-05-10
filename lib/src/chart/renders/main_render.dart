import 'dart:math';
import 'dart:ui' as ui;

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_render.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

class MainRender extends IRender {
  final Path linePath = Path();
  final Paint fillPaint = Paint();

  final Paint crossLineVerticalPaint = Paint();

  final Paint maxMinPaint = Paint();

  late TextSpan _textSpan;

  MainRender(super.config, super.adapter, super.matrixUtils) {
    crossLineVerticalPaint
      ..color = Colors.white
      ..shader = ui.Gradient.linear(
          const Offset(0, 0),
          Offset(0, config.height),
          KStaticConfig().crossColors,
          KStaticConfig().colorStops);
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
        canvas.drawLine(
            Offset(x, open),
            Offset(x, close),
            paint
              ..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2);

        canvas.drawLine(Offset(x, high), Offset(x, low),
            paint..strokeWidth = KStaticConfig().lineWidth);

        if (index == maxValueIndex) {
          double minLineStart;
          KAlign textAlign;
          if (x > config.width / 2) {
            minLineStart = x - KStaticConfig().maxMinLineLength;
            textAlign = KAlign.left;
          } else {
            minLineStart = x + KStaticConfig().maxMinLineLength;
            textAlign = KAlign.right;
          }
          canvas.drawLine(
              Offset(minLineStart, high),
              Offset(x, high),
              paint
                ..strokeWidth = KStaticConfig().lineWidth
                ..color = KStaticConfig().chartColors['maxMinColor']!);
          KTextPainter(minLineStart, high - KStaticConfig().maxMinTextSize / 2)
              .renderText(
                  canvas,
                  buildTextSpan(
                      config.mainValueFormatter.call(adapter.data[index].high),
                      color: KStaticConfig().chartColors['maxMinColor']!,
                      fontSize: KStaticConfig().maxMinTextSize),
                  top: false,
                  align: textAlign);
        }
        if (index == minValueIndex) {
          double minLineStart;
          KAlign textAlign;
          if (x > config.width / 2) {
            minLineStart = x - KStaticConfig().maxMinLineLength;
            textAlign = KAlign.left;
          } else {
            minLineStart = x + KStaticConfig().maxMinLineLength;
            textAlign = KAlign.right;
          }
          canvas.drawLine(
              Offset(minLineStart, low),
              Offset(x, low),
              paint
                ..strokeWidth = KStaticConfig().lineWidth
                ..color = KStaticConfig().chartColors['maxMinColor']!);
          KTextPainter(minLineStart, low - KStaticConfig().maxMinTextSize / 2)
              .renderText(
                  canvas,
                  buildTextSpan(
                      config.mainValueFormatter.call(adapter.data[index].low),
                      color: KStaticConfig().chartColors['maxMinColor']!,
                      fontSize: KStaticConfig().maxMinTextSize),
                  top: false,
                  align: textAlign);
        }

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

    renderPriceLine(index, x, canvas, close);
  }

  /// paint current price
  void renderPriceLine(int index, double x, ui.Canvas canvas, double close) {
    if (index == config.screenRight) {
      var textPainter = TextPainter()
        ..text = buildTextSpan(
            config.mainValueFormatter.call(adapter.data.last.close),
            color: KStaticConfig().chartColors['priceLineText']!)
        ..textDirection = TextDirection.rtl
        ..layout();

      var textWidth = textPainter.width,
          halfTextHeight = textPainter.height / 2,
          width = config.width;
      if (textWidth + x < width) {
        double lintRight = width - textWidth;
        for (double positionX = x;
            positionX < lintRight && positionX < lintRight;
            positionX += 4) {
          canvas.drawLine(
              Offset(positionX, close),
              Offset(positionX + 2, close),
              paint..color = KStaticConfig().chartColors['priceLineColor']!);
        }
        canvas.drawRect(
            Rect.fromLTRB(width - textWidth, close - halfTextHeight, width,
                close + halfTextHeight),
            paint
              ..color =
                  KStaticConfig().chartColors['priceLineRectBackground']!);
        textPainter.paint(
            canvas, Offset(width - textWidth, close - halfTextHeight));
      } else {
        for (double positionX = 0; positionX < width; positionX += 4) {
          canvas.drawLine(
              Offset(positionX, close),
              Offset(positionX + 2, close),
              paint..color = KStaticConfig().chartColors['priceLineColor']!);
        }
        canvas.drawRRect(
            RRect.fromLTRBR(
                width -
                    textWidth * 2 -
                    KStaticConfig().priceLineTextBoxHPadding,
                close - halfTextHeight,
                width - textWidth + KStaticConfig().priceLineTextBoxHPadding,
                close + halfTextHeight,
                Radius.circular(KStaticConfig().priceLineTextBoxRadius)),
            paint
              ..color =
                  KStaticConfig().chartColors['priceLineRectBackground']!);
        textPainter.paint(
            canvas, Offset(width - textWidth * 2, close - halfTextHeight));
      }
    }
  }

  /// paint time line
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

  /// paint ma line
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

  /// paint boll line
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
  void renderLine(Canvas canvas, {TextBuilder? builder}) {
    if (config.selectedX != null) {
      config.selectedIndex =
          config.xToIndex(config.selectedX!, adapter.dataLength);
      int selectedIndex = config.selectedIndex!;

      KLineEntity data = adapter.data[selectedIndex];

      _buildInfoText(data);

      Map<TextSpan, TextSpan> marketInfo =
          config.getMarketInfo(adapter, selectedIndex);
      renderCross(canvas, selectedIndex, data, builder: builder);
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

      var r = RRect.fromLTRBR(
          left,
          KStaticConfig().infoWindowWidthMarginVertical,
          right,
          KStaticConfig().infoWindowItemHeight * marketInfo.length +
              KStaticConfig().infoWindowWidthMarginVertical,
          Radius.circular(KStaticConfig().infoWindowRadius));
      canvas.drawRRect(r,
          paint..color = KStaticConfig().chartColors['infoWindowBackground']!);

      canvas.drawRRect(
          r,
          paint
            ..color = KStaticConfig().chartColors['infoWindowBorder']!
            ..style = PaintingStyle.stroke);
      paint.style = PaintingStyle.fill;

      List<TextSpan> keyList = [...marketInfo.keys];
      for (int i = 0; i < marketInfo.length; i++) {
        var rowY = KStaticConfig().infoWindowItemHeight * i +
            KStaticConfig().infoWindowWidthMarginVertical;
        KTextPainter(left + KStaticConfig().infoWindowHPadding, rowY)
            .renderText(canvas, keyList[i]);
        KTextPainter(right - KStaticConfig().infoWindowHPadding, rowY)
            .renderText(canvas, marketInfo[keyList[i]]!, align: KAlign.left);
      }
    } else {
      _buildInfoText(adapter.data.last);
    }
  }

  /// build  top info
  /// if show info window display  selected else display the last one
  /// [data] selected data
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
          align: KAlign.left);
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    var tempMax = chartAsiaMax;
    var tempMin = chartAsiaMin;
    displayValueMax = max(displayValueMax, item.high);
    displayValueMin = min(displayValueMin, item.low);

    /// 因为指标计算问题可能会导致最大值最小值不准确
    chartAsiaMax = max(chartAsiaMax, item.high);
    chartAsiaMin = min(chartAsiaMin, item.low);

    if (tempMax != chartAsiaMax) {
      maxValueIndex = index;
    }
    if (tempMin != chartAsiaMin) {
      minValueIndex = index;
    }
    switch (config.mainDisplayType) {
      case MainDisplayType.boll:
        displayValueMax = max(displayValueMax, item.up ?? displayValueMax);
        displayValueMin = min(displayValueMin, item.dn ?? displayValueMin);
        break;
      case MainDisplayType.ma:
        displayValueMax = max(displayValueMax, item.ma1 ?? displayValueMax);
        displayValueMax = max(displayValueMax, item.ma2 ?? displayValueMax);
        displayValueMax = max(displayValueMax, item.ma3 ?? displayValueMax);

        displayValueMin = min(displayValueMin, item.ma1 ?? displayValueMin);
        displayValueMin = min(displayValueMin, item.ma2 ?? displayValueMin);
        displayValueMin = min(displayValueMin, item.ma3 ?? displayValueMin);
        break;
      case MainDisplayType.none:
        break;
    }
  }

  ///  renderCross
  ///  canvas
  ///
  ///  data
  void renderCross(Canvas canvas, int selectedIndex, KLineEntity data,
      {TextBuilder? builder}) {
    int startIndex = 3 * 10 * (selectedIndex - config.screenLeft);
    int stopIndex = 3 * 10 * (selectedIndex - config.screenLeft + 1);
    var selectedDisplay =
        adapter.mainDisplayPoints.sublist(startIndex, stopIndex);
    var dy = selectedDisplay[KMainIndex.close * 3 + 1];
    double dx = config.selectedX!;
    var maxDy = config.height - KStaticConfig().xAxisHeight;
    double? selectedPriceX, selectedPriceY;
    KAlign? align;
    if (dx > config.width / 2) {
      selectedPriceX = 0;
      align = KAlign.right;
    } else {
      selectedPriceX = config.width;
      align = KAlign.left;
    }

    switch (config.crossType) {
      case CrossType.followClose:

        ///横线
        canvas.drawLine(Offset(0, dy), Offset(config.width, dy),
            paint..color = KStaticConfig().chartColors['crossHorizontal']!);

        selectedPriceY = dy;

        ///竖线
        canvas.drawLine(
            Offset(dx, 0),
            Offset(dx, maxDy),
            crossLineVerticalPaint
              ..strokeWidth =
                  config.chartScaleWidth - KStaticConfig().candleItemSpace * 2);

        break;
      case CrossType.followFinger:
        paint.color = KStaticConfig().chartColors['crossHorizontal']!;
        for (double i = 0; i < config.width; i += 4) {
          ///横虚线
          canvas.drawLine(Offset(i, config.selectedY!),
              Offset(i + 2, config.selectedY!), paint);
        }

        selectedPriceY = config.selectedY;
        crossLineVerticalPaint
          ..color = KStaticConfig().chartColors['crossVertical']!
          ..shader = null;
        for (double i = 0; i < maxDy; i += 4) {
          ///横虚线
          canvas.drawLine(
              Offset(dx, i), Offset(dx, i + 2), crossLineVerticalPaint);
        }
        break;
      case CrossType.followAll:
        var dx = config.selectedX!;
        paint.color = KStaticConfig().chartColors['crossHorizontal']!;
        for (double i = 0; i < config.width; i += 4) {
          ///横虚线
          canvas.drawLine(Offset(i, config.selectedY!),
              Offset(i + 2, config.selectedY!), paint);

          selectedPriceY = config.selectedY;

          ///横虚线
          canvas.drawLine(Offset(i, dy), Offset(i + 2, dy), paint);
        }
        crossLineVerticalPaint
          ..color = KStaticConfig().chartColors['crossVertical']!
          ..shader = null;
        for (double i = 0; i < maxDy; i += 4) {
          ///横虚线
          canvas.drawLine(
              Offset(dx, i), Offset(dx, i + 2), crossLineVerticalPaint);
        }

        break;
    }

    KTextPainter(selectedDisplay[0], config.height,
            boxHeight: KStaticConfig().xAxisHeight)
        .renderText(
            canvas,
            buildTextSpan(config.dateFormatter.call(data.time),
                color: KStaticConfig().chartColors['selectedAxisDate'],
                fontSize: KStaticConfig().mainXAxisTextSize),
            top: true,
            align: KAlign.center,
            backGroundColor:
                KStaticConfig().chartColors['selectedDateBackground']!);
    var matrix4 = Matrix4.inverted(matrixUtils.mainMatrix!);
    var result = matrix4.applyToVector3Array([0, dy, 0]);
    if (null != builder) {
      var kTextPainter = KTextPainter(selectedPriceX, selectedPriceY!);
      kTextPainter.renderText(
          canvas, builder.call(kTextPainter, align, result[1]),
          top: false,
          fitY: true,
          align: align,
          backGroundColor:
              KStaticConfig().chartColors['selectedPriceBackground']);
    }
  }

  @override
  double get axisTextSize => KStaticConfig().mainAxisTextSize;
}
