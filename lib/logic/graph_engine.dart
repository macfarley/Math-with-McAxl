import 'dart:math' as math;
import 'evaluator.dart';

/// A single (x, y) point on the graph.
class GraphPoint {
  final double x;
  final double y;
  const GraphPoint(this.x, this.y);
}

/// Result of a graph sampling pass.
class GraphData {
  final List<GraphPoint> points;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  const GraphData({
    required this.points,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });
}

/// Samples a single-variable function f(x) over [xMin, xMax].
class GraphEngine {
  final Evaluator _evaluator = Evaluator();

  /// Sample [expression] (a function of x) across [xMin]..[xMax]
  /// using [steps] sample points.  Returns a [GraphData] with valid points only.
  GraphData sample(
    String expression, {
    double xMin = -10,
    double xMax = 10,
    int steps = 400,
  }) {
    assert(steps >= 2);
    assert(xMin < xMax);

    final points = <GraphPoint>[];
    final step = (xMax - xMin) / (steps - 1);

    double yMin = double.infinity;
    double yMax = double.negativeInfinity;

    for (int i = 0; i < steps; i++) {
      final x = xMin + i * step;
      try {
        final expr = expression.replaceAll('x', '($x)');
        final y = _evaluator.evaluate(expr);
        if (y.isFinite) {
          points.add(GraphPoint(x, y));
          if (y < yMin) yMin = y;
          if (y > yMax) yMax = y;
        }
      } catch (_) {
        // Skip points where evaluation fails (e.g. sqrt of negative)
      }
    }

    if (yMin == double.infinity) yMin = -10;
    if (yMax == double.negativeInfinity) yMax = 10;
    if ((yMax - yMin).abs() < 1e-9) {
      yMin -= 1;
      yMax += 1;
    }

    return GraphData(
      points: points,
      xMin: xMin,
      xMax: xMax,
      yMin: yMin,
      yMax: yMax,
    );
  }

  /// Convert graph coordinates to screen pixel coordinates.
  static (double px, double py) toScreen(
    GraphPoint p, {
    required double screenWidth,
    required double screenHeight,
    required GraphData data,
    double padding = 0,
  }) {
    final xRange = data.xMax - data.xMin;
    final yRange = data.yMax - data.yMin;
    final px = padding + (p.x - data.xMin) / xRange * (screenWidth - 2 * padding);
    // Y axis is inverted in screen coordinates
    final py = padding + (data.yMax - p.y) / yRange * (screenHeight - 2 * padding);
    return (px, py);
  }

  /// Find the closest sample point to x-coordinate [xTarget].
  static GraphPoint? traceX(GraphData data, double xTarget) {
    if (data.points.isEmpty) return null;
    GraphPoint closest = data.points.first;
    double minDist = (closest.x - xTarget).abs();
    for (final p in data.points) {
      final d = (p.x - xTarget).abs();
      if (d < minDist) {
        minDist = d;
        closest = p;
      }
    }
    return closest;
  }

  /// Compute "nice" axis tick values for a range.
  static List<double> niceTicks(double min, double max, {int count = 5}) {
    final range = max - min;
    final rawStep = range / count;
    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floorToDouble()).toDouble();
    final niceSteps = [1.0, 2.0, 2.5, 5.0, 10.0];
    double step = magnitude;
    for (final ns in niceSteps) {
      if (magnitude * ns >= rawStep) {
        step = magnitude * ns;
        break;
      }
    }
    final start = (min / step).ceil() * step;
    final ticks = <double>[];
    double v = start;
    while (v <= max + 1e-9) {
      ticks.add(v);
      v += step;
    }
    return ticks;
  }
}
