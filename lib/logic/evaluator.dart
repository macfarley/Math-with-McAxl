import 'dart:math' as math;

/// Lightweight recursive‑descent expression evaluator.
/// Supports: +, -, *, /, ^, %, parentheses, unary minus,
/// and the functions: sin, cos, tan, asin, acos, atan,
/// sqrt, abs, log, log2, log10, exp, ceil, floor, round.
/// Constants: pi, e.
class Evaluator {
  late String _expr;
  late int _pos;

  /// Evaluate [expression] and return the numeric result.
  /// Throws [FormatException] on syntax errors.
  double evaluate(String expression) {
    _expr = expression.trim().toLowerCase();
    _pos = 0;
    final result = _parseExpression();
    if (_pos != _expr.length) {
      throw FormatException('Unexpected character at position $_pos');
    }
    return result;
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  String get _current => _pos < _expr.length ? _expr[_pos] : '';

  void _skipWhitespace() {
    while (_pos < _expr.length && _expr[_pos] == ' ') {
      _pos++;
    }
  }

  bool _isDigit(String ch) => ch.isNotEmpty && ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isAlpha(String ch) => ch.isNotEmpty && ((ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122));

  // ── grammar ────────────────────────────────────────────────────────────────

  // expression  = term (('+' | '-') term)*
  double _parseExpression() {
    _skipWhitespace();
    double value = _parseTerm();
    _skipWhitespace();
    while (_current == '+' || _current == '-') {
      final op = _current;
      _pos++;
      _skipWhitespace();
      final right = _parseTerm();
      _skipWhitespace();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  }

  // term = power (('*' | '/' | '%') power)*
  double _parseTerm() {
    double value = _parsePower();
    _skipWhitespace();
    while (_current == '*' || _current == '/' || _current == '%') {
      final op = _current;
      _pos++;
      _skipWhitespace();
      final right = _parsePower();
      _skipWhitespace();
      if (op == '*') {
        value *= right;
      } else if (op == '/') {
        if (right == 0) throw FormatException('Division by zero');
        value /= right;
      } else {
        value %= right;
      }
    }
    return value;
  }

  // power = unary ('^' power)?   (right-associative)
  double _parsePower() {
    final base = _parseUnary();
    _skipWhitespace();
    if (_current == '^') {
      _pos++;
      _skipWhitespace();
      final exp = _parsePower();
      return math.pow(base, exp).toDouble();
    }
    return base;
  }

  // unary = '-' unary | primary
  double _parseUnary() {
    _skipWhitespace();
    if (_current == '-') {
      _pos++;
      return -_parseUnary();
    }
    if (_current == '+') {
      _pos++;
      return _parseUnary();
    }
    return _parsePrimary();
  }

  // primary = number | constant | function '(' expression ')' | '(' expression ')'
  double _parsePrimary() {
    _skipWhitespace();

    // Parenthesised expression
    if (_current == '(') {
      _pos++;
      final value = _parseExpression();
      _skipWhitespace();
      if (_current != ')') throw FormatException('Expected ")"');
      _pos++;
      return value;
    }

    // Number literal
    if (_isDigit(_current) || _current == '.') {
      return _parseNumber();
    }

    // Identifier (function or constant)
    if (_isAlpha(_current)) {
      return _parseIdentifier();
    }

    throw FormatException('Unexpected token at position $_pos: "$_current"');
  }

  double _parseNumber() {
    final start = _pos;
    while (_pos < _expr.length && (_isDigit(_current) || _current == '.')) {
      _pos++;
    }
    // Scientific notation: e.g. 1.5e-3
    if (_pos < _expr.length && (_current == 'e')) {
      _pos++;
      if (_pos < _expr.length && (_current == '+' || _current == '-')) _pos++;
      while (_pos < _expr.length && _isDigit(_current)) {
        _pos++;
      }
    }
    final token = _expr.substring(start, _pos);
    final n = double.tryParse(token);
    if (n == null) throw FormatException('Invalid number: $token');
    return n;
  }

  double _parseIdentifier() {
    final start = _pos;
    while (_pos < _expr.length && (_isAlpha(_current) || _isDigit(_current))) {
      _pos++;
    }
    final name = _expr.substring(start, _pos);
    _skipWhitespace();

    // Constants
    switch (name) {
      case 'pi':
        return math.pi;
      case 'e':
        return math.e;
    }

    // Functions — expect '(' argument ')'
    if (_current != '(') {
      throw FormatException('Unknown identifier: $name');
    }
    _pos++;
    final arg = _parseExpression();
    _skipWhitespace();
    if (_current != ')') throw FormatException('Expected ")" after $name(...)');
    _pos++;

    switch (name) {
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        return math.tan(arg);
      case 'asin':
        return math.asin(arg);
      case 'acos':
        return math.acos(arg);
      case 'atan':
        return math.atan(arg);
      case 'sqrt':
        if (arg < 0) throw FormatException('sqrt of negative number');
        return math.sqrt(arg);
      case 'abs':
        return arg.abs();
      case 'log':
      case 'ln':
        if (arg <= 0) throw FormatException('log of non-positive number');
        return math.log(arg);
      case 'log2':
        if (arg <= 0) throw FormatException('log2 of non-positive number');
        return math.log(arg) / math.ln2;
      case 'log10':
        if (arg <= 0) throw FormatException('log10 of non-positive number');
        return math.log(arg) / math.ln10;
      case 'exp':
        return math.exp(arg);
      case 'ceil':
        return arg.ceilToDouble();
      case 'floor':
        return arg.floorToDouble();
      case 'round':
        return arg.roundToDouble();
      default:
        throw FormatException('Unknown function: $name');
    }
  }
}
