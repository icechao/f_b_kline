import 'dart:async';
import 'dart:isolate';

import 'package:f_b_kline/export_k_chart.dart';
import 'package:flutter/cupertino.dart';

///数据适配器
class DataAdapter {
  List<KLineEntity> data = [];
  int dataLength = 0;
  List<double> mainDisplayPoints = [];
  List<double> volDisplayPoints = [];
  List<double> senDisplayPoints = [];
  Isolate? isolate;

  StreamController dataController = StreamController.broadcast();
  StreamController<dynamic> typeController =
      StreamController<ChartGroupType>.broadcast();
  StreamController<double> translateController =
      StreamController<double>.broadcast();

  ///注册数据变化监听
  StreamSubscription bindDataListener(void Function(dynamic) function) {
    return dataController.stream.listen(function);
  }

  ///注册K线布局变化监听
  StreamSubscription bindChartTypeListener(void Function(dynamic) function) {
    return typeController.stream.listen(function);
  }

  ///注册改变k线位置监听
  StreamSubscription bindTranslateListener(void Function(double) function) {
    return translateController.stream.listen(function);
  }

  ///重置数据 当数据发生变化时调用
  ///[KLineEntity]数据模型
  resetData(List<KLineEntity>? data, {bool resetTranslate = false}) {
    dataLength = data?.length ?? 0;
    this.data
      ..clear()
      ..addAll(data ?? []);
    if (resetTranslate) {
      /// 是否使用动画重置
      changeTranslate(double.minPositive);
    }
    sendPort.send(data);
  }

  ///chart显示组合类型 会自动根据类型切换对应的类型
  /// [ChartGroupType]  主图成交量指标视图显示
  /// [ChartSenType]    附图类型显示
  /// [ChartDisplayType]  K线还是折线图
  /// [MainDisplayType]  主图指标显示
  changeType(dynamic type) {
    typeController.add(type);
  }

  ///X轴平移变化
  changeTranslate(double translate) {
    translateController.add(translate);
  }

  late SendPort sendPort;

  DataAdapter() {
    _initReceive();
  }

  /// init listeners
  void _initReceive() async {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is SendPort) {
        sendPort = message;
      } else if (message is List<KLineEntity>) {
        data
          ..clear()
          ..addAll(message);
        debugPrint(runtimeType.toString());
        dataController.add(1);
      }
    });
    isolate ??= await Isolate.spawn(
      _isolateFuture,
      receivePort.sendPort,
    );
  }

  void dispose() {
    isolate?.kill();
  }
}

/// new thread
/// [sendPort]  sendPort [SendPort]
_isolateFuture(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();

  receivePort.listen((message) {
    if (message is List<KLineEntity>) {
      DataUtil.calculate(message);
      sendPort.send(message);
    }
  });

  sendPort.send(receivePort.sendPort);
}
