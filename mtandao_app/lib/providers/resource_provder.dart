import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mtandao_app/model/resource_model.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResourceProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<Resource> _resources = [];
  bool _isLoading = false;

  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;

  // Base URL - Update with your actual backend URL
  final String baseUrl = AppConstants.resources;

  // Get JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // =================== FETCH ALL RESOURCES ===================
  Future<void> fetchResources() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      final response = await _dio.get(
        baseUrl,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        List data = response.data;
        _resources = data.map((e) => Resource.fromJson(e)).toList();
        debugPrint('✅ Fetched ${_resources.length} resources');
      }
    } catch (e) {
      debugPrint('❌ Error fetching resources: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== UPLOAD RESOURCE (TEACHERS ONLY) ===================
  Future<bool> uploadResource(File file, Resource resource) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      String fileName = file.path.split('/').last;

      // Get teacher name from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final teacherName = prefs.getString('name') ?? 'Unknown Teacher';

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'title': resource.title,
        'description': resource.description,
        'type': resource.type,
        'educationLevel': resource.educationLevel,
        'sublevel': resource.subLevel,
        'subject': resource.subject,
        'creator': teacherName,
      });

      final response = await _dio.post(
        '$baseUrl/upload',
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode == 200) {
        // Add the new resource to the list
        final newResource = Resource.fromJson(response.data);
        _resources.insert(0, newResource);
        notifyListeners();
        return true;
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Upload error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== FILTER RESOURCES (FOR STUDENTS) ===================
  List<Resource> filterResources({
    String? type,
    String? level,
    String? subject,
    String? creator,
  }) {
    return _resources.where((res) {
      final matchType =
          type == null || res.type.toLowerCase() == type.toLowerCase();
      final matchLevel =
          level == null ||
          res.educationLevel.toLowerCase() == level.toLowerCase();
      final matchSubject =
          subject == null || res.subject.toLowerCase() == subject.toLowerCase();
      final matchCreator =
          creator == null || res.creator.toLowerCase() == creator.toLowerCase();
      return matchType && matchLevel && matchSubject && matchCreator;
    }).toList();
  }

  // =================== COMPATIBILITY METHOD (For StudentResourcesPage) ===================
  List<Resource> filterResourcesLegacy(String type, String level) {
    return filterResources(
      type: type == "book" ? "books" : (type == "note" ? "notes" : type),
      level: level,
    );
  }

  // =================== FETCH TEACHER'S RESOURCES ===================
  Future<void> fetchTeacherResources() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final teacherName = prefs.getString('name');

      if (teacherName != null) {
        final token = await _getToken();
        final response = await _dio.get(
          '$baseUrl/filter/creator/$teacherName',
          options: Options(
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
          ),
        );

        if (response.statusCode == 200) {
          List data = response.data;
          _resources = data.map((e) => Resource.fromJson(e)).toList();
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching teacher resources: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =================== DOWNLOAD RESOURCE ===================
  Future<String> downloadResource(Resource resource) async {
    try {
      // Create downloads directory
      final dir = Directory('/storage/emulated/0/Download/mtandao_resources');
      if (!await dir.exists()) await dir.create(recursive: true);

      // Get file extension from URL or use default
      final fileExtension = resource.fileUrl.split('.').last;
      final fileName =
          '${resource.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.$fileExtension';
      final savePath = '${dir.path}/$fileName';

      // Download the file
      await _dio.download(
        resource.fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              'Download progress: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      debugPrint('✅ File saved to: $savePath');
      return savePath;
    } catch (e) {
      debugPrint('❌ Download failed: $e');
      rethrow;
    }
  }
}
