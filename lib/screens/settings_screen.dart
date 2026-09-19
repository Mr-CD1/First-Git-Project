import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../models/app_settings.dart';
import '../models/app_theme_mode.dart';
import '../models/storage_location.dart';
import '../widgets/backup_settings_section.dart';
import '../widgets/storage_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.appData,
    this.onSaved,
    this.onThemeModeChanged,
  });

  final AppData appData;
  final Future<void> Function(AppData data)? onSaved;
  final ValueChanged<AppThemeMode>? onThemeModeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _reminderEnabled;
  late int _reminderDay;
  late StorageLocation _storageLocation;
  String? _customStoragePath;
  late AppThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _syncFromAppData(widget.appData);
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appData != widget.appData) {
      _syncFromAppData(widget.appData);
    }
  }

  void _syncFromAppData(AppData data) {
    _reminderEnabled = data.settings.reminderEnabled;
    _reminderDay = data.settings.safeReminderDay;
    _storageLocation = data.settings.storageLocation;
    _customStoragePath = data.settings.customStoragePath;
    _themeMode = data.settings.themeMode;
  }

  AppSettings get _settings => AppSettings(
        reminderEnabled: _reminderEnabled,
        reminderDay: _reminderDay,
        storageLocation: _storageLocation,
        customStoragePath: _customStoragePath,
        themeMode: _themeMode,
      );

  void _onThemeModeSelected(AppThemeMode mode) {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged?.call(mode);
  }

  bool get _storageConfigValid {
    if (_storageLocation != StorageLocation.customPath) {
      return true;
    }
    return _customStoragePath != null && _customStoragePath!.trim().isNotEmpty;
  }

  bool get _storageChanged {
    final current = widget.appData.settings;
    return current.storageLocation != _storageLocation ||
        current.customStoragePath != _customStoragePath;
  }

  Future<bool> _confirmStorageMigration() async {
    if (!_storageChanged) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换存储位置'),
        content: const Text(
          '保存后会把现有数据迁移到新的存储位置，原位置的数据将被清理。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续迁移'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _save() async {
    if (!_storageConfigValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择自定义存储文件夹')),
      );
      return;
    }

    if (!await _confirmStorageMigration()) {
      return;
    }

    final nextData = widget.appData.updateSettings(_settings);
    if (widget.onSaved != null) {
      try {
        await widget.onSaved!(nextData);
      } catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$error')),
        );
        return;
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _storageChanged ? '设置已保存，数据已迁移' : '设置已保存',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(nextData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '外观',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '主题模式',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SegmentedButton<AppThemeMode>(
          segments: AppThemeMode.values
              .map(
                (mode) => ButtonSegment(
                  value: mode,
                  label: Text(mode.label),
                  icon: Icon(
                    mode == AppThemeMode.dark
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                  ),
                ),
              )
              .toList(),
          selected: {_themeMode},
          onSelectionChanged: (selection) {
            _onThemeModeSelected(selection.first);
          },
        ),
        const SizedBox(height: 8),
        Text(
          '切换后立即生效并自动保存；其它设置项需点击底部「保存设置」',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          '记账提醒',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('首页提醒'),
          subtitle: const Text('到指定日期后在首页显示记账提示'),
          value: _reminderEnabled,
          onChanged: (value) => setState(() => _reminderEnabled = value),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          enabled: _reminderEnabled,
          title: Text('提醒日期：每月 $_reminderDay 号'),
          subtitle: const Text('建议选择 1-28 号，避免部分月份没有该日期'),
        ),
        Slider(
          value: _reminderDay.toDouble(),
          min: 1,
          max: 28,
          divisions: 27,
          label: '$_reminderDay 号',
          onChanged: _reminderEnabled
              ? (value) => setState(() => _reminderDay = value.round())
              : null,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        StorageSettingsSection(
          storageLocation: _storageLocation,
          customStoragePath: _customStoragePath,
          onStorageLocationChanged: (location) {
            setState(() => _storageLocation = location);
          },
          onCustomPathChanged: (path) {
            setState(() => _customStoragePath = path);
          },
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        BackupSettingsSection(
          appData: widget.appData,
          onImport: (data) async {
            if (widget.onSaved == null) {
              return;
            }
            await widget.onSaved!(data);
            if (mounted) {
              setState(() => _syncFromAppData(data));
            }
          },
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _save,
          child: const Text('保存设置'),
        ),
      ],
    );
  }
}
