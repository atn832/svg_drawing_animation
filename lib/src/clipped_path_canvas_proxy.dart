import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class ClippedPathCanvasProxy implements Canvas {
  final double pathLengthLimit;
  final Canvas canvas;

  double drawnPathLength = 0;

  ClippedPathCanvasProxy(this.canvas, {required this.pathLengthLimit});

  @override
  void drawPath(Path path, Paint paint) {
    path.computeMetrics().forEach((contourMetrics) {
      final lengthToDraw =
          min(pathLengthLimit - drawnPathLength, contourMetrics.length);
      // Pass-through draw.
      if (lengthToDraw > 0) {
        final pathToDraw = contourMetrics.extractPath(0, lengthToDraw);
        canvas.drawPath(pathToDraw, paint);

        final isFinalStroke = lengthToDraw < contourMetrics.length;
        if (isFinalStroke) {
          // Render the pen's tip.
          final tip = contourMetrics.extractPath(lengthToDraw, lengthToDraw,
              startWithMoveTo: true);
          tip.addOval(
              Rect.fromCircle(center: tip.getBounds().center, radius: 10));
          final tipPaint = Paint()..color = Colors.red;
          canvas.drawPath(tip, tipPaint);
        }
      }
      drawnPathLength += lengthToDraw;
    });
  }

  @override
  void transform(Float64List matrix4) {
    return canvas.transform(matrix4);
  }

  @override
  getTransform() {
    return canvas.getTransform();
  }

  @override
  void save() {
    return canvas.save();
  }

  @override
  void restore() {
    return canvas.restore();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Ignore missing implementations.
    // super.noSuchMethod(invocation);
  }
}
