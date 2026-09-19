import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../services/data_transfer_facade.dart';
import '../services/data_transfer_service.dart';

class BackupSettingsSection extends StatefulWidget {
  const BackupSettingsSection({
    super.key,
    required this.appData,
    required this.onImport,
  });

  final AppData appData;
  final Future<void> Function(AppData data) onImport;

  @override
  State<BackupSettingsSection> createState() => _BackupSettingsSectionState();
}

class _BackupSettingsSectionState extends State<BackupSettingsSection> {
  final DataTransferFacade _facade = DataTransferFacade();
  bool _isExporting = false;
  bool _isImporting = false;

  Future<void> _exportData() async {
    setState(() => _isExporting = true);
    try {
      final path = await _facade.exportToFile(widget.appData);
      if (!mounted) {
        return;
      }
      if (path == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已导出到 $path')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导出失败：$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importData() async {
    setState(() => _isImporting = true);
    try {
      final preview = await _facade.pickAndPreviewImport();
      if (!mounted) {
        return;
      }
      if (preview == null) {
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => _ImportConfirmDialog(summary: preview.summary),
      );
      if (confirmed != true || !mounted) {
        return;
      }

      final merged = _facade.prepareImport(
        current: widget.appData,
        imported: preview.imported,
      );
      await widget.onImport(merged);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('数据导入成功')),
      );
    } on DataTransferException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败：$error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '备份与恢复',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '导出全部账户、变动记录和月度快照；导入时会保留当前存储位置设置',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _isExporting ? null : _exportData,
          icon: _isExporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file_outlined),
          label: Text(_isExporting ? '正在导出...' : '导出 JSON'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _isImporting ? null : _importData,
          icon: _isImporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_outlined),
          label: Text(_isImporting ? '正在导入...' : '从 JSON 导入'),
        ),
      ],
    );
  }
}

class _ImportConfirmDialog extends StatelessWidget {
  const _ImportConfirmDialog({required this.summary});

  final DataTransferSummary summary;

  @override
  Widget build(BuildContext context) {
    final exportedAt = summary.exportedAt;

    return AlertDialog(
      title: const Text('确认导入'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('导入后会覆盖当前所有资产数据，是否继续？'),
          const SizedBox(height: 12),
          Text('账户：${summary.accountCount} 个'),
          Text('变动记录：${summary.recordCount} 条'),
          Text('月度快照：${summary.snapshotCount} 条'),
          if (exportedAt != null) ...[
            const SizedBox(height: 8),
            Text('备份时间：${exportedAt.toLocal()}'),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('确认导入'),
        ),
      ],
    );
  }
}
