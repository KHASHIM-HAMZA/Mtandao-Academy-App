import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // update to your backend URL
  static const baseUrl = 'http://localhost:8081/api';

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final resp = await http.post(
      url,
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      // Save token locally
      final prefs = await SharedPreferences.getInstance();
      if (data['token'] != null) {
        await prefs.setString('jwt_token', data['token']);
        await prefs.setString(
          'name',
          (data['name'] ?? data['email']) as String,
        );
      }
      return data;
    } else {
      return null;
    }
  }

  Future<http.Response> get(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final url = Uri.parse('$baseUrl$path');
    return http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // implement postMultipart, post, put, delete helpers...
}
