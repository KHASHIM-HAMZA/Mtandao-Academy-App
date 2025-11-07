import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/teacher/history_page.dart';
import 'package:mtandao_app/screens/teacher/online_test/Create_test_page.dart';
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

  // Keep one instance of each page to preserve state
  final List<Widget> _pages = const [
    TeacherHomePage(),
    TeacherUploadResourcePage(),
    CreateTestPage(),
    TeacherProfilePage(),
    TeacherHistoryPage(),
  ];

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
              'Teacher Portal',
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
          PopupMenuButton(
            icon: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                Icons.more_vert_outlined,
                size: 24,
                color: Colors.white,
              ),
            ),
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    onTap: () {
                      Navigator.pushNamed(context, "/settings");
                    },
                    child: Text("Settings"),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.pushNamed(context, "/login");
                    },
                    child: Text("Logout"),
                  ),
                ],
          ),
        ],
      ),

      // ✅ IndexedStack keeps all pages alive, preventing rebuilds
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
                icon: Icon(Icons.upload_outlined),
                activeIcon: Icon(Icons.upload, size: 30),
                label: 'Upload',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz, size: 30),
                label: 'Online Test',
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
