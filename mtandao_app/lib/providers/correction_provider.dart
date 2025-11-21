import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mtandao_app/services/pastpaper_service.dart';
import 'package:mtandao_app/utils/constants.dart';

class CorrectionsProvider with ChangeNotifier {
  final PastPaperService _service = PastPaperService();

  bool isLoading = false;
  List<dynamic> corrections = [];

  Future<void> fetchCorrections() async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await Dio().get("${AppConstants.baseUrl}/api/corrections");

      corrections = res.data;
    } catch (e) {
      print("Error loading corrections: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> filterByLevel(String level) {
    return corrections
        .where(
          (c) =>
              c["educationLevel"].toString().toLowerCase() ==
              level.toLowerCase(),
        )
        .toList();
  }

  Future<void> fetchAllCorrections() async {
    isLoading = true;
    notifyListeners();
    try {
      corrections = (await _service.fetchAllCorrections());
    } catch (e) {
      debugPrint("❌ Error fetching corrections: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
