import 'app_theme_mode.dart';
import 'storage_location.dart';

class AppSettings {
  const AppSettings({
    this.reminderDay = 10,
    this.reminderEnabled = true,
    this.storageLocation = StorageLocation.appInternal,
    this.customStoragePath,
    this.themeMode = AppThemeMode.light,
  });

  final int reminderDay;
  final bool reminderEnabled;
  final StorageLocation storageLocation;
  final String? customStoragePath;
  final AppThemeMode themeMode;

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
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      reminderDay: reminderDay ?? this.reminderDay,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      storageLocation: storageLocation ?? this.storageLocation,
      customStoragePath: customStoragePath ?? this.customStoragePath,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'reminderDay': reminderDay,
        'reminderEnabled': reminderEnabled,
        'storageLocation': storageLocation.value,
        'customStoragePath': customStoragePath,
        'themeMode': themeMode.value,
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
      themeMode: AppThemeMode.fromValue(json['themeMode'] as String?),
    );
  }

  factory AppSettings.defaults() => const AppSettings();
}
