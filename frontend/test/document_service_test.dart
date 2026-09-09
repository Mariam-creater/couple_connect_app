import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:couple_connect_frontend/core/services/document_service.dart';

void main() {
  group('DocumentService Tests', () {
    test('formatBytes formats file sizes correctly', () {
      expect(DocumentService.formatBytes(0), '0 B');
      expect(DocumentService.formatBytes(512), '512 B');
      expect(DocumentService.formatBytes(1024), '1.0 KB');
      expect(DocumentService.formatBytes(1536), '1.5 KB');
      expect(DocumentService.formatBytes(1048576), '1.0 MB');
      expect(DocumentService.formatBytes(2621440), '2.5 MB');
      expect(DocumentService.formatBytes(1073741824), '1.0 GB');
    });

    test('getDocumentIcon returns appropriate icons for document extensions', () {
      expect(DocumentService.getDocumentIcon('pdf'), Icons.picture_as_pdf_rounded);
      expect(DocumentService.getDocumentIcon('PDF'), Icons.picture_as_pdf_rounded);
      expect(DocumentService.getDocumentIcon('docx'), Icons.description_rounded);
      expect(DocumentService.getDocumentIcon('xlsx'), Icons.table_chart_rounded);
      expect(DocumentService.getDocumentIcon('pptx'), Icons.slideshow_rounded);
      expect(DocumentService.getDocumentIcon('zip'), Icons.folder_zip_rounded);
      expect(DocumentService.getDocumentIcon('txt'), Icons.text_snippet_rounded);
      expect(DocumentService.getDocumentIcon('unknown'), Icons.insert_drive_file_rounded);
    });

    test('getDocumentColor returns distinct theme colors for file types', () {
      expect(DocumentService.getDocumentColor('pdf'), const Color(0xFFEF4444));
      expect(DocumentService.getDocumentColor('docx'), const Color(0xFF3B82F6));
      expect(DocumentService.getDocumentColor('xlsx'), const Color(0xFF10B981));
      expect(DocumentService.getDocumentColor('pptx'), const Color(0xFFF97316));
      expect(DocumentService.getDocumentColor('zip'), const Color(0xFF8B5CF6));
      expect(DocumentService.getDocumentColor('txt'), const Color(0xFF06B6D4));
    });

    test('allowedExtensions contains standard document formats', () {
      expect(DocumentService.allowedExtensions, contains('pdf'));
      expect(DocumentService.allowedExtensions, contains('docx'));
      expect(DocumentService.allowedExtensions, contains('xlsx'));
      expect(DocumentService.allowedExtensions, contains('pptx'));
      expect(DocumentService.allowedExtensions, contains('txt'));
      expect(DocumentService.allowedExtensions, contains('zip'));
    });
  });
}
