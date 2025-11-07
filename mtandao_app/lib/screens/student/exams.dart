import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/student/examination/SchemePage.dart';
import 'package:mtandao_app/screens/student/examination/correction_page.dart';
import 'package:mtandao_app/screens/student/examination/tests/online_tests.dart';
import 'package:mtandao_app/screens/student/examination/past_papers.dart';
import 'package:mtandao_app/screens/student/resources_page.dart';

class Exams extends StatefulWidget {
  const Exams({super.key});

  @override
  State<Exams> createState() => _ExamsState();
}

class _ExamsState extends State<Exams> {
  //list of instance category
  List<Category> categories = [
    Category(
      nametitle: "Online Tests",
      icon: Icons.assignment,
      page: OnlineTestsPage(),
    ),
    Category(
      nametitle: "Past Papers",
      icon: Icons.library_books,
      page: PastPapers(),
    ),
    Category(
      nametitle: "Corrections",
      icon: Icons.assignment_turned_in_sharp,
      page: CorrectionPage(),
    ),
    Category(
      nametitle: "Scheme",
      icon: Icons.align_horizontal_left_outlined,
      page: Schemepage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 12,
        title: Text(
          "Examinations",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 27, 88, 138),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return TweenAnimationBuilder<double>(
            duration: Duration(microseconds: 500 + index * 200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 50 * (1 - value)), // Slide up effect
                  child: child,
                ),
              );
            },
            child: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                visualDensity: const VisualDensity(vertical: 4),
                leading: Hero(
                  tag: 'icon_${category.nametitle}',
                  child: Icon(category.icon),
                ),
                title: Text(category.nametitle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => category.page),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

//custom class of categories
class Category {
  final String nametitle;
  final IconData icon;
  final Widget page;

  Category({required this.nametitle, required this.icon, required this.page});
}
