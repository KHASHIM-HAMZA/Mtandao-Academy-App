import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class PdfOpener {
  static Future<void> openPdf(String url, {String? fileName}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final savePath = "${tempDir.path}/${fileName ?? "document"}.pdf";

      final dio = Dio();

      // Download file
      await dio.download(url, savePath);

      // Open file
      final result = await OpenFilex.open(savePath);
      print("Open result: ${result.message}");
    } catch (e) {
      print("❌ PDF open error: $e");
      throw Exception("Failed to open PDF");
    }
  }
}
