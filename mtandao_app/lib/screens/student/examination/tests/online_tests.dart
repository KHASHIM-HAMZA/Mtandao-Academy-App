import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/student/examination/tests/test_attempt_page.dart';
import 'package:mtandao_app/providers/test_provider.dart';
import 'package:provider/provider.dart';

class OnlineTestsPage extends StatefulWidget {
  const OnlineTestsPage({Key? key}) : super(key: key);

  @override
  State<OnlineTestsPage> createState() => _OnlineTestsPageState();
}

class _OnlineTestsPageState extends State<OnlineTestsPage>
    with SingleTickerProviderStateMixin {
  String selectedLevel = 'All';
  String searchQuery = '';
  bool isLoading = false;
  // List<TestModel> onlineTests =

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  Future _loadTests() async {
    await Provider.of<TestProvider>(context, listen: false).fetchTests();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TestProvider>(context);

    final filteredTests =
        provider.tests.where((test) {
          final matchesLevel =
              selectedLevel == 'All' || test.level == selectedLevel;
          final matchesSearch =
              searchQuery.isEmpty ||
              test.title.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesLevel && matchesSearch;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B588A),
        title: Text(
          'Online Tests',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search tests...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          // 🧩 Level filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ['All', 'Primary', 'O-Level', 'A-Level']
                        .map(
                          (level) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(level),
                              selected: selectedLevel == level,
                              onSelected:
                                  (_) => setState(() => selectedLevel = level),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 📋 Test list
          Expanded(
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : filteredTests.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [const Text("No tests available for now.")],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: provider.tests.length,
                      itemBuilder: (context, index) {
                        final test = filteredTests[index];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              test.title,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Subject: ${test.subject}"),
                                Text("Level: ${test.level}"),
                                Text("Duration: ${test.duration} mins"),
                                Text("Questions: ${test.questions}"),
                                Text("By: ${test.creator}"),
                              ],
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                final testModel = test; // from provider or API

                                var currentUserId;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => TestAttemptPage(
                                          testId: testModel.id,
                                          title: testModel.title,
                                          durationSeconds:
                                              testModel.duration * 60,
                                          questions: testModel.questions,
                                          userId:
                                              currentUserId, // from auth/session
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text("Attempt"),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
