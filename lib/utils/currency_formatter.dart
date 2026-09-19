class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {bool showSign = false}) {
    final isNegative = amount < 0;
    final absolute = amount.abs();
    final parts = absolute.toStringAsFixed(2).split('.');
    final integerPart = _addThousandsSeparator(parts[0]);
    final formatted = '$integerPart.${parts[1]}';

    if (showSign && isNegative) {
      return '-¥ $formatted';
    }
    if (showSign && amount > 0) {
      return '+¥ $formatted';
    }
    return '${isNegative ? '-' : ''}¥ $formatted';
  }

  static String _addThousandsSeparator(String digits) {
    if (digits.length <= 3) {
      return digits;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
