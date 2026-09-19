enum StorageLocation {
  appInternal(
    'app_internal',
    '应用内置',
    '保存在应用私有存储，适合日常使用',
  ),
  localFile(
    'local_file',
    '本地文件',
    '保存在应用文档目录，便于备份与迁移',
  ),
  customPath(
    'custom_path',
    '自定义位置',
    '自选文件夹保存 JSON 数据文件',
  );

  const StorageLocation(this.value, this.label, this.description);

  final String value;
  final String label;
  final String description;

  static StorageLocation fromValue(String? value) {
    return StorageLocation.values.firstWhere(
      (location) => location.value == value,
      orElse: () => StorageLocation.appInternal,
    );
  }
}
