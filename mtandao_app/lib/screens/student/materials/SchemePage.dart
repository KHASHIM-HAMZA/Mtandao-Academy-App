import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:mtandao_app/providers/scheme_provider.dart';
import 'package:mtandao_app/utils/constants.dart';

class StudentSchemePage extends StatefulWidget {
  const StudentSchemePage({super.key});

  @override
  State<StudentSchemePage> createState() => _StudentSchemePageState();
}

class _StudentSchemePageState extends State<StudentSchemePage> {
  String searchQuery = "";
  String? selectedSubject;
  String? selectedLevel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SchemeProvider>(context, listen: false).fetchPublicSchemes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final schemeProvider = Provider.of<SchemeProvider>(context);
    final Color primaryColor = const Color(0xFF1B588A);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Schemes of Work",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh, size: 20),
            ),
            onPressed: () => schemeProvider.fetchPublicSchemes(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          schemeProvider.isLoading
              ? _buildLoadingState()
              : Column(
                children: [
                  _buildHeaderSection(),
                  _buildSearchAndFilterSection(schemeProvider.publicSchemes),
                  const SizedBox(height: 8),
                  _buildResultsCount(schemeProvider.publicSchemes),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildSchemeList(schemeProvider.publicSchemes),
                  ),
                ],
              ),
    );
  }

  // 🔄 LOADING STATE
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF1B588A)),
          ),
          const SizedBox(height: 16),
          Text(
            "Loading Schemes...",
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 📊 HEADER SECTION
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1B588A),
            const Color(0xFF1B588A).withOpacity(0.9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Schemes of Work",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Access curriculum plans and teaching schedules",
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔎 SEARCH AND FILTER SECTION
  Widget _buildSearchAndFilterSection(List schemes) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                hintText: "Search schemes by title or subject...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => searchQuery = "");
                          },
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Row
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  value: selectedSubject,
                  hint: "All Subjects",
                  items:
                      schemes
                          .map((e) => e['subject'].toString())
                          .toSet()
                          .toList(),
                  onChanged: (v) => setState(() => selectedSubject = v),
                  icon: Icons.subject_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterDropdown(
                  value: selectedLevel,
                  hint: "All Levels",
                  items:
                      schemes
                          .map((e) => e['educationLevel'].toString())
                          .toSet()
                          .toList(),
                  onChanged: (v) => setState(() => selectedLevel = v),
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(width: 8),
              _buildClearFilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  // 🎚 FILTER DROPDOWN
  Widget _buildFilterDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF1B588A)),
        ),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              hint,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
            ),
          ),
          ...items.map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
        onChanged: onChanged,
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF1B588A)),
        style: GoogleFonts.poppins(fontSize: 13),
      ),
    );
  }

  // 🗑 CLEAR FILTER BUTTON
  Widget _buildClearFilterButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.filter_alt_off, color: Colors.grey[600], size: 20),
        onPressed: () {
          setState(() {
            selectedLevel = null;
            selectedSubject = null;
            _searchController.clear();
            searchQuery = "";
          });
        },
        tooltip: 'Clear filters',
      ),
    );
  }

  // 📈 RESULTS COUNT
  Widget _buildResultsCount(List schemes) {
    final filteredCount = _getFilteredSchemes(schemes).length;
    final totalCount = schemes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Available Schemes",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1B588A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$filteredCount of $totalCount",
              style: GoogleFonts.poppins(
                color: const Color(0xFF1B588A),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 📄 SCHEME LIST
  Widget _buildSchemeList(List<dynamic> schemes) {
    final filtered = _getFilteredSchemes(schemes);

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final scheme = filtered[index];
        final pdfUrl = "${AppConstants.openeurl}${scheme['fileUrl']}";

        return _buildSchemeCard(scheme, pdfUrl, context);
      },
    );
  }

  // 🃏 SCHEME CARD
  Widget _buildSchemeCard(
    Map<String, dynamic> scheme,
    String pdfUrl,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) =>
                        SchemePdfViewer(title: scheme['title'], pdfUrl: pdfUrl),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // PDF Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B588A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: const Color(0xFF1B588A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Scheme Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme['title'] ?? 'Untitled',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Subject and Level
                      Row(
                        children: [
                          _buildInfoChip(
                            scheme['subject'] ?? 'No Subject',
                            Icons.subject_outlined,
                          ),
                          const SizedBox(width: 6),
                          _buildInfoChip(
                            scheme['educationLevel'] ?? 'No Level',
                            Icons.school_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Term and Year
                      Row(
                        children: [
                          _buildInfoChip(
                            scheme['term'] ?? 'No Term',
                            Icons.calendar_today_outlined,
                          ),
                          const SizedBox(width: 6),
                          _buildInfoChip(
                            scheme['year']?.toString() ?? 'No Year',
                            Icons.date_range_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // View Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B588A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "View",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🏷 INFO CHIP
  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 📭 EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No Schemes Found",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Try adjusting your search or filters to find what you're looking for",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B588A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              setState(() {
                selectedLevel = null;
                selectedSubject = null;
                _searchController.clear();
                searchQuery = "";
              });
            },
            child: Text(
              "Clear Filters",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 HELPER: GET FILTERED SCHEMES
  List<dynamic> _getFilteredSchemes(List<dynamic> schemes) {
    return schemes.where((s) {
      final matchesSubject =
          selectedSubject == null ||
          s["subject"].toString().toLowerCase() ==
              selectedSubject!.toLowerCase();

      final matchesLevel =
          selectedLevel == null ||
          s["educationLevel"].toString().toLowerCase() ==
              selectedLevel!.toLowerCase();

      final matchesSearch =
          searchQuery.isEmpty ||
          s["title"].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          s["subject"].toString().toLowerCase().contains(
            searchQuery.toLowerCase(),
          );

      return matchesSubject && matchesLevel && matchesSearch;
    }).toList();
  }
}

// 📘 PDF VIEWER
class SchemePdfViewer extends StatelessWidget {
  final String title;
  final String pdfUrl;

  const SchemePdfViewer({super.key, required this.title, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    final PdfViewerController pdfViewerController = PdfViewerController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF1B588A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              pdfViewerController.zoomLevel = 1.25;
            },
            tooltip: 'Zoom In',
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              pdfViewerController.zoomLevel = 0.75;
            },
            tooltip: 'Zoom Out',
          ),
        ],
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        controller: pdfViewerController,
        pageLayoutMode: PdfPageLayoutMode.single,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}
