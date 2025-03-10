import 'dart:math';

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_renderer.dart';
import 'package:f_b_kline/src/chart/index.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

/// macd painter
/// [difPath] dif line path
/// [deaPath] dea line path
class MacdRenderer extends IRenderer {
  MacdRenderer(super.config, super.adapter, super.matrixUtils);

  final Path difPath = Path();
  final Path deaPath = Path();

  @override
  void rendererChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double halfWidth = itemWidth / 2;
    double x = c[0];
    double macd = c[SenIndex.macd * 3 + 1];
    double dif = c[SenIndex.dif * 3 + 1];
    double dea = c[SenIndex.dea * 3 + 1];
    double lastDif = l[SenIndex.dif * 3 + 1];
    double zero = c[c.length - 2];

    if (macd > zero) {
      paint
        ..color = KStaticConfig().chartColors['decrease']!
        ..strokeWidth = itemWidth - KStaticConfig().candleItemSpace * 2;
    } else if (macd > 0) {
      paint
        ..color = KStaticConfig().chartColors['increase']!
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
  void rendererLine(Canvas canvas, {TextBuilder? builder}) {
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
  void rendererText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    List<InlineSpan> text = [
      buildTextSpan(
          'MACD(${KIndexParams().macdS},${KIndexParams().macdL},${KIndexParams().macdL}):${data.macd?.toStringAsFixed(2)}',
          color: KStaticConfig().colorConfig.text)
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
        .rendererText(canvas, TextSpan(children: text), align: KAlign.right);
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

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
