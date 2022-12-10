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
    for (final contourMetrics in path.computeMetrics()) {
      // Compute how much we're allowed to draw.
      final lengthToDraw =
          min(pathLengthLimit - drawnPathLength, contourMetrics.length);

      // If we can't draw anymore, abort.
      if (lengthToDraw == 0) {
        break;
      }

      // Pass-through draw.
      final pathToDraw = contourMetrics.extractPath(0, lengthToDraw);
      canvas.drawPath(pathToDraw, paint);
      drawnPathLength += lengthToDraw;

      // If we drew less than the full contour length, it means we've reached
      // [pathLengthLimit] and the end of the current contour is where the "pen"
      // is.
      final isFinalStroke = lengthToDraw < contourMetrics.length;
      if (isFinalStroke) {
        final pathEndPoint = contourMetrics
            .extractPath(lengthToDraw, lengthToDraw, startWithMoveTo: true);
        final tipPosition = pathEndPoint.getBounds().center;
        pathEndPoint.moveTo(tipPosition.dx, tipPosition.dy);
        pathEndPoint.addOval(Rect.fromCircle(center: tipPosition, radius: 10));
        final tipPaint = Paint()..color = Colors.red;
        // Render the pen's tip.
        canvas.drawPath(pathEndPoint, tipPaint);
      }
    }
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
