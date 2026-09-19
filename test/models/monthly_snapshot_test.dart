import 'package:flutter_application_2/models/monthly_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MonthlySnapshot', () {
    test('calculates savings compared to previous month', () {
      final jan = MonthlySnapshot(
        id: '1',
        year: 2026,
        month: 1,
        netWorth: 10000,
        totalAssets: 10000,
        totalLiabilities: 0,
        recordedAt: DateTime(2026, 1, 10),
      );
      final feb = MonthlySnapshot(
        id: '2',
        year: 2026,
        month: 2,
        netWorth: 11500,
        totalAssets: 11500,
        totalLiabilities: 0,
        recordedAt: DateTime(2026, 2, 10),
      );
      final mar = MonthlySnapshot(
        id: '3',
        year: 2026,
        month: 3,
        netWorth: 11000,
        totalAssets: 11000,
        totalLiabilities: 0,
        recordedAt: DateTime(2026, 3, 10),
      );

      final snapshots = [feb, jan, mar];

      expect(MonthlySnapshot.savingsFor(jan, snapshots), isNull);
      expect(MonthlySnapshot.savingsFor(feb, snapshots), 1500);
      expect(MonthlySnapshot.savingsFor(mar, snapshots), -500);
    });
  });
}
