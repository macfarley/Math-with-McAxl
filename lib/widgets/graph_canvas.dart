import 'dart:ui';
import 'package:flutter/material.dart';
import '../logic/graph_engine.dart';

/// Renders a sampled function graph with axes, ticks, and an optional trace point.
class GraphCanvas extends StatelessWidget {
  final GraphData data;
  final GraphPoint? tracePoint;

  const GraphCanvas({
    super.key,
    required this.data,
    this.tracePoint,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => CustomPaint(
        size: Size(constraints.maxWidth, constraints.maxHeight),
        painter: _GraphPainter(
          data: data,
          tracePoint: tracePoint,
          colorScheme: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final GraphData data;
  final GraphPoint? tracePoint;
  final ColorScheme colorScheme;
  static const double padding = 36.0;

  const _GraphPainter({
    required this.data,
    required this.colorScheme,
    this.tracePoint,
  });

  (double, double) _map(double x, double y, Size size) {
    final w = size.width - 2 * padding;
    final h = size.height - 2 * padding;
    final px = padding + (x - data.xMin) / (data.xMax - data.xMin) * w;
    final py = padding + (data.yMax - y) / (data.yMax - data.yMin) * h;
    return (px, py);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = colorScheme.surface;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final axisPaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.3)
      ..strokeWidth = 1.0;

    final gridPaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.08)
      ..strokeWidth = 0.5;

    // Draw grid and ticks
    final xTicks = GraphEngine.niceTicks(data.xMin, data.xMax);
    final yTicks = GraphEngine.niceTicks(data.yMin, data.yMax);

    final tickStyle = TextStyle(
      color: colorScheme.onSurface.withOpacity(0.5),
      fontSize: 9,
      fontFamily: 'monospace',
    );

    for (final tx in xTicks) {
      final (px, _) = _map(tx, 0, size);
      canvas.drawLine(Offset(px, padding), Offset(px, size.height - padding), gridPaint);
      if (tx == 0) continue;
      _drawText(canvas, _fmt(tx), Offset(px - 10, size.height - padding + 2), tickStyle);
    }

    for (final ty in yTicks) {
      final (_, py) = _map(0, ty, size);
      canvas.drawLine(Offset(padding, py), Offset(size.width - padding, py), gridPaint);
      if (ty == 0) continue;
      _drawText(canvas, _fmt(ty), Offset(2, py - 6), tickStyle);
    }

    // X axis
    if (data.yMin <= 0 && data.yMax >= 0) {
      final (_, ay) = _map(0, 0, size);
      canvas.drawLine(Offset(padding, ay), Offset(size.width - padding, ay), axisPaint);
    }

    // Y axis
    if (data.xMin <= 0 && data.xMax >= 0) {
      final (ax, _) = _map(0, 0, size);
      canvas.drawLine(Offset(ax, padding), Offset(ax, size.height - padding), axisPaint);
    }

    // Draw function curve
    final curvePaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool penDown = false;

    for (final pt in data.points) {
      final (px, py) = _map(pt.x, pt.y, size);
      if (!penDown) {
        path.moveTo(px, py);
        penDown = true;
      } else {
        path.lineTo(px, py);
      }
    }
    canvas.drawPath(path, curvePaint);

    // Trace point
    if (tracePoint != null) {
      final tp = tracePoint!;
      final (px, py) = _map(tp.x, tp.y, size);
      final dotPaint = Paint()
        ..color = colorScheme.secondary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), 5, dotPaint);
      final label = 'x=${_fmt(tp.x)}  y=${_fmt(tp.y)}';
      _drawText(
        canvas,
        label,
        Offset(px + 8, py - 16),
        TextStyle(color: colorScheme.secondary, fontSize: 11, fontWeight: FontWeight.bold),
      );
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e6) return v.toInt().toString();
    return v.toStringAsPrecision(4);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final para = ParagraphBuilder(
      ParagraphStyle(
        textDirection: TextDirection.ltr,
        fontSize: style.fontSize ?? 10,
      ),
    )
      ..pushStyle(style.getTextStyle())
      ..addText(text);
    final p = para.build()..layout(const ParagraphConstraints(width: 120));
    canvas.drawParagraph(p, offset);
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.data != data || old.tracePoint != tracePoint || old.colorScheme != colorScheme;
}
