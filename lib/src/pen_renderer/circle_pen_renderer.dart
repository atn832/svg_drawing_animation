import 'dart:ui';

import 'pen_renderer.dart';

class CirclePenRenderer implements PenRenderer {
  CirclePenRenderer({required this.radius, this.paint});

  final double radius;

  /// A custom paint. If null, the Renderer will use the current Paint.
  final Paint? paint;

  @override
  void draw(Canvas canvas, Offset penPosition, Paint currentPaint) {
    canvas.drawCircle(penPosition, radius, paint ?? currentPaint);
  }
}
