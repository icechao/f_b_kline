import 'dart:ui';

import 'package:f_b_kline/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/chart/i_render.dart';
import 'package:f_b_kline/chart/k_static_config.dart';
import 'package:f_b_kline/chart/k_text_painter.dart';

class XAxisRender extends IRender {
  XAxisRender(super.config, super.adapter);

  @override
  void renderAxis(Canvas canvas) {}

  @override
  void renderChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {}

  @override
  void renderLine(Canvas canvas) {}

  @override
  void renderText(Canvas canvas) {
    for (var element in axisPainter) {
      int? index = config.xToIndex(element.x, adapter.dataLength);
      var data = adapter.data[index];
      element.renderText(
        canvas,
        buildTextSpan(config.dateFormatter.call(data.time),
            fontSize: axisTextSize,
            color: KStaticConfig().chartColors['axisDate']),
        top: true,
        align: KTextAlign.center,
      );
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {}

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
