import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/test_provider.dart';

class TestResultPage extends StatefulWidget {
  final String testTitle;
  final int score;
  final int totalQuestions;

  const TestResultPage({
    super.key,
    required this.testTitle,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<TestResultPage> createState() => _TestResultPageState();
}

class _TestResultPageState extends State<TestResultPage> {
  @override
  Widget build(BuildContext context) {
    String grade;
    double ratio = widget.totalQuestions == 0 ? 0 : widget.score / 100;
    if (ratio >= 0.9)
      grade = 'A';
    else if (ratio >= 0.75)
      grade = 'B';
    else if (ratio >= 0.6)
      grade = 'C';
    else if (ratio >= 0.5)
      grade = 'D';
    else
      grade = 'F';

    return Scaffold(
      appBar: AppBar(title: Text('Result - ${widget.testTitle}')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 80, color: Colors.amber),
                const SizedBox(height: 12),
                Text(
                  '${widget.score}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Grade: $grade', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<TestProvider>(context, listen: false).retry();
                    Navigator.pop(context);
                  },
                  child: const Text('Retry Test'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to Tests'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
