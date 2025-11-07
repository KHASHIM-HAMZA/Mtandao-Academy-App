import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mtandao_app/model/test_model.dart';

class TeacherTestProvider with ChangeNotifier {
  final String baseUrl = "https://your-backend-api.com/api/tests";

  List<TestModel> _teacherTests = [];
  List<TestModel> get teacherTests => _teacherTests;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ========= CREATE TEST =========
  Future<bool> createTest(TestModel test) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(test.toJson()),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        _teacherTests.add(test);
        notifyListeners();
        return true;
      } else {
        debugPrint("Failed to create test: ${response.body}");
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Error creating test: $e");
      return false;
    }
  }

  // ========= FETCH TEACHER'S TESTS =========
  Future<void> fetchTeacherTests(String teacherId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(Uri.parse("$baseUrl/teacher/$teacherId"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _teacherTests = data.map((e) => TestModel.fromJson(e)).toList();
      } else {
        debugPrint("Failed to fetch teacher tests: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching teacher tests: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========= UPDATE TEST =========
  Future<bool> updateTest(TestModel test) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/${test.id}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(test.toJson()),
      );

      if (response.statusCode == 200) {
        int index = _teacherTests.indexWhere(
          (element) => element.id == test.id,
        );
        if (index != -1) {
          _teacherTests[index] = test;
          notifyListeners();
        }
        return true;
      } else {
        debugPrint("Failed to update test: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error updating test: $e");
      return false;
    }
  }

  // ========= DELETE TEST =========
  Future<bool> deleteTest(int testId) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/$testId"));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _teacherTests.removeWhere((test) => test.id == testId);
        notifyListeners();
        return true;
      } else {
        debugPrint("Failed to delete test: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error deleting test: $e");
      return false;
    }
  }

  // ========= PUBLISH / UNPUBLISH TEST =========
  Future<bool> togglePublishStatus(int testId, bool publish) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$testId/publish"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"published": publish}),
      );

      if (response.statusCode == 200) {
        int index = _teacherTests.indexWhere((test) => test.id == testId);
        if (index != -1) {
          _teacherTests[index] = _teacherTests[index].copyWith(
            published: publish,
          );
          notifyListeners();
        }
        return true;
      } else {
        debugPrint("Failed to toggle publish status: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error toggling publish status: $e");
      return false;
    }
  }
}
