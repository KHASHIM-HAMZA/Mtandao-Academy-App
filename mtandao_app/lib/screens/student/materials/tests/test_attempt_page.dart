import 'package:flutter/material.dart';
import 'package:mtandao_app/model/questions_model.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../providers/test_provider.dart';
import 'test_result_page.dart';

class TestAttemptPage extends StatefulWidget {
  final int testId;
  final String title;
  final List<Question> questions;
  final int durationSeconds;
  final int userId;

  const TestAttemptPage({
    super.key,
    required this.testId,
    required this.title,
    required this.questions,
    required this.durationSeconds,
    required this.userId,
  });

  @override
  State<TestAttemptPage> createState() => _TestAttemptPageState();
}

class _TestAttemptPageState extends State<TestAttemptPage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TestProvider>(context, listen: false);
    provider.loadTest(
      testQuestions: widget.questions,
      durationSeconds: widget.durationSeconds,
    );
  }

  Future<void> _autoSubmit(TestProvider provider) async {
    final result = provider.calculateScore();

    await _submitResultToBackend(
      testId: widget.testId,
      userId: widget.userId,
      score: result['score']!,
      totalQuestions: result['total']!,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => TestResultPage(
                testTitle: widget.title,
                score: result['score']!,
                totalQuestions: result['total']!,
              ),
        ),
      );
    }
  }

  Future<void> _submitResultToBackend({
    required int testId,
    required int userId,
    required int score,
    required int totalQuestions,
  }) async {
    final url = Uri.parse(
      "https://your-backend-api.com/api/tests/$testId/submit",
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "score": score,
          "totalQuestions": totalQuestions,
        }),
      );
      if (response.statusCode == 200) {
        debugPrint("✅ Result saved successfully!");
      } else {
        debugPrint("❌ Failed to save result: ${response.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Error submitting result: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, provider, _) {
        if (provider.questions.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final question = provider.questions[provider.currentIndex];
        final remaining = provider.remainingSeconds;
        final progress =
            (provider.currentIndex + 1) / provider.questions.length;
        final percent = 1 - (remaining / provider.initialDuration);

        // When time runs out, auto-submit
        if (remaining <= 0) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _autoSubmit(provider),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(
                  child: Text(
                    '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: percent.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade300,
                  progressColor: Colors.blueAccent,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Q${provider.currentIndex + 1} / ${provider.questions.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${(percent * 100).toStringAsFixed(0)}% completed'),
                  ],
                ),
                const SizedBox(height: 18),

                // Question content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildQuestionCard(question, provider),
                  ),
                ),

                // Navigation
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            provider.currentIndex == 0
                                ? null
                                : provider.prevQuestion,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            provider.currentIndex ==
                                    provider.questions.length - 1
                                ? () async {
                                  final result = provider.calculateScore();
                                  await _submitResultToBackend(
                                    testId: widget.testId,
                                    userId: widget.userId,
                                    score: result['score']!,
                                    totalQuestions: result['total']!,
                                  );
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => TestResultPage(
                                              testTitle: widget.title,
                                              score: result['score']!,
                                              totalQuestions: result['total']!,
                                            ),
                                      ),
                                    );
                                  }
                                }
                                : provider.nextQuestion,
                        child: Text(
                          provider.currentIndex == provider.questions.length - 1
                              ? 'Submit'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionCard(Question q, TestProvider provider) {
    Widget media = const SizedBox.shrink();

    if (q.mediaUrl != null) {
      if (q.mediaUrl!.endsWith(".pdf")) {
        media = SizedBox(height: 180, child: SfPdfViewer.network(q.mediaUrl!));
      } else if (q.mediaUrl!.endsWith(".jpg") || q.mediaUrl!.endsWith(".png")) {
        media = CachedNetworkImage(
          imageUrl: q.mediaUrl!,
          placeholder: (_, __) => const CircularProgressIndicator(),
        );
      }
    }

    final selected = provider.answers[q.id];

    return Card(
      key: ValueKey(q.id),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                q.questionText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (q.mediaUrl != null) ...[media, const SizedBox(height: 12)],
              if (q.type == "MULTIPLE_CHOICE")
                ...q.options.map(
                  (opt) => RadioListTile<String>(
                    value: opt,
                    groupValue: selected,
                    onChanged: (v) => provider.selectAnswer(q.id, v!),
                    title: Text(opt),
                  ),
                ),
              if (q.type == "TRUE_FALSE")
                ...["True", "False"].map(
                  (opt) => RadioListTile<String>(
                    value: opt,
                    groupValue: selected,
                    onChanged: (v) => provider.selectAnswer(q.id, v!),
                    title: Text(opt),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
