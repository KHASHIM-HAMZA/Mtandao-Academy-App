import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mtandao_app/model/resource_model.dart';
import 'package:mtandao_app/model/test_model.dart';

class TeacherProvider with ChangeNotifier {
  final String baseUrl = "https://your-backend-api.com/api";
  final int teacherId;

  TeacherProvider(this.teacherId);

  List<Resource> _resources = [];
  List<TestModel> _tests = [];

  List<Resource> get resources => _resources;
  List<TestModel> get tests => _tests;

  Future<void> fetchTeacherResources() async {
    final response = await http.get(
      Uri.parse("$baseUrl/teacher/$teacherId/resources"),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      _resources = data.map((e) => Resource.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception("Failed to load teacher resources");
    }
  }

  Future<void> fetchTeacherTests() async {
    final response = await http.get(
      Uri.parse("$baseUrl/teacher/$teacherId/tests"),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      _tests = data.map((e) => TestModel.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception("Failed to load teacher tests");
    }
  }
}
