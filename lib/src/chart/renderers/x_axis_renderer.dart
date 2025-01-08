import 'dart:ui';

import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:f_b_kline/src/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/src/chart/i_renderer.dart';

class XAxisRenderer extends IRenderer {
  XAxisRenderer(super.config, super.adapter, super.matrixUtils);

  @override
  void rendererAxis(Canvas canvas) {}

  @override
  void rendererChart(Canvas canvas, List<double> c, List<double> l,
      double itemWidth, int index) {}

  @override
  void rendererLine(Canvas canvas, {TextBuilder? builder}) {}

  @override
  void rendererText(Canvas canvas) {
    for (var element in axisPainter) {
      int? index = config.xToIndex(element.x, adapter.dataLength);
      var data = adapter.data[index];
      element.rendererText(
        canvas,
        buildTextSpan(config.dateFormatter.call(data.time),
            fontSize: axisTextSize,
            color: KStaticConfig().chartColors['axisDate']),
        top: true,
      );
    }
  }

  @override
  void calcMaxMin(KLineEntity item, int index) {}

  @override
  double get axisTextSize => KStaticConfig().senAxisTextSize;
}
