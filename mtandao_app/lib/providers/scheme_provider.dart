import 'package:flutter/material.dart';
import '../services/scheme_service.dart';

class SchemeProvider with ChangeNotifier {
  final SchemeService _service = SchemeService();

  bool _isLoading = false;
  List<dynamic> _mySchemes = [];
  List<dynamic> _publicSchemes = [];

  bool get isLoading => _isLoading;
  List<dynamic> get mySchemes => _mySchemes;
  List<dynamic> get publicSchemes => _publicSchemes;

  Future<void> fetchMySchemes(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final schemes = await _service.getMySchemes(email);
      _mySchemes = schemes;
      debugPrint("✅ Fetched ${_mySchemes.length} schemes for teacher: $email");

      // Debug: Print scheme details
      for (var scheme in _mySchemes) {
        debugPrint("📋 Scheme: ${scheme['title']} - ID: ${scheme['id']}");
      }
    } catch (e) {
      debugPrint("❌ Error fetching my schemes: $e");
      _mySchemes = []; // Clear on error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPublicSchemes() async {
    _isLoading = true;
    notifyListeners();
    try {
      _publicSchemes = await _service.getAllPublicSchemes();
      debugPrint("✅ Fetched ${_publicSchemes.length} public schemes");
    } catch (e) {
      debugPrint("❌ Error fetching public schemes: $e");
      _publicSchemes = []; // Clear on error
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadScheme(Map<String, String> fields, String filePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint("📤 Starting scheme upload...");
      debugPrint("📋 Fields: $fields");
      debugPrint("📁 File path: $filePath");

      final success = await _service.uploadScheme(fields, filePath);

      if (success) {
        debugPrint("✅ Scheme uploaded successfully");
        // Force refresh the teacher's schemes
        final teacherEmail = fields['uploadedBy'];
        if (teacherEmail != null) {
          await fetchMySchemes(teacherEmail);
        }
        return true;
      } else {
        debugPrint("❌ Scheme upload failed - service returned false");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Scheme upload error: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear cache if needed
  void clearCache() {
    _mySchemes = [];
    _publicSchemes = [];
    notifyListeners();
  }
}
