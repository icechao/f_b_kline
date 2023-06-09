import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:f_b_kline/chart/background_painter.dart';
import 'package:f_b_kline/chart/data_adapter.dart';
import 'package:f_b_kline/chart/chart_painter.dart';
import 'package:f_b_kline/chart/k_run_config.dart';
import 'package:f_b_kline/chart/k_static_config.dart';

/// Kline chart Widget
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

  @override
  void initState() {
    animationController = AnimationController(
        vsync: this,
        value: 0,
        lowerBound: double.negativeInfinity,
        upperBound: double.infinity,
        duration: const Duration(seconds: 1));

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
      } else if (type is ChartDisplayType) {
        if (type != widget.config.chartDisplayType) {
          widget.config.chartDisplayType = type;
          reRender(force: true);
        }
      }
    });

    bindDataListener = widget.adapter.bindDataListener((data) {
      reRender(force: true);
    });

    bindTranslateListener = widget.adapter.bindTranslateListener((data) {
      animationController?.reset();
      Animation animate = Tween(begin: widget.config.translateX, end: data)
          .animate(animationController!);
      listener() {
        widget.config.updateTranslate(animate.value, widget.adapter.dataLength);
      }

      stateListener(status) {
        if (status == AnimationStatus.completed) {
          animationController?.removeListener(listener);
          animationController?.removeStatusListener(stateListener);
        }
      }

      animationController
        ?..addListener(listener)
        ..addStatusListener(stateListener);

      reRender();
    });

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
          reRender();
        }
      },
      onScaleEnd: (ScaleEndDetails details) {
        debugPrint('detail   :   ${details.velocity.pixelsPerSecond.dx}');
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
              reRender();
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
          reRender();
        }
      },
      onTapUp: (TapUpDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          if (widget.config.selectedX != null) {
            widget.config.updateSelectedX(null);
            widget.config.updateSelectedY(null);
          } else {
            widget.config.updateSelectedX(details.globalPosition.dx);
            widget.config.updateSelectedY(details.localPosition.dy);
          }
          reRender();
        }
      },
      onLongPressStart: (LongPressStartDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          widget.config.updateSelectedY(details.localPosition.dy);
          reRender();
        }
      },
      onLongPressMoveUpdate: (LongPressMoveUpdateDetails details) {
        var dataLength = widget.adapter.dataLength;

        if (dataLength > 0) {
          widget.config.updateSelectedX(details.globalPosition.dx);
          widget.config.updateSelectedY(details.localPosition.dy);
          reRender();
        }
      },
      onTapDown: (TapDownDetails details) {
        var dataLength = widget.adapter.dataLength;
        if (dataLength != 0) {
          animationController?.stop();
          animationController?.clearListeners();
          animationController?.clearStatusListeners();
          animationController?.reset();
          reRender();
        }
      },
      child: CustomPaint(
        painter: BackgroundPainter(),
        foregroundPainter: ChartPainter(
            widget.config.type ?? ChartGroupType.withVolSen,
            widget.adapter,
            widget.config,
            repaint),
      ),
    );
  }

  /// next frame repaint
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

  @override
  void didRegisterListener() {
    animationController?.didRegisterListener();
  }

  @override
  void didUnregisterListener() {
    animationController?.didUnregisterListener();
  }
}
