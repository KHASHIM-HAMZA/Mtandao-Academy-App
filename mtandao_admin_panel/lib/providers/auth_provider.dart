import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _adminName;
  String? _adminEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get adminName => _adminName;
  String? get adminEmail => _adminEmail;

  Future<bool> login(String email, String password) async {
    // TODO: Implement API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock success
    _isAuthenticated = true;
    _adminName = "Admin User";
    _adminEmail = email;

    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _adminName = null;
    _adminEmail = null;
    notifyListeners();
  }
}

// import 'package:flutter/material.dart';
// import 'package:mtandao_admin_panel/services/Api_services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthProvider with ChangeNotifier {
//   final ApiService _api = ApiService();

//   bool _isLoggedIn = false;
//   String? _token;
//   String? _userName;

//   bool get isLoggedIn => _isLoggedIn;
//   String? get token => _token;
//   String? get userName => _userName;

//   AuthProvider() {
//     _loadFromStorage();
//   }

//   Future<void> _loadFromStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('jwt_token');
//     _userName = prefs.getString('name');
//     _isLoggedIn = _token != null;
//     notifyListeners();
//   }

//   Future<bool> login(String email, String password) async {
//     try {
//       final resp = await _api.login(email, password);
//       if (resp != null && resp['token'] != null) {
//         _token = resp['token'];
//         _userName = resp['name'] ?? resp['email'];
//         _isLoggedIn = true;
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('jwt_token', _token!);
//         await prefs.setString('name', _userName!);
//         notifyListeners();
//         return true;
//       }
//     } catch (e) {
//       debugPrint('Auth error: $e');
//     }
//     return false;
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     _isLoggedIn = false;
//     _token = null;
//     _userName = null;
//     notifyListeners();
//   }
// }
