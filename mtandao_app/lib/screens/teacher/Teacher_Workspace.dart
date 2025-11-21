import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/teacher/TeacherPastPaperPage.dart';
import 'package:mtandao_app/screens/teacher/Teacher_Scheme.dart';
import 'package:mtandao_app/screens/teacher/Teacher_resource_upload.dart';

class TeachersWorkspace extends StatefulWidget {
  const TeachersWorkspace({super.key});

  @override
  State<TeachersWorkspace> createState() => _TeachersWorkspaceState();
}

class _TeachersWorkspaceState extends State<TeachersWorkspace>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
                "Teacher's Workspace",
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
                      "Workspace Tools",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B588A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Manage your teaching materials and resources",
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

          // Workspace Tools List
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final tool = _workspaceTools[index];
              return _buildWorkspaceItem(tool, index);
            }, childCount: _workspaceTools.length),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspaceItem(WorkspaceTool tool, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToPage(tool.page, tool.title),
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
                  child: Icon(tool.icon, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: const Color(0xFF1B588A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.subtitle,
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

  // Workspace Tools Data
  final List<WorkspaceTool> _workspaceTools = [
    WorkspaceTool(
      title: "Upload Resources",
      subtitle: "Share books, notes and learning materials",
      icon: Icons.library_add,
      page: const TeacherUploadResourcePage(),
    ),
    WorkspaceTool(
      title: "Upload Past Papers",
      subtitle: "Add exam papers and solutions",
      icon: Icons.assignment_add,
      page: const UploadPastPaperPage(),
    ),
    WorkspaceTool(
      title: "Upload Schemes",
      subtitle: "Upload teaching schemes and lesson plans",
      icon: Icons.schedule,
      page: const TeacherSchemePage(),
    ),
  ];
}

// Model for workspace tools
class WorkspaceTool {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;

  WorkspaceTool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
}
