import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StudentService {
  // Get student profile with complete data
  Future<Map<String, dynamic>?> getStudentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/student/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Student profile loaded: $data');
        return data;
      } else {
        print('❌ Failed to load student profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching student profile: $e');
    }
    return null;
  }

  // Update student profile
  Future<Map<String, dynamic>?> updateStudentProfile(
    Map<String, dynamic> profileData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) return null;

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}/student/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Student profile updated: $data');
        return data;
      } else {
        final errorData = json.decode(response.body);
        print('❌ Failed to update student profile: ${errorData['error']}');
        throw Exception(errorData['error'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('❌ Error updating student profile: $e');
      throw e;
    }
  }

  // Get student dashboard data
  Future<Map<String, dynamic>> getStudentDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/student/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Student dashboard loaded: $data');
        return data;
      }
    } catch (e) {
      print('❌ Error fetching student dashboard: $e');
    }

    // Return mock data if API fails
    return {
      'studentName': 'Student',
      'level': 'O-Level',
      'subLevel': 'Form 3',
      'school': 'Unknown School',
      'completedAssignments': 12,
      'upcomingExams': 3,
      'resourcesDownloaded': 25,
      'averageScore': 78.5,
      'attendanceRate': 95.2,
    };
  }

  // Get recent resources
  Future<List<dynamic>> getRecentResources() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/resources/recent'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('❌ Error fetching recent resources: $e');
    }
    return [];
  }

  // Get student's level for filtering
  Future<String?> getStudentLevel() async {
    final prefs = await SharedPreferences.getInstance();

    // First try to get from SharedPreferences (cached)
    String? cachedLevel = prefs.getString('studentLevel');
    if (cachedLevel != null) return cachedLevel;

    // If not cached, fetch from API
    final dashboard = await getStudentDashboard();
    final level = dashboard['level']?.toString().toLowerCase();

    if (level != null) {
      await prefs.setString('studentLevel', level);
    }

    return level;
  }
}
