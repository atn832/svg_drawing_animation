import 'dart:typed_data';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

// Because of https://github.com/flutter/flutter/issues/116847, we cannot
// extend Canvas on Web. Instead we need to implement it ourselves. So we
// implement transformations manually using Matrix4.
class MeasurePathLengthCanvas implements Canvas {
  double pathLengthSum = 0;
  Float64List _transform = Float64List.fromList(Matrix4.identity().storage);
  final List<Float64List> _transformStack = [];

  MeasurePathLengthCanvas();

  @override
  void drawPath(Path path, Paint paint) {
    final pathLength = path
        .transform(getTransform())
        .computeMetrics()
        .map((contourMetric) => contourMetric.length)
        .reduce(
          (value, element) => value + element,
        );
    pathLengthSum += pathLength;
  }

  @override
  void save() {
    // Push.
    _transformStack.add(_transform);
  }

  @override
  void restore() {
    // Pop.
    _transform = _transformStack.last;
    _transformStack.removeLast();
  }

  @override
  Float64List getTransform() {
    return _transform;
  }

  @override
  void transform(Float64List matrix4) {
    _transform = Matrix4.fromFloat64List(_transform)
        .multiplied(Matrix4.fromFloat64List(matrix4))
        .storage;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Do nothing.
  }
}
