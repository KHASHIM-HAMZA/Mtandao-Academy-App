import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mtandao_app/model/questions_model.dart';
import '../model/test_model.dart';

class TestProvider with ChangeNotifier {
  final String baseUrl = "https://your-backend-api.com/api/tests";

  // ========= API DATA =========
  List<TestModel> _tests = [];
  List<TestModel> get tests => _tests;

  Future<void> fetchTests() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        _tests = data.map((e) => TestModel.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error fetching online tests: $e');
    }
  }

  Future<TestModel> fetchTestById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/$id"));
    if (response.statusCode == 200) {
      return TestModel.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to load test details");
    }
  }

  // ========= ATTEMPT DATA =========
  int _score = 0;
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  Map<int, String> _answers = {};
  Map<int, String> get answers => _answers;

  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;

  int _initialDuration = 0;
  int get initialDuration => _initialDuration;

  Timer? _timer;
  bool _submitted = false;
  bool get submitted => _submitted;

  // ========= LOAD TEST ATTEMPT =========
  void loadTest({
    required List<Question> testQuestions,
    required int durationSeconds,
  }) {
    _questions = testQuestions;
    _currentIndex = 0;
    _answers.clear();
    _initialDuration = durationSeconds;
    _remainingSeconds = durationSeconds;
    _submitted = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        timer.cancel();
        autoSubmit();
      }
    });

    notifyListeners();
  }

  // ========= QUESTION NAVIGATION =========
  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void prevQuestion() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  // ========= ANSWER SELECTION =========
  void selectAnswer(int questionId, String value) {
    _answers[questionId] = value;
    notifyListeners();
  }

  // ========= AUTO SUBMIT =========

  Future<void> autoSubmit() async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();
    final result = calculateScore();
    _score = result['score'] ?? 0;
    notifyListeners();
  }

  // ========= MANUAL SUBMIT =========
  Future<void> submitManual({
    required String userId,
    required String testId,
    required String title,
  }) async {
    if (_submitted) return;
    _submitted = true;
    _timer?.cancel();

    final result = calculateScore();
    _score = result['score'] ?? 0;

    final submission = {
      "userId": userId,
      "testId": testId,
      "title": title,
      "answers": _answers,
      "score": _score,
      "submittedAt": DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/submit"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(submission),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to submit test");
      }
    } catch (e) {
      debugPrint("Submit error: $e");
    }

    notifyListeners();
  }

  // ========= SCORE CALCULATION =========
  Map<String, int> calculateScore() {
    int correct = 0;
    for (final q in _questions) {
      final userAns = _answers[q.id];
      if (userAns != null && userAns == q.correctAnswer) correct++;
    }

    _score = ((correct / _questions.length) * 100).round();
    return {'score': _score, 'total': _questions.length};
  }

  int getScore() => _score;

  // ========= CLEANUP =========
  void retry() {
    _answers.clear();
    _score = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
