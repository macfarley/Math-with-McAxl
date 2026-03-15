import 'package:flutter/material.dart';
import '../logic/evaluator.dart';
import '../widgets/display.dart';
import '../widgets/keypad.dart';

/// Main calculator screen.
class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _evaluator = Evaluator();
  String _expression = '';
  String _result = '0';
  String? _error;
  bool _justEvaled = false;

  void _onKey(String key) {
    setState(() {
      _error = null;
      switch (key) {
        case 'AC':
          _expression = '';
          _result = '0';
          _justEvaled = false;
          break;
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
          _justEvaled = false;
          _liveEval();
          break;
        case '=':
          _evaluate();
          break;
        case '÷':
          if (_justEvaled) _expression = _result;
          _expression += '/';
          _justEvaled = false;
          _liveEval();
          break;
        case '×':
          if (_justEvaled) _expression = _result;
          _expression += '*';
          _justEvaled = false;
          _liveEval();
          break;
        case '−':
          if (_justEvaled) _expression = _result;
          _expression += '-';
          _justEvaled = false;
          _liveEval();
          break;
        case 'π':
          if (_justEvaled) _expression = '';
          _expression += 'pi';
          _justEvaled = false;
          _liveEval();
          break;
        default:
          if (_justEvaled &&
              RegExp(r'[0-9.(]').hasMatch(key.isNotEmpty ? key[0] : '')) {
            _expression = '';
          }
          _expression += key;
          _justEvaled = false;
          _liveEval();
      }
    });
  }

  void _liveEval() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    try {
      final v = _evaluator.evaluate(_expression);
      _result = _formatResult(v);
      _error = null;
    } catch (_) {
      // Live eval errors are silent — only show on "="
    }
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final v = _evaluator.evaluate(_expression);
      _result = _formatResult(v);
      _error = null;
      _justEvaled = true;
    } catch (e) {
      _error = e.toString().replaceFirst('FormatException: ', '');
    }
  }

  String _formatResult(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    // Use up to 10 significant digits, strip trailing zeros
    String s = v.toStringAsPrecision(10);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '');
      s = s.replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 3,
            child: CalcDisplay(
              expression: _expression,
              result: _result,
              error: _error,
            ),
          ),
          const Divider(height: 1),
          // Keypad
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Keypad(onKey: _onKey),
            ),
          ),
        ],
      ),
    );
  }
}
