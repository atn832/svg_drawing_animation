import 'dart:ui';

/// A class that renders a Pen.
abstract class PenRenderer {
  /// Draws a Pen. The drawing animation ends at [penPosition] using
  /// [currentPaint]. It's up to the [PenRenderer]s to use them.
  void draw(Canvas canvas, Offset penPosition, Paint currentPaint);
}
