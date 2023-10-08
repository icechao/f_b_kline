import 'dart:math';

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_render.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

class VolRender extends IRender {
  VolRender(super.config, super.adapter);

  final Path maFirPath = Path();
  final Path maSenPath = Path();
  final Paint maPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = KStaticConfig().lineWidth;

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {
    double x = c[0];
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

    if (lastVolMa1.isInfinite && !volMa1.isInfinite) {
      maFirPath
        ..reset()
        ..moveTo(x + halfWidth, volMa1);
    } else if (!lastVolMa1.isInfinite && !volMa1.isInfinite) {
      maFirPath.lineTo(x + halfWidth, volMa1);
    }

    if (lastVolMa2.isInfinite && !volMa2.isInfinite) {
      maSenPath
        ..reset()
        ..moveTo(x + halfWidth, volMa2);
    } else if (!lastVolMa2.isInfinite && !volMa2.isInfinite) {
      maSenPath.lineTo(x + halfWidth, volMa2);
    }
  }

  @override
  void renderLine(Canvas canvas) {
    canvas
      ..drawPath(
          maFirPath, maPaint..color = KStaticConfig().chartColors['volMaFir']!)
      ..drawPath(
          maSenPath, maPaint..color = KStaticConfig().chartColors['volMaSen']!);
  }

  @override
  void renderText(Canvas canvas) {
    KLineEntity data =
        adapter.data[config.selectedIndex ?? adapter.dataLength - 1];

    List<InlineSpan> text = [
      buildTextSpan('VOL:${config.volValueFormatter.call(data.vol)}',
          color: KStaticConfig().chartColors['text'])
    ];

    if (data.maVolume1 != null) {
      text.add(buildTextSpan(
          '  MA(${KIndexParams().volMa1}):${config.volValueFormatter.call(data.maVolume1)}',
          color: KStaticConfig().chartColors['volMaFir']));
    }

    if (data.maVolume2 != null) {
      text.add(buildTextSpan(
          '  MA(${KIndexParams().volMa1}):${config.volValueFormatter.call(data.maVolume2)}',
          color: KStaticConfig().chartColors['volMaSen']));
    }
    KTextPainter(config.volRect!.left, config.volRect!.top)
        .renderText(canvas, TextSpan(children: text), align: KTextAlign.right);
  }

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

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
