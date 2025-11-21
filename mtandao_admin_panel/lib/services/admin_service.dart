import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AdminService {
  static const String baseUrl = 'https://your-api.mtandao.academy/api/admin';
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // USERS MANAGEMENT APIs
  
  // Get all users with pagination and filters
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
    String? level,
    String? status,
    String? region,
  }) async {
    final params = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (level != null && level != 'all') 'level': level,
      if (status != null && status != 'all') 'status': status,
      if (region != null && region != 'all') 'region': region,
    };

    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: params);
    
    final response = await http.get(uri, headers: await _getHeaders());
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  // Get user by ID
  Future<User> getUserById(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  // Create new user
  Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: await _getHeaders(),
      body: json.encode(userData),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to create user: ${response.statusCode}');
    }
  }

  // Update user
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _getHeaders(),
      body: json.encode(userData),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  }

  // Activate/Deactivate user
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$userId/status'),
      headers: await _getHeaders(),
      body: json.encode({'isActive': isActive}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update user status: ${response.statusCode}');
    }
  }

  // Reset user password
  Future<void> resetUserPassword(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/reset-password'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to reset password: ${response.statusCode}');
    }
  }

  // Get user activity
  Future<Map<String, dynamic>> getUserActivity(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/activity'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user activity: ${response.statusCode}');
    }
  }

  // Get available regions and levels for filters
  Future<Map<String, dynamic>> getUserFilters() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/filters'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      // Return default filters if API fails
      return {
        'regions': ['Dar es Salaam', 'Arusha', 'Mwanza', 'Mbeya', 'Dodoma'],
        'levels': ['Primary', 'O-Level', 'A-Level'],
        'statuses': ['active', 'inactive', 'suspended'],
      };
    }
  }
}