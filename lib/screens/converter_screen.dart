import 'package:flutter/material.dart';
import '../logic/converters/units.dart';
import '../logic/converters/currency.dart';

/// Unit and currency converter screen.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: UnitCategory.values.length + 1, // +1 for currency
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ...UnitCategory.values.map((c) => Tab(text: _categoryLabel(c))),
      const Tab(text: 'Currency'),
    ];

    final views = [
      ...UnitCategory.values.map((c) => _UnitConverterTab(category: c)),
      const _CurrencyConverterTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: views,
      ),
    );
  }

  String _categoryLabel(UnitCategory c) {
    switch (c) {
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.mass:
        return 'Mass';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.temperature:
        return 'Temp';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.energy:
        return 'Energy';
    }
  }
}

// ── Unit Converter Tab ─────────────────────────────────────────────────────

class _UnitConverterTab extends StatefulWidget {
  final UnitCategory category;
  const _UnitConverterTab({required this.category});

  @override
  State<_UnitConverterTab> createState() => _UnitConverterTabState();
}

class _UnitConverterTabState extends State<_UnitConverterTab> {
  final _controller = TextEditingController(text: '1');
  late List<UnitDef> _units;
  late String _fromUnit;
  late String _toUnit;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _units = UnitConverter.units[widget.category]!;
    _fromUnit = _units[0].name;
    _toUnit = _units.length > 1 ? _units[1].name : _units[0].name;
    _calculate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() => _result = 'Invalid input');
      return;
    }
    try {
      final r = UnitConverter.convert(widget.category, _fromUnit, _toUnit, input);
      setState(() => _result = _fmt(r));
    } catch (e) {
      setState(() => _result = 'Error');
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e12) return v.toInt().toString();
    return v.toStringAsPrecision(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildDropdown(_fromUnit, (v) => setState(() { _fromUnit = v!; _calculate(); }))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => setState(() {
                    final tmp = _fromUnit;
                    _fromUnit = _toUnit;
                    _toUnit = tmp;
                    _calculate();
                  }),
                ),
              ),
              Expanded(child: _buildDropdown(_toUnit, (v) => setState(() { _toUnit = v!; _calculate(); }))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _result,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  _toUnit,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String value, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
      items: _units
          .map((u) => DropdownMenuItem(value: u.name, child: Text('${u.name} (${u.symbol})')))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Currency Converter Tab ────────────────────────────────────────────────

class _CurrencyConverterTab extends StatefulWidget {
  const _CurrencyConverterTab();

  @override
  State<_CurrencyConverterTab> createState() => _CurrencyConverterTabState();
}

class _CurrencyConverterTabState extends State<_CurrencyConverterTab> {
  final _controller = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'EUR';
  String _result = '';

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final input = double.tryParse(_controller.text);
    if (input == null) {
      setState(() => _result = 'Invalid input');
      return;
    }
    try {
      final r = CurrencyConverter.convert(_from, _to, input);
      setState(() => _result = r.toStringAsFixed(2));
    } catch (e) {
      setState(() => _result = 'Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencies = CurrencyConverter.currencies;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Static rates · Ref: ${CurrencyConverter.rateDate}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _calculate(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _from,
                  decoration: const InputDecoration(labelText: 'From', border: OutlineInputBorder(), isDense: true),
                  items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() { _from = v!; _calculate(); }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: () => setState(() {
                    final tmp = _from;
                    _from = _to;
                    _to = tmp;
                    _calculate();
                  }),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _to,
                  decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder(), isDense: true),
                  items: currencies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() { _to = v!; _calculate(); }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_result $_to',
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
