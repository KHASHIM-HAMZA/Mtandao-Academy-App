import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/screens/teacher/online_test/classroom_detail.dart';

class ClassroomManagementPage extends StatefulWidget {
  const ClassroomManagementPage({super.key});

  @override
  State<ClassroomManagementPage> createState() =>
      _ClassroomManagementPageState();
}

class _ClassroomManagementPageState extends State<ClassroomManagementPage> {
  final List<Classroom> _classrooms = [
    Classroom(
      id: '1',
      name: 'Form 4A Mathematics',
      subject: 'Mathematics',
      level: 'O-Level',
      joinKey: 'MATH4A2024',
      studentCount: 25,
      createdDate: '2024-01-15',
    ),
    Classroom(
      id: '2',
      name: 'Form 3 Physics',
      subject: 'Physics',
      level: 'O-Level',
      joinKey: 'PHYS32024',
      studentCount: 18,
      createdDate: '2024-01-20',
    ),
    Classroom(
      id: '3',
      name: 'Form 2 Science',
      subject: 'Science',
      level: 'O-Level',
      joinKey: 'SCI22024',
      studentCount: 12,
      createdDate: '2024-02-01',
    ),
  ];

  void _createNewClassroom() {
    showDialog(
      context: context,
      builder:
          (context) => CreateClassroomDialog(
            onCreate: (classroom) {
              setState(() {
                _classrooms.add(classroom);
              });
            },
          ),
    );
  }

  void _viewClassroomDetails(Classroom classroom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassroomDetailsPage(classroom: classroom),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Classrooms',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Classroom'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _createNewClassroom,
                ),
              ],
            ),
          ),

          // Classrooms List
          Expanded(
            child:
                _classrooms.isEmpty
                    ? const Center(child: Text('No classrooms created yet'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _classrooms.length,
                      itemBuilder: (context, index) {
                        final classroom = _classrooms[index];
                        return ClassroomCard(
                          classroom: classroom,
                          onTap: () => _viewClassroomDetails(classroom),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class Classroom {
  final String id;
  final String name;
  final String subject;
  final String level;
  final String joinKey;
  final int studentCount;
  final String createdDate;

  Classroom({
    required this.id,
    required this.name,
    required this.subject,
    required this.level,
    required this.joinKey,
    required this.studentCount,
    required this.createdDate,
  });
}

class ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final VoidCallback onTap;

  const ClassroomCard({
    super.key,
    required this.classroom,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.groups, color: Colors.blue.shade600),
        ),
        title: Text(
          classroom.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Subject: ${classroom.subject} • ${classroom.level}'),
            const SizedBox(height: 4),
            Text('Students: ${classroom.studentCount}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.vpn_key, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Join Key: ${classroom.joinKey}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class CreateClassroomDialog extends StatefulWidget {
  final Function(Classroom) onCreate;

  const CreateClassroomDialog({super.key, required this.onCreate});

  @override
  State<CreateClassroomDialog> createState() => _CreateClassroomDialogState();
}

class _CreateClassroomDialogState extends State<CreateClassroomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  String _selectedLevel = 'O-Level';
  String _joinKey = '';

  @override
  void initState() {
    super.initState();
    _generateJoinKey();
  }

  void _generateJoinKey() {
    // Generate a random join key
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _joinKey = 'CLASS${random.substring(random.length - 6)}';
    });
  }

  void _createClassroom() {
    if (_formKey.currentState!.validate()) {
      final classroom = Classroom(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        subject: _subjectController.text,
        level: _selectedLevel,
        joinKey: _joinKey,
        studentCount: 0,
        createdDate: DateTime.now().toIso8601String(),
      );

      widget.onCreate(classroom);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Classroom',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Classroom Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter classroom name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Education Level',
                  border: OutlineInputBorder(),
                ),
                items:
                    ['Primary', 'O-Level', 'A-Level']
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                initialValue: _joinKey,
                decoration: InputDecoration(
                  labelText: 'Join Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _generateJoinKey,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                      ),
                      onPressed: _createClassroom,
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
