class NumericInput {
  NumericInput._();

  static String appendDigit(String current, String digit) {
    if (digit == '.') {
      if (current.contains('.')) {
        return current;
      }
      return current.isEmpty ? '0.' : '$current.';
    }

    if (current == '0' && digit != '.') {
      return digit;
    }

    if (current.contains('.')) {
      final fraction = current.split('.')[1];
      if (fraction.length >= 2) {
        return current;
      }
    }

    return '$current$digit';
  }

  static String backspace(String current) {
    if (current.isEmpty) {
      return current;
    }
    return current.substring(0, current.length - 1);
  }

  static double? parse(String value) {
    if (value.isEmpty || value == '.') {
      return null;
    }
    return double.tryParse(value);
  }

  static String normalize(double value) {
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
