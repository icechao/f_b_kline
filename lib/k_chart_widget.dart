import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:f_b_kline/background_painter.dart';
import 'package:f_b_kline/data_adapter.dart';
import 'package:f_b_kline/chart_painter.dart';
import 'package:f_b_kline/k_run_config.dart';
import 'package:f_b_kline/k_static_config.dart';

class KChartWidget extends StatefulWidget {
  final DataAdapter adapter;
  final KRunConfig config;

  const KChartWidget(this.adapter, {super.key, required this.config});

  @override
  State<StatefulWidget> createState() {
    return KChartWidgetState();
  }
}

class KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  late ValueNotifier<int> repaint;

  StreamSubscription? bindChartTypeListener,
      bindDataListener,
      bindTranslateListener;

  AnimationController? animationController;

  @override
  void initState() {
    bindChartTypeListener?.cancel();
    bindTranslateListener?.cancel();
    bindDataListener?.cancel();
    repaint = ValueNotifier<int>(-9999999999);
    bindChartTypeListener = widget.adapter.bindChartTypeListener((type) {
      if (type is ChartGroupType) {
        if (type != widget.config.type) {
          widget.config.type = type;
          reRender(force: true);
        }
      } else if (type is MainDisplayType) {
        if (type != widget.config.mainDisplayType) {
          widget.config.mainDisplayType = type;
          reRender(force: true);
        }
      } else if (type is ChartSenType) {
        if (type != widget.config.chartSenType) {
          widget.config.chartSenType = type;
          reRender(force: true);
        }
      }
    });

    bindDataListener = widget.adapter.bindDataListener((data) {
      reRender(force: true);
    });

    bindTranslateListener = widget.adapter.bindTranslateListener((data) {
      reRender();
    });

    animationController = AnimationController(
        vsync: this,
        value: 0,
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity,
        duration: const Duration(seconds: 1));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double tempScale = 0;

    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        var dataLength = widget.adapter.dataLength;
        if (dataLength > 0) {
          if (details.pointerCount > 1) {
            tempScale = widget.config.scaleX;
            reRender();
          } else {
            widget.config.updateSelectedX(details.focalPoint.dx);
          }
        }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        widget.config.selectedX = null;
        var dataLength = widget.adapter.dataLength;
        if (dataLength != 0) {
          if (details.pointerCount > 1) {
            widget.config.updateScale(
                (((details.horizontalScale - 1) / 2) + 1.0) * tempScale,
                dataLength);
          } else {
            widget.config
                .updateTranslateWithDx(details.focalPointDelta.dx, dataLength);
          }
          reRender();
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        var dataLength = widget.adapter.dataLength;
        if (dataLength > 0) {
          ClampingScrollSimulation clampingScrollSimulation =
              ClampingScrollSimulation(
                  position: widget.config.translateX,
                  velocity: details.velocity.pixelsPerSecond.dx,
                  friction: 0.09);
          animationController?.addListener(() {
            double tempValue = animationController?.value ?? 0.0;
            if (!tempValue.isInfinite &&
                tempValue != widget.config.translateX) {
              widget.config.updateTranslate(tempValue, dataLength);
              reRender();
            }
          });
          animationController?.animateWith(clampingScrollSimulation);
          reRender();
        }
      },
      onTapUp: (TapUpDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          if (widget.config.selectedX != null) {
            widget.config.selectedX = null;
          } else {
            widget.config.updateSelectedX(details.globalPosition.dx);
          }
          reRender();
        }
      },
      onLongPressStart: (LongPressStartDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          reRender();
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          reRender();
        }
      },
      onTapDown: (TapDownDetails details) {
        var dataLength = widget.adapter.dataLength;
        if (dataLength != 0) {
          animationController?.stop();
          animationController?.reset();
          reRender();
        }
      },
      child: CustomPaint(
        painter: BackgroundPainter(),
        foregroundPainter: ChartPainter(
            widget.config.type ?? ChartGroupType.withVol,
            widget.adapter,
            widget.config,
            repaint),
      ),
    );
  }

  void reRender({bool force = false}) {
    if (force) {
      repaint.value = DateTime.now().millisecondsSinceEpoch;
    } else {
      var newTime = DateTime.now().millisecondsSinceEpoch;
      if (newTime - (repaint.value) > 10) {
        repaint.value = newTime;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    bindChartTypeListener?.cancel();
    bindTranslateListener?.cancel();
    bindDataListener?.cancel();
  }
}
