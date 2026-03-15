import 'package:flutter/material.dart';
import '../logic/utility_math.dart';
import '../logic/converters/calendar_math.dart';
import '../logic/converters/time_math.dart';

/// Utility math panel: tips, tax, discounts, interest, percent change, calendar, time math.
class UtilityPanel extends StatefulWidget {
  const UtilityPanel({super.key});

  @override
  State<UtilityPanel> createState() => _UtilityPanelState();
}

class _UtilityPanelState extends State<UtilityPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tip / Tax'),
            Tab(text: 'Interest'),
            Tab(text: 'Calendar'),
            Tab(text: 'Time'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _TipTaxTab(),
          _InterestTab(),
          _CalendarTab(),
          _TimeTab(),
        ],
      ),
    );
  }
}

// ── Tip / Tax / Discount Tab ───────────────────────────────────────────────

class _TipTaxTab extends StatefulWidget {
  const _TipTaxTab();
  @override
  State<_TipTaxTab> createState() => _TipTaxTabState();
}

class _TipTaxTabState extends State<_TipTaxTab> {
  final _billCtrl = TextEditingController(text: '50.00');
  final _tipCtrl = TextEditingController(text: '18');
  final _taxCtrl = TextEditingController(text: '8.5');
  final _discCtrl = TextEditingController(text: '10');
  final _peopleCtrl = TextEditingController(text: '2');

  String _tipResult = '';
  String _taxResult = '';
  String _discResult = '';
  String _splitResult = '';
  String _pctChangeOld = '';
  String _pctChangeNew = '';
  String _pctChangeResult = '';

  final _pctOldCtrl = TextEditingController(text: '80');
  final _pctNewCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  void dispose() {
    for (final c in [_billCtrl, _tipCtrl, _taxCtrl, _discCtrl, _peopleCtrl, _pctOldCtrl, _pctNewCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _calc() {
    final bill = double.tryParse(_billCtrl.text) ?? 0;
    final tip = double.tryParse(_tipCtrl.text) ?? 0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0;
    final disc = double.tryParse(_discCtrl.text) ?? 0;
    final people = int.tryParse(_peopleCtrl.text) ?? 1;
    final old = double.tryParse(_pctOldCtrl.text) ?? 1;
    final nw = double.tryParse(_pctNewCtrl.text) ?? 0;

    setState(() {
      _tipResult =
          'Tip: \$${UtilityMath.tipAmount(bill, tip).toStringAsFixed(2)}  Total: \$${UtilityMath.totalWithTip(bill, tip).toStringAsFixed(2)}';
      _taxResult =
          'Tax: \$${UtilityMath.taxAmount(bill, tax).toStringAsFixed(2)}  Total: \$${UtilityMath.priceAfterTax(bill, tax).toStringAsFixed(2)}';
      _discResult =
          'Save: \$${UtilityMath.discountAmount(bill, disc).toStringAsFixed(2)}  Pay: \$${UtilityMath.priceAfterDiscount(bill, disc).toStringAsFixed(2)}';
      try {
        _splitResult =
            'Each person pays: \$${UtilityMath.splitBill(bill, tip, people).toStringAsFixed(2)}';
      } catch (_) {
        _splitResult = 'Enter valid people count';
      }
      try {
        _pctChangeResult =
            'Change: ${UtilityMath.percentChange(old, nw).toStringAsFixed(2)}%';
      } catch (_) {
        _pctChangeResult = 'Old value cannot be 0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader('Bill Amount'),
          _NumberField(label: 'Bill (\$)', controller: _billCtrl, onChanged: (_) => _calc()),
          const SizedBox(height: 16),
          _SectionHeader('Tip'),
          _NumberField(label: 'Tip %', controller: _tipCtrl, onChanged: (_) => _calc()),
          _ResultCard(_tipResult),
          const SizedBox(height: 16),
          _SectionHeader('Sales Tax'),
          _NumberField(label: 'Tax %', controller: _taxCtrl, onChanged: (_) => _calc()),
          _ResultCard(_taxResult),
          const SizedBox(height: 16),
          _SectionHeader('Discount'),
          _NumberField(label: 'Discount %', controller: _discCtrl, onChanged: (_) => _calc()),
          _ResultCard(_discResult),
          const SizedBox(height: 16),
          _SectionHeader('Split Bill (with tip)'),
          _NumberField(label: 'People', controller: _peopleCtrl, onChanged: (_) => _calc()),
          _ResultCard(_splitResult),
          const SizedBox(height: 16),
          _SectionHeader('Percent Change'),
          _NumberField(label: 'Old Value', controller: _pctOldCtrl, onChanged: (_) => _calc()),
          _NumberField(label: 'New Value', controller: _pctNewCtrl, onChanged: (_) => _calc()),
          _ResultCard(_pctChangeResult),
        ],
      ),
    );
  }
}

// ── Interest Tab ──────────────────────────────────────────────────────────

class _InterestTab extends StatefulWidget {
  const _InterestTab();
  @override
  State<_InterestTab> createState() => _InterestTabState();
}

class _InterestTabState extends State<_InterestTab> {
  final _principalCtrl = TextEditingController(text: '1000');
  final _rateCtrl = TextEditingController(text: '5');
  final _yearsCtrl = TextEditingController(text: '3');
  String _simpleResult = '';
  String _compoundResult = '';

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _rateCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  void _calc() {
    final p = double.tryParse(_principalCtrl.text) ?? 0;
    final r = double.tryParse(_rateCtrl.text) ?? 0;
    final t = double.tryParse(_yearsCtrl.text) ?? 0;
    setState(() {
      final si = UtilityMath.simpleInterest(p, r, t);
      _simpleResult =
          'Interest: \$${si.toStringAsFixed(2)}  Total: \$${(p + si).toStringAsFixed(2)}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader('Simple Interest'),
          _NumberField(label: 'Principal (\$)', controller: _principalCtrl, onChanged: (_) => _calc()),
          _NumberField(label: 'Rate (%)', controller: _rateCtrl, onChanged: (_) => _calc()),
          _NumberField(label: 'Time (years)', controller: _yearsCtrl, onChanged: (_) => _calc()),
          _ResultCard(_simpleResult),
        ],
      ),
    );
  }
}

// ── Calendar Tab ──────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();
  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _dateA = DateTime.now();
  DateTime _dateB = DateTime.now().add(const Duration(days: 30));
  String _result = '';
  String _addDaysResult = '';
  int _daysToAdd = 7;
  int _selectedWeekday = 1;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  void _calc() {
    final diff = CalendarMath.daysBetween(_dateA, _dateB);
    final weeks = CalendarMath.weeksBetween(_dateA, _dateB);
    final added = CalendarMath.addDays(_dateA, _daysToAdd);
    final wdName = CalendarMath.weekdayName(_dateA);
    final count = CalendarMath.countWeekday(
        _dateA, _dateB, _selectedWeekday);
    final wdLabel = CalendarMath.weekdayNames[_selectedWeekday - 1];
    setState(() {
      _result = [
        'Days between: $diff  (${diff.abs()} days)',
        'Weeks between: $weeks',
        'Weekday of Date A: $wdName',
        '$wdLabel count between dates: $count',
      ].join('\n');
      _addDaysResult =
          '${_dateA.toLocal().toString().split(' ').first} + $_daysToAdd days = ${added.toLocal().toString().split(' ').first}';
    });
  }

  Future<void> _pickDate(bool isA) async {
    final initial = isA ? _dateA : _dateB;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isA) {
          _dateA = picked;
        } else {
          _dateB = picked;
        }
      });
      _calc();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader('Date Picker'),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_dateA.toLocal().toString().split(' ').first),
                onPressed: () => _pickDate(true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_dateB.toLocal().toString().split(' ').first),
                onPressed: () => _pickDate(false),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          _ResultCard(_result),
          const SizedBox(height: 16),
          _SectionHeader('Add / Subtract Days from Date A'),
          Row(children: [
            Expanded(
              child: Slider(
                value: _daysToAdd.toDouble(),
                min: -365,
                max: 365,
                divisions: 730,
                label: '$_daysToAdd days',
                onChanged: (v) {
                  setState(() => _daysToAdd = v.toInt());
                  _calc();
                },
              ),
            ),
            Text('$_daysToAdd d'),
          ]),
          _ResultCard(_addDaysResult),
          const SizedBox(height: 16),
          _SectionHeader('Count Weekday Between Dates'),
          DropdownButton<int>(
            value: _selectedWeekday,
            items: List.generate(7, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(CalendarMath.weekdayNames[i]),
                )),
            onChanged: (v) {
              setState(() => _selectedWeekday = v!);
              _calc();
            },
          ),
        ],
      ),
    );
  }
}

