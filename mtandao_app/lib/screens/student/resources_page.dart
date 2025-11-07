import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/model/resource_model.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentResourcesPage extends StatefulWidget {
  const StudentResourcesPage({super.key});

  @override
  State<StudentResourcesPage> createState() => _StudentResourcesPageState();
}

class _StudentResourcesPageState extends State<StudentResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLevel = 'primary';
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  // Track download progress and offline status
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _offlineStatus = {};
  final Map<String, String> _localFilePaths = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadResources();
    _checkExistingDownloads();
  }

  Future<void> _loadResources() async {
    await Provider.of<ResourceProvider>(
      context,
      listen: false,
    ).fetchResources();
  }

  Future<void> _checkExistingDownloads() async {
    // Check if files already exist in local storage
    // You can implement this with your local database
  }

  Future<void> _downloadResource(Resource resource) async {
    if (!await _checkPermission()) return;

    setState(() {
      _downloadProgress[resource.id] = 0.0;
    });

    try {
      final provider = Provider.of<ResourceProvider>(context, listen: false);
      final filePath = await provider.downloadResource(resource);

      setState(() {
        _offlineStatus[resource.id] = true;
        _localFilePaths[resource.id] = filePath;
        _downloadProgress.remove(resource.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${resource.title} downloaded successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        _downloadProgress.remove(resource.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Storage permission is required to download files'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  void _viewResource(Resource resource) {
    if (_offlineStatus[resource.id] == true) {
      _openOfflineFile(resource);
    } else {
      showDialog(
        context: context,
        builder:
            (context) => ResourceDetailsDialog(
              resource: resource,
              isDownloaded: _offlineStatus[resource.id] ?? false,
              downloadProgress: _downloadProgress[resource.id],
              onDownload: () => _downloadResource(resource),
              onViewOnline: () => _viewOnline(resource),
            ),
      );
    }
  }

  void _openOfflineFile(Resource resource) {
    // Implement offline file viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening offline: ${resource.title}'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewOnline(Resource resource) {
    // Implement online viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing online: ${resource.title}'),
        backgroundColor: Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _changeLevel(String level) {
    setState(() => _selectedLevel = level);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResourceProvider>(context);
    final books = provider.filterResources("book", _selectedLevel);
    final notes = provider.filterResources("note", _selectedLevel);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Learning Resources",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primaryColor,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_outlined), text: "Books"),
            Tab(icon: Icon(Icons.note_alt_outlined), text: "Notes"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Education Level Filter
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Education Level',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLevelButton("Primary", Icons.people_outlined),
                    _buildLevelButton("O-Level", Icons.school_outlined),
                    _buildLevelButton("A-Level", Icons.auto_stories_outlined),
                  ],
                ),
              ],
            ),
          ),

          // Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildResourceGrid(books, "Books"),
                _buildResourceGrid(notes, "Notes"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(String level, IconData icon) {
    String levelKey = level.toLowerCase().replaceAll('-', '');
    bool isActive = _selectedLevel == levelKey;
    return GestureDetector(
      onTap: () => _changeLevel(levelKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              level,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceGrid(List<Resource> resources, String category) {
    if (resources.isEmpty) {
      return _buildEmptyState(category);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: resources.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final resource = resources[index];
          final isDownloading = _downloadProgress.containsKey(resource.id);
          final isDownloaded = _offlineStatus[resource.id] ?? false;

          return _ResourceCard(
            resource: resource,
            category: category,
            isDownloading: isDownloading,
            isDownloaded: isDownloaded,
            downloadProgress: _downloadProgress[resource.id],
            onTap: () => _viewResource(resource),
            onDownload: () => _downloadResource(resource),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No $category Available',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new $category',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "books":
        return Icons.menu_book_outlined;
      case "notes":
        return Icons.note_alt_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}

class _ResourceCard extends StatelessWidget {
  final Resource resource;
  final String category;
  final bool isDownloading;
  final bool isDownloaded;
  final double? downloadProgress;
  final VoidCallback onTap;
  final VoidCallback onDownload;

  const _ResourceCard({
    required this.resource,
    required this.category,
    required this.isDownloading,
    required this.isDownloaded,
    required this.downloadProgress,
    required this.onTap,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final Color categoryColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail/Icon Section
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getCategoryIcon(category),
                      size: 40,
                      color: categoryColor,
                    ),
                  ),
                ),

                // Download Progress Indicator
                if (isDownloading)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: downloadProgress,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                    ),
                  ),

                // Status Badges
                Positioned(
                  top: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // File Type Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          resource.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Offline Badge
                      if (isDownloaded)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'OFFLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.educationLevel.toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.blue.shade600,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(resource.createdAt),
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                        const Spacer(),
                        _buildDownloadButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton() {
    if (isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          value: downloadProgress,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getCategoryColor(category),
          ),
        ),
      );
    } else if (isDownloaded) {
      return IconButton(
        icon: Icon(Icons.check_circle, size: 18, color: Colors.green.shade600),
        onPressed: () {}, // Already downloaded
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.download,
          size: 18,
          color: _getCategoryColor(category),
        ),
        onPressed: onDownload,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "books":
        return Icons.menu_book_outlined;
      case "notes":
        return Icons.note_alt_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case "books":
        return Colors.blue.shade600;
      case "notes":
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ResourceDetailsDialog extends StatelessWidget {
  final Resource resource;
  final bool isDownloaded;
  final double? downloadProgress;
  final VoidCallback onDownload;
  final VoidCallback onViewOnline;

  const ResourceDetailsDialog({
    super.key,
    required this.resource,
    required this.isDownloaded,
    required this.downloadProgress,
    required this.onDownload,
    required this.onViewOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              resource.description,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.subject, 'Type', resource.type),
            _buildDetailRow(
              Icons.school,
              'Education Level',
              resource.educationLevel,
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'Upload Date',
              '${resource.createdAt.day}/${resource.createdAt.month}/${resource.createdAt.year}',
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                if (!isDownloaded) ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                      ),
                      onPressed: onDownload,
                      child: const Text(
                        'Download',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                      ),
                      onPressed: onViewOnline,
                      child: const Text(
                        'Open Offline',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
