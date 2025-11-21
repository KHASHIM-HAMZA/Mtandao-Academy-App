import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/model/resource_model.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class StudentResourcesPage extends StatefulWidget {
  const StudentResourcesPage({super.key});

  @override
  State<StudentResourcesPage> createState() => _StudentResourcesPageState();
}

class _StudentResourcesPageState extends State<StudentResourcesPage>
    with SingleTickerProviderStateMixin {
  String selectedLevel = 'All';
  String selectedCategory = 'All';
  String selectedSubLevel = 'All';
  String searchQuery = '';
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Track download progress and offline status
  final Map<String, bool> _downloading = {};
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloaded = {};
  final Map<String, String> _localFilePaths = {};
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
    _loadResources();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    setState(() => isLoading = true);
    await Provider.of<ResourceProvider>(
      context,
      listen: false,
    ).fetchResources();
    setState(() => isLoading = false);
  }

  void _refreshResources() async {
    setState(() => isLoading = true);
    _animationController.reset();
    await Provider.of<ResourceProvider>(
      context,
      listen: false,
    ).fetchResources();
    setState(() => isLoading = false);
    _animationController.forward();
  }

  Future<void> _checkExistingDownloads() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files =
          dir.listSync().where((f) => f.path.endsWith('.pdf')).toList();

      for (final file in files) {
        final fileName = file.uri.pathSegments.last;
        _downloaded[fileName] = true;
        _localFilePaths[fileName] = file.path;
      }
    } catch (e) {
      print('Error checking downloads: $e');
    }
  }

  String _getResourceKey(Resource resource) {
    return '${resource.id}_${resource.title}'.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '_',
    );
  }

  bool _isDownloaded(Resource resource) {
    return _downloaded[_getResourceKey(resource)] ?? false;
  }

  bool _isDownloading(Resource resource) {
    return _downloading[_getResourceKey(resource)] ?? false;
  }

  double _getProgress(Resource resource) {
    return _downloadProgress[_getResourceKey(resource)] ?? 0.0;
  }

  // NEW: Show payment dialog before download
  void _showPaymentDialog(Resource resource) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PaymentDialog(
            resource: resource,
            onPaymentSuccess: () {
              // After successful payment, proceed with download
              _downloadResource(resource);
            },
          ),
    );
  }

  Future<void> _downloadResource(Resource resource) async {
    if (!_permissionChecked) {
      await _checkPermissions();
    }

    final resourceKey = _getResourceKey(resource);
    final fileUrl = resource.fileUrl;

    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('File URL not available');
      return;
    }

    setState(() {
      _downloading[resourceKey] = true;
      _downloadProgress[resourceKey] = 0.0;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${resource.title}.pdf'.replaceAll(
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
              _downloadProgress[resourceKey] = received / total;
            });
          }
        },
      );

      setState(() {
        _downloading.remove(resourceKey);
        _downloadProgress.remove(resourceKey);
        _downloaded[resourceKey] = true;
        _localFilePaths[resourceKey] = path;
      });

      _showSnackBar('Downloaded successfully', isError: false);
    } catch (e) {
      print('Download error: $e');
      setState(() {
        _downloading.remove(resourceKey);
        _downloadProgress.remove(resourceKey);
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

  void _viewOnline(Resource resource) {
    final fileUrl = resource.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      _showSnackBar('File URL not available');
      return;
    }

    const String baseUrl = AppConstants.openeurl;
    final fullUrl = '$baseUrl$fileUrl';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ResourcePdfViewerPage(title: resource.title, url: fullUrl),
      ),
    );
  }

  void _openDownloadedFile(Resource resource) async {
    final resourceKey = _getResourceKey(resource);
    final path = _localFilePaths[resourceKey];

    if (path != null && await File(path).exists()) {
      try {
        await OpenFile.open(path);
      } catch (e) {
        _showSnackBar('Cannot open file: ${e.toString()}');
      }
    } else {
      _showSnackBar('File not found. Please re-download.');
      setState(() {
        _downloaded.remove(resourceKey);
        _localFilePaths.remove(resourceKey);
      });
    }
  }

  void _showResourceOptions(Resource resource) {
    final isDownloading = _isDownloading(resource);
    final isDownloaded = _isDownloaded(resource);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                resource.title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                '${resource.type} • ${_formatLevel(resource.educationLevel)}',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              _buildOptionButton(
                icon: Icons.visibility_outlined,
                title: 'View Online',
                subtitle: 'Open in PDF viewer',
                onTap: () {
                  Navigator.pop(context);
                  _viewOnline(resource);
                },
              ),
              if (!isDownloaded)
                _buildOptionButton(
                  icon: Icons.download_outlined,
                  title: 'Download',
                  subtitle: 'Save for offline use - TZS 500',
                  onTap: () {
                    Navigator.pop(context);
                    _showPaymentDialog(
                      resource,
                    ); // Show payment dialog instead of direct download
                  },
                ),
              if (isDownloaded)
                _buildOptionButton(
                  icon: Icons.file_open,
                  title: 'Open File',
                  subtitle: 'Open downloaded file',
                  onTap: () {
                    Navigator.pop(context);
                    _openDownloadedFile(resource);
                  },
                ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF1B588A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF1B588A)),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
      ),
      onTap: onTap,
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

  Widget _buildResourceCard(
    int index,
    Resource resource,
    BuildContext context,
  ) {
    final isDownloading = _isDownloading(resource);
    final isDownloaded = _isDownloaded(resource);
    final downloadProgress = _getProgress(resource);

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
          onTap: () => _showResourceOptions(resource),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Resource Icon with gradient - DIFFERENT ICONS FOR BOOKS/NOTES
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
                  child: Icon(
                    _getResourceIcon(resource.type),
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Resource Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
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
                        _getCategoryIcon(resource.type),
                        resource.type,
                      ),
                      _buildDetailRow(
                        Icons.school,
                        _formatLevel(resource.educationLevel),
                      ),
                      _buildDetailRow(
                        Icons.class_,
                        resource.subLevel ?? 'Not Specified',
                      ),
                      _buildDetailRow(Icons.description, resource.description),
                      _buildDetailRow(
                        Icons.calendar_today,
                        _formatDate(resource.createdAt),
                      ),

                      if (isDownloading)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: downloadProgress,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF1B588A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Downloading... ${((downloadProgress ?? 0) * 100).toStringAsFixed(0)}%',
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
                _buildActionButton(
                  resource,
                  isDownloading,
                  isDownloaded,
                  context,
                ),
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
    Resource resource,
    bool isDownloading,
    bool isDownloaded,
    BuildContext context,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: isDownloading ? null : () => _showResourceOptions(resource),
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
            const Icon(Icons.visibility, size: 18),
            const SizedBox(width: 4),
            Text(
              "View",
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

  // DIFFERENT ICONS FOR BOOKS AND NOTES
  IconData _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return Icons.auto_stories;
      case 'note':
        return Icons.notes;
      default:
        return Icons.description;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'book':
        return Icons.menu_book;
      case 'note':
        return Icons.note_alt;
      default:
        return Icons.category;
    }
  }

  String _formatLevel(String level) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);
    final allResources = provider.resources;

    final filteredResources =
        allResources.where((resource) {
          final matchesLevel =
              selectedLevel == 'All' ||
              _formatLevel(resource.educationLevel) == selectedLevel;
          final matchesCategory =
              selectedCategory == 'All' ||
              resource.type.toLowerCase() == selectedCategory.toLowerCase();
          final matchesSubLevel =
              selectedSubLevel == 'All' ||
              resource.subLevel == selectedSubLevel;
          final matchesSearch =
              searchQuery.isEmpty ||
              resource.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              resource.description.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
          return matchesLevel &&
              matchesCategory &&
              matchesSubLevel &&
              matchesSearch;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B588A),
        elevation: 0,
        title: Text(
          'Learning Resources',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedRotation(
              turns: isLoading ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child: const Icon(Icons.refresh),
            ),
            onPressed: _refreshResources,
            tooltip: 'Refresh resources',
          ),
        ],
      ),
      body: FadeTransition(
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
                    hintText: 'Search resources...',
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
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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

            // 🧩 Category filter tabs with scroll
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['All', 'Book', 'Note']
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                                selected: selectedCategory == entry.value,
                                onSelected:
                                    (_) => setState(
                                      () => selectedCategory = entry.value,
                                    ),
                                backgroundColor: Colors.white,
                                selectedColor: const Color(0xFF1B588A),
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color:
                                      selectedCategory == entry.value
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

            const SizedBox(height: 8),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${filteredResources.length} resource${filteredResources.length != 1 ? 's' : ''} found',
                    key: ValueKey(filteredResources.length),
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 📋 Resources list
            Expanded(
              child:
                  isLoading
                      ? _buildShimmerLoading()
                      : filteredResources.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No resources available",
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
                        onRefresh: () => provider.fetchResources(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredResources.length,
                          itemBuilder: (context, index) {
                            final resource = filteredResources[index];
                            return _buildResourceCard(index, resource, context);
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Payment Dialog Widget
class PaymentDialog extends StatelessWidget {
  final Resource resource;
  final VoidCallback onPaymentSuccess;

  const PaymentDialog({
    super.key,
    required this.resource,
    required this.onPaymentSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Payment Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1B588A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 40,
                color: Color(0xFF1B588A),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'Premium Resource',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B588A),
              ),
            ),

            const SizedBox(height: 10),

            // Resource Name
            Text(
              resource.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Price Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Download Price: ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'TZS 500',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Payment Methods
            Text(
              'Available Payment Methods',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 15),

            // Payment Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaymentOption('M-Pesa', Icons.phone_android),
                _buildPaymentOption('Airtel Money', Icons.phone_iphone),
                _buildPaymentOption('Tigo Pesa', Icons.phone),
              ],
            ),

            const SizedBox(height: 25),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close payment dialog
                      onPaymentSuccess(); // Proceed with download
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B588A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Pay & Download',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String name, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Icon(icon, color: const Color(0xFF1B588A)),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// DEDICATED PDF VIEWER FOR RESOURCES
class ResourcePdfViewerPage extends StatefulWidget {
  final String url;
  final String title;
  const ResourcePdfViewerPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<ResourcePdfViewerPage> createState() => _ResourcePdfViewerPageState();
}

class _ResourcePdfViewerPageState extends State<ResourcePdfViewerPage> {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkPdfUrl,
            tooltip: 'Reload PDF',
          ),
        ],
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B588A),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : SfPdfViewer.network(
                widget.url,
                pageLayoutMode: PdfPageLayoutMode.single,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDocumentLinkAnnotation: false,
              ),
    );
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
                  4,
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
