import 'package:flutter/material.dart';
import 'package:mtandao_app/services/Student_service.dart';

class StudentProvider with ChangeNotifier {
  final StudentService _studentService = StudentService();

  Map<String, dynamic>? _studentProfile;
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get studentProfile => _studentProfile;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load student data
  Future<void> loadStudentData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load profile and dashboard data in parallel
      final [profile, dashboard] = await Future.wait([
        _studentService.getStudentProfile(),
        _studentService.getStudentDashboard(),
      ]);

      _studentProfile = profile;
      _dashboardData = dashboard;

      print('✅ Student data loaded successfully');
    } catch (e) {
      _errorMessage = 'Failed to load student data: $e';
      print('❌ Error loading student data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update student profile
  Future<bool> updateStudentProfile(Map<String, dynamic> profileData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProfile = await _studentService.updateStudentProfile(
        profileData,
      );

      if (updatedProfile != null) {
        _studentProfile = updatedProfile['profile'] ?? updatedProfile;
        print('✅ Student profile updated successfully');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      print('❌ Error updating student profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh student data
  Future<void> refreshStudentData() async {
    await loadStudentData();
  }

  // Clear student data (on logout)
  void clearStudentData() {
    _studentProfile = null;
    _dashboardData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
