import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';

class RsiRender extends IRender {
  RsiRender(super.config, super.adapter) {
    paint
      ..strokeWidth = KStaticConfig.lineWidth
      ..color = KStaticConfig.chartColors['rsi']!;
  }


  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double lX = l[0];
    if (lX.isInfinite) {
      return;
    }
    double halfWidth = itemWidth/2;
    double x = c[0];
    double y = c[SenIndex.rsi * 3 + 1];
    double lastY = l[SenIndex.rsi * 3 + 1];

    canvas.drawLine(Offset(lX+ halfWidth, lastY), Offset(x+ halfWidth, y), paint);
  }

  @override
  void renderLine(Canvas canvas) {

  }

  @override
  void renderText(Canvas canvas) {

  }

  @override
  void calcMaxMin(KLineEntity item, int index){
    if (null != item.rsi) {
      displayValueMax = max(displayValueMax, item.rsi!);
      displayValueMin = min(displayValueMin, item.rsi!);
    }
  }
}
