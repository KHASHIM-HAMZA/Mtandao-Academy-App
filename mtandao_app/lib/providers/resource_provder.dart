import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mtandao_app/model/resource_model.dart';

class ResourceProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Resource> _resources = [];
  bool _isLoading = false;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;

  // Base URL (replace with your real backend endpoint)
  final String baseUrl = 'https://yourapi.com/resources';

  // ---------------- FETCH ALL RESOURCES ----------------
  Future<void> fetchResources() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(baseUrl);
      if (response.statusCode == 200) {
        List data = response.data;
        _resources = data.map((e) => Resource.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching resources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- FETCH TEACHER RESOURCES ----------------
  Future<void> fetchTeacherResources(String teacherId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get('$baseUrl/teacher/$teacherId');
      if (response.statusCode == 200) {
        List data = response.data;
        _resources = data.map((e) => Resource.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching teacher resources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- UPLOAD RESOURCE ----------------
  Future<void> uploadResource(File file, Resource resource) async {
    _isLoading = true;
    notifyListeners();

    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'title': resource.title,
        'description': resource.description,
        'subject': resource.subject,
        'type': resource.type, // e.g. "Book" or "Note"
        'educationLevel': resource.educationLevel,
        'teacherId': resource.teacherId,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('$baseUrl/upload', data: formData);

      if (response.statusCode == 201) {
        _resources.add(Resource.fromJson(response.data));
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---------------- STUDENT DOWNLOAD RESOURCE ----------------
  Future<String> downloadResource(Resource resource) async {
    try {
      final dir = Directory('/storage/emulated/0/Download/mtandao_resources');
      if (!await dir.exists()) await dir.create(recursive: true);

      final savePath = '${dir.path}/${resource.title}.pdf';
      await _dio.download(resource.fileUrl, savePath);

      debugPrint('✅ File saved to: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      rethrow;
    }
  }

  // ---------------- FILTER BY TYPE & LEVEL ----------------
  List<Resource> filterResources(String type, String level) {
    return _resources
        .where(
          (res) =>
              res.type.toLowerCase() == type.toLowerCase() &&
              res.educationLevel.toLowerCase() == level.toLowerCase(),
        )
        .toList();
  }
}
