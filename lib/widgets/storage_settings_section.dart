import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../data/storage/storage_config.dart';
import '../models/storage_location.dart';

class StorageSettingsSection extends StatefulWidget {
  const StorageSettingsSection({
    super.key,
    required this.storageLocation,
    required this.customStoragePath,
    required this.onStorageLocationChanged,
    required this.onCustomPathChanged,
  });

  final StorageLocation storageLocation;
  final String? customStoragePath;
  final ValueChanged<StorageLocation> onStorageLocationChanged;
  final ValueChanged<String?> onCustomPathChanged;

  @override
  State<StorageSettingsSection> createState() => _StorageSettingsSectionState();
}

class _StorageSettingsSectionState extends State<StorageSettingsSection> {
  String? _resolvedPath;
  bool _isLoadingPath = false;

  @override
  void initState() {
    super.initState();
    _refreshResolvedPath();
  }

  @override
  void didUpdateWidget(covariant StorageSettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storageLocation != widget.storageLocation ||
        oldWidget.customStoragePath != widget.customStoragePath) {
      _refreshResolvedPath();
    }
  }

  Future<void> _refreshResolvedPath() async {
    setState(() => _isLoadingPath = true);
    final path = await _resolveDisplayPath();
    if (!mounted) {
      return;
    }
    setState(() {
      _resolvedPath = path;
      _isLoadingPath = false;
    });
  }

  Future<String> _resolveDisplayPath() async {
    switch (widget.storageLocation) {
      case StorageLocation.appInternal:
        return '应用私有存储（SharedPreferences）';
      case StorageLocation.localFile:
        final directory = await getApplicationDocumentsDirectory();
        return '${directory.path}/${StorageConfig.dataFileName}';
      case StorageLocation.customPath:
        final path = widget.customStoragePath?.trim();
        if (path == null || path.isEmpty) {
          return '尚未选择文件夹';
        }
        return '$path/${StorageConfig.dataFileName}';
    }
  }

  Future<void> _pickCustomFolder() async {
    final selectedPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '选择数据保存文件夹',
    );
    if (selectedPath == null || selectedPath.isEmpty) {
      return;
    }
    widget.onCustomPathChanged(selectedPath);
    widget.onStorageLocationChanged(StorageLocation.customPath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据存储',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '选择资产数据的保存位置，切换时会自动迁移已有数据',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        ...StorageLocation.values.map(
          (location) => RadioListTile<StorageLocation>(
            value: location,
            groupValue: widget.storageLocation,
            onChanged: (value) {
              if (value == null) {
                return;
              }
              widget.onStorageLocationChanged(value);
            },
            title: Text(location.label),
            subtitle: Text(location.description),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (widget.storageLocation == StorageLocation.customPath) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickCustomFolder,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('选择文件夹'),
          ),
        ],
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.45),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '当前存储位置',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              if (_isLoadingPath)
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Text(
                  _resolvedPath ?? '--',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
