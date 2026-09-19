import 'storage_location.dart';

class AppSettings {
  const AppSettings({
    this.reminderDay = 10,
    this.reminderEnabled = true,
    this.storageLocation = StorageLocation.appInternal,
    this.customStoragePath,
  });

  final int reminderDay;
  final bool reminderEnabled;
  final StorageLocation storageLocation;
  final String? customStoragePath;

  int get safeReminderDay {
    if (reminderDay < 1) {
      return 1;
    }
    if (reminderDay > 28) {
      return 28;
    }
    return reminderDay;
  }

  AppSettings copyWith({
    int? reminderDay,
    bool? reminderEnabled,
    StorageLocation? storageLocation,
    String? customStoragePath,
  }) {
    return AppSettings(
      reminderDay: reminderDay ?? this.reminderDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      storageLocation: storageLocation ?? this.storageLocation,
      customStoragePath: customStoragePath ?? this.customStoragePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'reminderDay': reminderDay,
        'reminderEnabled': reminderEnabled,
        'storageLocation': storageLocation.value,
        'customStoragePath': customStoragePath,
      };

  factory AppSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AppSettings();
    }
    return AppSettings(
      reminderDay: json['reminderDay'] as int? ?? 10,
      reminderEnabled: json['reminderEnabled'] as bool? ?? true,
      storageLocation: StorageLocation.fromValue(
        json['storageLocation'] as String?,
      ),
      customStoragePath: json['customStoragePath'] as String?,
    );
  }

  factory AppSettings.defaults() => const AppSettings();
}
