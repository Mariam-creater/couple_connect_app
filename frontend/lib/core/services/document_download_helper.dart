import 'dart:convert';
import 'dart:typed_data';
import 'document_download_stub.dart'
    if (dart.library.html) 'document_download_web.dart';

void triggerDocumentDownload({
  required String downloadUrl,
  required String fileName,
  Uint8List? fileBytes,
  String? mimeType,
}) {
  platformTriggerDownload(
    downloadUrl: downloadUrl,
    fileName: fileName,
    fileBytes: fileBytes,
    mimeType: mimeType,
  );
}
