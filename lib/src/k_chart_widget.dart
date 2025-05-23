import 'dart:async';
import 'dart:math';

import 'package:f_b_kline/src/chart/background_painter.dart';
import 'package:f_b_kline/src/chart/chart_painter.dart';
import 'package:f_b_kline/src/export_k_chart.dart';
import 'package:flutter/cupertino.dart';

/// Kline chart Widget
class KChartWidget extends StatefulWidget {
  final DataAdapter adapter;
  final KRunConfig config;

  ///constructor
  const KChartWidget(this.adapter, {super.key, required this.config});

  @override
  State<StatefulWidget> createState() {
    return KChartWidgetState();
  }
}

class KChartWidgetState extends State<KChartWidget>
    with
        TickerProviderStateMixin,
        AnimationLocalStatusListenersMixin,
        AnimationLocalListenersMixin {
  late ValueNotifier<int> repaint;

  ///bind stream
  StreamSubscription? bindChartTypeListener,
      bindDataListener,
      bindTranslateListener;

  ///animation Controller
  AnimationController? animationController;
  AnimationController? translateController;

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this,
        value: 0,
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity,
        duration: const Duration(seconds: 1));
    translateController = AnimationController(
        vsync: this,
        value: 0,
        lowerBound: 0,
        upperBound: 1,
        duration: const Duration(seconds: 1));

    bindChartTypeListener?.cancel();
    bindTranslateListener?.cancel();
    bindDataListener?.cancel();
    repaint = ValueNotifier<int>(-9999999999);
    bindChartTypeListener = widget.adapter.bindChartTypeListener((type) {
      if (type is ChartGroupType) {
        if (type != widget.config.chartGroupType) {
          widget.config.chartGroupType = type;
          reRenderer(force: true);
        }
      } else if (type is MainDisplayType) {
        if (type != widget.config.mainDisplayType) {
          widget.config.mainDisplayType = type;
          reRenderer(force: true);
        }
      } else if (type is ChartSenType) {
        if (type != widget.config.chartSenType) {
          widget.config.chartSenType = type;
          reRenderer(force: true);
        }
      } else if (type is ChartDisplayType) {
        if (type != widget.config.chartDisplayType) {
          widget.config.chartDisplayType = type;
          reRenderer(force: true);
        }
      } else if (type is XAxisType) {
        if (type != widget.config.xAxisType) {
          widget.config.xAxisType = type;
          reRenderer(force: true);
        }
      } else if (type is CrossType) {
        if (type != widget.config.crossType) {
          widget.config.crossType = type;
          reRenderer(force: true);
        }
      } else if (type is TapType) {
        if (type != widget.config.tapType) {
          widget.config.tapType = type;
          reRenderer(force: true);
        }
      }
    });

    bindDataListener = widget.adapter.bindDataListener((data) {
      reRenderer(force: true);
    });

    bindTranslateListener = widget.adapter.bindTranslateListener((end) {
      var begin = widget.config.translateX;
      if (end != begin && !end.isInfinite) {
        translateController
          ?..stop()
          ..reset();

        // var diff = end - begin;
        var target = min(
            max(widget.config.calcMinTranslateX(widget.adapter.dataLength),
                end),
            0.0);
        Animation<double> animate = Tween<double>(begin: begin, end: target)
            .animate(translateController!);
        listener() {
          widget.config
              .updateTranslate(animate.value, widget.adapter.dataLength);
          reRenderer(force: true);
        }

        stateListener(status) {
          if (status == AnimationStatus.completed) {
            translateController?.removeListener(listener);
            translateController?.removeStatusListener(stateListener);
          }
        }

        translateController
          ?..addListener(listener)
          ..addStatusListener(stateListener);
        translateController?.forward(from: 0);
      } else {
        widget.config.updateTranslate(end, widget.adapter.dataLength);
      }
      reRenderer();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double tempScale = 0;

    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        translateController?.stop();
        var dataLength = widget.adapter.dataLength;
        if (dataLength > 0) {
          if (details.pointerCount > 1) {
            tempScale = widget.config.scaleX;
            reRenderer();
          } else {
            widget.config.updateSelectedX(details.focalPoint.dx);
            widget.config.updateSelectedY(details.localFocalPoint.dy);
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
          reRenderer();
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
          listener() {
            double tempValue = animationController?.value ?? 0.0;
            if (!tempValue.isInfinite &&
                tempValue != widget.config.translateX) {
              widget.config.updateTranslate(tempValue, dataLength);
              reRenderer();
            }
          }

          animationController?.addListener(listener);
          stateListener(status) {
            if (status == AnimationStatus.completed) {
              animationController?.removeStatusListener(stateListener);
            }
          }

          animationController?.addStatusListener(stateListener);
          animationController?.animateWith(clampingScrollSimulation);
          reRenderer();
        }
      },
      onTapUp: (TapUpDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          if (widget.config.tapType == TapType.single) {
            if (widget.config.selectedX != null) {
              widget.config.updateSelectedX(null);
              widget.config.updateSelectedY(null);
            } else {
              widget.config.updateSelectedX(details.globalPosition.dx);
              widget.config.updateSelectedY(details.localPosition.dy);
            }
          } else {
            widget.config.updateSelectedX(details.globalPosition.dx);
            widget.config.updateSelectedY(details.localPosition.dy);
          }
          reRenderer();
        }
      },
      onLongPressStart: (LongPressStartDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          widget.config.updateSelectedY(details.localPosition.dy);
          reRenderer();
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          widget.config.updateSelectedY(details.localPosition.dy);
          reRenderer();
        }
      },
      onTapDown: (TapDownDetails details) {
        var dataLength = widget.adapter.dataLength;
        if (dataLength != 0) {
          animationController?.stop();
          animationController?.clearListeners();
          animationController?.clearStatusListeners();
          animationController?.reset();
          reRenderer();
        }
      },
      child: CustomPaint(
        painter: BackgroundPainter(),
        foregroundPainter: ChartPainter(widget.adapter, widget.config, repaint),
      ),
    );
  }

  /// next frame repaint
  void reRenderer({bool force = false}) {
    if (widget.adapter.dataLength != 0) {
      if (force) {
        repaint.value = DateTime.now().millisecondsSinceEpoch;
      } else {
        var newTime = DateTime.now().millisecondsSinceEpoch;
        if (newTime - (repaint.value) > 10) {
          repaint.value = newTime;
        }
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

  @override
  void didRegisterListener() {
    animationController?.didRegisterListener();
    translateController?.didRegisterListener();
  }

  @override
  void didUnregisterListener() {
    animationController?.didUnregisterListener();
    translateController?.didUnregisterListener();
  }
}
