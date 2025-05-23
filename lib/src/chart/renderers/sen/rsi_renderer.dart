import 'dart:math';
import 'dart:ui';

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_renderer.dart';
import 'package:f_b_kline/src/chart/index.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

class RsiRenderer extends IRenderer {
  final Path linePath = Path();

  RsiRenderer(super.config, super.adapter, super.matrixUtils) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = KStaticConfig().lineWidth
      ..color = KStaticConfig().chartColors['rsi']!;
  }

  @override
  void rendererChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double x = c[0] + itemWidth / 2;
    double y = c[SenIndex.rsi * 3 + 1];
    double lastY = l[SenIndex.rsi * 3 + 1];
    if (lastY.isInfinite) {
      linePath
        ..reset()
        ..moveTo(x, y);
    } else {
      linePath.lineTo(x, y);
    }
  }

  @override
  void rendererLine(Canvas canvas, {TextBuilder? builder}) {
    canvas.drawPath(linePath, paint);
  }

  @override
  void rendererText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    if (data.rsi != null) {
      var text = buildTextSpan(
          'RSI(${KIndexParams().rsiOne}):${data.rsi!.toStringAsFixed(2)}',
          color: KStaticConfig().chartColors['rsi']);
      KTextPainter(config.volRect!.left, config.senRect!.top)
          .rendererText(canvas, text);
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    if (null != item.rsi) {
      displayValueMax = max(displayValueMax, item.rsi!);
      displayValueMin = min(displayValueMin, item.rsi!);
    }
  }

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
