import 'package:flutter/cupertino.dart';

/// 文本位置枚举
enum KTextAlign { left, center, right }

/// text render
class KTextPainter {
  final Paint paint = Paint();

  late double x, y, boxHeight;
  late TextPainter painter = TextPainter();

  /// 对文本进行二次封装方便后期使用
  KTextPainter(this.x, this.y, {StrutStyle? strutStyle, this.boxHeight = 0}) {
    painter
      ..textDirection = TextDirection.ltr
      ..strutStyle = strutStyle;
  }

  /// paint text
  /// [canvas] canvas
  /// [span] text
  /// [top] text 是否向上
  /// [align] align [KTextAlign]
  /// [backGroundColor] backGroundColor
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
