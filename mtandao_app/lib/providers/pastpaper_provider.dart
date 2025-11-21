import 'package:flutter/material.dart';
import 'package:mtandao_app/model/correction_model.dart';
import 'package:mtandao_app/model/pastpaper_model.dart';
import 'package:mtandao_app/utils/constants.dart';
import '../services/pastpaper_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PastPaperProvider with ChangeNotifier {
  final PastPaperService _service = PastPaperService();

  final Dio _dio = Dio();
  bool _isLoading = false;
  List<dynamic> _papers = [];
  Map<int, List<dynamic>> _corrections = {};
  String baseUrl = AppConstants.pastPapers;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  bool get isLoading => _isLoading;
  List<dynamic> get papers => _papers;
  Map<int, List<dynamic>> get corrections => _corrections;

  Future<void> fetchPapers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _papers = await _service.fetchPastPapers();
    } catch (e) {
      debugPrint("❌ Error fetching papers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //For Teacher
  Future<void> fetchTeacherPapers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final teacherName = prefs.getString('name');

      if (teacherName != null) {
        final token = await _getToken();
        final response = await _dio.get(
          '$baseUrl/creator/$teacherName',
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          ),
        );

        if (response.statusCode == 200) {
          List data = response.data;
          _papers = data.map((e) => PastPaper.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching teacher resources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCorrections(int paperId) async {
    try {
      _corrections[paperId] = await _service.fetchCorrections(paperId);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error fetching corrections: $e");
    }
  }

  Future<bool> uploadPastPaper(
    Map<String, String> fields,
    String filePath,
  ) async {
    final success = await _service.uploadPastPaper(fields, filePath);
    if (success) await fetchPapers();
    return success;
  }

  // UPDATED: Upload correction with support for both PDF and Video
  Future<bool> uploadCorrection({
    required Map<String, String> fields,
    String? filePath, // Optional for video corrections
  }) async {
    final success = await _service.uploadCorrection(
      fields: fields,
      filePath: filePath,
    );
    return success;
  }
}
