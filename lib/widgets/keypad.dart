import 'package:flutter/material.dart';

/// A single button on the calculator keypad.
class KeypadButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final double? fontSize;
  final int flex;

  const KeypadButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.fontSize,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = color ?? theme.colorScheme.surfaceVariant;
    final fg = textColor ?? theme.colorScheme.onSurface;
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: SizedBox(
              height: 56,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: fg,
                    fontSize: fontSize ?? 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The full calculator keypad.
class Keypad extends StatelessWidget {
  final void Function(String key) onKey;

  const Keypad({super.key, required this.onKey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final tertiary = theme.colorScheme.tertiary;
    final onTertiary = theme.colorScheme.onTertiary;

    Widget btn(String label, {Color? color, Color? fg, double? fs, int flex = 1}) => KeypadButton(
          label: label,
          onTap: () => onKey(label),
          color: color,
          textColor: fg,
          fontSize: fs,
          flex: flex,
        );

    return Column(
      children: [
        // Row 0: function row
        Row(children: [
          btn('sin(', fs: 15),
          btn('cos(', fs: 15),
          btn('tan(', fs: 15),
          btn('√(', fs: 15),
          btn('^', color: tertiary, fg: onTertiary),
        ]),
        Row(children: [
          btn('log(', fs: 15),
          btn('ln(', fs: 15),
          btn('π', fs: 18),
          btn('e', fs: 18),
          btn('(', color: tertiary, fg: onTertiary),
        ]),
        // Row 1: AC / +- / % / ÷
        Row(children: [
          btn('AC', color: theme.colorScheme.errorContainer, fg: theme.colorScheme.onErrorContainer),
          btn('⌫', color: theme.colorScheme.errorContainer, fg: theme.colorScheme.onErrorContainer),
          btn(')', color: tertiary, fg: onTertiary),
          btn('÷', color: primary, fg: onPrimary),
        ]),
        // Row 2: 7 8 9 ×
        Row(children: [
          btn('7'),
          btn('8'),
          btn('9'),
          btn('×', color: primary, fg: onPrimary),
        ]),
        // Row 3: 4 5 6 −
        Row(children: [
          btn('4'),
          btn('5'),
          btn('6'),
          btn('−', color: primary, fg: onPrimary),
        ]),
        // Row 4: 1 2 3 +
        Row(children: [
          btn('1'),
          btn('2'),
          btn('3'),
          btn('+', color: primary, fg: onPrimary),
        ]),
        // Row 5: 0 . = (= is wide)
        Row(children: [
          btn('0', flex: 2),
          btn('.'),
          btn('=', color: primary, fg: onPrimary),
        ]),
      ],
    );
  }
}
