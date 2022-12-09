import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'measure_path_length_canvas.dart';
import 'clipped_path_painter.dart';
import 'svg_provider.dart';

typedef AnimatedSvgLoadingBuilder = Widget Function(BuildContext context);

/// A builder that renders a [CircularProgressIndicator].
Widget defaultLoadingBuilder(context) =>
    const Center(child: CircularProgressIndicator());

/// A widget that displays a drawing animation of SVG.
class SvgDrawingAnimation extends StatefulWidget {
  const SvgDrawingAnimation(this.drawableRoot,
      {super.key,
      required this.duration,
      this.curve = Curves.linear,
      this.repeats = false,
      this.loadingBuilder = defaultLoadingBuilder});

  /// The SVG to display.
  final SvgProvider drawableRoot;

  /// Whether the animation plays once or repeats indefinitely.
  final bool repeats;

  /// The duration over which to animate.
  final Duration duration;

  /// The curve to apply when animating.
  final Curve curve;

  /// A builder that specifies the widget to display to the user while the SVG
  /// is still loading.
  final AnimatedSvgLoadingBuilder loadingBuilder;

  /// Computes the total length of paths in some SVG.
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
        future: widget.drawableRoot,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return widget.loadingBuilder(context);
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
                                    animation.value * totalPathLength))));
              });
        });
  }
}
