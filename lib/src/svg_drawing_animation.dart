import 'dart:ui';

import 'package:flutter/material.dart' hide ErrorWidgetBuilder;
import 'package:flutter_svg/flutter_svg.dart';

import 'builders.dart';
import 'measure_path_length_canvas.dart';
import 'clipped_path_painter.dart';
import 'pen_renderer/pen_renderer.dart';
import 'svg_provider.dart';

/// A widget that displays a drawing animation of SVG.
class SvgDrawingAnimation extends StatefulWidget {
  const SvgDrawingAnimation(this.svgProvider,
      {super.key,
      required this.duration,
      this.curve = Curves.linear,
      this.repeats = false,
      this.loadingWidgetBuilder = defaultLoadingWidgetBuilder,
      this.errorWidgetBuilder = defaultErrorWidgetBuilder,
      this.penRenderer});

  /// Provides the SVG to display.
  final SvgProvider svgProvider;

  /// Whether the animation plays once or repeats indefinitely.
  final bool repeats;

  /// The duration over which to animate.
  final Duration duration;

  /// The curve to apply when animating.
  final Curve curve;

  /// A builder that specifies the widget to display to the user while the SVG
  /// is still loading.
  final LoadingWidgetBuilder loadingWidgetBuilder;

  /// A builder that specifies the widget to display to the user if an error
  /// has occurred.
  final ErrorWidgetBuilder errorWidgetBuilder;

  /// Optionally renders the Pen during the drawing animation.
  final PenRenderer? penRenderer;

  /// Computes the total length of paths in SVG.
  static double getPathLengthSum(Drawable drawable) {
    final c = MeasurePathLengthCanvas(PictureRecorder());
    // TODO: pass proper values to bounds.
    drawable.draw(c, const Rect.fromLTRB(0, 0, 1, 1));
    return c.pathLengthSum;
  }

  @override
  State<SvgDrawingAnimation> createState() => _SvgDrawingAnimationState();
}

class _SvgDrawingAnimationState extends State<SvgDrawingAnimation>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  bool isTotalPathLengthSet = false;
  late final double totalPathLength;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = CurvedAnimation(parent: controller, curve: widget.curve);
    if (widget.repeats) {
      controller.repeat();
    } else {
      controller.forward();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.svgProvider.resolve(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return widget.loadingWidgetBuilder(context);
          }
          if (snapshot.hasError) {
            return widget.errorWidgetBuilder(
                context, snapshot.error!, snapshot.stackTrace);
          }
          final drawable = snapshot.data!;
          if (!isTotalPathLengthSet) {
            totalPathLength = SvgDrawingAnimation.getPathLengthSum(drawable);
            isTotalPathLengthSet = true;
          }
          return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return FittedBox(
                    child: SizedBox.fromSize(
                        size: drawable.viewport.viewBox,
                        child: CustomPaint(
                            painter: ClippedPathPainter(snapshot.data!,
                                pathLengthLimit:
                                    animation.value * totalPathLength,
                                penRenderer: widget.penRenderer))));
              });
        });
  }
}
