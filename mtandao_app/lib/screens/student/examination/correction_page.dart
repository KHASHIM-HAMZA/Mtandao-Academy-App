import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CorrectionPage extends StatefulWidget {
  const CorrectionPage({super.key});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String searchQuery = "";
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Simulated correction data
  final Map<String, List<Map<String, String>>> corrections = {
    'Primary': [
      {
        'subject': 'Science',
        'title': 'Primary Science Mock 2024',
        'pdfUrl': 'https://example.com/primary_science.pdf',
        'youtubeUrl': 'https://youtube.com/watch?v=abc123',
      },
      {
        'subject': 'Mathematics',
        'title': 'Primary Math Revision 2023',
        'pdfUrl': 'https://example.com/primary_math.pdf',
        'youtubeUrl': 'https://youtube.com/',
      },
    ],
    'O-Level': [
      {
        'subject': 'Physics',
        'title': 'Physics NECTA 2023',
        'pdfUrl': 'https://example.com/olevel_physics.pdf',
        'youtubeUrl': 'https://youtube.com/watch?v=ghi789',
      },
    ],
    'A-Level': [
      {
        'subject': 'Chemistry',
        'title': 'A-Level Chemistry 2024',
        'pdfUrl': 'https://example.com/alevel_chemistry.pdf',
        'youtubeUrl': 'https://youtube.com/watch?v=jkl012',
      },
    ],
  };

  List<Map<String, String>> getFilteredCorrections(String level) {
    return corrections[level]!
        .where(
          (correction) => correction['subject']!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> openPdf(String title, String pdfUrl) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/$title.pdf";

    File file = File(filePath);
    if (!await file.exists()) {
      setState(() => isDownloading = true);
      await Dio().download(pdfUrl, filePath);
      setState(() => isDownloading = false);
    }

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CorrectionPdfViewer(file: file, title: title),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 8,
        title: Text(
          "Corrections",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B588A),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Primary"),
            Tab(text: "O-Level"),
            Tab(text: "A-Level"),
          ],
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by subject...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // 🧾 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildCorrectionList(getFilteredCorrections('Primary')),
                buildCorrectionList(getFilteredCorrections('O-Level')),
                buildCorrectionList(getFilteredCorrections('A-Level')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCorrectionList(List<Map<String, String>> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No corrections found"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final correction = items[index];
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + index * 100),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              leading: Hero(
                tag: correction['title']!,
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.redAccent,
                ),
              ),
              title: Text(
                correction['title']!,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                correction['subject']!,
                style: GoogleFonts.poppins(color: Colors.grey[700]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
                onPressed: () async {
                  final url = Uri.parse(correction['youtubeUrl']!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              onTap: () => openPdf(correction['title']!, correction['pdfUrl']!),
            ),
          ),
        );
      },
    );
  }
}

// 📄 PDF Viewer with caching
class CorrectionPdfViewer extends StatelessWidget {
  final File file;
  final String title;

  const CorrectionPdfViewer({
    super.key,
    required this.file,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: SfPdfViewer.file(file),
    );
  }
}
