import 'package:flutter_application_2/utils/numeric_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumericInput', () {
    test('appends digits and decimal with two fraction digits max', () {
      expect(NumericInput.appendDigit('', '1'), '1');
      expect(NumericInput.appendDigit('1', '2'), '12');
      expect(NumericInput.appendDigit('12', '.'), '12.');
      expect(NumericInput.appendDigit('12.', '3'), '12.3');
      expect(NumericInput.appendDigit('12.3', '4'), '12.34');
      expect(NumericInput.appendDigit('12.34', '5'), '12.34');
    });

    test('backspace removes last character', () {
      expect(NumericInput.backspace('123'), '12');
      expect(NumericInput.backspace(''), '');
    });

    test('clear resets input', () {
      expect(NumericInput.clear(), '');
    });

    test('filter normalizes keyboard and paste input', () {
      expect(NumericInput.filter('12.345'), '12.34');
      expect(NumericInput.filter('abc12.3x4'), '12.34');
      expect(NumericInput.filter('0.5'), '0.5');
    });

    test('parse and normalize values', () {
      expect(NumericInput.parse('12.3'), 12.3);
      expect(NumericInput.normalize(100), '100');
      expect(NumericInput.normalize(100.5), '100.5');
    });
  });
}
