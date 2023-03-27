import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';

class MacdRender extends IRender {
  MacdRender(super.config, super.adapter);

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double halfWidth = itemWidth / 2;
    double x = c[0];
    double macd = c[SenIndex.macd * 3 + 1];
    double dif = c[SenIndex.dif * 3 + 1];
    double dea = c[SenIndex.dea * 3 + 1];
    double lastDif = l[SenIndex.dif * 3 + 1];
    double lastDea = l[SenIndex.dea * 3 + 1];
    double zero = c[c.length - 2];

    if (macd > zero) {
      paint
        ..color = config.chartColor = KStaticConfig().chartColors['decrease']!
        ..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2;
    } else if (macd > 0) {
      paint
        ..color = config.chartColor = KStaticConfig().chartColors['increase']!
        ..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2;
    } else {
      macd += 1;
    }
    canvas.drawLine(
        Offset(x + halfWidth, zero), Offset(x + halfWidth, macd), paint);
    double lX = l[0];
    if (lX.isInfinite) {
      return;
    }
    canvas.drawLine(
        Offset(lX + halfWidth, lastDif),
        Offset(x + halfWidth, dif),
        paint
          ..color = KStaticConfig().chartColors['dif']!
          ..strokeWidth = KStaticConfig().lineWidth);
    canvas.drawLine(
        Offset(lX + halfWidth, lastDea),
        Offset(x + halfWidth, dea),
        paint
          ..color = KStaticConfig().chartColors['dea']!
          ..strokeWidth = KStaticConfig().lineWidth);
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
    if (null != item.macd) {
      displayValueMax = max(displayValueMax, item.macd!);
      displayValueMin = min(displayValueMin, item.macd!);
    }
    if (null != item.dea) {
      displayValueMax = max(displayValueMax, item.dea!);
      displayValueMin = min(displayValueMin, item.dea!);
    }
    if (null != item.dif) {
      displayValueMax = max(displayValueMax, item.dif!);
      displayValueMin = min(displayValueMin, item.dif!);
    }
  }
}
