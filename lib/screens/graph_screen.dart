import 'package:flutter/material.dart';
import '../logic/graph_engine.dart';
import '../widgets/graph_canvas.dart';

/// Graphing screen: plot a single-variable function with zoom/pan/trace.
class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final _textController = TextEditingController(text: 'sin(x)');
  final _engine = GraphEngine();

  GraphData? _data;
  GraphPoint? _tracePoint;
  String? _error;

  double _xMin = -10;
  double _xMax = 10;

  // Panning state
  double? _panStartX;
  double? _panStartXMin;
  double? _panStartXMax;

  @override
  void initState() {
    super.initState();
    _plot();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _plot() {
    final expr = _textController.text.trim();
    if (expr.isEmpty) return;
    try {
      final d = _engine.sample(expr, xMin: _xMin, xMax: _xMax, steps: 400);
      setState(() {
        _data = d;
        _error = null;
        _tracePoint = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('FormatException: ', '');
      });
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details, Size canvasSize) {
    if (details.pointerCount == 1) {
      // Pan
      final dx = details.focalPointDelta.dx;
      final range = _xMax - _xMin;
      final shift = -dx / canvasSize.width * range;
      setState(() {
        _xMin += shift;
        _xMax += shift;
      });
      _plot();
    } else if (details.pointerCount >= 2) {
      // Pinch zoom
      final scale = details.scale.clamp(0.5, 2.0);
      final center = (_xMin + _xMax) / 2;
      final range = (_xMax - _xMin) / scale;
      setState(() {
        _xMin = center - range / 2;
        _xMax = center + range / 2;
      });
      _plot();
    }
  }

  void _onTapDown(TapDownDetails details, Size canvasSize) {
    if (_data == null) return;
    final relX = details.localPosition.dx;
    final range = _xMax - _xMin;
    final xTarget = _xMin + (relX / canvasSize.width) * range;
    setState(() {
      _tracePoint = GraphEngine.traceX(_data!, xTarget);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph'), centerTitle: true),
      body: Column(
        children: [
          // Function input
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'f(x) =',
                      hintText: 'e.g. sin(x), x^2 - 3',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _plot(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _plot,
                  child: const Text('Plot'),
                ),
              ],
            ),
          ),
          // X range controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              children: [
                Text('x: ${_xMin.toStringAsFixed(1)}  →  ${_xMax.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _xMin = -10;
                      _xMax = 10;
                    });
                    _plot();
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          // Graph canvas
          Expanded(
            child: _data == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (ctx, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        onScaleUpdate: (d) => _onScaleUpdate(d, size),
                        onTapDown: (d) => _onTapDown(d, size),
                        child: GraphCanvas(
                          data: _data!,
                          tracePoint: _tracePoint,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
