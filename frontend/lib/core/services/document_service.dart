import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'document_download_helper.dart';

class PickedDocumentData {
  final String name;
  final Uint8List bytes;
  final int sizeBytes;
  final String formattedSize;
  final String extension;
  final String mimeType;

  PickedDocumentData({
    required this.name,
    required this.bytes,
    required this.sizeBytes,
    required this.formattedSize,
    required this.extension,
    required this.mimeType,
  });
}

class DocumentService {
  static const List<String> allowedExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
    'txt',
    'zip',
    'rar',
    '7z',
    'csv',
    'rtf',
    'json',
  ];

  /// Opens native device file picker across Web, Mobile & Desktop
  static Future<PickedDocumentData?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      Uint8List? fileBytes = file.bytes;

      if (fileBytes == null || fileBytes.isEmpty) {
        return null;
      }

      final name = file.name;
      final ext = (file.extension ?? (name.contains('.') ? name.split('.').last : '')).toLowerCase();
      final size = file.size > 0 ? file.size : fileBytes.length;
      final mime = _lookupMimeType(ext);

      return PickedDocumentData(
        name: name,
        bytes: fileBytes,
        sizeBytes: size,
        formattedSize: formatBytes(size),
        extension: ext,
        mimeType: mime,
      );
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  static String formatBytes(int bytes, [int precision = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final clampedI = min(i, suffixes.length - 1);
    final val = bytes / pow(1024, clampedI);
    return '${val.toStringAsFixed(clampedI == 0 ? 0 : precision)} ${suffixes[clampedI]}';
  }

  static IconData getDocumentIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
      case 'rtf':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;
      case 'txt':
      case 'json':
        return Icons.text_snippet_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  static Color getDocumentColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFEF4444); // Red
      case 'doc':
      case 'docx':
      case 'rtf':
        return const Color(0xFF3B82F6); // Blue
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const Color(0xFF10B981); // Green
      case 'ppt':
      case 'pptx':
        return const Color(0xFFF97316); // Orange
      case 'zip':
      case 'rar':
      case '7z':
        return const Color(0xFF8B5CF6); // Purple
      case 'txt':
      case 'json':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFFE84393); // Pink
    }
  }

  static String _lookupMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'doc':
        return 'application/msword';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      case '7z':
        return 'application/x-7z-compressed';
      case 'txt':
        return 'text/plain';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }

  /// Downloads or triggers native document view/save
  static Future<void> downloadOrOpenDocument({
    required String downloadUrl,
    required String fileName,
    Uint8List? fileBytes,
  }) async {
    final ext = fileName.contains('.') ? fileName.split('.').last : '';
    triggerDocumentDownload(
      downloadUrl: downloadUrl,
      fileName: fileName,
      fileBytes: fileBytes,
      mimeType: _lookupMimeType(ext),
    );
  }
}
