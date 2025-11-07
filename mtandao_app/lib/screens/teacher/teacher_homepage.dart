import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/teacher/Teacher_resource_upload.dart';
import 'package:mtandao_app/screens/teacher/history_page.dart';
import 'package:mtandao_app/screens/teacher/online_test/Create_test_page.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double padding = size.width < 360 ? 12 : 20;
    final double cardRadius = size.width < 360 ? 12 : 16;
    final double iconSize = size.width < 360 ? 20 : 24;
    final double avatarSize = size.width < 360 ? 50 : 60;

    final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

    // Mock data
    final stats = {
      'totalStudents': 45,
      'activeClassrooms': 3,
      'resourcesUploaded': 28,
      'quizzesCreated': 12,
    };

    final recentActivities = [
      {'type': 'quiz', 'title': 'Mathematics Quiz 1', 'date': '2 hours ago'},
      {
        'type': 'resource',
        'title': 'Uploaded Physics Notes',
        'date': '5 hours ago',
      },
      {
        'type': 'classroom',
        'title': 'New student joined Form 4A',
        'date': '1 day ago',
      },
    ];

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmallScreen = constraints.maxWidth < 360;

          return SingleChildScrollView(
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
                      colors: [primaryColor, primaryColor.withOpacity(0.8)],
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
                              'Welcome, Teacher!',
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
                      'Students',
                      stats['totalStudents'].toString(),
                      Icons.people_outlined,
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
                      'Quizzes',
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
                      () {},
                      isSmallScreen,
                    ),
                    _buildActionCard(
                      'Upload Resource',
                      Icons.upload_outlined,
                      Colors.green.shade600,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherUploadResourcePage(),
                          ),
                        );
                      },
                      isSmallScreen,
                    ),
                    _buildActionCard(
                      'Create Quiz',
                      Icons.quiz_outlined,
                      Colors.orange.shade600,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateTestPage(),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherHistoryPage(),
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
}
