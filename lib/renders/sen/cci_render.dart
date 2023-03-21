import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';

class CciRender extends IRender {
  CciRender(super.config, super.adapter) {
    paint
      ..strokeWidth = KStaticConfig.lineWidth
      ..color = KStaticConfig.chartColors['cci']!;
  }


  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double lX = l[0];
    if (lX.isInfinite) {
      return;
    }
    double x = c[0];
    double y = c[SenIndex.cci * 3 + 1];
    double lastY = l[SenIndex.rsi * 3 + 1];

    canvas.drawLine(Offset(lX, lastY), Offset(x, y), paint);
  }

  @override
  void renderLine(Canvas canvas) {}

  @override
  void renderText(Canvas canvas) {}

  @override
  void calcMaxMin(KLineEntity item, int index) {
    if (null != item.rsi) {
      displayValueMax = max(displayValueMax, item.cci!);
      displayValueMin = min(displayValueMin, item.cci!);
    }
  }
}
