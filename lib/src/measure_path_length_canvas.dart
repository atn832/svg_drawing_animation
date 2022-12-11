import 'dart:ui';

class MeasurePathLengthCanvas extends Canvas {
  double pathLengthSum = 0;

  MeasurePathLengthCanvas(super.recorder);

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
}