// ── Time Math Tab ─────────────────────────────────────────────────────────

class _TimeTab extends StatefulWidget {
  const _TimeTab();
  @override
  State<_TimeTab> createState() => _TimeTabState();
}

class _TimeTabState extends State<_TimeTab> {
  final _t1Ctrl = TextEditingController(text: '01:30');
  final _t2Ctrl = TextEditingController(text: '02:45');
  String _addResult = '';
  String _fmtResult = '';
  int _durationMinutes = 90;

  @override
  void initState() {
    super.initState();
    _calc();
  }

  @override
  void dispose() {
    _t1Ctrl.dispose();
    _t2Ctrl.dispose();
    super.dispose();
  }

  void _calc() {
    setState(() {
      try {
        _addResult = 'Sum: ${TimeMath.addTimes(_t1Ctrl.text, _t2Ctrl.text)}';
      } catch (_) {
        _addResult = 'Invalid time format (use HH:MM)';
      }
      final (h, m) = TimeMath.minutesToHoursMinutes(_durationMinutes);
      _fmtResult = '$_durationMinutes minutes = ${h}h ${m}m';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader('Add Two Times (HH:MM)'),
          _NumberField(
            label: 'Time 1 (HH:MM)',
            controller: _t1Ctrl,
            onChanged: (_) => _calc(),
            isTime: true,
          ),
          _NumberField(
            label: 'Time 2 (HH:MM)',
            controller: _t2Ctrl,
            onChanged: (_) => _calc(),
            isTime: true,
          ),
          _ResultCard(_addResult),
          const SizedBox(height: 16),
          _SectionHeader('Minutes → Hours & Minutes'),
          Row(children: [
            Expanded(
              child: Slider(
                value: _durationMinutes.toDouble(),
                min: 1,
                max: 1440,
                divisions: 1439,
                label: '$_durationMinutes min',
                onChanged: (v) {
                  setState(() => _durationMinutes = v.toInt());
                  _calc();
                },
              ),
            ),
            Text('$_durationMinutes min'),
          ]),
          _ResultCard(_fmtResult),
        ],
      ),
    );
  }
}

// ── Shared helper widgets ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final bool isTime;

  const _NumberField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        keyboardType: isTime
            ? TextInputType.text
            : const TextInputType.numberWithOptions(decimal: true, signed: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String text;
  const _ResultCard(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
