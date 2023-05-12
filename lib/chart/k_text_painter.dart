import 'package:flutter/cupertino.dart';

/// 文本位置枚举
enum KTextAlign { left, center, right }

///文本渲染封装
class KTextPainter {
  final Paint paint = Paint();

  late double x, y, boxHeight;
  late TextPainter painter = TextPainter();

  KTextPainter(this.x, this.y, {StrutStyle? strutStyle, this.boxHeight = 0}) {
    painter
      ..textDirection = TextDirection.ltr
      ..strutStyle = strutStyle;
  }

  /// paint text
  renderText(Canvas canvas, InlineSpan span,
      {bool top = false, KTextAlign? align, Color? backGroundColor}) {
    painter
      ..text = span
      ..layout();
    double dx;
    switch (align) {
      case KTextAlign.left:
        dx = x - painter.width;
        break;
      case KTextAlign.center:
        dx = x - painter.width / 2;
        break;

      case KTextAlign.right:
      default:
        dx = x;
        break;
    }
    double tempY;
    if (boxHeight > painter.height) {
      tempY = y - ((boxHeight - painter.height) / 2);
    } else {
      tempY = y;
    }

    var dy = top ? tempY - painter.height : tempY;
    if (null != backGroundColor) {
      canvas.drawRect(
          Rect.fromLTRB(dx, dy, dx + painter.width, dy + painter.height),
          paint..color = backGroundColor);
    }

    painter.paint(canvas, Offset(dx, dy));
  }
}
