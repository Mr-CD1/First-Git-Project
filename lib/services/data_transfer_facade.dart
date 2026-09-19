import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../models/app_data.dart';
import 'data_transfer_service.dart';

class DataTransferFacade {
  DataTransferFacade({DataTransferService? service})
      : _service = service ?? DataTransferService();

  final DataTransferService _service;

  Future<String?> exportToFile(AppData data) async {
    final content = _service.encodeExport(data);
    final fileName = _service.buildExportFileName();
    final bytes = utf8.encode(content);

    final path = await FilePicker.platform.saveFile(
      dialogTitle: '导出 JSON 备份',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: bytes,
    );

    if (path == null) {
      return null;
    }

    if (!path.endsWith('.json')) {
      final file = File('$path.json');
      await file.writeAsString(content);
      return file.path;
    }

    final file = File(path);
    if (!await file.exists()) {
      await file.writeAsString(content);
    }

    return file.path;
  }

  Future<ImportPreview?> pickAndPreviewImport() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: '选择 JSON 备份文件',
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final picked = result.files.single;
    final raw = await _readPickedFile(picked);
    final imported = _service.decodeImport(raw);
    final summary = _service.summarizeFromExport(raw);

    return ImportPreview(
      imported: imported,
      summary: summary,
    );
  }

  AppData prepareImport({
    required AppData current,
    required AppData imported,
  }) {
    return _service.mergeImportedData(current: current, imported: imported);
  }

  Future<String> _readPickedFile(PlatformFile file) async {
    if (file.bytes != null) {
      return utf8.decode(file.bytes!);
    }

    final path = file.path;
    if (path == null || path.isEmpty) {
      throw DataTransferException('无法读取所选文件');
    }

    return File(path).readAsString();
  }
}

class ImportPreview {
  const ImportPreview({
    required this.imported,
    required this.summary,
  });

  final AppData imported;
  final DataTransferSummary summary;
}
