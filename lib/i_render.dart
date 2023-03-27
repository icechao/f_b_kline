import 'package:flutter/material.dart';
import 'package:f_b_kline/data_adapter.dart';
import 'package:f_b_kline/entity/index.dart';
import 'package:f_b_kline/k_run_config.dart';
import 'package:f_b_kline/k_static_config.dart';
import 'package:f_b_kline/k_text_painter.dart';

abstract class IRender {
  final KRunConfig config;
  final DataAdapter adapter;
  late double displayValueMax, displayValueMin, chartAsiaMax, chartAsiaMin;
  late int maxValueIndex, minValueIndex;
  final Paint paint = Paint()..strokeWidth = KStaticConfig().lineWidth;

  final List<KTextPainter> axisPainter = [];

  final List<KTextPainter> valuePainter = [];

  IRender(this.config, this.adapter);

  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index);

  void renderText(Canvas canvas);

  void renderLine(Canvas canvas);

  void renderAxis(Canvas canvas) {
    if (axisPainter.isNotEmpty) {
      axisPainter.first.renderText(
          canvas, buildTextSpan(getFormatter().call(chartAsiaMax)),
          top: false, align: KTextAlign.left);

      axisPainter.last.renderText(
          canvas, buildTextSpan(getFormatter().call(chartAsiaMin)),
          top: true, align: KTextAlign.left);
    }
  }

  ValueFormatter getFormatter() {
    return (number) {
      return number?.toStringAsFixed(2) ?? '--';
    };
  }

  void calcMaxMin(KLineEntity item, int index);

  InlineSpan buildTextSpan(String text, {Color? color, double fontSize = 10}) {
    return TextSpan(
        text: text,
        style: TextStyle(
            color: color ?? KStaticConfig().chartColors['text']!,
            fontSize: fontSize));
  }
}
