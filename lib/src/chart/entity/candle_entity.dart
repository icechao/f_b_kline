mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;

  ///均线
  double? ma1;
  double? ma2;
  double? ma3;

  ///  上轨线
  double? up;

  ///  中轨线
  double? mb;

  ///  下轨线
  double? dn;

  double? bollMa;
}
