import 'package:flutter/material.dart';
import 'package:mtandao_app/providers/teacher_provider.dart';
import 'package:provider/provider.dart';

class UTeacherHistoryPage extends StatefulWidget {
  const UTeacherHistoryPage({super.key});

  @override
  State<UTeacherHistoryPage> createState() => _TeacherHistoryPageState();
}

class _TeacherHistoryPageState extends State<UTeacherHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = Provider.of<TeacherProvider>(context, listen: false);
    provider.fetchTeacherResources();
    provider.fetchTeacherTests();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TeacherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload History"),
        bottom: const TabBar(
          tabs: [Tab(text: "Resources"), Tab(text: "Tests")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildResourcesTab(provider), _buildTestsTab(provider)],
      ),
    );
  }

  Widget _buildResourcesTab(TeacherProvider provider) {
    if (provider.resources.isEmpty) {
      return const Center(child: Text("No resources uploaded yet."));
    }
    return ListView.builder(
      itemCount: provider.resources.length,
      itemBuilder: (context, index) {
        final r = provider.resources[index];
        return ListTile(
          title: Text(r.title),
          // subtitle: Text("${r.level} - ${r.subject}"),
          trailing: const Icon(Icons.file_present),
        );
      },
    );
  }

  Widget _buildTestsTab(TeacherProvider provider) {
    if (provider.tests.isEmpty) {
      return const Center(child: Text("No tests created yet."));
    }
    return ListView.builder(
      itemCount: provider.tests.length,
      itemBuilder: (context, index) {
        final t = provider.tests[index];
        return ListTile(
          title: Text(t.title),
          // subtitle: Text("${t.subject} - ${t.durationSeconds ~/ 60} mins"),
          trailing: const Icon(Icons.quiz),
        );
      },
    );
  }
}
