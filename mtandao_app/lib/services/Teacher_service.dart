import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class TeacherService {
  Future<Map<String, dynamic>?> fetchCurrentTeacher() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}/teacher/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Failed to fetch teacher data: ${response.statusCode}");
      return null;
    }
  }

  Future<bool> updateTeacherProfile(Map<String, dynamic> profileData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        print("❌ No token found");
        return false;
      }

      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/teacher/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        print("✅ Teacher profile updated successfully");
        return true;
      } else {
        print("❌ Failed to update teacher profile: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error updating teacher profile: $e");
      return false;
    }
  }
}
