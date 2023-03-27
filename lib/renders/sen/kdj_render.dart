import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';

class KdjRender extends IRender {
  KdjRender(super.config, super.adapter);

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double lX = l[0];
    if (lX.isInfinite) {
      return;
    }
    double halfWidth = itemWidth / 2;
    double x = c[0];
    double k = c[SenIndex.k * 3 + 1];
    double d = c[SenIndex.d * 3 + 1];
    double j = c[SenIndex.j * 3 + 1];
    double lastK = l[SenIndex.k * 3 + 1];
    double lastD = l[SenIndex.d * 3 + 1];
    double lastJ = l[SenIndex.j * 3 + 1];

    canvas.drawLine(Offset(lX + halfWidth, lastK), Offset(x + halfWidth, k),
        paint..color = KStaticConfig().chartColors['k']!);
    canvas.drawLine(Offset(lX + halfWidth, lastD), Offset(x + halfWidth, d),
        paint..color = KStaticConfig().chartColors['d']!);
    canvas.drawLine(Offset(lX + halfWidth, lastJ), Offset(x + halfWidth, j),
        paint..color = KStaticConfig().chartColors['j']!);
  }

  @override
  void renderLine(Canvas canvas) {
    // TODO: implement renderLine
  }

  @override
  void renderText(Canvas canvas) {
    // TODO: implement renderText
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    if (null != item.k) {
      displayValueMax = max(displayValueMax, item.k!);
      displayValueMin = min(displayValueMin, item.k!);
    }
    if (null != item.d) {
      displayValueMax = max(displayValueMax, item.d!);
      displayValueMin = min(displayValueMin, item.d!);
    }
    if (null != item.j) {
      displayValueMax = max(displayValueMax, item.j!);
      displayValueMin = min(displayValueMin, item.j!);
    }
  }
}
