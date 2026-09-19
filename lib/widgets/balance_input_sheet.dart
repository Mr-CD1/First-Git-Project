import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
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
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _input = widget.initialValue == 0
        ? ''
        : NumericInput.normalize(widget.initialValue);
    _controller = TextEditingController(text: _input);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection.collapsed(offset: _input.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double? get _parsedValue => NumericInput.parse(_input);

  void _setInput(String value) {
    setState(() => _input = value);
    if (_controller.text != value) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  void _onTextChanged(String raw) {
    final filtered = NumericInput.filter(raw);
    setState(() => _input = filtered);
    if (_controller.text != filtered) {
      _controller.value = TextEditingValue(
        text: filtered,
        selection: TextSelection.collapsed(offset: filtered.length),
      );
    }
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
    final previewValue = _parsedValue ?? 0;
    final previewText = widget.isLiability
        ? '欠款 ${CurrencyFormatter.format(previewValue)}'
        : CurrencyFormatter.format(previewValue);

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
          const SizedBox(height: 8),
          Text(
            '可直接用键盘输入，或使用下方数字键盘',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: AppTheme.softPanelPrimary(theme.colorScheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  textAlign: TextAlign.right,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  onChanged: _onTextChanged,
                  onSubmitted: (_) => _confirm(),
                ),
                if (_input.isNotEmpty)
                  Text(
                    previewText,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NumericKeypad(
            value: _input,
            onChanged: _setInput,
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
