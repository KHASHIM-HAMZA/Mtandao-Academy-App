import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/student/materials/SchemePage.dart';
import 'package:mtandao_app/screens/student/materials/correction_page.dart';
import 'package:mtandao_app/screens/student/materials/tests/online_tests.dart';
import 'package:mtandao_app/screens/student/materials/past_papers.dart';
import 'package:mtandao_app/screens/student/resources_page.dart';

class AcademicMaterials extends StatefulWidget {
  const AcademicMaterials({super.key});

  @override
  State<AcademicMaterials> createState() => _AcademicMaterialsState();
}

class _AcademicMaterialsState extends State<AcademicMaterials>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // List of academic materials categories
  final List<AcademicCategory> _categories = [
    AcademicCategory(
      title: "Learning Resources",
      subtitle: "Books, notes and study materials",
      icon: Icons.library_books,
      page: const StudentResourcesPage(),
    ),
    AcademicCategory(
      title: "Past Papers",
      subtitle: "Previous examination papers",
      icon: Icons.assignment,
      page: const PastPapers(),
    ),
    AcademicCategory(
      title: "Corrections",
      subtitle: "Solutions and answer guides",
      icon: Icons.assignment_turned_in,
      page: const CorrectionPage(),
    ),
    AcademicCategory(
      title: "Teaching Schemes",
      subtitle: "Lesson plans and curricula",
      icon: Icons.schedule,
      page: const StudentSchemePage(),
    ),
    AcademicCategory(
      title: "Online Tests",
      subtitle: "Practice tests and quizzes",
      icon: Icons.quiz,
      page: const OnlineTestsPage(),
    ),
    // AcademicCategory(
    //   title: "Announcements",
    //   subtitle: "Important updates and notices",
    //   icon: Icons.announcement,
    //   page: Container(), // Replace with your AnnouncementsPage
    // ),
  ];

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToPage(Widget page, String title) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF1B588A),
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Mtandao Library",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B588A), Color(0xFF2D9CDB)],
                  ),
                ),
              ),
            ),
          ),

          // Header Section
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Academic Materials",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B588A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Access all learning resources, past papers, and teaching materials",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Materials Categories List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = _categories[index];
              return _buildCategoryItem(category, index);
            }, childCount: _categories.length),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(AcademicCategory category, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToPage(category.page, category.title),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1B588A), Color(0xFF2D9CDB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B588A).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF1B588A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B588A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF1B588A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Model for academic categories
class AcademicCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  AcademicCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
}
