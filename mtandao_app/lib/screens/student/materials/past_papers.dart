import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';

class PastPapers extends StatefulWidget {
  const PastPapers({super.key});

  @override
  State<PastPapers> createState() => _PastPapersState();
}

class _PastPapersState extends State<PastPapers>
    with SingleTickerProviderStateMixin {
  String selectedLevel = 'All';
  String selectedSubLevel = 'All';
  String searchQuery = '';
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Download state management
  final Map<String, bool> _downloading = {};
  final Map<String, double> _progress = {};
  final Map<String, bool> _downloaded = {};
  final Map<String, String> _localPaths = {};
  bool _permissionChecked = false;

  // Sublevel options for each education level
  final Map<String, List<String>> subLevels = {
    'primary': [
      'All',
      'Standard 1',
      'Standard 2',
      'Standard 3',
      'Standard 4',
      'Standard 5',
      'Standard 6',
      'Standard 7',
    ],
    'olevel': ['All', 'Form 1', 'Form 2', 'Form 3', 'Form 4'],
    'alevel': ['All', 'Form 5', 'Form 6'],
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkExistingDownloads();
    _animationController.forward();
    Future.microtask(() {
      Provider.of<PastPaperProvider>(context, listen: false).fetchPapers();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingDownloads() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files =
          dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();

      for (final file in files) {
        final fileName = file.uri.pathSegments.last;
        _downloaded[fileName] = true;
        _localPaths[fileName] = file.path;
      }
    } catch (e) {
      print('Error checking downloads: $e');
    }
  }

  void _refreshPapers() async {
    setState(() => isLoading = true);
    _animationController.reset();
    await Provider.of<PastPaperProvider>(context, listen: false).fetchPapers();
    setState(() => isLoading = false);
    _animationController.forward();
  }

  String _getPaperKey(Map<String, dynamic> paper) {
    return '${paper['id']}_${paper['title']}'.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '_',
    );
  }

  bool _isDownloaded(Map<String, dynamic> paper) {
    return _downloaded[_getPaperKey(paper)] ?? false;
  }

  bool _isDownloading(Map<String, dynamic> paper) {
    return _downloading[_getPaperKey(paper)] ?? false;
  }

  double _getProgress(Map<String, dynamic> paper) {
    return _progress[_getPaperKey(paper)] ?? 0.0;
  }

  Future<void> _downloadPdf(Map<String, dynamic> paper) async {
    if (!_permissionChecked) {
      await _checkPermissions();
    }

    final paperKey = _getPaperKey(paper);
    final fileUrl = paper['fileUrl'];

    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('File URL not available');
      return;
    }

    setState(() {
      _downloading[paperKey] = true;
      _progress[paperKey] = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${paper['title']}_${paper['year']}.pdf'.replaceAll(
        RegExp(r'[^a-zA-Z0-9._-]'),
        '_',
      );
      final path = '${dir.path}/$fileName';

      const String baseUrl = AppConstants.openeurl;
      final fullUrl = '$baseUrl$fileUrl';

      await Dio().download(
        fullUrl,
        path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress[paperKey] = received / total;
            });
          }
        },
      );

      setState(() {
        _downloading.remove(paperKey);
        _progress.remove(paperKey);
        _downloaded[paperKey] = true;
        _localPaths[paperKey] = path;
      });

      _showSnackBar('Downloaded successfully', isError: false);
    } catch (e) {
      print('Download error: $e');
      setState(() {
        _downloading.remove(paperKey);
        _progress.remove(paperKey);
      });
      _showSnackBar('Download failed: ${e.toString()}');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      setState(() {
        _permissionChecked = true;
      });
    } catch (e) {
      print('Permission error: $e');
      setState(() {
        _permissionChecked = true;
      });
    }
  }

  void _viewOnline(Map<String, dynamic> paper) {
    final fileUrl = paper['fileUrl'];
    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('File URL not available');
      return;
    }

    const String baseUrl = AppConstants.openeurl;
    final fullUrl = '$baseUrl$fileUrl';

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => SafePdfViewerPage(
              title: paper['title'] ?? 'Past Paper',
              url: fullUrl,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _ShimmerCard();
      },
    );
  }

  Widget _buildPaperCard(int index, dynamic paper, BuildContext context) {
    final downloading = _isDownloading(paper);
    final progress = _getProgress(paper);
    final downloaded = _isDownloaded(paper);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.blue[50]!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _viewOnline(paper),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // PDF Icon with gradient
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B588A), Color(0xFF2D9CDB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B588A).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Paper Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper['title'] ?? 'Untitled',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF1B588A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      _buildDetailRow(
                        Icons.subject,
                        paper['subject'] ?? 'No Subject',
                      ),
                      _buildDetailRow(
                        Icons.school,
                        _formatLevel(paper['educationLevel']),
                      ),
                      _buildDetailRow(
                        Icons.class_,
                        paper['sublevel'] ?? 'Not Specified', // Show sublevel
                      ),
                      _buildDetailRow(
                        Icons.calendar_today,
                        paper['year']?.toString() ?? 'Unknown Year',
                      ),
                      _buildDetailRow(
                        Icons.person,
                        "By: ${paper['uploadedBy'] ?? 'Unknown'}",
                      ),

                      if (downloading)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1B588A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Downloading... ${(progress * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Action Button
                const SizedBox(width: 12),
                _buildActionButton(paper, downloading, downloaded, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    dynamic paper,
    bool downloading,
    bool downloaded,
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed:
            downloading
                ? null
                : () {
                  if (downloaded) {
                    _openDownloadedFile(paper);
                  } else {
                    _downloadPdf(paper);
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B588A),
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shadowColor: const Color(0xFF1B588A).withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              downloading
                  ? Icons.downloading
                  : downloaded
                  ? Icons.file_open
                  : Icons.download,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              downloading
                  ? "Downloading"
                  : downloaded
                  ? "Open"
                  : "Download",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B588A),
        elevation: 0,
        title: Text(
          'Past Papers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download_for_offline_outlined, size: 20),
            ),
            tooltip: 'My Downloads',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OfflineDownloadsPage()),
              );
            },
          ),
          IconButton(
            icon: AnimatedRotation(
              turns: isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Icon(Icons.refresh),
            ),
            onPressed: _refreshPapers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<PastPaperProvider>(
        builder: (context, provider, child) {
          final filteredPapers =
              provider.papers.where((paper) {
                final paperLevel =
                    paper['educationLevel']?.toString().toLowerCase();
                final targetLevel = selectedLevel.toLowerCase().replaceAll(
                  '-',
                  '',
                );

                final paperSubLevel = paper['sublevel']?.toString();
                final targetSubLevel = selectedSubLevel;

                final matchesLevel =
                    selectedLevel == 'All' || paperLevel == targetLevel;
                final matchesSubLevel =
                    selectedSubLevel == 'All' ||
                    paperSubLevel == targetSubLevel;
                final matchesSearch =
                    searchQuery.isEmpty ||
                    paper['title'].toString().toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    paper['subject'].toString().toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );

                return matchesLevel && matchesSubLevel && matchesSearch;
              }).toList();

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 🔍 Search bar with animation
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF1B588A),
                        ),
                        hintText: 'Search past papers...',
                        hintStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      style: GoogleFonts.poppins(),
                    ),
                  ),
                ),

                // 🧩 Level filter tabs with scroll
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children:
                        ['All', 'Primary', 'O-Level', 'A-Level']
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: AnimatedContainer(
                                  duration: Duration(
                                    milliseconds: 200 + (entry.key * 50),
                                  ),
                                  child: FilterChip(
                                    label: Text(
                                      entry.value,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    selected: selectedLevel == entry.value,
                                    onSelected:
                                        (_) => setState(() {
                                          selectedLevel = entry.value;
                                          selectedSubLevel =
                                              'All'; // Reset sublevel when level changes
                                        }),
                                    backgroundColor: Colors.white,
                                    selectedColor: const Color(0xFF1B588A),
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          selectedLevel == entry.value
                                              ? Colors.white
                                              : Colors.grey[700],
                                    ),
                                    elevation: 2,
                                    shadowColor: Colors.grey.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),

                // 🎯 Sublevel filter (shown only when a specific level is selected)
                if (selectedLevel != 'All')
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          _getCurrentSubLevels()
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: FilterChip(
                                    label: Text(
                                      entry.value,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                    selected: selectedSubLevel == entry.value,
                                    onSelected:
                                        (_) => setState(
                                          () => selectedSubLevel = entry.value,
                                        ),
                                    backgroundColor: Colors.white,
                                    selectedColor: Colors.green[600],
                                    checkmarkColor: Colors.white,
                                    labelStyle: TextStyle(
                                      color:
                                          selectedSubLevel == entry.value
                                              ? Colors.white
                                              : Colors.grey[700],
                                    ),
                                    elevation: 2,
                                    shadowColor: Colors.grey.withOpacity(0.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                const SizedBox(height: 8),

                // Results count
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        '${filteredPapers.length} paper${filteredPapers.length != 1 ? 's' : ''} found',
                        key: ValueKey(filteredPapers.length),
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 📋 Papers list
                Expanded(
                  child:
                      provider.isLoading
                          ? _buildShimmerLoading()
                          : filteredPapers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_outlined,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No past papers available",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Try changing your filters or search",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          )
                          : RefreshIndicator(
                            onRefresh: () => provider.fetchPapers(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: filteredPapers.length,
                              itemBuilder: (context, index) {
                                final paper = filteredPapers[index];
                                return _buildPaperCard(index, paper, context);
                              },
                            ),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getCurrentSubLevels() {
    switch (selectedLevel.toLowerCase()) {
      case 'primary':
        return subLevels['primary']!;
      case 'o-level':
        return subLevels['olevel']!;
      case 'a-level':
        return subLevels['alevel']!;
      default:
        return ['All'];
    }
  }

  String _formatLevel(String? level) {
    if (level == null) return 'Unknown Level';
    switch (level.toLowerCase()) {
      case 'primary':
        return 'Primary';
      case 'olevel':
        return 'O-Level';
      case 'alevel':
        return 'A-Level';
      default:
        return level;
    }
  }

  Future<void> _openDownloadedFile(Map<String, dynamic> paper) async {
    final paperKey = _getPaperKey(paper);
    final path = _localPaths[paperKey];

    if (path != null && await File(path).exists()) {
      try {
        await OpenFile.open(path);
      } catch (e) {
        _showSnackBar('Cannot open file: ${e.toString()}');
      }
    } else {
      _showSnackBar('File not found. Please re-download.');
      setState(() {
        _downloaded.remove(paperKey);
        _localPaths.remove(paperKey);
      });
    }
  }
}

// Custom shimmer loading widget
class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your existing SafePdfViewerPage and OfflineDownloadsPage implementations
class SafePdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  const SafePdfViewerPage({super.key, required this.url, required this.title});

  @override
  State<SafePdfViewerPage> createState() => _SafePdfViewerPageState();
}

class _SafePdfViewerPageState extends State<SafePdfViewerPage> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPdfUrl();
  }

  Future<void> _checkPdfUrl() async {
    try {
      final response = await Dio().head(widget.url);
      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'PDF not found (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Cannot load PDF: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1B588A),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Cannot Load PDF',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkPdfUrl,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : SfPdfViewer.network(
                widget.url,
                pageLayoutMode: PdfPageLayoutMode.single,
                canShowScrollHead: true,
                canShowScrollStatus: true,
              ),
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
    try {
      final dir = await getApplicationDocumentsDirectory();
      setState(() {
        files = dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();
      });
    } catch (e) {
      print('Error loading downloads: $e');
    }
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
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_for_offline_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No files downloaded yet",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Download past papers to view them offline",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  final fileName = file.uri.pathSegments.last;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: Colors.red,
                      ),
                      title: Text(
                        fileName,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${(File(file.path).lengthSync() / 1024 / 1024).toStringAsFixed(1)} MB',
                        style: GoogleFonts.poppins(color: Colors.grey.shade600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        onPressed: () {
                          File(file.path).deleteSync();
                          loadDownloads();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted $fileName'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => Scaffold(
                                  appBar: AppBar(
                                    title: Text(fileName),
                                    backgroundColor: const Color(0xFF1B588A),
                                  ),
                                  body: SfPdfViewer.file(File(file.path)),
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
