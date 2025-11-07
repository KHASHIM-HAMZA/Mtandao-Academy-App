import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/model/test_model.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:mtandao_app/providers/teacher_test_provider.dart';
import 'package:provider/provider.dart';
import 'package:mtandao_app/model/resource_model.dart';

class TeacherHistoryPage extends StatefulWidget {
  const TeacherHistoryPage({Key? key}) : super(key: key);

  @override
  State<TeacherHistoryPage> createState() => _TeacherHistoryPageState();
}

class _TeacherHistoryPageState extends State<TeacherHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String teacherId = "TCH001"; // TODO: replace with logged-in teacher ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Fetch both resources and tests on load
    Future.microtask(() {
      Provider.of<ResourceProvider>(
        context,
        listen: false,
      ).fetchTeacherResources(teacherId);
      Provider.of<TeacherTestProvider>(
        context,
        listen: false,
      ).fetchTeacherTests(teacherId);
    });
  }

  Future<void> _refreshAll() async {
    await Provider.of<ResourceProvider>(
      context,
      listen: false,
    ).fetchTeacherResources(teacherId);
    await Provider.of<TeacherTestProvider>(
      context,
      listen: false,
    ).fetchTeacherTests(teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 88, 138),
        title: Text(
          "Upload History",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: "Resources"),
            Tab(icon: Icon(Icons.quiz_outlined), text: "Online Tests"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: TabBarView(
          controller: _tabController,
          children: const [_ResourcesHistoryTab(), _TestsHistoryTab()],
        ),
      ),
    );
  }
}

// ========================= RESOURCES TAB =========================
class _ResourcesHistoryTab extends StatelessWidget {
  const _ResourcesHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final resources = provider.resources;

    if (resources.isEmpty) {
      return const Center(child: Text("No uploaded resources yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final Resource item = resources[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              item.type.toLowerCase() == "book"
                  ? Icons.book_outlined
                  : Icons.note_alt_outlined,
              color: Colors.blueAccent,
              size: 32,
            ),
            title: Text(
              item.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${item.subject} • ${item.educationLevel} • ${item.createdAt.toLocal().toString().split(' ')[0]}",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "Delete") {
                  // You can implement delete call later if API supports it
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: "Edit", child: Text("Edit")),
                    PopupMenuItem(value: "Delete", child: Text("Delete")),
                  ],
            ),
          ),
        );
      },
    );
  }
}

// ========================= TESTS TAB =========================
class _TestsHistoryTab extends StatelessWidget {
  const _TestsHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final testProvider = Provider.of<TeacherTestProvider>(context);

    if (testProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final tests = testProvider.teacherTests;

    if (tests.isEmpty) {
      return const Center(child: Text("No uploaded tests yet."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tests.length,
      itemBuilder: (context, index) {
        final TestModel test = tests[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(
              Icons.assignment_outlined,
              color: Colors.deepPurple,
              size: 32,
            ),
            title: Text(
              test.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "${test.createdAt.toLocal().toString().split(' ')[0]} • ${test.questions.length} Questions • ${test.duration} mins",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "Delete") {
                  // Implement delete later if needed
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: "Edit", child: Text("Edit")),
                    PopupMenuItem(value: "Delete", child: Text("Delete")),
                  ],
            ),
          ),
        );
      },
    );
  }
}
