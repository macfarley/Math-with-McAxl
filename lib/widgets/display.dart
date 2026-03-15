import 'package:flutter/material.dart';

/// The scrollable result + expression display at the top of the calculator.
class CalcDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String? error;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expression line
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Text(
              expression.isEmpty ? '0' : expression,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Result / error line
          if (error != null)
            Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                result,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
