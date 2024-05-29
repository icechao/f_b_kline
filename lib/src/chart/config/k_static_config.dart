import 'package:f_b_kline/src/chart/k_text_painter.dart';
import 'package:flutter/material.dart';

/// K线的显示类型
enum ChartGroupType { withVol, withVolSen, withSen, withNone }

/// 附图的指标类型
enum ChartSenType { macd, kdj, wr, rsi, cci }

/// 主图显示的类型
enum ChartDisplayType { kline, timeLine }

/// 主图显示的指标类型
enum MainDisplayType { boll, ma, none }

///十字线的显示模式
enum CrossType { followClose, followFinger, followAll }

/// X坐标的滑动模式
enum XAxisType { flow, pin }

///选中手势的点击模式
enum TapType { single, continuous }

///静态常量工具不需要修改
///只需要在运行前修改代码
class KStaticConfig {
  ///---------------------------------------------------------

  /// instance
  static KStaticConfig? _instance;

  /// constructor
  KStaticConfig._internal() {
    _instance = this;
  }

  /// factory
  factory KStaticConfig() {
    _instance ??= KStaticConfig._internal();
    return _instance!;
  }

  ///展示与实际值的计算因数  :
  /// max = min
  /// max = max *( 1+ displayFactor)
  /// min = min * ( 1-displayFactor)
  /// max = max + (max-min) * displayFactor
  /// min = min - (max-min) * displayFactor

  double get displayFactor => 0.2;

  /// X坐标高
  double xAxisHeight = 20.0;

  /// 初始右侧space
  double kRightSpace = 100;

  /// 最大最小值连线的长
  double maxMinLineLength = 20.0;

  ///主图纵坐标文字大小
  double mainAxisTextSize = 10.0;

  ///最高最低文字大小
  double maxMinTextSize = 10.0;

  ///主图横坐标文字大小
  double mainXAxisTextSize = 10.0;

  ///成交量坐标文字大小
  double volAxisTextSize = 10.0;

  ///附图坐标文字大小
  double senAxisTextSize = 10.0;

  ///主图上内间距
  double topPadding = 30.0;

  ///网格行数
  int gridRowCount = 4;

  ///网络列数
  int gridColumnCount = 4;

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

  /// x axis count
  int xAxisCount = 3;

  /// x axis align
  KAlign xAxisAlign = KAlign.center;

  /// X坐标适配
  bool fitXAxis = true;

  ///十字线渐变色,仅在十字线竖线是宽线模式线生效
  List<Color> crossColors = [
    Colors.transparent,
    Colors.white30,
    Colors.white30,
    Colors.transparent
  ];

  ///十字线纵向渐变色关键点
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

    /// 选中的时间的背景色
    'selectedDateBackground': Colors.deepPurple,

    /// 十字线横线颜色
    'crossHorizontal': Colors.white,

    /// 十字线竖线颜色
    'crossVertical': Colors.white,

    /// 选中弹出窗的背景色
    'infoWindowBackground': Colors.lightBlueAccent,

    /// 选中弹出窗的边框颜色
    'infoWindowBorder': Colors.white,

    /// 当前价格线颜色
    'priceLineColor': Colors.grey,

    /// 当前价格框背景颜色
    'priceLineRectBackground': Colors.orange,

    /// 当前选中价格框背景颜色
    'selectedPriceBackground': Colors.orange,

    ///当前价格文字颜色
    'priceLineText': Colors.white,

    /// 最大值最小值颜色
    'maxMinColor': Colors.white,
  };
}

/// K线的指标参数
class KIndexParams {
  /// instance
  static KIndexParams? _instance;

  /// constructor
  KIndexParams._internal() {
    _instance = this;
  }

  /// factory
  factory KIndexParams() {
    _instance ??= KIndexParams._internal();
    return _instance!;
  }

  ///ma参数
  int mainMa1 = 5;

  ///ma参数
  int mainMa2 = 10;

  ///ma参数
  int mainMa3 = 20;

  ///boll参数
  int bollN = 20;

  ///boll参数
  int bollK = 2;

  ///cci参数
  int cciCount = 14;

  /// kdj参数
  int kdjN = 9;

  /// kdj参数
  int kdjM1 = 3;

  /// kdj参数
  int kdjM2 = 3;

  ///成交量ma
  int volMa1 = 5;

  ///成交量ma
  int volMa2 = 10;

  ///wr
  int rsiOne = 10;

  ///rsi
  int wrOne = 10;

  ///计算使用参数
  ///macd
  int macdS = 12;

  ///macd
  int macdL = 26;

  ///macd
  int macdM = 9;
}