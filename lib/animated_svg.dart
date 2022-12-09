library animated_svg;

import 'dart:ui';

import 'package:animated_svg/clipped_path_canvas_proxy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';

import 'measure_path_length_canvas.dart';

class AnimatedSvg extends StatelessWidget {
  const AnimatedSvg(this.svgString, {super.key});

  static Future<double> getPathLengthSum(String svgString) async {
    final root = await SvgParser().parse(svgString);
    final c = MeasurePathLengthCanvas(PictureRecorder());
    root.draw(c, const Rect.fromLTRB(0, 0, 100, 100));
    return c.pathLengthSum;
  }

  final String svgString;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SvgParser().parse(svgString),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const CircularProgressIndicator();
          }
          return CustomPaint(painter: MyPainter(snapshot.data!));
        });
  }
}

class MyPainter extends CustomPainter {
  MyPainter(this.drawableRoot);

  final DrawableRoot drawableRoot;

  @override
  void paint(Canvas canvas, Size size) {
    drawableRoot.draw(ClippedPathCanvasProxy(canvas, pathLengthLimit: 200),
        drawableRoot.viewport.viewBoxRect);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: optimize?
    return true;
  }
}
