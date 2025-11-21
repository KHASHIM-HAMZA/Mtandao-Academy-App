import 'dart:convert';
import '../utils/constants.dart';
import 'api_client.dart';

class TestService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getAllTests() async {
    final res = await _api.get('${AppConstants.tests}/all');
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  Future<bool> submitTestResult(
    int testId,
    int userId,
    int score,
    int totalQuestions,
  ) async {
    final body = {
      'userId': userId,
      'score': score,
      'totalQuestions': totalQuestions,
    };
    final res = await _api.post('${AppConstants.tests}/$testId/submit', body);
    return res.statusCode == 200;
  }
}
