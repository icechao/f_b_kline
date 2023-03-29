import 'dart:math';

import 'package:f_b_kline/chart/entity/k_line_entity.dart';
import 'package:f_b_kline/chart/k_static_config.dart';

class DataUtil {
  static calculate(List<KLineEntity> dataList) {
    calcMA(dataList, KStaticConfig().mainMa1, KStaticConfig().mainMa2,
        KStaticConfig().mainMa3);
    calcBOLL(dataList, KStaticConfig().bollN, KStaticConfig().bollK);
    calcVolumeMA(dataList, KStaticConfig().volMa1, KStaticConfig().volMa2);
    calcKDJ(dataList, KStaticConfig().kdjN, KStaticConfig().kdjM1,
        KStaticConfig().kdjM2);
    calcMACD(dataList, KStaticConfig().macdS, KStaticConfig().macdL,
        KStaticConfig().macdM);
    calcRSI(dataList, KStaticConfig().rsiOne);
    calcWR(dataList, KStaticConfig().wrOne);
    calcCCI(dataList, KStaticConfig().cciCount);
  }

  static calcMA(
      List<KLineEntity> dataList, int firParam, int senParam, int thrParam) {
    double fir = 0.0, sen = 0.0, thi = 0.0;
    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];

        var temp = i - firParam;
        if (temp >= 0) {
          fir -= dataList[temp].close;
        }
        fir += entity.close;

        temp = i - senParam;
        if (temp >= 0) {
          sen -= dataList[temp].close;
        }
        sen += entity.close;

        temp = i - thrParam;
        if (temp >= 0) {
          thi -= dataList[temp].close;
        }
        thi += entity.close;
        if (i >= firParam) {
          entity.ma1 = fir / firParam.toDouble();
        }
        if (i >= senParam) {
          entity.ma2 = sen / senParam.toDouble();
        }
        if (i >= thrParam) {
          entity.ma3 = thi / thrParam.toDouble();
        }
      }
    }
  }

  static void calcBOLL(List<KLineEntity> dataList, int n, int k) {
    _calcBOLLMA(n, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= n) {
        double md = 0.0;
        for (int j = i - n + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.bollMa!;
          double value = c - m;
          md += value * value;
        }
        md = md / (n - 1);
        md = sqrt(md);
        entity.mb = entity.bollMa!;
        entity.up = entity.mb! + k * md;
        entity.dn = entity.mb! - k * md;
      }
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.bollMa = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.bollMa = ma / day;
      } else {
        entity.bollMa = null;
      }
    }
  }

  /// 12 26 9
  static void calcMACD(
      List<KLineEntity> dataList, int ma1, ma2, int diffParam) {
    double ema1 = 0;
    double ema2 = 0;
    double dif = 0.0;
    double dea = 0.0;
    double macd = 0.0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema1 = closePrice;
        ema2 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema1 = ema1 * (ma1 - 1) / (ma1 + 1) + closePrice * 2 / (ma1 + 1);
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema2 = ema2 * (ma2 - 1) / (ma2 + 1) + closePrice * 2 / (ma2 + 1);
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema1 - ema2;
      dea = dea * (diffParam - 1) / (diffParam + 1) + dif * 2 / (diffParam + 1);
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  static void calcVolumeMA(List<KLineEntity> dataList, int volMa1, int volMa2) {
    double volumeMa1 = 0.0;
    double volumeMa2 = 0.0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];

      var temp = i - volMa1;
      if ((temp) >= 0) {
        volumeMa1 -= dataList[temp].vol;
      }
      volumeMa1 += entity.vol;
      temp = i - volMa2;
      if (temp > 0) {
        volumeMa2 -= dataList[temp].vol;
      }
      volumeMa2 += entity.vol;
      if (i >= volMa1) {
        entity.maVolume1 = volumeMa1 / volMa1.toDouble();
      }
      if (i >= volMa2) {
        entity.maVolume2 = volumeMa2 / volMa2.toDouble();
      }
    }
  }

  static void calcRSI(List<KLineEntity> dataList, int rsiParsm) {
    double? rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0.0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double rMax = max(0, closePrice - dataList[i - 1].close.toDouble());
        double rAbs = (closePrice - dataList[i - 1].close.toDouble()).abs();

        rsiMaxEma = (rMax + (rsiParsm - 1) * rsiMaxEma) / rsiParsm;
        rsiABSEma = (rAbs + (rsiParsm - 1) * rsiABSEma) / rsiParsm;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < (rsiParsm - 1)) rsi = null;
      entity.rsi = rsi;
    }
  }

  static void calcKDJ(List<KLineEntity> dataList, int n, int m1, int m2) {
    var preK = 50.0;
    var preD = 50.0;
    final tmp = dataList.first;
    tmp.k = preK;
    tmp.d = preD;
    tmp.j = 50.0;
    for (int i = 1; i < dataList.length; i++) {
      final entity = dataList[i];
      final temp = max(0, i - n + 1);
      var low = entity.low;
      var high = entity.high;
      for (int j = temp; j < i; j++) {
        final t = dataList[j];
        if (t.low < low) {
          low = t.low;
        }
        if (t.high > high) {
          high = t.high;
        }
      }
      final cur = entity.close;
      var rsv = (cur - low) * 100.0 / (high - low);
      rsv = rsv.isNaN ? 0 : rsv;
      final k = ((m1 - 1) * preK + rsv) / m1;
      final d = ((m2 - 1) * preD + k) / m2;
      final j = 3 * k - 2 * d;
      preK = k;
      preD = d;
      entity.k = k;
      entity.d = d;
      entity.j = j;
    }
  }

  static void calcWR(List<KLineEntity> dataList, int wrParam) {
    double r;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - wrParam;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double tempMax = 0.0;
      double tempMin = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        tempMax = max(tempMax, dataList[index].high);
        tempMin = min(tempMin, dataList[index].low);
      }
      if (i < (wrParam - 1)) {
        entity.r = -10;
      } else {
        r = -100 * (tempMax - dataList[i].close) / (tempMax - tempMin);
        entity.r = r;
      }
    }
  }

  static void calcCCI(List<KLineEntity> dataList, int count) {
    final size = dataList.length;
    for (int i = 0; i < size; i++) {
      final kline = dataList[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (dataList[n].high + dataList[n].low + dataList[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (dataList[n].high + dataList[n].low + dataList[n].close) / 3)
                .abs();
      }
      final md = amount / len;
      kline.cci = ((tp - ma) / 0.015 / md);
    }
  }
}
