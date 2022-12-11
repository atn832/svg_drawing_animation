import 'dart:ui';

/// A class that renders a Pen.
abstract class PenRenderer {
  /// Draws a Pen.
  /// @param penPosition Position of the pen.
  /// @param currentPaint The Path's current [Paint].
  void draw(Canvas canvas, Offset penPosition, Paint currentPaint);
}
