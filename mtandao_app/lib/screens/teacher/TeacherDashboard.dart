import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/Help.dart';
import 'package:mtandao_app/screens/student/Academic_Materials.dart';
import 'package:mtandao_app/screens/student/materials/past_papers.dart';
import 'package:mtandao_app/screens/teacher/Teacher_Scheme.dart';
import 'package:mtandao_app/screens/teacher/Teacher_Workspace.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtandao_app/screens/teacher/TeacherPastPaperPage.dart';
import 'package:mtandao_app/screens/teacher/history_page.dart';
import 'package:mtandao_app/screens/teacher/teacher_homepage.dart';
import 'package:mtandao_app/screens/teacher/Teacher_resource_upload.dart';
import 'package:mtandao_app/screens/teacher/TeacherProfile.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int _currentIndex = 0;
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  String? teacherName;
  String? teacherEmail;
  String? token;
  List<String> teacherSubjects = [];
  String? profileImageUrl;

  final List<Widget> _pages = const [
    TeacherHomePage(),
    TeachersWorkspace(),
    AcademicMaterials(),
    TeacherProfilePage(),
    TeacherHistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherName = prefs.getString('name') ?? 'Teacher';
      teacherEmail = prefs.getString('email') ?? '';
      token = prefs.getString('jwt_token');
      profileImageUrl = prefs.getString('profileImage');

      // Load subjects from shared preferences
      final subjectsString = prefs.getString('subjects');
      if (subjectsString != null && subjectsString.isNotEmpty) {
        teacherSubjects = List<String>.from(json.decode(subjectsString));
      }
    });
  }

  void _updateSubjects(List<String> newSubjects) {
    setState(() {
      teacherSubjects = newSubjects;
    });
  }

  // Method to navigate to specific pages
  void _navigateToPage(Widget page, {String? routeName}) {
    if (routeName != null) {
      Navigator.pushNamed(context, routeName);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    }
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Avatar
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child:
                      profileImageUrl != null && profileImageUrl!.isNotEmpty
                          ? Image.network(
                            profileImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) =>
                                    _buildDefaultAvatar(),
                          )
                          : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacherName ?? 'Teacher',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacherEmail ?? '',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Subjects Preview
          if (teacherSubjects.isNotEmpty) ...[
            Text(
              'My Subjects:',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children:
                  teacherSubjects.take(3).map((subject) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
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
            if (teacherSubjects.length > 3)
              Text(
                '+${teacherSubjects.length - 3} more',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.white,
      child: Icon(Icons.person, color: primaryColor, size: 30),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    bool isSelected = false,
    bool isBottomNavItem = true,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? primaryColor : Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      trailing:
          isSelected && isBottomNavItem
              ? Icon(Icons.arrow_forward_ios, color: primaryColor, size: 16)
              : null,
      onTap: () {
        Navigator.pop(context); // Close drawer

        if (isBottomNavItem) {
          // Navigate to bottom navigation pages
          setState(() => _currentIndex = index);
        } else {
          // Navigate to other pages not in bottom nav
          switch (title) {
            case 'Scheme of Work':
              _navigateToPage(const TeacherSchemePage());
              break;
            case 'help & support':
              // Navigate to settings page
              _navigateToPage(HelpSupportPage());
              break;
            case 'Past Papers & Corrections':
              _navigateToPage(const PastPapers());
            // Add more cases for other drawer items if needed
          }
        }
      },
    );
  }

  Widget _buildSubjectsDrawerItem() {
    return ExpansionTile(
      leading: Icon(Icons.subject_outlined, color: Colors.grey[700], size: 22),
      title: Text(
        'My Subjects',
        style: GoogleFonts.poppins(
          color: Colors.grey[700],
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      children: [
        if (teacherSubjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No subjects assigned',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 12),
            ),
          )
        else
          ...teacherSubjects.map(
            (subject) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 6, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subject,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          Icon(Icons.school, color: primaryColor, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Mtandao Academy',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Bottom Navigation Items
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    index: 0,
                    isSelected: _currentIndex == 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.upload_outlined,
                    title: 'Upload Resources',
                    index: 1,
                    isSelected: _currentIndex == 1,
                  ),
                  _buildDrawerItem(
                    icon: Icons.quiz_outlined,
                    title: 'Past Papers & Corrections',
                    index: 2,
                    isSelected: _currentIndex == 2,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outlined,
                    title: 'My Profile',
                    index: 3,
                    isSelected: _currentIndex == 3,
                  ),
                  _buildDrawerItem(
                    icon: Icons.history_outlined,
                    title: 'History',
                    index: 4,
                    isSelected: _currentIndex == 4,
                  ),

                  const Divider(height: 20),

                  // Additional Drawer Items (Not in Bottom Nav)
                  _buildDrawerItem(
                    icon: Icons.schedule_outlined,
                    title: 'Scheme of Work',
                    index: -1, // Not in bottom nav
                    isSelected: false,
                    isBottomNavItem: false,
                  ),

                  const Divider(height: 20),

                  _buildSubjectsDrawerItem(),

                  const Divider(height: 20),

                  // Settings and Logout
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'help & support',
                    index: -1,
                    isSelected: false,
                    isBottomNavItem: false,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout_outlined,
                      color: Colors.red,
                      size: 22,
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // Logout completely
                      if (mounted) {
                        Navigator.pushReplacementNamed(context, "/login");
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Keep all pages alive
      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
            ),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard, size: 30),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.desk_outlined),
                activeIcon: Icon(Icons.desk, size: 30),
                label: 'WorkSpace',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                activeIcon: Icon(Icons.library_books, size: 30),
                label: "Materials",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                activeIcon: Icon(Icons.person, size: 30),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history, size: 30),
                label: 'History',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
