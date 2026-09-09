import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

void platformTriggerDownload({
  required String downloadUrl,
  required String fileName,
  Uint8List? fileBytes,
  String? mimeType,
}) {
  try {
    if (fileBytes != null && fileBytes.isNotEmpty) {
      final base64Data = base64Encode(fileBytes);
      final mime = mimeType ?? 'application/octet-stream';
      final uri = 'data:$mime;base64,$base64Data';
      final anchor = html.AnchorElement(href: uri)
        ..setAttribute('download', fileName)
        ..click();
    } else {
      final anchor = html.AnchorElement(href: downloadUrl)
        ..setAttribute('download', fileName)
        ..setAttribute('target', '_blank')
        ..click();
    }
  } catch (e) {
    // Fallback window open
    html.window.open(downloadUrl, '_blank');
  }
}
