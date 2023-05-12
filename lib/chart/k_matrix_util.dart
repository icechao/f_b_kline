import 'package:flutter/material.dart';

/// 图形变换工具类
/// 将实际数据转换成图形上的点 
class KMatrixUtils {
  static KMatrixUtils? _instance;

  KMatrixUtils._internal() {
    _instance = this;
  }

  factory KMatrixUtils() {
    _instance ??= KMatrixUtils._internal();
    return _instance!;
  }

  Matrix4? mainMatrix, volMatrix, senMatrix;

  void exeMainMatrix(double translateX, double translateY, double scaleX,
      double scaleY, List<double> data,
      {preTranslateY = 0.0}) {
    KMatrixUtils().mainMatrix = Matrix4.diagonal3Values(1, -1, 1);

    KMatrixUtils().mainMatrix!
      ..translate(translateX, preTranslateY, 0.0)
      ..scale(scaleX, scaleY, 1.0)
      ..translate(0.0, translateY, 0.0);
    KMatrixUtils().mainMatrix!.applyToVector3Array(data);
  }

  void exeVolMatrix(double translateX, double translateY, double scaleX,
      double scaleY, List<double> data,
      {preTranslateY = 0.0}) {
    KMatrixUtils().volMatrix = Matrix4.diagonal3Values(1, -1, 1);

    KMatrixUtils().volMatrix!
      ..translate(translateX, preTranslateY, 0.0)
      ..scale(scaleX, scaleY, 1.0)
      ..translate(0.0, translateY, 0.0);
    KMatrixUtils().volMatrix!.applyToVector3Array(data);
  }

  void exeSenMatrix(double translateX, double translateY, double scaleX,
      double scaleY, List<double> data,
      {preTranslateY = 0.0}) {
    KMatrixUtils().senMatrix = Matrix4.diagonal3Values(1, -1, 1);

    KMatrixUtils().senMatrix!
      ..translate(translateX, preTranslateY, 0.0)
      ..scale(scaleX, scaleY, 1.0)
      ..translate(0.0, translateY, 0.0);

    KMatrixUtils().senMatrix!.applyToVector3Array(data);
  }
}
