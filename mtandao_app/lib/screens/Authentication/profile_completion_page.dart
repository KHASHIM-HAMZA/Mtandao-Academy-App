import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mtandao_app/screens/student/home_page.dart';
import 'package:mtandao_app/screens/teacher/TeacherDashboard.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({super.key});

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Additional user data fields
  String? _selectedSchool;
  String? _selectedLevel;
  String? _selectedSubject;
  String? _phoneNumber;

  // Lists for dropdowns
  final List<String> _schools = [
    'University of Dar es Salaam',
    'University of Dodoma',
    'Nelson Mandela African Institution of Science and Technology',
    'Ardhi University',
    'Moshi Cooperative University',
    'Institute of Accountancy Arusha',
    'Other',
  ];

  final List<String> _studentLevels = [
    'Form 1',
    'Form 2',
    'Form 3',
    'Form 4',
    'Form 5',
    'Form 6',
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
    'Masters',
    'PhD',
  ];

  final List<String> _teacherSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Kiswahili',
    'History',
    'Geography',
    'Computer Science',
    'Commerce',
    'Book Keeping',
    'Accountancy',
    'Economics',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: const Color.fromARGB(255, 27, 88, 138),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Almost there! Please provide some additional information to complete your profile.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // School/Institution
              const Text(
                'School/Institution *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSchool,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Select your school',
                ),
                items:
                    _schools.map((String school) {
                      return DropdownMenuItem<String>(
                        value: school,
                        child: Text(school),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSchool = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your school';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Level/Subject based on user type
              FutureBuilder<String>(
                future: _getUserType(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final userType = snapshot.data!;

                    if (userType == 'student') {
                      return _buildStudentLevelField();
                    } else {
                      return _buildTeacherSubjectField();
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),

              const SizedBox(height: 20),

              // Phone Number
              const Text(
                'Phone Number',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: '+255 XXX XXX XXX',
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => _phoneNumber = value,
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 88, 138),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _completeProfile,
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                          : const Text(
                            'Complete Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentLevelField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Level *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedLevel,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Select your level',
          ),
          items:
              _studentLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedLevel = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your level';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTeacherSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Primary Subject *',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedSubject,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            hintText: 'Select your subject',
          ),
          items:
              _teacherSubjects.map((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedSubject = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select your subject';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<String> _getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType') ?? 'student';
  }

  Future<void> _completeProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');
        final String? userId = prefs.getString('userId');
        final String userType = prefs.getString('userType') ?? 'student';

        // Prepare profile data
        final Map<String, dynamic> profileData = {
          'school': _selectedSchool,
          'phoneNumber': _phoneNumber,
          'profileCompleted': true,
        };

        // Add type-specific data
        if (userType == 'student') {
          profileData['level'] = _selectedLevel;
        } else {
          profileData['subject'] = _selectedSubject;
        }

        final response = await http.put(
          Uri.parse('https://your-api-domain.com/api/users/$userId/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(profileData),
        );

        if (response.statusCode == 200) {
          // Update local storage
          await prefs.setBool('profileCompleted', true);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to appropriate dashboard
          if (userType == 'teacher') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const TeacherDashboard()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } else {
          _showError('Failed to update profile. Please try again.');
        }
      } catch (error) {
        print('Profile completion error: $error');
        _showError('Network error. Please check your connection.');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
