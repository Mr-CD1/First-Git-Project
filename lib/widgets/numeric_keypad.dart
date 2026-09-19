import 'package:flutter/material.dart';

import '../utils/numeric_input.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _KeyRow(
          keys: const ['1', '2', '3'],
          onKeyTap: _handleKeyTap,
        ),
        _KeyRow(
          keys: const ['4', '5', '6'],
          onKeyTap: _handleKeyTap,
        ),
        _KeyRow(
          keys: const ['7', '8', '9'],
          onKeyTap: _handleKeyTap,
        ),
        _KeyRow(
          keys: const ['.', '0', 'delete'],
          onKeyTap: _handleKeyTap,
        ),
      ],
    );
  }

  void _handleKeyTap(String key) {
    if (key == 'delete') {
      onChanged(NumericInput.backspace(value));
      return;
    }
    onChanged(NumericInput.appendDigit(value, key));
  }
}

class _KeyRow extends StatelessWidget {
  const _KeyRow({
    required this.keys,
    required this.onKeyTap,
  });

  final List<String> keys;
  final ValueChanged<String> onKeyTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: keys.map((key) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _KeyButton(
                label: _labelFor(key),
                icon: key == 'delete' ? Icons.backspace_outlined : null,
                onTap: () => onKeyTap(key),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _labelFor(String key) {
    return switch (key) {
      'delete' => '',
      _ => key,
    };
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          height: 56,
          child: Center(
            child: icon != null
                ? Icon(icon, color: theme.colorScheme.onSurface)
                : Text(
                    label,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
