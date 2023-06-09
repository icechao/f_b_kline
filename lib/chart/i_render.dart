import 'package:f_b_kline/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/chart/k_run_config.dart';
import 'package:flutter/material.dart';
import 'package:f_b_kline/chart/data_adapter.dart';
import 'package:f_b_kline/chart/k_static_config.dart';
import 'package:f_b_kline/chart/k_text_painter.dart';

///interface
abstract class IRender {
  final KRunConfig config;
  final DataAdapter adapter;
  late double displayValueMax, displayValueMin, chartAsiaMax, chartAsiaMin;
  late int maxValueIndex, minValueIndex;
  final Paint paint = Paint()..strokeWidth = KStaticConfig().lineWidth;

  final List<KTextPainter> axisPainter = [];

  final List<KTextPainter> valuePainter = [];

  IRender(this.config, this.adapter);

  ///paint chart
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index);

  /// paint text
  /// [canvas]
  void renderText(Canvas canvas);

  ///paint lines
  /// [canvas]
  void renderLine(Canvas canvas);

  ///paint Axis
  /// [canvas]
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

  /// axis text size
  double get axisTextSize;

  /// chart formatter
  ValueFormatter getFormatter() {
    return (number) {
      return number?.toStringAsFixed(2) ?? '--';
    };
  }

  ///calc max & min value
  void calcMaxMin(KLineEntity item, int index);

  /// build a text span
  InlineSpan buildTextSpan(String text, {Color? color, double fontSize = 10}) {
    return TextSpan(
        text: text,
        style: TextStyle(
            color: color ?? KStaticConfig().chartColors['text']!,
            fontSize: fontSize));
  }
}
