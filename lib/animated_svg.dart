library animated_svg;

import 'dart:ui';

import 'package:animated_svg/clipped_path_canvas_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

import 'measure_path_length_canvas.dart';

class AnimatedSvg extends StatefulWidget {
  const AnimatedSvg(this.svgString, {super.key});

  static Future<double> getPathLengthSum(String svgString) async {
    final root = await SvgParser().parse(svgString);
    final c = MeasurePathLengthCanvas(PictureRecorder());
    root.draw(c, const Rect.fromLTRB(0, 0, 100, 100));
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

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = Tween<double>(begin: 0, end: 300).animate(controller)
      ..addListener(() {
        setState(() {
          // The state that has changed here is the animation object’s value.
        });
      });
    controller.forward();
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
          return CustomPaint(
              painter:
                  MyPainter(snapshot.data!, pathLengthLimit: animation.value));
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
