import 'dart:math';

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_run_config.dart';
import 'package:f_b_kline/k_static_config.dart';

class VolRender extends IRender {
  VolRender(super.config, super.adapter);

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double x = c[0];
    double lX = l[0];
    double vol = c[KVolIndex.vol * 3 + 1];
    double volMa1 = c[KVolIndex.volMaOne * 3 + 1];
    double volMa2 = c[KVolIndex.volMaTwo * 3 + 1];

    double lastVolMa1 = l[KVolIndex.volMaOne * 3 + 1];
    double lastVolMa2 = l[KVolIndex.volMaTwo * 3 + 1];
    paint.color = config.chartColor;

    var halfWidth = itemWidth / 2;
    canvas.drawLine(
        Offset(x + halfWidth, vol),
        Offset(x + halfWidth, config.volRect!.bottom),
        paint..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2);

    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = KStaticConfig().lineWidth;
    if (!lastVolMa1.isInfinite && !volMa1.isInfinite) {
      canvas.drawLine(
          Offset(lX + halfWidth, lastVolMa1),
          Offset(x + halfWidth, volMa1),
          paint..color = KStaticConfig().chartColors['volMaFir']!);
    }

    if (!lastVolMa2.isInfinite && !volMa2.isInfinite) {
      canvas.drawLine(
          Offset(lX + halfWidth, lastVolMa2),
          Offset(x + halfWidth, volMa2),
          paint..color = KStaticConfig().chartColors['volMaSen']!);
    }
  }

  @override
  void renderLine(Canvas canvas) {}

  @override
  void renderText(Canvas canvas) {}

  @override
  ValueFormatter getFormatter() {
    return config.volValueFormatter;
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {
    displayValueMax = max(displayValueMax, item.vol);
    displayValueMin = min(displayValueMin, item.vol);
    if (item.maVolume1 != null) {
      displayValueMax = max(displayValueMax, item.maVolume1!);
      displayValueMin = min(displayValueMin, item.maVolume1!);
    }

    if (item.maVolume2 != null) {
      displayValueMax = max(displayValueMax, item.maVolume2!);
      displayValueMin = min(displayValueMin, item.maVolume2!);
    }
  }
}
