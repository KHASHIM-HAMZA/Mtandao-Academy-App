import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  // -------- LOGIN --------
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.auth}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveUserData(data);
      return true;
    } else {
      return false;
    }
  }

  // -------- REGISTER --------
  Future<bool> register(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('${AppConstants.auth}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _saveUserData(data);
      return true;
    } else {
      print("❌ Registration failed: ${response.body}");
      return false;
    }
  }

  // -------- GOOGLE LOGIN --------
  Future<bool> googleLogin(String idToken) async {
    final response = await http.post(
      Uri.parse('${AppConstants.auth}/google-login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveUserData(data);
      return true;
    } else {
      print("❌ Google login failed: ${response.body}");
      return false;
    }
  }

  // -------- SAVE USER DATA LOCALLY --------
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Save basic user data
    await prefs.setString('jwt_token', data['token']);
    await prefs.setString('email', data['email'] ?? '');
    await prefs.setString('role', data['role'] ?? '');
    await prefs.setString('name', data['name'] ?? '');
    await prefs.setString('userId', data['userId']?.toString() ?? '');

    // Save contact information
    await prefs.setString('phone', data['phone'] ?? '');

    // Save school information
    await prefs.setString('school', data['school'] ?? '');

    // Save profile photo
    await prefs.setString('profilePhoto', data['profilePhoto'] ?? '');

    // Save teacher-specific data
    await prefs.setString('qualification', data['qualification'] ?? '');
    await prefs.setString('experience', data['experience'] ?? '');

    // Save subjects as JSON string
    if (data['subjects'] != null) {
      await prefs.setString('subjects', json.encode(data['subjects']));
    } else {
      await prefs.setString('subjects', '[]'); // Empty array
    }

    // Print saved data for debugging
    print('✅ Saved user data:');
    print('   Name: ${data['name']}');
    print('   Email: ${data['email']}');
    print('   Role: ${data['role']}');
    print('   School: ${data['school']}');
    print('   Subjects: ${data['subjects']}');
    print('   Qualification: ${data['qualification']}');
    print('   Experience: ${data['experience']}');
  }

  // -------- LOGOUT --------
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // -------- TOKEN GETTER --------
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // -------- GET USER PROFILE DATA --------
  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? '',
      'email': prefs.getString('email') ?? '',
      'role': prefs.getString('role') ?? '',
      'phone': prefs.getString('phone') ?? '',
      'school': prefs.getString('school') ?? '',
      'qualification': prefs.getString('qualification') ?? '',
      'experience': prefs.getString('experience') ?? '',
      'profilePhoto': prefs.getString('profilePhoto') ?? '',
      'subjects': _parseSubjects(prefs.getString('subjects')),
    };
  }

  List<String> _parseSubjects(String? subjectsJson) {
    if (subjectsJson == null || subjectsJson.isEmpty) return [];
    try {
      final List<dynamic> subjectsList = json.decode(subjectsJson);
      return subjectsList.map((subject) => subject.toString()).toList();
    } catch (e) {
      print('Error parsing subjects: $e');
      return [];
    }
  }
}
