import 'package:flutter/cupertino.dart';

/// 文本位置枚举
enum KAlign { left, center, right }

/// text renderer
class KTextPainter {
  double Function(double)? xParser;

  KAlign? align;

  get x {
    return xParser?.call(_x) ?? _x;
  }

  final Paint paint = Paint();

  final double _x, _y, boxHeight;
  final TextPainter painter = TextPainter();

  /// 对文本进行二次封装方便后期使用
  KTextPainter(this._x, this._y,
      {StrutStyle? strutStyle, this.boxHeight = 0, this.xParser, this.align}) {
    painter
      ..textDirection = TextDirection.ltr
      ..strutStyle = strutStyle;
  }

  /// paint text
  /// [canvas] canvas
  /// [span] text
  /// [top] text 是否向上
  /// [align] align [KAlign]
  /// [backGroundColor] backGroundColor
  rendererText(Canvas canvas, InlineSpan span,
      {bool top = false,
      KAlign? align,
      Color? backGroundColor,
      double radius = 0,
      bool fitY = false}) {
    painter
      ..text = span
      ..layout();
    double dx;
    switch (align ?? this.align) {
      case KAlign.left:
        dx = x - painter.width;
        break;
      case KAlign.center:
        dx = x - painter.width / 2;
        break;

      case KAlign.right:
      default:
        dx = x;
        break;
    }
    double tempY;
    if (boxHeight > painter.height) {
      tempY = _y - ((boxHeight - painter.height) / 2);
    } else {
      tempY = _y;
    }

    var dy = top ? tempY - painter.height : tempY;
    if (fitY) {
      dy = dy - painter.height / 2;
    }
    if (null != backGroundColor) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(dx, dy, dx + painter.width, dy + painter.height),
              Radius.circular(radius)),
          paint..color = backGroundColor);
    }

    painter.paint(canvas, Offset(dx, dy));
  }
}
