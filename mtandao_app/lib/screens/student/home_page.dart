import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:mtandao_app/screens/student/exams.dart';
import 'package:mtandao_app/screens/student/profile_page.dart';
import 'package:mtandao_app/screens/student/resources_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  final List<Widget> _pages = [
    const HomeContent(),
    const StudentResourcesPage(),
    const Exams(),
    const ProfilePage(),
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
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert, color: Colors.white, size: 22),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog(context);
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 8),
                        Text('My Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'help',
                    child: Row(
                      children: [
                        Icon(Icons.help_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Help & Support'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _pages[_currentIndex],
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
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 0
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                    size: 22,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 1
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentIndex == 1
                        ? Icons.menu_book
                        : Icons.menu_book_outlined,
                    size: 22,
                  ),
                ),
                label: 'Resources',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentIndex == 2 ? Icons.school : Icons.school_outlined,
                    size: 22,
                  ),
                ),
                label: 'Exams',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 3
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentIndex == 3 ? Icons.person : Icons.person_outlined,
                    size: 22,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout from your account?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  // Implement logout logic here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
    final banners = [
      'assets/primary1.png',
      'assets/secondary2.png',
      'assets/advance.png',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Karibu, Student! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Continue your learning journey with personalized resources',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.waving_hand,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Banner Carousel
          CarouselSlider(
            options: CarouselOptions(
              height: 160,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlayInterval: const Duration(seconds: 4),
            ),
            items:
                banners.map((img) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        img,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: primaryColor.withOpacity(0.1),
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 28),

          // Quick Access Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Access',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Level Cards
          Row(
            children: const [
              Expanded(
                child: LevelCard(
                  level: "Primary",
                  subtitle: "Std 1-7",
                  icon: Icons.people_outline,
                  color: Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: LevelCard(
                  level: "O-Level",
                  subtitle: "Form 1-4",
                  icon: Icons.school_outlined,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: LevelCard(
                  level: "A-Level",
                  subtitle: "Form 5-6",
                  icon: Icons.auto_stories_outlined,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Popular Subjects
          Text(
            'Popular Subjects',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: const [
              SubjectCard(
                title: 'Mathematics',
                subtitle: 'Algebra & Calculus',
                icon: Icons.calculate_outlined,
                color: Colors.blue,
              ),
              SubjectCard(
                title: 'Kiswahili',
                subtitle: 'Lugha na Fasihi',
                icon: Icons.language_outlined,
                color: Colors.green,
              ),
              SubjectCard(
                title: 'Physics',
                subtitle: 'Mechanics & Waves',
                icon: Icons.science_outlined,
                color: Colors.orange,
              ),
              SubjectCard(
                title: 'Geography',
                subtitle: 'Maps & Environment',
                icon: Icons.map_outlined,
                color: Colors.purple,
              ),
              SubjectCard(
                title: 'Biology',
                subtitle: 'Living Organisms',
                icon: Icons.psychology_outlined,
                color: Colors.red,
              ),
              SubjectCard(
                title: 'History',
                subtitle: 'Tanzania & World',
                icon: Icons.history_outlined,
                color: Colors.brown,
              ),
            ],
          ),

          // FIXED: Added bottom padding to prevent overflow
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final String level;
  final String subtitle;
  final IconData icon;
  final Color color;

  const LevelCard({
    super.key,
    required this.level,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            level,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SubjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header - FIXED: Better profile picture container
          Container(
            height: 200,
            width: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED: Better profile container without white background issues
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/user.png',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              color: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: primaryColor,
                                size: 35,
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Student',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Form 3 Student',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard',
                  onTap: () {},
                ),
                _DrawerItem(
                  icon: Icons.menu_book_outlined,
                  title: 'My Courses',
                  onTap: () {
                    Navigator.pushNamed(context, "/resources");
                  },
                ),
                _DrawerItem(
                  icon: Icons.assignment_outlined,
                  title: 'Assignments',
                  onTap: () {},
                ),
                _DrawerItem(
                  icon: Icons.quiz_outlined,
                  title: 'Practice Tests',
                  onTap: () {},
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'Progress Report',
                  onTap: () {},
                ),
                const Divider(indent: 20, endIndent: 20),
                _DrawerItem(
                  icon: Icons.campaign_outlined,
                  title: 'Announcements',
                  onTap: () {},
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {},
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const Divider(indent: 20, endIndent: 20),
                _DrawerItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    // Show logout dialog
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 10),
                Text('Logout'),
              ],
            ),
            content: const Text(
              'Are you sure you want to logout from your account?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
