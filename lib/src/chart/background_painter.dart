import 'package:f_b_kline/src/chart/config/k_static_config.dart';
import 'package:flutter/material.dart';

/// K线背景绘制画笔
class BackgroundPainter extends CustomPainter {
  final Paint backgroundPaint = Paint();
  final Paint gridPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    canvas.drawRect(Rect.fromLTRB(0, 0, width, height), backgroundPaint);

    double columnSpace = width / KStaticConfig().gridColumnCount;
    double rowSpace =
        (height - KStaticConfig().topPadding - KStaticConfig().xAxisHeight) /
            KStaticConfig().gridRowCount;
    for (int i = 0; i <= KStaticConfig().gridColumnCount; i++) {
      var x = i * columnSpace;
      canvas.drawLine(Offset(x, 0),
          Offset(x, height - KStaticConfig().xAxisHeight), gridPaint);
    }
    for (int i = 0; i <= KStaticConfig().gridRowCount; i++) {
      var y = i * rowSpace + KStaticConfig().topPadding;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  BackgroundPainter() : super() {
    backgroundPaint
      ..color = KStaticConfig().chartColors['background']!
      ..style = PaintingStyle.fill;
    gridPaint
      ..color = KStaticConfig().chartColors['grid']!
      ..style = PaintingStyle.fill;
  }
}
