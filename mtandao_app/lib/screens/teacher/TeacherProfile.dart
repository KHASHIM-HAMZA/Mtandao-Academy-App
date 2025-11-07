import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherProfilePage extends StatelessWidget {
  const TeacherProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

    // Fixed teacher data structure
    final Map<String, dynamic> teacherData = {
      'name': 'Dr. Sarah Johnson',
      'email': 'sarah.johnson@mtandao.academy',
      'phone': '+255 712 345 678',
      'subjects': ['Mathematics', 'Physics'],
      'qualification': 'MSc. Mathematics Education',
      'experience': '8 years',
      'school': 'Mlimani Secondary School',
      'region': 'Dar es Salaam',
      'joinDate': '2023-08-15',
    };

    // Teacher statistics
    final Map<String, dynamic> teacherStats = {
      'activeClassrooms': 3,
      'totalStudents': 45,
      'resourcesUploaded': 28,
      'quizzesCreated': 12,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/teacher.png',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: primaryColor,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  teacherData['name'] as String,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacherData['qualification'] as String,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children:
                      (teacherData['subjects'] as List<String>)
                          .map(
                            (subject) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                subject,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Teacher Statistics
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teaching Statistics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildTeacherStat(
                      'Active Classrooms',
                      teacherStats['activeClassrooms'].toString(),
                      Icons.groups_outlined,
                      Colors.blue.shade600,
                    ),
                    _buildTeacherStat(
                      'Total Students',
                      teacherStats['totalStudents'].toString(),
                      Icons.people_outlined,
                      Colors.green.shade600,
                    ),
                    _buildTeacherStat(
                      'Resources Uploaded',
                      teacherStats['resourcesUploaded'].toString(),
                      Icons.menu_book_outlined,
                      Colors.orange.shade600,
                    ),
                    _buildTeacherStat(
                      'Quizzes Created',
                      teacherStats['quizzesCreated'].toString(),
                      Icons.quiz_outlined,
                      Colors.purple.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Professional Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.school_outlined,
                  'Qualification',
                  teacherData['qualification'] as String,
                ),
                _buildInfoRow(
                  Icons.work_outline,
                  'Experience',
                  teacherData['experience'] as String,
                ),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'School',
                  teacherData['school'] as String,
                ),
                _buildInfoRow(
                  Icons.place_outlined,
                  'Region',
                  teacherData['region'] as String,
                ),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Member Since',
                  teacherData['joinDate'] as String,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Information',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.email_outlined,
                  'Email',
                  teacherData['email'] as String,
                ),
                _buildInfoRow(
                  Icons.phone_outlined,
                  'Phone',
                  teacherData['phone'] as String,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 3.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildActionButton(
                      'Edit Profile',
                      Icons.edit_outlined,
                      Colors.blue.shade600,
                      () {
                        // Edit profile
                      },
                    ),
                    _buildActionButton(
                      'Change Password',
                      Icons.lock_outlined,
                      Colors.green.shade600,
                      () {
                        // Change password
                      },
                    ),
                    _buildActionButton(
                      'Settings',
                      Icons.settings_outlined,
                      Colors.orange.shade600,
                      () {
                        // Settings
                      },
                    ),
                    _buildActionButton(
                      'Logout',
                      Icons.logout,
                      Colors.red.shade600,
                      () {
                        // Logout
                        _showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTeacherStat(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
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
                  Navigator.pushNamed(context, "/login");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('you logged out!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
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
