class MonthlySnapshot {
  const MonthlySnapshot({
    required this.id,
    required this.year,
    required this.month,
    required this.netWorth,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.recordedAt,
  });

  final String id;
  final int year;
  final int month;
  final double netWorth;
  final double totalAssets;
  final double totalLiabilities;
  final DateTime recordedAt;

  String get monthLabel => '$year年$month月';

  Map<String, dynamic> toJson() => {
        'id': id,
        'year': year,
        'month': month,
        'netWorth': netWorth,
        'totalAssets': totalAssets,
        'totalLiabilities': totalLiabilities,
        'recordedAt': recordedAt.toIso8601String(),
      };

  factory MonthlySnapshot.fromJson(Map<String, dynamic> json) {
    return MonthlySnapshot(
      id: json['id'] as String,
      year: json['year'] as int,
      month: json['month'] as int,
      netWorth: (json['netWorth'] as num).toDouble(),
      totalAssets: (json['totalAssets'] as num).toDouble(),
      totalLiabilities: (json['totalLiabilities'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  static int compareByMonth(MonthlySnapshot a, MonthlySnapshot b) {
    if (a.year != b.year) {
      return a.year.compareTo(b.year);
    }
    return a.month.compareTo(b.month);
  }

  static List<MonthlySnapshot> sorted(List<MonthlySnapshot> snapshots) {
    final sorted = [...snapshots]..sort(compareByMonth);
    return sorted;
  }

  static double? savingsFor(
    MonthlySnapshot snapshot,
    List<MonthlySnapshot> snapshots,
  ) {
    final sorted = MonthlySnapshot.sorted(snapshots);
    final index = sorted.indexWhere((item) => item.id == snapshot.id);
    if (index <= 0) {
      return null;
    }
    return snapshot.netWorth - sorted[index - 1].netWorth;
  }

  static MonthlySnapshot? previousOf(
    MonthlySnapshot snapshot,
    List<MonthlySnapshot> snapshots,
  ) {
    final sorted = MonthlySnapshot.sorted(snapshots);
    final index = sorted.indexWhere((item) => item.id == snapshot.id);
    if (index <= 0) {
      return null;
    }
    return sorted[index - 1];
  }
}
