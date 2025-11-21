import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:mtandao_app/model/resource_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TeacherHistoryPage extends StatefulWidget {
  const TeacherHistoryPage({Key? key}) : super(key: key);

  @override
  State<TeacherHistoryPage> createState() => _TeacherHistoryPageState();
}

class _TeacherHistoryPageState extends State<TeacherHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? teacherName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherName = prefs.getString('name');
    });

    // Fetch both resources and past papers on load
    if (teacherName != null) {
      Future.microtask(() {
        Provider.of<ResourceProvider>(
          context,
          listen: false,
        ).fetchTeacherResources();
        Provider.of<PastPaperProvider>(
          context,
          listen: false,
        ).fetchTeacherPapers();
      });
    }
  }

  Future<void> _refreshAll() async {
    if (teacherName != null) {
      await Provider.of<ResourceProvider>(
        context,
        listen: false,
      ).fetchTeacherResources();
      await Provider.of<PastPaperProvider>(
        context,
        listen: false,
      ).fetchTeacherPapers();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: "Resources"),
            Tab(icon: Icon(Icons.assignment_outlined), text: "Past Papers"),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        child: TabBarView(
          controller: _tabController,
          children: const [_ResourcesHistoryTab(), _PastPapersHistoryTab()],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Uploaded Resources",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Resources you upload will appear here",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
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
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: 24,
              ),
            ),
            title: Text(
              item.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.description.isNotEmpty
                      ? item.description
                      : 'No description',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      item.subject.isNotEmpty ? item.subject : 'No Subject',
                      Icons.subject_outlined,
                    ),
                    const SizedBox(width: 6),
                    _buildInfoChip(
                      item.educationLevel.toUpperCase(),
                      Icons.school_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded on ${_formatDate(item.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) async {
                if (value == "delete") {
                  _showDeleteDialog(context, item);
                } else if (value == "view") {
                  _viewResourceDetails(context, item);
                } else if (value == "preview" && item.fileUrl.isNotEmpty) {
                  _viewPdf(context, item.title, item.fileUrl);
                }
              },
              itemBuilder:
                  (context) => [
                    if (item.fileUrl.isNotEmpty &&
                        item.fileUrl.toLowerCase().endsWith('.pdf'))
                      PopupMenuItem(
                        value: "preview",
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text("View PDF"),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: "view",
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text("View Details"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'books':
        return Icons.menu_book_outlined;
      case 'notes':
        return Icons.note_alt_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'books':
        return Colors.blue.shade600;
      case 'notes':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewResourceDetails(BuildContext context, Resource resource) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Resource Details",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow("Title", resource.title),
                _buildDetailRow(
                  "Description",
                  resource.description.isNotEmpty
                      ? resource.description
                      : 'No description',
                ),
                _buildDetailRow("Type", resource.type),
                _buildDetailRow("Subject", resource.subject),
                _buildDetailRow("Education Level", resource.educationLevel),
                _buildDetailRow("Upload Date", _formatDate(resource.createdAt)),
                if (resource.creator.isNotEmpty)
                  _buildDetailRow("Uploaded By", resource.creator),
                if (resource.fileUrl.isNotEmpty)
                  _buildDetailRow("File URL", resource.fileUrl),
              ],
            ),
            actions: [
              if (resource.fileUrl.isNotEmpty &&
                  resource.fileUrl.toLowerCase().endsWith('.pdf'))
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewPdf(context, resource.title, resource.fileUrl);
                  },
                  child: Text("View PDF"),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Resource resource) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Resource?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Are you sure you want to delete \"${resource.title}\"? This action cannot be undone.",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality when backend supports it
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Delete functionality coming soon"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _viewPdf(BuildContext context, String title, String fileUrl) {
    // Debug the file URL from backend
    print('📄 File URL from backend: $fileUrl');

    const String baseUrl = AppConstants.openeurl;

    final fullUrl = '$baseUrl$fileUrl';

    // Test URL in browser
    print('🌐 Test this URL in browser: $fullUrl');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(title),
                backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                actions: [
                  IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () {
                      // Open in browser for testing
                      // You'll need the url_launcher package for this
                      // _launchUrl(fullUrl);
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SfPdfViewer.network(
                      fullUrl,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        print(
                          '✅ PDF loaded successfully: ${details.document.pages.count} pages',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF loaded: ${details.document.pages.count} pages',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onDocumentLoadFailed: (
                        PdfDocumentLoadFailedDetails details,
                      ) {
                        print('❌ PDF load failed: ${details.error}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to load PDF: ${details.error}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        print('📖 Page changed: ${details.newPageNumber}');
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}

// ========================= PAST PAPERS TAB =========================
class _PastPapersHistoryTab extends StatelessWidget {
  const _PastPapersHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pastPaperProvider = Provider.of<PastPaperProvider>(context);

    if (pastPaperProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final pastPapers = pastPaperProvider.papers;

    if (pastPapers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Uploaded Past Papers",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Past papers and corrections you upload will appear here",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pastPapers.length,
      itemBuilder: (context, index) {
        final paper = pastPapers[index];
        final bool hasCorrections =
            pastPaperProvider.corrections[paper['id']] != null &&
            pastPaperProvider.corrections[paper['id']]!.isNotEmpty;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color:
                    hasCorrections
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasCorrections
                    ? Icons.assignment_turned_in_outlined
                    : Icons.assignment_outlined,
                color: hasCorrections ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              paper['title'] ?? 'Untitled',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildPastPaperInfoChip(
                      paper['subject'] ?? 'No Subject',
                      Icons.subject_outlined,
                    ),
                    const SizedBox(width: 6),
                    _buildPastPaperInfoChip(
                      paper['educationLevel']?.toString().toUpperCase() ??
                          'N/A',
                      Icons.school_outlined,
                    ),
                    const SizedBox(width: 6),
                    _buildPastPaperInfoChip(
                      '${paper['year']}',
                      Icons.calendar_today_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (hasCorrections)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 12,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Has Corrections',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Uploaded on ${_formatDate(DateTime.parse(paper['uploadedAt']))}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              onSelected: (value) {
                if (value == "delete") {
                  _showDeletePastPaperDialog(context, paper);
                } else if (value == "view") {
                  _viewPastPaperDetails(context, paper, pastPaperProvider);
                } else if (value == "preview" && paper['fileUrl'] != null) {
                  _viewPdf(
                    context,
                    paper['title'] ?? 'Past Paper',
                    paper['fileUrl'],
                  );
                } else if (value == "corrections") {
                  _viewCorrections(context, paper, pastPaperProvider);
                }
              },
              itemBuilder:
                  (context) => [
                    if (paper['fileUrl'] != null &&
                        paper['fileUrl'].toString().toLowerCase().endsWith(
                          '.pdf',
                        ))
                      PopupMenuItem(
                        value: "preview",
                        child: Row(
                          children: [
                            Icon(Icons.picture_as_pdf_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text("View PDF"),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: "corrections",
                      child: Row(
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text("View Corrections"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "view",
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text("View Details"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text("Delete", style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPastPaperInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewPastPaperDetails(
    BuildContext context,
    Map<String, dynamic> paper,
    PastPaperProvider provider,
  ) {
    final corrections = provider.corrections[paper['id']] ?? [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Past Paper Details",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPastPaperDetailRow("Title", paper['title'] ?? 'N/A'),
                _buildPastPaperDetailRow("Subject", paper['subject'] ?? 'N/A'),
                _buildPastPaperDetailRow(
                  "Education Level",
                  paper['educationLevel'] ?? 'N/A',
                ),
                _buildPastPaperDetailRow(
                  "Year",
                  paper['year']?.toString() ?? 'N/A',
                ),
                _buildPastPaperDetailRow(
                  "Uploaded By",
                  paper['uploadedBy'] ?? 'N/A',
                ),
                _buildPastPaperDetailRow(
                  "Upload Date",
                  _formatDate(DateTime.parse(paper['uploadedAt'])),
                ),
                _buildPastPaperDetailRow(
                  "Corrections",
                  "${corrections.length} available",
                ),
              ],
            ),
            actions: [
              if (paper['fileUrl'] != null &&
                  paper['fileUrl'].toString().toLowerCase().endsWith('.pdf'))
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewPdf(
                      context,
                      paper['title'] ?? 'Past Paper',
                      paper['fileUrl'],
                    );
                  },
                  child: Text("View PDF"),
                ),
              if (corrections.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewCorrections(context, paper, provider);
                  },
                  child: Text("View Corrections"),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _buildPastPaperDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _viewCorrections(
    BuildContext context,
    Map<String, dynamic> paper,
    PastPaperProvider provider,
  ) {
    final paperId = paper['id'];
    final corrections = provider.corrections[paperId] ?? [];

    // Fetch corrections if not already loaded
    if (corrections.isEmpty) {
      provider.fetchCorrections(paperId);
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Corrections for ${paper['title']}",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  corrections.isEmpty
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Corrections Available",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Upload corrections for this past paper",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: corrections.length,
                        itemBuilder: (context, index) {
                          final correction = corrections[index];
                          return ListTile(
                            leading: Icon(
                              Icons.assignment_turned_in_outlined,
                              color: Colors.green,
                            ),
                            title: Text(correction['title'] ?? 'Correction'),
                            subtitle: Text(
                              'Uploaded on ${_formatDate(DateTime.parse(correction['uploadedAt']))}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.picture_as_pdf_outlined),
                              onPressed: () {
                                Navigator.pop(context);
                                _viewPdf(
                                  context,
                                  correction['title'] ?? 'Correction',
                                  correction['fileUrl'],
                                );
                              },
                            ),
                          );
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  void _showDeletePastPaperDialog(
    BuildContext context,
    Map<String, dynamic> paper,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Past Paper?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Are you sure you want to delete \"${paper['title']}\"? This will also delete all associated corrections.",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement delete past paper functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Delete functionality coming soon"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  void _viewPdf(BuildContext context, String title, String fileUrl) {
    // Debug the file URL from backend
    print('📄 File URL from backend: $fileUrl');

    const String baseUrl = AppConstants.openeurl;

    final fullUrl = '$baseUrl$fileUrl';
    print('🔗 Full PDF URL: $fullUrl');

    // Test URL in browser
    print('🌐 Test this URL in browser: $fullUrl');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(
                title: Text(title),
                backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                actions: [
                  IconButton(
                    icon: Icon(Icons.open_in_browser),
                    onPressed: () {
                      // Open in browser for testing
                      // You'll need the url_launcher package for this
                      // _launchUrl(fullUrl);
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: SfPdfViewer.network(
                      fullUrl,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      canShowScrollHead: true,
                      canShowScrollStatus: true,
                      onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                        print(
                          '✅ PDF loaded successfully: ${details.document.pages.count} pages',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'PDF loaded: ${details.document.pages.count} pages',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      onDocumentLoadFailed: (
                        PdfDocumentLoadFailedDetails details,
                      ) {
                        print('❌ PDF load failed: ${details.error}');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to load PDF: ${details.error}',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      onPageChanged: (PdfPageChangedDetails details) {
                        print('📖 Page changed: ${details.newPageNumber}');
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
