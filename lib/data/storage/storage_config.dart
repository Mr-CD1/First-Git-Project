import '../../models/storage_location.dart';
import '../../models/app_settings.dart';

class StorageConfig {
  const StorageConfig({
    this.location = StorageLocation.appInternal,
    this.customPath,
  });

  static const metaKey = 'storage_config';
  static const dataFileName = 'my_assets_data.json';
  static const legacyDataKey = 'app_data';

  final StorageLocation location;
  final String? customPath;

  bool get isValid {
    if (location == StorageLocation.customPath) {
      return customPath != null && customPath!.trim().isNotEmpty;
    }
    return true;
  }

  factory StorageConfig.fromSettings(AppSettings settings) {
    return StorageConfig(
      location: settings.storageLocation,
      customPath: settings.customStoragePath,
    );
  }

  AppSettings applyTo(AppSettings settings) {
    return settings.copyWith(
      storageLocation: location,
      customStoragePath: customPath,
    );
  }

  factory StorageConfig.defaults() => const StorageConfig();

  Map<String, dynamic> toJson() => {
        'location': location.value,
        'customPath': customPath,
      };

  factory StorageConfig.fromJson(Map<String, dynamic> json) {
    return StorageConfig(
      location: StorageLocation.fromValue(json['location'] as String?),
      customPath: json['customPath'] as String?,
    );
  }

  StorageConfig copyWith({
    StorageLocation? location,
    String? customPath,
  }) {
    return StorageConfig(
      location: location ?? this.location,
      customPath: customPath ?? this.customPath,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StorageConfig &&
        other.location == location &&
        other.customPath == customPath;
  }

  @override
  int get hashCode => Object.hash(location, customPath);
}
