import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/student/materials/past_papers.dart';
import 'package:mtandao_app/screens/student/resources_page.dart';
import 'package:mtandao_app/screens/teacher/Teacher_resource_upload.dart';
import 'package:mtandao_app/screens/teacher/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';
import 'package:mtandao_app/model/resource_model.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  String? teacherName;
  List<String> teacherSubjects = [];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
    _loadData();
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherName = prefs.getString('name') ?? 'Teacher';

      // Load subjects from shared preferences
      final subjectsString = prefs.getString('subjects');
      if (subjectsString != null && subjectsString.isNotEmpty) {
        teacherSubjects = List<String>.from(json.decode(subjectsString));
      }
    });
  }

  Future<void> _loadData() async {
    // Fetch teacher's resources and past papers
    final resourceProvider = Provider.of<ResourceProvider>(
      context,
      listen: false,
    );
    final pastPaperProvider = Provider.of<PastPaperProvider>(
      context,
      listen: false,
    );

    await resourceProvider.fetchTeacherResources();
    await pastPaperProvider.fetchPapers();
  }

  // Get real statistics from providers
  Map<String, int> _getStats(
    ResourceProvider resourceProvider,
    PastPaperProvider pastPaperProvider,
  ) {
    final resources = resourceProvider.resources;
    final papers = pastPaperProvider.papers;

    return {
      'totalStudents':
          teacherSubjects.length, // Using subjects count as placeholder
      'activeClassrooms': 0, // Static until implemented
      'resourcesUploaded': resources.length,
      'quizzesCreated': papers.length, // Using past papers as quizzes
    };
  }

  // Get recent activities from resources and past papers
  List<Map<String, dynamic>> _getRecentActivities(
    ResourceProvider resourceProvider,
    PastPaperProvider pastPaperProvider,
  ) {
    final activities = <Map<String, dynamic>>[];

    // Add recent resources
    final resources = resourceProvider.resources.take(2).toList();
    for (final resource in resources) {
      activities.add({
        'type': 'resource',
        'title': 'Uploaded ${resource.title}',
        'date': _formatRelativeTime(resource.createdAt),
        'resource': resource,
      });
    }

    // Add recent past papers
    final papers = pastPaperProvider.papers.take(1).toList();
    for (final paper in papers) {
      activities.add({
        'type': 'quiz',
        'title': 'Uploaded ${paper['title'] ?? 'Past Paper'}',
        'date': _formatRelativeTime(DateTime.parse(paper['uploadedAt'])),
        'paper': paper,
      });
    }

    // Sort by date (newest first) and take max 3
    activities.sort((a, b) {
      final dateA =
          a['type'] == 'resource'
              ? a['resource'].createdAt
              : DateTime.parse(a['paper']['uploadedAt']);
      final dateB =
          b['type'] == 'resource'
              ? b['resource'].createdAt
              : DateTime.parse(b['paper']['uploadedAt']);
      return dateB.compareTo(dateA);
    });

    return activities.take(3).toList();
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${difference.inDays ~/ 7} weeks ago';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double padding = size.width < 360 ? 12 : 20;
    final double cardRadius = size.width < 360 ? 12 : 16;
    final double iconSize = size.width < 360 ? 20 : 24;
    final double avatarSize = size.width < 360 ? 50 : 60;

    final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 360;

          return Consumer2<ResourceProvider, PastPaperProvider>(
            builder: (context, resourceProvider, pastPaperProvider, child) {
              final stats = _getStats(resourceProvider, pastPaperProvider);
              final recentActivities = _getRecentActivities(
                resourceProvider,
                pastPaperProvider,
              );

              return RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Welcome Section ===
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor,
                              primaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoSizeText(
                                    'Welcome, ${teacherName ?? 'Teacher'}!',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 18 : 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 4),
                                  AutoSizeText(
                                    'Manage classrooms & track progress',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                    maxLines: 2,
                                  ),
                                  if (teacherSubjects.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children:
                                          teacherSubjects.take(2).map((
                                            subject,
                                          ) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                subject,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              width: avatarSize,
                              height: avatarSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.school,
                                color: Colors.white,
                                size: avatarSize * 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // === Overview ===
                      _buildSectionTitle('Overview', isSmallScreen),
                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: isSmallScreen ? 1.6 : 1.5,
                        crossAxisSpacing: isSmallScreen ? 8 : 12,
                        mainAxisSpacing: isSmallScreen ? 8 : 12,
                        children: [
                          _buildStatCard(
                            'Subjects',
                            stats['totalStudents'].toString(),
                            Icons.subject_outlined,
                            Colors.blue.shade600,
                            isSmallScreen,
                            iconSize,
                          ),
                          _buildStatCard(
                            'Classrooms',
                            stats['activeClassrooms'].toString(),
                            Icons.groups_outlined,
                            Colors.green.shade600,
                            isSmallScreen,
                            iconSize,
                          ),
                          _buildStatCard(
                            'Resources',
                            stats['resourcesUploaded'].toString(),
                            Icons.menu_book_outlined,
                            Colors.orange.shade600,
                            isSmallScreen,
                            iconSize,
                          ),
                          _buildStatCard(
                            'Past Papers',
                            stats['quizzesCreated'].toString(),
                            Icons.quiz_outlined,
                            Colors.purple.shade600,
                            isSmallScreen,
                            iconSize,
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 28),

                      // === Quick Actions ===
                      _buildSectionTitle('Quick Actions', isSmallScreen),
                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: isSmallScreen ? 1.9 : 1.8,
                        crossAxisSpacing: isSmallScreen ? 8 : 12,
                        mainAxisSpacing: isSmallScreen ? 8 : 12,
                        children: [
                          _buildActionCard(
                            'Create Classroom',
                            Icons.add_circle_outline,
                            Colors.blue.shade600,
                            () {
                              // TODO: Implement classroom creation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Classroom feature coming soon',
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            isSmallScreen,
                          ),
                          _buildActionCard(
                            'Resources',
                            Icons.book_sharp,
                            Colors.green.shade600,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentResourcesPage(),
                                ),
                              );
                            },
                            isSmallScreen,
                          ),
                          _buildActionCard(
                            'Past Papers',
                            Icons.quiz_outlined,
                            Colors.orange.shade600,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PastPapers(),
                                ),
                              );
                            },
                            isSmallScreen,
                          ),
                          _buildActionCard(
                            'View Analytics',
                            Icons.analytics_outlined,
                            Colors.purple.shade600,
                            () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => TeacherHistoryPage(),
                              //   ),
                              // );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Classroom feature coming soon',
                                  ),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            isSmallScreen,
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 28),

                      // === Recent Activity ===
                      _buildSectionTitle('Recent Activity', isSmallScreen),
                      const SizedBox(height: 12),

                      if (recentActivities.isEmpty)
                        _buildEmptyActivityState(isSmallScreen)
                      else
                        ...recentActivities
                            .map(
                              (activity) => _buildActivityItem(
                                activity,
                                isSmallScreen,
                                iconSize,
                                cardRadius,
                              ),
                            )
                            .toList(),

                      const SizedBox(height: 20), // Extra bottom padding
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Helper: Section Title
  Widget _buildSectionTitle(String title, bool isSmall) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: isSmall ? 16 : 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  // Helper: Stat Card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isSmall,
    double iconSize,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmall ? 32 : 40,
            height: isSmall ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(height: 8),
          AutoSizeText(
            value,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          AutoSizeText(
            title,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: isSmall ? 11 : 12,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  // Helper: Action Card
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isSmall,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: isSmall ? 28 : 32),
            const SizedBox(height: 6),
            AutoSizeText(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                fontSize: isSmall ? 12 : 14,
              ),
              maxLines: 2,
              minFontSize: 10,
            ),
          ],
        ),
      ),
    );
  }

  // Helper: Activity Item
  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    bool isSmall,
    double iconSize,
    double radius,
  ) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'quiz':
        icon = Icons.quiz_outlined;
        color = Colors.orange.shade600;
        break;
      case 'resource':
        icon = Icons.menu_book_outlined;
        color = Colors.green.shade600;
        break;
      case 'classroom':
        icon = Icons.groups_outlined;
        color = Colors.blue.shade600;
        break;
      default:
        icon = Icons.notifications_outlined;
        color = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 32 : 40,
            height: isSmall ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  activity['title'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: isSmall ? 13 : 14,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 2),
                AutoSizeText(
                  activity['date'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: isSmall ? 11 : 12,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Empty Activity State
  Widget _buildEmptyActivityState(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history_outlined,
            size: isSmall ? 40 : 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your uploaded resources and past papers will appear here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isSmall ? 11 : 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
