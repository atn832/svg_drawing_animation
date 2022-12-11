import 'dart:ui';

/// A Function that renders a Pen.
abstract class PenRenderer {
  ///
  void draw(
      Canvas canvas,

      /// Position of the pen.
      Offset penPosition,

      /// The Path's current [Paint].
      Paint currentPaint);
}
