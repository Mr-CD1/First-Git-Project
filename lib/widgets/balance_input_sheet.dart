import 'package:flutter/material.dart';

import '../utils/currency_formatter.dart';
import '../utils/numeric_input.dart';
import 'numeric_keypad.dart';

Future<double?> showBalanceInputSheet({
  required BuildContext context,
  required String title,
  required double initialValue,
  required bool isLiability,
}) {
  return showModalBottomSheet<double>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return _BalanceInputSheet(
        title: title,
        initialValue: initialValue,
        isLiability: isLiability,
      );
    },
  );
}

class _BalanceInputSheet extends StatefulWidget {
  const _BalanceInputSheet({
    required this.title,
    required this.initialValue,
    required this.isLiability,
  });

  final String title;
  final double initialValue;
  final bool isLiability;

  @override
  State<_BalanceInputSheet> createState() => _BalanceInputSheetState();
}

class _BalanceInputSheetState extends State<_BalanceInputSheet> {
  late String _input;

  @override
  void initState() {
    super.initState();
    _input = widget.initialValue == 0
        ? ''
        : NumericInput.normalize(widget.initialValue);
  }

  double? get _parsedValue => NumericInput.parse(_input);

  String get _displayText {
    final value = _parsedValue ?? 0;
    final formatted = CurrencyFormatter.format(value);
    return widget.isLiability ? '欠款 $formatted' : formatted;
  }

  void _confirm() {
    final value = _parsedValue;
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入有效金额')),
      );
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _input.isEmpty ? '0.00' : _displayText,
              textAlign: TextAlign.right,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          NumericKeypad(
            value: _input,
            onChanged: (value) => setState(() => _input = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _confirm,
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
}
