import 'package:f_b_kline/src/chart/config/k_run_config.dart';
import 'package:f_b_kline/src/chart/data_adapter.dart';
import 'package:flutter/material.dart';

///主视图绘制调度
class ChartPainter extends CustomPainter {
  final KRunConfig runConfig;
  final DataAdapter adapter;
  final Listenable repaint;

  /// constructor
  /// [adapter] data adapter
  /// [runConfig] cache config
  /// [repaint] repaint
  const ChartPainter(this.adapter, this.runConfig, this.repaint)
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    if (adapter.data.isEmpty) {
      return;
    }

    runConfig
      ..setSize(size)
      ..initRect(runConfig.chartGroupType, adapter)
      ..calcScreenIndex(adapter)
      ..calcShowValues(adapter)
      ..renderChart(canvas, adapter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
