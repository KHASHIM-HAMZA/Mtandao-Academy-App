import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/teacher/online_test/classroom_management.dart';

class ClassroomDetailsPage extends StatefulWidget {
  final Classroom classroom;

  const ClassroomDetailsPage({super.key, required this.classroom});

  @override
  State<ClassroomDetailsPage> createState() => _ClassroomDetailsPageState();
}

class _ClassroomDetailsPageState extends State<ClassroomDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  // Mock data for the classroom
  final List<Student> _students = [
    Student(
      id: '1',
      name: 'John Doe',
      email: 'john@student.com',
      joinDate: '2024-01-15',
    ),
    Student(
      id: '2',
      name: 'Jane Smith',
      email: 'jane@student.com',
      joinDate: '2024-01-16',
    ),
    Student(
      id: '3',
      name: 'Mike Johnson',
      email: 'mike@student.com',
      joinDate: '2024-01-20',
    ),
  ];

  final List<ClassroomResource> _resources = [
    ClassroomResource(
      id: '1',
      title: 'Mathematics Chapter 1 Notes',
      type: 'pdf',
      uploadDate: '2024-01-18',
    ),
    ClassroomResource(
      id: '2',
      title: 'Algebra Practice Problems',
      type: 'pdf',
      uploadDate: '2024-01-22',
    ),
    ClassroomResource(
      id: '3',
      title: 'Geometry Video Tutorial',
      type: 'video',
      uploadDate: '2024-01-25',
    ),
  ];

  final List<ClassroomQuiz> _quizzes = [
    ClassroomQuiz(
      id: '1',
      title: 'Algebra Basics Quiz',
      dueDate: '2024-02-01',
      totalQuestions: 10,
    ),
    ClassroomQuiz(
      id: '2',
      title: 'Geometry Test',
      dueDate: '2024-02-08',
      totalQuestions: 15,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _shareJoinKey() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Classroom Join Key'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share this key with your students:',
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.classroom.joinKey,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // Copy to clipboard
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Join key copied to clipboard!'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Students can use this key to join your classroom from their app.',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _addStudent() {
    // Implement add student functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add student functionality coming soon!')),
    );
  }

  void _uploadResource() {
    // Navigate to resource upload page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to resource upload')),
    );
  }

  void _createQuiz() {
    // Navigate to quiz creation page
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Navigate to quiz creation')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareJoinKey,
            tooltip: 'Share Join Key',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Students'),
            Tab(text: 'Resources'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudentsTab(),
          _buildResourcesTab(),
          _buildQuizzesTab(),
        ],
      ),
    );
  }

  Widget _buildStudentsTab() {
    return Column(
      children: [
        // Header with student count and add button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Students (${_students.length})',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Add Student'),
                onPressed: _addStudent,
              ),
            ],
          ),
        ),

        // Students List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _students.length,
            itemBuilder: (context, index) {
              final student = _students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Icon(Icons.person, color: primaryColor),
                  ),
                  title: Text(
                    student.name,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(student.email),
                  trailing: Text(
                    'Joined ${student.joinDate}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesTab() {
    return Column(
      children: [
        // Header with upload button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resources (${_resources.length})',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload, size: 18),
                label: const Text('Upload Resource'),
                onPressed: _uploadResource,
              ),
            ],
          ),
        ),

        // Resources List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _resources.length,
            itemBuilder: (context, index) {
              final resource = _resources[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getResourceColor(resource.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getResourceIcon(resource.type),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    resource.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${resource.type.toUpperCase()} • ${resource.uploadDate}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      // Download resource
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuizzesTab() {
    return Column(
      children: [
        // Header with create quiz button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quizzes (${_quizzes.length})',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Quiz'),
                onPressed: _createQuiz,
              ),
            ],
          ),
        ),

        // Quizzes List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _quizzes.length,
            itemBuilder: (context, index) {
              final quiz = _quizzes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.quiz, color: Colors.orange.shade600),
                  ),
                  title: Text(
                    quiz.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Due: ${quiz.dueDate} • ${quiz.totalQuestions} questions',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // View quiz details
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getResourceColor(String type) {
    switch (type) {
      case 'pdf':
        return Colors.red.shade600;
      case 'video':
        return Colors.blue.shade600;
      case 'image':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getResourceIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.videocam;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// Supporting data classes
class Student {
  final String id;
  final String name;
  final String email;
  final String joinDate;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
  });
}

class ClassroomResource {
  final String id;
  final String title;
  final String type;
  final String uploadDate;

  ClassroomResource({
    required this.id,
    required this.title,
    required this.type,
    required this.uploadDate,
  });
}

class ClassroomQuiz {
  final String id;
  final String title;
  final String dueDate;
  final int totalQuestions;

  ClassroomQuiz({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.totalQuestions,
  });
}
