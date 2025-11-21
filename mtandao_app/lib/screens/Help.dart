import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Frequently Asked Questions"),
            _buildFAQ(),

            const SizedBox(height: 20),
            _buildSectionTitle("Contact Support"),
            _buildContactButtons(),

            const SizedBox(height: 20),
            _buildSectionTitle("Report a Problem"),
            _buildReportProblemCard(context),

            const SizedBox(height: 20),
            _buildSectionTitle("How to Use the App"),
            _buildTutorialCards(),

            const SizedBox(height: 20),
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    );
  }

  // ----------- FAQ SECTION ----------
  Widget _buildFAQ() {
    return Column(
      children: [
        _faqTile(
          "How do I download resources?",
          "Open the Resources page → choose a subject → tap the download icon.",
        ),

        _faqTile(
          "How to view past papers?",
          "Go to Past Papers page → select your level → choose year & subject.",
        ),

        _faqTile(
          "Why can’t I access some materials?",
          "Some materials require an active subscription. Check your profile subscription status.",
        ),

        _faqTile(
          "How do I update my profile?",
          "Go to Profile → Quick Actions → Edit Profile.",
        ),
      ],
    );
  }

  Widget _faqTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: GoogleFonts.poppins(fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            answer,
            style: GoogleFonts.poppins(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  // ----------- CONTACT SUPPORT ----------
  Widget _buildContactButtons() {
    return Column(
      children: [
        _contactButton(
          Icons.email_outlined,
          "Email Support",
          "support@mtandao.academy",
          () {
            launchUrl(Uri.parse("mailto:support@mtandao.academy"));
          },
        ),

        const SizedBox(height: 10),
        _contactButton(
          FontAwesomeIcons.whatsapp,
          "WhatsApp Support",
          "+255 789 456 123",
          () {
            launchUrl(Uri.parse("https://wa.me/255789456123"));
          },
        ),

        const SizedBox(height: 10),
        _contactButton(Icons.call_outlined, "Call Us", "+255 714 123 555", () {
          launchUrl(Uri.parse("tel:+255714123555"));
        }),
      ],
    );
  }

  Widget _contactButton(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------- REPORT PROBLEM ----------
  Widget _buildReportProblemCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, "/report"),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.bug_report_outlined, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Report a bug or issue",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.red[800],
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  // ----------- TUTORIAL SECTION ----------
  Widget _buildTutorialCards() {
    return Column(
      children: [
        _tutorialCard(
          Icons.play_circle_outline,
          "How to use Resources",
          "Learn how to browse & download books, notes, and pastpapers",
        ),

        const SizedBox(height: 12),
        _tutorialCard(
          Icons.video_library_outlined,
          "How to view corrections",
          "Understanding video & PDF solutions for past papers",
        ),

        const SizedBox(height: 12),
        _tutorialCard(
          Icons.school_outlined,
          "How to take tests",
          "Tutorial on taking online tests in the app",
        ),
      ],
    );
  }

  Widget _tutorialCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------- APP INFO ----------
  Widget _buildAppInfo() {
    return Center(
      child: Text(
        "Mtandao Academy • Version 1.0.0",
        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
      ),
    );
  }
}
