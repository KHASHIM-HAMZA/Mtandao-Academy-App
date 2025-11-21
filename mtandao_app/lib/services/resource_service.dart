import 'dart:convert';
import '../utils/constants.dart';
import 'api_client.dart';

class ResourceService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> fetchResources() async {
    final res = await _api.get('${AppConstants.resources}/all');
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to fetch resources');
    }
  }

  Future<bool> uploadResource(
    Map<String, String> fields,
    String filePath,
  ) async {
    final res = await _api.multipart(
      '${AppConstants.resources}/upload',
      fields,
      filePath,
      'file',
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
