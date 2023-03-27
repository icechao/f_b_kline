import 'dart:math';
import 'dart:ui';

import 'package:f_b_kline/k_text_painter.dart';
import 'package:flutter/material.dart';
import 'package:f_b_kline/entity/k_line_entity.dart';
import 'package:f_b_kline/i_render.dart';
import 'package:f_b_kline/k_static_config.dart';

class MacdRender extends IRender {
  MacdRender(super.config, super.adapter);

  final Path difPath = Path();
  final Path deaPath = Path();

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
    if (!macd.isInfinite) {
      canvas.drawLine(
          Offset(x + halfWidth, zero), Offset(x + halfWidth, macd), paint);
    }
    if (lastDif.isInfinite && !dif.isInfinite) {
      difPath
        ..reset()
        ..moveTo(x + halfWidth, dif);
      deaPath
        ..reset()
        ..moveTo(x + halfWidth, dea);
    } else if (!lastDif.isInfinite && !dif.isInfinite) {
      difPath.lineTo(x + halfWidth, dif);
      deaPath.lineTo(x + halfWidth, dea);
    }
  }

  @override
  void renderLine(Canvas canvas) {
    canvas
      ..drawPath(
          difPath,
          paint
            ..color = KStaticConfig().chartColors['dif']!
            ..strokeWidth = KStaticConfig().lineWidth
            ..style = PaintingStyle.stroke)
      ..drawPath(deaPath, paint..color = KStaticConfig().chartColors['dea']!);
  }

  @override
  void renderText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    List<InlineSpan> text = [
      buildTextSpan(
          'MACD(${KStaticConfig().macdS},${KStaticConfig().macdL},${KStaticConfig().macdL}):${data.macd?.toStringAsFixed(2)}',
          color: KStaticConfig().chartColors['text'])
    ];

    if (data.dif != null) {
      text.add(buildTextSpan('  DIF :${data.dif!.toStringAsFixed(2)}',
          color: KStaticConfig().chartColors['dif']));
    }

    if (data.dea != null) {
      text.add(buildTextSpan('  DEA :${data.dea!.toStringAsFixed(2)}',
          color: KStaticConfig().chartColors['dea']));
    }
    KTextPainter(config.senRect!.left, config.senRect!.top)
        .renderText(canvas, TextSpan(children: text), align: KTextAlign.right);
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
