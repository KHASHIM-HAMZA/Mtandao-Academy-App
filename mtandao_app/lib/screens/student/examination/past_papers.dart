import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PastPaper {
  final String id;
  final String name;
  final String year;
  final String pdfUrl;
  final String subject;
  final String level;
  final String fileSize;
  final String uploadDate;

  PastPaper({
    required this.id,
    required this.name,
    required this.year,
    required this.pdfUrl,
    required this.subject,
    required this.level,
    required this.fileSize,
    required this.uploadDate,
  });
}

class PastPapers extends StatefulWidget {
  const PastPapers({super.key});

  @override
  State<PastPapers> createState() => _PastPapersState();
}

class _PastPapersState extends State<PastPapers> {
  final Color primaryColor = const Color(0xFF1B588A);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            "Past Papers",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          backgroundColor: primaryColor,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: "Primary"),
              Tab(text: "O-Level"),
              Tab(text: "A-Level"),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download_for_offline_outlined),
              tooltip: 'My Downloads',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OfflineDownloadsPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            LevelTab(level: 'Primary'),
            LevelTab(level: 'O-Level'),
            LevelTab(level: 'A-Level'),
          ],
        ),
      ),
    );
  }
}

class LevelTab extends StatefulWidget {
  final String level;
  const LevelTab({super.key, required this.level});

  @override
  State<LevelTab> createState() => _LevelTabState();
}

class _LevelTabState extends State<LevelTab> {
  final Map<String, bool> _downloading = {};
  final Map<String, double> _progress = {};
  final Map<String, bool> _downloaded = {};

  // Mock data
  Future<List<PastPaper>> _fetchPapers() async {
    await Future.delayed(const Duration(seconds: 1));

    final mockData = {
      'Primary': [
        PastPaper(
          id: '1',
          name: "Igunga grade 4 mock",
          year: "2023",
          pdfUrl:
              "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
          subject: "Mathematics",
          level: "Primary",
          fileSize: "2.5 MB",
          uploadDate: "2024-01-15",
        ),
        PastPaper(
          id: '2',
          name: "Kigamboni District Mock",
          year: "2023",
          pdfUrl:
              "https://maktaba.tetea.org/past-papers/csee/biology/Biology%201%20-%20F4%20-%202016.pdf",
          subject: "Science",
          level: "Primary",
          fileSize: "1.8 MB",
          uploadDate: "2024-01-10",
        ),
      ],
      'O-Level': [
        PastPaper(
          id: '3',
          name: "Ilala Form 2 district mock",
          year: "2023",
          pdfUrl:
              "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
          subject: "Mathematics",
          level: "O-Level",
          fileSize: "3.2 MB",
          uploadDate: "2024-01-12",
        ),
      ],
      'A-Level': [
        PastPaper(
          id: '4',
          name: "Bagamoyo form 6 mock exam",
          year: "2023",
          pdfUrl:
              "https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf",
          subject: "Geography 2",
          level: "A-Level",
          fileSize: "5.2 MB",
          uploadDate: "2024-01-16",
        ),
      ],
    };

    return mockData[widget.level] ?? [];
  }

  Future<void> _downloadPdf(PastPaper paper) async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      _showSnackBar('Storage permission required');
      return;
    }

    setState(() {
      _downloading[paper.id] = true;
      _progress[paper.id] = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${paper.name}_${paper.year}.pdf';

      await Dio().download(
        paper.pdfUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress[paper.id] = received / total;
            });
          }
        },
      );

      setState(() {
        _downloading.remove(paper.id);
        _progress.remove(paper.id);
        _downloaded[paper.id] = true;
      });

      _showSnackBar('Downloaded successfully', isError: false);
    } catch (e) {
      setState(() {
        _downloading.remove(paper.id);
        _progress.remove(paper.id);
      });
      _showSnackBar('Download failed: $e');
    }
  }

  Future<void> _openDownloadedFile(PastPaper paper) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${paper.name}_${paper.year}.pdf';
    final file = File(path);

    if (await file.exists()) {
      await OpenFile.open(path);
    } else {
      _showSnackBar('File not found. Please re-download.');
    }
  }

  void _viewOnline(PastPaper paper) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PdfViewerPage(title: paper.name, url: paper.pdfUrl),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PastPaper>>(
      future: _fetchPapers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final papers = snapshot.data ?? [];
        if (papers.isEmpty) {
          return const Center(child: Text('No papers found'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: papers.length,
          itemBuilder: (context, index) {
            final paper = papers[index];
            final downloading = _downloading[paper.id] ?? false;
            final progress = _progress[paper.id] ?? 0.0;
            final downloaded = _downloaded[paper.id] ?? false;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paper.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${paper.subject} • ${paper.year}',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    if (downloading)
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF1B588A),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _viewOnline(paper),
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Online'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child:
                              downloaded
                                  ? ElevatedButton.icon(
                                    onPressed: () => _openDownloadedFile(paper),
                                    icon: const Icon(Icons.file_open),
                                    label: const Text('Open'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                    ),
                                  )
                                  : ElevatedButton.icon(
                                    onPressed:
                                        downloading
                                            ? null
                                            : () => _downloadPdf(paper),
                                    icon:
                                        downloading
                                            ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                              ),
                                            )
                                            : const Icon(Icons.download),
                                    label: Text(
                                      downloading ? 'Downloading' : 'Download',
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
      },
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String url;
  final String title;
  const PdfViewerPage({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF1B588A),
      ),
      body: SfPdfViewer.network(url),
    );
  }
}

class OfflineDownloadsPage extends StatefulWidget {
  const OfflineDownloadsPage({super.key});

  @override
  State<OfflineDownloadsPage> createState() => _OfflineDownloadsPageState();
}

class _OfflineDownloadsPageState extends State<OfflineDownloadsPage> {
  List<FileSystemEntity> files = [];

  Future<void> loadDownloads() async {
    final dir = await getApplicationDocumentsDirectory();
    setState(
      () =>
          files = dir.listSync().where((f) => f.path.endsWith('.pdf')).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    loadDownloads();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        backgroundColor: const Color(0xFF1B588A),
      ),
      body:
          files.isEmpty
              ? const Center(child: Text("No files downloaded yet"))
              : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    title: Text(file.uri.pathSegments.last),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        File(file.path).deleteSync();
                        loadDownloads();
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SfPdfViewer.file(File(file.path)),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
