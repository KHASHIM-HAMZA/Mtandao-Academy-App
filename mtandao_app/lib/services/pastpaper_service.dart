import 'dart:convert';
import '../utils/constants.dart';
import 'api_client.dart';

class PastPaperService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> fetchPastPapers() async {
    final res = await _api.get('${AppConstants.pastPapers}/all');
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  Future<List<dynamic>> fetchAllCorrections() async {
    final res = await _api.get('${AppConstants.pastPapers}/corrections/all');
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  Future<List<dynamic>> fetchCorrections(int paperId) async {
    final res = await _api.get(
      '${AppConstants.pastPapers}/$paperId/corrections',
    );
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  Future<bool> uploadPastPaper(
    Map<String, String> fields,
    String filePath,
  ) async {
    final res = await _api.multipart(
      '${AppConstants.pastPapers}/upload',
      fields,
      filePath,
      'file',
    );
    return res.statusCode == 200;
  }

  Future<bool> uploadCorrection({
    required Map<String, String> fields,
    String? filePath,
  }) async {
    if (filePath != null && filePath.isNotEmpty) {
      // PDF correction with file upload
      final res = await _api.multipart(
        '${AppConstants.pastPapers}/uploadCorrection',
        fields,
        filePath,
        'file',
      );
      return res.statusCode == 200;
    } else {
      // Video correction - convert to query parameters for @RequestParam
      final queryParams = fields.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final url = '${AppConstants.pastPapers}/uploadCorrection?$queryParams';
      final res = await _api.post(url, {}); // Empty body for GET-style POST
      return res.statusCode == 200;
    }
  }
}
