import 'dart:convert';

import '../models/app_data.dart';

class DataTransferException implements Exception {
  DataTransferException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DataTransferSummary {
  const DataTransferSummary({
    required this.accountCount,
    required this.recordCount,
    required this.snapshotCount,
    required this.exportedAt,
  });

  final int accountCount;
  final int recordCount;
  final int snapshotCount;
  final DateTime? exportedAt;
}

class DataTransferService {
  static const exportVersion = 1;
  static const appId = 'my_assets';

  String encodeExport(AppData data) {
    final payload = {
      'version': exportVersion,
      'app': appId,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data.toJson(),
    };
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  AppData decodeImport(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw DataTransferException('文件不是有效的 JSON 格式');
    }

    if (decoded is! Map<String, dynamic>) {
      throw DataTransferException('备份文件格式不正确');
    }

    final Map<String, dynamic> dataJson;
    if (decoded['data'] is Map<String, dynamic>) {
      final version = decoded['version'];
      if (version != null && version is! num) {
        throw DataTransferException('备份版本信息无效');
      }
      dataJson = decoded['data'] as Map<String, dynamic>;
    } else if (decoded['store'] is Map<String, dynamic>) {
      dataJson = decoded;
    } else {
      throw DataTransferException('未找到可导入的数据内容');
    }

    try {
      return AppData.fromJson(dataJson);
    } catch (_) {
      throw DataTransferException('备份数据结构不完整或已损坏');
    }
  }

  DataTransferSummary summarize(AppData data, {DateTime? exportedAt}) {
    return DataTransferSummary(
      accountCount: data.store.accounts.length,
      recordCount: data.records.length,
      snapshotCount: data.monthlySnapshots.length,
      exportedAt: exportedAt,
    );
  }

  DataTransferSummary summarizeFromExport(String raw) {
    final dynamic decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final exportedAtRaw = decoded['exportedAt'] as String?;
      final exportedAt =
          exportedAtRaw == null ? null : DateTime.tryParse(exportedAtRaw);
      return summarize(decodeImport(raw), exportedAt: exportedAt);
    }
    return summarize(decodeImport(raw));
  }

  AppData mergeImportedData({
    required AppData current,
    required AppData imported,
  }) {
    return imported.copyWith(settings: current.settings);
  }

  String buildExportFileName([DateTime? time]) {
    final now = time ?? DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';
    return 'my_assets_backup_$stamp.json';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
