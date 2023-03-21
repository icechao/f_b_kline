import 'package:flutter/material.dart';
import 'package:f_b_kline/data_adapter.dart';
import 'package:f_b_kline/k_run_config.dart';
import 'package:f_b_kline/k_static_config.dart';

class ChartPainter extends CustomPainter {
  final KRunConfig runConfig;
  final ChartGroupType? type;
  final DataAdapter adapter;
  final Listenable repaint;

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
