import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class LeaderboardPage extends StatefulWidget {
  final String testId;
  const LeaderboardPage({super.key, required this.testId});
  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final Dio _dio = Dio();
  List<Map<String, dynamic>> rows = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final resp = await _dio.get(
        'https://your-api.com/api/tests/${widget.testId}/leaderboard',
      );
      // expected: [{ "userId": "...", "name": "...", "score": 8, "total": 10 }]
      setState(() {
        rows = List<Map<String, dynamic>>.from(resp.data);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Leaderboard fetch failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final r = rows[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${i + 1}')),
            title: Text(r['name'] ?? r['userId']),
            subtitle: Text('Score: ${r['score']} / ${r['total']}'),
            trailing: Text(
              '${((r['score'] / r['total']) * 100).toStringAsFixed(0)}%',
            ),
          );
        },
      ),
    );
  }
}
