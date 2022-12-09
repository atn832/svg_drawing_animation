import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'clipped_path_canvas_proxy.dart';

class ClippedPathPainter extends CustomPainter {
  ClippedPathPainter(this.drawableRoot, {required this.pathLengthLimit});

  final DrawableRoot drawableRoot;
  final double pathLengthLimit;

  @override
  void paint(Canvas canvas, Size size) {
    drawableRoot.draw(
        ClippedPathCanvasProxy(canvas, pathLengthLimit: pathLengthLimit),
        // `bounds` are not used according to [DrawableRoot.draw].
        Rect.zero);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: optimize?
    return true;
  }
}
