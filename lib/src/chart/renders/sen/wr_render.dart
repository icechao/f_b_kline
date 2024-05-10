import 'dart:math';
import 'dart:ui';

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_render.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

class WrRender extends IRender {
  final Path linePath = Path();

  WrRender(super.config, super.adapter,super.matrixUtils) {
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = KStaticConfig().lineWidth
      ..color = KStaticConfig().chartColors['wr']!;
  }

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double halfWidth = itemWidth / 2;
    double x = c[0] + halfWidth;
    double y = c[SenIndex.wr * 3 + 1];
    double lastY = l[SenIndex.wr * 3 + 1];

    if (lastY.isInfinite) {
      linePath
        ..reset()
        ..moveTo(x, y);
    } else {
      linePath.lineTo(x, y);
    }
  }

  @override
  void renderLine(Canvas canvas, {TextBuilder? builder}) {
    canvas.drawPath(linePath, paint);
  }

  @override
  void renderText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    if (data.rsi != null) {
      var text = buildTextSpan(
          'WR(${KIndexParams().wrOne}):${data.r!.toStringAsFixed(2)}',
          color: KStaticConfig().chartColors['wr']);
      KTextPainter(config.volRect!.left, config.senRect!.top)
          .renderText(canvas, text);
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    if (null != item.r) {
      displayValueMax = max(displayValueMax, item.r!);
      displayValueMin = min(displayValueMin, item.r!);
    }
  }

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
