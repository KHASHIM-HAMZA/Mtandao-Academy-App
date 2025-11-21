import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // if you store pdf path and want to show

class TestHistoryPage extends StatefulWidget {
  const TestHistoryPage({super.key});
  @override
  State<TestHistoryPage> createState() => _TestHistoryPageState();
}

class _TestHistoryPageState extends State<TestHistoryPage> {
  List<Map<String, dynamic>> results = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox('test_results');
    final list =
        box.values
            .cast<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
    setState(() => results = list.reversed.toList()); // newest first
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test History')),
      body:
          results.isEmpty
              ? const Center(child: Text('No attempts yet'))
              : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final r = results[i];
                  final date = DateTime.parse(r['date']);
                  return ListTile(
                    title: Text(r['title']),
                    subtitle: Text(
                      '${r['score']} / ${r['total']} • ${DateFormat.yMMMd().add_jm().format(date)}',
                    ),
                    onTap: () {
                      // optionally show details
                    },
                  );
                },
              ),
    );
  }
}
