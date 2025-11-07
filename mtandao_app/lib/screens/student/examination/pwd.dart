// driving_lessons_page.dart
import 'package:flutter/material.dart';

// Data model remains the same
class LessonLevel {
  final String name;
  final IconData icon;
  final Widget page;
  final Color color; // Added for level-specific color

  LessonLevel({
    required this.name,
    required this.icon,
    required this.page,
    required this.color,
  });
}

// Main page, now Stateful for animations
class DrivingLessonsPage extends StatefulWidget {
  DrivingLessonsPage({super.key});

  @override
  State<DrivingLessonsPage> createState() => _DrivingLessonsPageState();
}

class _DrivingLessonsPageState extends State<DrivingLessonsPage> {
  // List of levels with colors
  final List<LessonLevel> levels = [
    LessonLevel(
      name: 'Beginner Level',
      icon: Icons.school,
      page: const BeginnerPage(),
      color: Colors.green,
    ),
    LessonLevel(
      name: 'Intermediate Level',
      icon: Icons.directions_car,
      page: const IntermediatePage(),
      color: Colors.orange,
    ),
    LessonLevel(
      name: 'Advanced Level',
      icon: Icons.star,
      page: const AdvancedPage(),
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Step 1: SliverAppBar for dynamic header
          SliverAppBar(
            expandedHeight: 200.0, // Expandable height
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Driving Lessons'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.drive_eta, size: 100, color: Colors.white),
                ),
              ),
            ),
          ),
          // Step 4: Padding for spacing
          const SliverPadding(padding: EdgeInsets.all(8.0)),
          // Step 2: SliverList with animated items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = levels[index];
                // Staggered animation: delay based on index
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 500 + index * 200),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Hero(
                        tag: 'icon_${level.name}', // Unique tag for Hero animation
                        child: Icon(level.icon, color: level.color, size: 40),
                      ),
                      title: Text(level.name, style: TextStyle(color: level.color, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => level.page),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: levels.length,
            ),
          ),
        ],
      ),
    );
  }
}

// Updated target pages with matching Hero for transitions
class BeginnerPage extends StatelessWidget {
  const BeginnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beginner Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon_Beginner Level',
              child: const Icon(Icons.school, size: 100, color: Colors.green),
            ),
            const Text('Content for beginners: basics of driving.'),
          ],
        ),
      ),
    );
  }
}

class IntermediatePage extends StatelessWidget {
  const IntermediatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Intermediate Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon_Intermediate Level',
              child: const Icon(Icons.directions_car, size: 100, color: Colors.orange),
            ),
            const Text('Content for intermediate: highway rules.'),
          ],
        ),
      ),
    );
  }
}

class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Level')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'icon_Advanced Level',
              child: const Icon(Icons.star, size: 100, color: Colors.red),
            ),
            const Text('Content for advanced: defensive driving.'),
          ],
        ),
      ),
    );
  }
}