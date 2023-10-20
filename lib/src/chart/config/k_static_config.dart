import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

enum ChartGroupType { withVol, withVolSen, withSen, withNone }

enum ChartSenType { macd, kdj, wr, rsi, cci }

enum ChartDisplayType { kline, timeLine }

enum MainDisplayType { boll, ma, none }

enum CrossType { followClose, followFinger, followAll }

enum XAxisType { flow, pin }

///静态常量工具不需要修改
///只需要在运行前修改代码
class KStaticConfig {
  ///---------------------------------------------------------

  static KStaticConfig? _instance;
  double xAxisHeight = 20.0;

  KStaticConfig._internal() {
    _instance = this;
  }

  factory KStaticConfig() {
    _instance ??= KStaticConfig._internal();
    return _instance!;
  }

  double kRightSpace = 100;

  ///主图纵坐标文字大小
  double mainAxisTextSize = 10.0;

  ///主图横坐标文字大小
  double mainXAxisTextSize = 10.0;

  ///成交量坐标文字大小
  double volAxisTextSize = 10.0;

  ///附图坐标文字大小
  double senAxisTextSize = 10.0;

  ///主图上内间距
  double topPadding = 30.0;

  ///网格行数
  int gridRowCount = 5;

  ///网络列数
  int gridColumnCount = 5;

  ///candle width
  double candleItemWidth = 12.0;

  ///candle/candle space
  double candleItemSpace = 1.0;

  ///选中弹出窗口宽
  double infoWindowWidth = 120.0;

  ///选中弹出窗口横向Padding
  double infoWindowHPadding = 5.0;

  ///选中弹出窗口外框圆角
  double infoWindowRadius = 2.0;

  ///选中弹出窗纵向与边缘距离
  double infoWindowWidthMarginVertical = 20.0;

  ///选中弹出窗纵向距离
  double infoWindowWidthMarginHorizontal = 20.0;

  ///弹出窗每行高
  double infoWindowItemHeight = 20.0;

  ///统一线宽
  double lineWidth = 0.6;

  ///最新价格线文字框左右间距
  double priceLineTextBoxHPadding = 4.0;

  ///最新价格线文字框圆角
  double priceLineTextBoxRadius = 2;

  ///主图显示图表
  ChartGroupType defaultChartType = ChartGroupType.withVol;

  /// X Axis Type
  XAxisType xAxisType = XAxisType.flow;

  /// x axis count
  int xAxisCount = 3;

  /// x axis align
  KAlign xAxisAlign = KAlign.center;

  ///十字线渐变色,仅在十字线竖线是宽线模式线生效
  List<Color> crossColors = [
    Colors.transparent,
    Colors.white30,
    Colors.white30,
    Colors.transparent
  ];

  ///十字线纵向渐变色关键眯
  List<double>? colorStops = [0.1, 0.3, 0.7, 0.9];

  final chartColors = {
    ///默认文本颜色
    'text': Colors.blue,

    ///分时线
    'timeLine': Colors.blue,

    ///背景色
    'background': Colors.black,

    ///涨
    'increase': Colors.green,

    ///跌
    'decrease': Colors.red,

    ///横坐标文字
    'axisDate': Colors.grey,

    ///选中横坐标文字
    'selectedAxisDate': Colors.grey,

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
    'selectedDateBackground': Colors.deepPurple,

    //选中的时间的背景色
    'crossHorizontal': Colors.white,
    'crossVertical': Colors.white,

    //选中的时间的背景色
    'infoWindowBackground': Colors.lightBlueAccent,

    //当前价格线颜色
    'priceLineColor': Colors.grey,

    //当前价格框背景颜色
    'priceLineRectBackground': Colors.orange,

    //当前价格文字颜色
    'priceLineText': Colors.white,
  };
}

class KIndexParams {
  static KIndexParams? _instance;

  KIndexParams._internal() {
    _instance = this;
  }

  factory KIndexParams() {
    _instance ??= KIndexParams._internal();
    return _instance!;
  }

  int mainMa1 = 5;

  int mainMa2 = 10;

  int mainMa3 = 20;

  ///boll参数
  int bollN = 20;

  int bollK = 2;

  ///cci参数
  int cciCount = 14;

  /// kdj参数
  int kdjN = 9;

  int kdjM1 = 3;

  int kdjM2 = 3;

  ///成交量ma
  int volMa1 = 5;

  int volMa2 = 10;

  ///wr
  int rsiOne = 10;

  ///rsi
  int wrOne = 10;

  /// kdj
  ///计算使用参数
  ///macd
  int macdS = 12;

  int macdL = 26;

  int macdM = 9;
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
