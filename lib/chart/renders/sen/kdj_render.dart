import 'dart:math';
import 'dart:ui';

import 'package:f_b_kline/chart/k_text_painter.dart';
import 'package:flutter/material.dart';
import 'package:f_b_kline/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/chart/i_render.dart';
import 'package:f_b_kline/chart/k_static_config.dart';

class KdjRender extends IRender {
  KdjRender(super.config, super.adapter) {
    paint
      ..strokeWidth = KStaticConfig().lineWidth
      ..style = PaintingStyle.stroke;
  }

  final Path kPath = Path();
  final Path dPath = Path();
  final Path jPath = Path();

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double lX = l[0];

    double x = c[0] + itemWidth / 2;
    double k = c[SenIndex.k * 3 + 1];
    double d = c[SenIndex.d * 3 + 1];
    double j = c[SenIndex.j * 3 + 1];

    if (lX.isInfinite) {
      kPath
        ..reset()
        ..moveTo(x, k);
      dPath
        ..reset()
        ..moveTo(x, d);
      jPath
        ..reset()
        ..moveTo(x, j);
    } else {
      kPath.lineTo(x, k);
      dPath.lineTo(x, d);
      jPath.lineTo(x, j);
    }
  }

  @override
  void renderLine(Canvas canvas) {
    canvas
      ..drawPath(kPath, paint..color = KStaticConfig().chartColors['k']!)
      ..drawPath(dPath, paint..color = KStaticConfig().chartColors['d']!)
      ..drawPath(jPath, paint..color = KStaticConfig().chartColors['j']!);
  }

  @override
  void renderText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    List<InlineSpan> text = [
      buildTextSpan(
          'KDJ(${KStaticConfig().kdjN},${KStaticConfig().kdjM1},${KStaticConfig().kdjM2})}',
          color: KStaticConfig().chartColors['text'])
    ];

    text.add(buildTextSpan('  K :${data.k?.toStringAsFixed(2)}',
        color: KStaticConfig().chartColors['k']));

    text.add(buildTextSpan('  D :${data.d?.toStringAsFixed(2)}',
        color: KStaticConfig().chartColors['d']));

    text.add(buildTextSpan('  J :${data.j?.toStringAsFixed(2)}',
        color: KStaticConfig().chartColors['j']));

    KTextPainter(config.senRect!.left, config.senRect!.top)
        .renderText(canvas, TextSpan(children: text), align: KTextAlign.right);
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
  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
