import 'package:f_b_kline/src/chart/k_matrix_util.dart';
import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:f_b_kline/src/export_k_chart.dart';
import 'package:flutter/material.dart';

/// interface
/// [config] cache config [KRunConfig]
/// [adapter] data adapter [DataAdapter]
/// [displayValueMax] the max value  witch chart display
/// [displayValueMin] the min value  witch chart display
/// [chartAsiaMax] the max value witch chart Asia
/// [chartAsiaMin] the min value witch chart Asia
abstract class IRenderer {
  final KRunConfig config;
  final DataAdapter adapter;
  final KMatrixUtils matrixUtils;
  late double displayValueMax, displayValueMin, chartAsiaMax, chartAsiaMin;
  int maxValueIndex = 0, minValueIndex = 0;
  final Paint paint = Paint()..strokeWidth = KStaticConfig().lineWidth;

  final List<KTextPainter> axisPainter = [];

  final List<KTextPainter> valuePainter = [];

  IRenderer(this.config, this.adapter, this.matrixUtils);

  ///paint chart
  ///[canvas] canvas
  ///[c] current index data
  ///[l] last index data
  ///[itemWidth] itemWidth
  ///[index] index
  void rendererChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index);

  /// paint text
  /// [canvas]
  void rendererText(Canvas canvas);

  ///paint lines
  /// [canvas]
  void rendererLine(Canvas canvas, {TextBuilder? builder});

  ///paint Axis
  /// [canvas]
  void rendererAxis(Canvas canvas) {
    if (axisPainter.isNotEmpty) {
      axisPainter.first.rendererText(
          canvas, buildTextSpan(getFormatter().call(chartAsiaMax)),
          top: false, align: KAlign.left);

      axisPainter.last.rendererText(
          canvas, buildTextSpan(getFormatter().call(chartAsiaMin)),
          top: true, align: KAlign.left);
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
  /// [text] text
  /// [color] color
  /// [fontSize] fontSize
  InlineSpan buildTextSpan(String text, {Color? color, double fontSize = 10}) {
    return TextSpan(
        text: text,
        style: TextStyle(
            color: color ?? KStaticConfig().chartColors['text']!,
            fontSize: fontSize));
  }
}
