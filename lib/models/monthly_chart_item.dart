import 'monthly_snapshot.dart';

class MonthlyChartItem {
  const MonthlyChartItem({
    required this.snapshot,
    required this.savings,
  });

  final MonthlySnapshot snapshot;
  final double savings;

  String get label => '${snapshot.month}月';

  String get fullLabel => snapshot.monthLabel;
}
