import 'package:f_b_kline/src/chart/data_adapter.dart';
import 'package:f_b_kline/src/chart/k_run_config.dart';
import 'package:f_b_kline/src/chart/k_static_config.dart';
import 'package:flutter/material.dart';

///主视图绘制调度
class ChartPainter extends CustomPainter {
  final KRunConfig runConfig;
  final ChartGroupType? type;
  final DataAdapter adapter;
  final Listenable repaint;

  /// constructor
  /// [type] type  [ChartGroupType]
  /// [adapter]   adapter   [DataAdapter]
  /// [repaint]   repaint notice   [Listenable]
  const ChartPainter(this.type, this.adapter, this.runConfig, this.repaint)
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (adapter.data.isEmpty) {
      return;
    }

    runConfig
      ..setSize(size)
      ..initRect(type, adapter)
      ..calcScreenIndex(adapter)
      ..calcShowValues(adapter)
      ..renderChart(canvas, adapter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
