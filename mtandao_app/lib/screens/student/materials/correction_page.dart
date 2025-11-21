import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/providers/correction_provider.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';
import 'package:provider/provider.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class CorrectionPage extends StatefulWidget {
  const CorrectionPage({super.key});

  @override
  State<CorrectionPage> createState() => _CorrectionPageState();
}

class _CorrectionPageState extends State<CorrectionPage>
    with SingleTickerProviderStateMixin {
  String selectedLevel = 'All';
  String selectedType = 'All';
  String searchQuery = '';
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> correctionTypes = ['All', 'PDF', 'Video'];
  final Color primaryColor = Color(0xFF1B588A);
  final Color videoColor = Color(0xFFFF0000);
  final Color pdfColor = Color(0xFF1B588A);

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
    _loadCorrections();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future _loadCorrections() async {
    setState(() => isLoading = true);
    await Provider.of<CorrectionsProvider>(
      context,
      listen: false,
    ).fetchAllCorrections();
    setState(() => isLoading = false);
  }

  void _refreshCorrections() async {
    setState(() => isLoading = true);
    _animationController.reset();
    await Provider.of<CorrectionsProvider>(
      context,
      listen: false,
    ).fetchCorrections();
    setState(() => isLoading = false);
    _animationController.forward();
  }

  Future<File> downloadPdf(String title, String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/${title.replaceAll(" ", "_")}.pdf";

    File file = File(path);

    if (!await file.exists()) {
      await Dio().download(url, path);
    }

    return file;
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

  Widget _buildCorrectionCard(
    int index,
    dynamic correction,
    BuildContext context,
  ) {
    final isVideo = correction['type']?.toString().toUpperCase() == 'VIDEO';
    final fileUrl = "${AppConstants.openeurl}${correction['fileUrl']}";
    final youtubeUrl = correction["youtubeUrl"];
    final videoTitle = correction["videoTitle"];

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isVideo ? videoColor.withOpacity(0.05) : pdfColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color:
              isVideo ? videoColor.withOpacity(0.2) : pdfColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            if (isVideo) {
              if (youtubeUrl != null &&
                  youtubeUrl.toString().trim().isNotEmpty) {
                final url = Uri.parse(youtubeUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              }
            } else {
              File file = await downloadPdf(correction["title"], fileUrl);
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => CorrectionPdfViewer(
                        file: file,
                        title: correction["title"],
                      ),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Correction Type Icon with distinct colors
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isVideo
                              ? [videoColor, Color(0xFFFF5252)]
                              : [pdfColor, Color(0xFF2D9CDB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: (isVideo ? videoColor : pdfColor).withOpacity(
                          0.3,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isVideo ? Icons.play_circle_fill : Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Correction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with type badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              correction['title'] ?? 'Untitled',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: primaryColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isVideo ? videoColor : pdfColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isVideo ? 'VIDEO' : 'PDF',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Video title for video corrections
                      if (isVideo && videoTitle != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            videoTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: videoColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      _buildDetailRow(
                        Icons.subject,
                        correction['subject'] ?? 'No Subject',
                      ),
                      _buildDetailRow(
                        Icons.school,
                        _formatLevel(correction['educationLevel']),
                      ),
                      _buildDetailRow(
                        Icons.calendar_today,
                        correction['year']?.toString() ?? 'Unknown Year',
                      ),
                      _buildDetailRow(
                        Icons.person,
                        correction['uploadedBy'] ?? 'Unknown Teacher',
                      ),
                    ],
                  ),
                ),

                // Action Button
                const SizedBox(width: 12),
                _buildActionButton(correction, context),
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

  Widget _buildActionButton(dynamic correction, BuildContext context) {
    final isVideo = correction['type']?.toString().toUpperCase() == 'VIDEO';
    final youtubeUrl = correction["youtubeUrl"];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: () async {
          if (isVideo) {
            if (youtubeUrl != null && youtubeUrl.toString().trim().isNotEmpty) {
              final url = Uri.parse(youtubeUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
          } else {
            final fileUrl = "${AppConstants.openeurl}${correction['fileUrl']}";
            File file = await downloadPdf(correction["title"], fileUrl);
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => CorrectionPdfViewer(
                      file: file,
                      title: correction["title"],
                    ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isVideo ? videoColor : pdfColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shadowColor: (isVideo ? videoColor : pdfColor).withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isVideo ? Icons.play_arrow : Icons.visibility, size: 18),
            const SizedBox(width: 4),
            Text(
              isVideo ? "Watch" : "View",
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

  Widget _buildFilterChip(
    String label,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = currentValue == label;
    final isVideo = label == 'Video';
    final isPdf = label == 'PDF';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isVideo)
                Icon(
                  Icons.videocam,
                  size: 16,
                  color: isSelected ? Colors.white : videoColor,
                ),
              if (isPdf)
                Icon(
                  Icons.picture_as_pdf,
                  size: 16,
                  color: isSelected ? Colors.white : pdfColor,
                ),
              if (isVideo || isPdf) const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(label),
          backgroundColor: Colors.white,
          selectedColor:
              isVideo
                  ? videoColor
                  : isPdf
                  ? pdfColor
                  : primaryColor,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          elevation: 2,
          shadowColor: Colors.grey.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CorrectionsProvider>(context);

    final filteredCorrections =
        provider.corrections.where((correction) {
          final matchesLevel =
              selectedLevel == 'All' ||
              _formatLevel(correction['educationLevel']) == selectedLevel;
          final matchesType =
              selectedType == 'All' ||
              correction['type']?.toString().toUpperCase() ==
                  selectedType.toUpperCase();
          final matchesSearch =
              searchQuery.isEmpty ||
              correction['title'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              correction['subject'].toString().toLowerCase().contains(
                searchQuery.toLowerCase(),
              ) ||
              (correction['videoTitle']?.toString().toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ??
                  false);
          return matchesLevel && matchesType && matchesSearch;
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          'Corrections',
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
            onPressed: _refreshCorrections,
            tooltip: 'Refresh corrections',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 🔍 Search bar
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
                    hintText: 'Search corrections...',
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

            // 🎚️ Double filter row
            Column(
              children: [
                // Level filter
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children:
                        ['All', 'Primary', 'O-Level', 'A-Level']
                            .map(
                              (level) => _buildFilterChip(
                                level,
                                selectedLevel,
                                (value) {
                                  setState(() => selectedLevel = value);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
                // Type filter
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children:
                        correctionTypes
                            .map(
                              (type) =>
                                  _buildFilterChip(type, selectedType, (value) {
                                    setState(() => selectedType = value);
                                  }),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Results count with type breakdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      '${filteredCorrections.length} correction${filteredCorrections.length != 1 ? 's' : ''} found',
                      key: ValueKey(filteredCorrections.length),
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (filteredCorrections.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildTypeBreakdown(filteredCorrections),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 📋 Corrections list
            Expanded(
              child:
                  isLoading
                      ? _buildShimmerLoading()
                      : filteredCorrections.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                        onRefresh: () => provider.fetchCorrections(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filteredCorrections.length,
                          itemBuilder: (context, index) {
                            final correction = filteredCorrections[index];
                            return _buildCorrectionCard(
                              index,
                              correction,
                              context,
                            );
                          },
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBreakdown(List<dynamic> corrections) {
    final pdfCount =
        corrections
            .where((c) => c['type']?.toString().toUpperCase() != 'VIDEO')
            .length;
    final videoCount =
        corrections
            .where((c) => c['type']?.toString().toUpperCase() == 'VIDEO')
            .length;

    return Row(
      children: [
        if (pdfCount > 0) ...[
          Row(
            children: [
              Icon(Icons.picture_as_pdf, size: 12, color: pdfColor),
              const SizedBox(width: 2),
              Text(
                '$pdfCount PDF',
                style: GoogleFonts.poppins(
                  color: pdfColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        if (pdfCount > 0 && videoCount > 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(width: 1, height: 12, color: Colors.grey[300]),
          ),
        ],
        if (videoCount > 0) ...[
          Row(
            children: [
              Icon(Icons.videocam, size: 12, color: videoColor),
              const SizedBox(width: 2),
              Text(
                '$videoCount Video',
                style: GoogleFonts.poppins(
                  color: videoColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No corrections available",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try changing your filters or search",
            style: GoogleFonts.poppins(color: Colors.grey[400]),
          ),
        ],
      ),
    );
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
        backgroundColor: const Color(0xFF1B588A),
      ),
      body: SfPdfViewer.file(file),
    );
  }
}
