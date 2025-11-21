import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';
import 'api_client.dart';

class SchemeService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getAllPublicSchemes() async {
    try {
      final res = await _api.get('${AppConstants.schemes}/public');
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMySchemes(String email) async {
    try {
      final res = await _api.get('${AppConstants.schemes}/teacher/$email');
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> uploadScheme(Map<String, String> fields, String filePath) async {
    try {
      final res = await _api.multipart(
        '${AppConstants.schemes}/upload',
        fields,
        filePath,
        'file',
      );

      if (res.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
