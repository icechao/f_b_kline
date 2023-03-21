import 'package:flutter/material.dart';

enum ChartGroupType { withVol, withVolSen, withSen, withNone }

enum ChartSenType { macd, kdj, wr, rsi, cci, none }

enum ChartDisplayType { kline, timeLine }

enum MainDisplayType { boll, ma, none }

///静态常量工具不需要修改
///只需要在运行前修改代码
class KStaticConfig {
  ///---------------------------------------------------------
  ///主图ma
  static const mainMa1 = 5;
  static const mainMa2 = 10;
  static const mainMa3 = 20;

  ///boll参数
  static const bollN = 20;
  static const bollK = 2;

  ///cci参数
  static const cciCount = 14;

  /// kdj参数
  static const kdjN = 9;
  static const kdjM1 = 3;
  static const kdjM2 = 3;

  ///成交量ma
  static const volMa1 = 5;
  static const volMa2 = 10;

  ///wr
  static const rsiOne = 10;

  ///rsi
  static const wrOne = 10;

  /// kdj
  ///计算使用参数
  ///macd
  static const macdS = 12;
  static const macdL = 26;
  static const macdM = 9;

  ///---------------------------------------------------------

  static KStaticConfig? _instance;
  static const xAxisHeight = 20.0;

  KStaticConfig._internal() {
    _instance = this;
  }

  factory KStaticConfig() {
    _instance ??= KStaticConfig._internal();
    return _instance!;
  }

  static const gridRowCount = 5;
  static const gridColumnCount = 5;

  static const candleItemWidth = 12.0;
  static const candleItemSpace = 1.0;
  static const infoWindowWidth = 120.0;
  static const infoWindowWidthMarginVertical = 20.0;
  static const infoWindowWidthMarginHorizontal = 20.0;
  static const infoWindowItemHeight = 20.0;
  static const lineWidth = 1.0;
  static const defaultChartType = ChartGroupType.withVol;

  static const topPadding = 30.0;

  static const chartColors = {
    ///默认文本颜色
    'text': Colors.blue,

    ///分时线
    'timeLine': Colors.blue,

    ///背景色
    'background': Colors.grey,

    ///涨
    'increase': Colors.green,

    ///跌
    'decrease': Colors.red,

    ///坐标文字
    'axis': Colors.grey,

    ///网格
    'grid': Colors.blueGrey,

    ///maOne
    'maFir': Colors.white,

    ///maSen
    'maSen': Colors.blue,

    ///maThi
    'maThr': Colors.yellow,

    ///boll
    'boll': Colors.white,

    ///bollUb
    'ub': Colors.yellow,

    ///bollLb
    'lb': Colors.blue,

    ///macd dif
    'dif': Colors.white,

    ///macd dea
    'dea': Colors.yellow,

    ///k
    'k': Colors.white,

    ///d
    'd': Colors.blue,

    ///j
    'j': Colors.yellow,

    ///sr
    'wr': Colors.yellow,

    ///rsi
    'rsi': Colors.yellow,

    ///cci
    'cci': Colors.yellow,

    ///成交量均线1
    'volMaFir': Colors.white,

    ///成交量均线2
    'volMaSen': Colors.yellow,

    //选中的时间的背景色
    'selectedTime': Colors.deepPurple,

    //选中的时间的背景色
    'crossHorizontal': Colors.white,
    //选中的时间的背景色
    'infoWindowBackground': Colors.lightBlueAccent,
  };
}

class CalcKeys {
  static const chartScaleWidth = 'chartScaleWidth';
  static const translateX = 'translateX';
  static const minTranslateX = 'minTranslateX';
  static const widgetWidth = 'widgetWidth';
  static const widgetHeight = 'widgetHeight';
  static const dataLength = 'dataLength';
  static const dataCount = 'dataCount';
  static const screenLeft = 'screenLeft';
  static const screenRight = 'screenRight';
  static const mainRectHeight = 'mainRectHeight';
  static const displayData = 'mainRectHeight';
}

class KMainIndex {
  static const open = 0;
  static const close = 1;
  static const low = 2;
  static const high = 3;
  static const maOne = 4;
  static const maTwo = 5;
  static const maThree = 6;
  static const mb = 7;
  static const up = 8;
  static const dn = 9;
}

class KVolIndex {
  static const vol = 0;
  static const volMaOne = 1;
  static const volMaTwo = 2;
}

class SenIndex {
  static const macd = 0;
  static const dif = 1;
  static const dea = 2;
  static const k = 3;
  static const d = 4;
  static const j = 5;
  static const wr = 6;
  static const rsi = 7;
  static const cci = 8;
  static const tempZero = 9;
}
