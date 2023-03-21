import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:f_b_kline/data_helper.dart';
import 'package:f_b_kline/entity/index.dart';
import 'package:f_b_kline/k_static_config.dart';

class DataAdapter {
  List<KLineEntity> data = [];
  int dataLength = 0;
  List<double> mainDisplayPoints = [];
  List<double> volDisplayPoints = [];
  List<double> senDisplayPoints = [];
  Isolate? isolate;

  StreamController<int> dataController = StreamController<int>.broadcast();
  StreamController<dynamic> typeController =
      StreamController<ChartGroupType>.broadcast();
  StreamController<double> translateController =
      StreamController<double>.broadcast();

  StreamSubscription bindDataListener(void Function(dynamic) function) {
    return dataController.stream.listen(function);
  }

  StreamSubscription bindChartTypeListener(void Function(dynamic) function) {
    return typeController.stream.listen(function);
  }

  StreamSubscription bindTranslateListener(void Function(double) function) {
    return translateController.stream.listen(function);
  }

  ///重置数据 当数据发生变化时调用
  resetData(List<KLineEntity>? data, {bool resetTranslate = false}) {
    dataLength = data?.length ?? 0;
    this.data
      ..clear()
      ..addAll(data ?? []);
    if (resetTranslate) {
      /// 是否使用动画重置
    }
    sendPort.send(data);
  }

  changeType(ChartGroupType type) {
    typeController.add(type);
  }

  changeTranslate(double translate) {
    translateController.add(translate);
  }

  late SendPort sendPort;

  DataAdapter() {
    initReceive();
  }

  void initReceive() async {
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
      isolateFuture,
      receivePort.sendPort,
    );
  }

  void dispose() {
    isolate?.kill();
  }
}

isolateFuture(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();

  receivePort.listen((message) {
    if (message is List<KLineEntity>) {
      DataUtil.calculate(message);
      sendPort.send(message);
    }
  });

  sendPort.send(receivePort.sendPort);
}
