library animated_svg;

import 'dart:ui';

import 'package:animated_svg/clipped_path_canvas_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

import 'measure_path_length_canvas.dart';

class AnimatedSvg extends StatefulWidget {
  const AnimatedSvg(
    this.svgString, {
    super.key,
    required this.duration,
    this.repeats = false,
  });

  final bool repeats;
  final Duration duration;

  static double getPathLengthSum(Drawable drawable) {
    final c = MeasurePathLengthCanvas(PictureRecorder());
    drawable.draw(c, const Rect.fromLTRB(0, 0, 100, 100));
    return c.pathLengthSum;
  }

  final String svgString;

  @override
  State<AnimatedSvg> createState() => _AnimatedSvgState();
}

class _AnimatedSvgState extends State<AnimatedSvg>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  bool isTotalPathLengthSet = false;
  late final double totalPathLength;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    animation = controller;
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
        future: SvgParser().parse(widget.svgString),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const CircularProgressIndicator();
          }
          final drawable = snapshot.data!;
          if (!isTotalPathLengthSet) {
            totalPathLength = AnimatedSvg.getPathLengthSum(drawable);
            isTotalPathLengthSet = true;
          }
          return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                    painter: MyPainter(snapshot.data!,
                        pathLengthLimit: animation.value * totalPathLength));
              });
        });
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.drawableRoot, {required this.pathLengthLimit});

  final DrawableRoot drawableRoot;
  final double pathLengthLimit;

  @override
  void paint(Canvas canvas, Size size) {
    drawableRoot.draw(
        ClippedPathCanvasProxy(canvas, pathLengthLimit: pathLengthLimit),
        drawableRoot.viewport.viewBoxRect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: optimize?
    return true;
  }
}
