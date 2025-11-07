import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  // Mock user data - replace with actual data from your backend
  final Map<String, dynamic> _userData = {
    'name': 'John Student',
    'email': 'john.student@mtandao.academy',
    'phone': '+255 789 456 123',
    'level': 'O-Level',
    'grade': 'Form 3',
    'school': 'Mlimani Secondary School',
    'region': 'Dar es Salaam',
    'joinDate': '2024-01-15',
    'profileImage': 'assets/user.png',
  };

  // Mock subscription data
  final Map<String, dynamic> _subscriptionData = {
    'isActive': true,
    'plan': 'Monthly Plan',
    'startDate': '2025-02-01',
    'endDate': '2025-03-01',
    'remainingDays': 15,
    'autoRenew': true,
  };

  // Mock learning statistics
  // final Map<String, dynamic> _learningStats = {
  //   'totalResourcesDownloaded': 24,
  //   'totalStudyTime': '45h 30m',
  //   'subjectsStudied': 8,
  //   'testsCompleted': 12,
  //   'averageScore': 78.5,
  // };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(),

            // Subscription Status Card
            _buildSubscriptionCard(),

            // Learning Statistics
            // _buildStatisticsSection(),

            // Account Information
            _buildAccountInfoSection(),

            // Quick Actions
            _buildQuickActionsSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Picture
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
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
                    _userData['profileImage'],
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
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 2),
                  ),
                  child: Icon(Icons.edit, color: primaryColor, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _userData['name'],
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userData['email'],
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_userData['grade']} • ${_userData['level']}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subscription Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      _subscriptionData['isActive']
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _subscriptionData['isActive'] ? 'ACTIVE' : 'EXPIRED',
                  style: GoogleFonts.poppins(
                    color:
                        _subscriptionData['isActive']
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.workspace_premium, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _subscriptionData['plan'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Remaining Time Progress
          _buildRemainingTimeProgress(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(_subscriptionData['startDate']),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expires',
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(_subscriptionData['endDate']),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                // Navigate to subscription page
                _manageSubscription();
              },
              child: Text(
                'Manage Subscription',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemainingTimeProgress() {
    final totalDays = _calculateTotalDays();
    final remainingDays = _subscriptionData['remainingDays'];
    final progress = remainingDays / totalDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Remaining Time',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            Text(
              '$remainingDays days left',
              style: GoogleFonts.poppins(
                color: primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress > 0.3 ? Colors.green.shade600 : Colors.orange.shade600,
          ),
          borderRadius: BorderRadius.circular(10),
          minHeight: 8,
        ),
      ],
    );
  }

  int _calculateTotalDays() {
    // Calculate total subscription days
    return 30; // For monthly plan
  }

  // Widget _buildStatisticsSection() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16),
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(20),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: const Offset(0, 4),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Text(
  //         //   'Learning Statistics',
  //         //   style: GoogleFonts.poppins(
  //         //     fontSize: 18,
  //         //     fontWeight: FontWeight.w600,
  //         //     color: Colors.black87,
  //         //   ),
  //         // ),
  //         // const SizedBox(height: 16),
  //         // GridView.count(
  //         //   shrinkWrap: true,
  //         //   physics: const NeverScrollableScrollPhysics(),
  //         //   crossAxisCount: 2,
  //         //   childAspectRatio: 1.8,
  //         //   crossAxisSpacing: 12,
  //         //   mainAxisSpacing: 12,
  //         //   children: [
  //         //     _buildStatCard(
  //         //       'Resources Downloaded',
  //         //       _learningStats['totalResourcesDownloaded'].toString(),
  //         //       Icons.download_outlined,
  //         //       Colors.blue.shade600,
  //         //     ),
  //         //     _buildStatCard(
  //         //       'Study Time',
  //         //       _learningStats['totalStudyTime'],
  //         //       Icons.access_time_outlined,
  //         //       Colors.green.shade600,
  //         //     ),
  //         //     _buildStatCard(
  //         //       'Subjects Studied',
  //         //       _learningStats['subjectsStudied'].toString(),
  //         //       Icons.menu_book_outlined,
  //         //       Colors.orange.shade600,
  //         //     ),
  //         //     _buildStatCard(
  //         //       'Average Score',
  //         //       '${_learningStats['averageScore']}%',
  //         //       Icons.bar_chart_outlined,
  //         //       Colors.purple.shade600,
  //         //     ),
  //       ],
  //     ),
  //     //   ],
  //     // ),
  //   );
  // }

  Widget _buildStatCard(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
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
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
            'Account Information',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Full Name', _userData['name']),
          _buildInfoRow(Icons.email_outlined, 'Email', _userData['email']),
          _buildInfoRow(Icons.phone_outlined, 'Phone', _userData['phone']),
          _buildInfoRow(
            Icons.school_outlined,
            'Education Level',
            '${_userData['grade']} - ${_userData['level']}',
          ),
          _buildInfoRow(
            Icons.location_on_outlined,
            'School',
            _userData['school'],
          ),
          _buildInfoRow(Icons.place_outlined, 'Region', _userData['region']),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Member Since',
            _formatDate(_userData['joinDate']),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
              color: Colors.black87,
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
                Colors.blue,
                _editProfile,
              ),
              _buildActionButton(
                'Change Password',
                Icons.lock_outlined,
                Colors.green,
                _changePassword,
              ),
              _buildActionButton(
                'Study Progress',
                Icons.analytics_outlined,
                Colors.orange,
                _viewProgress,
              ),
              _buildActionButton(
                'Help & Support',
                Icons.help_outline,
                Colors.purple,
                _helpSupport,
              ),
              _buildActionButton(
                'Settings',
                Icons.settings_outlined,
                Colors.grey,
                _openSettings,
              ),
              _buildActionButton('Logout', Icons.logout, Colors.red, _logout),
            ],
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

  String _formatDate(String dateString) {
    // Simple date formatting - you can use intl package for better formatting
    return dateString; // Replace with proper formatting
  }

  // Action Methods
  void _manageSubscription() {
    // Navigate to subscription management page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirecting to subscription management...'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pushNamed(context, "/payment");
  }

  void _editProfile() {
    // Navigate to edit profile page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening profile editor...'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _changePassword() {
    // Navigate to change password page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening password changer...'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _viewProgress() {
    // Navigate to progress page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening study progress...'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _helpSupport() {
    // Navigate to help & support
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening help & support...'),
        backgroundColor: Colors.purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSettings() {
    // Navigate to settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening settings...'),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _logout() {
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
                  Navigator.pushNamed(context, "/login");
                  // Implement logout logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
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
