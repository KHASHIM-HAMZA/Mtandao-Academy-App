import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mtandao_app/services/auth_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mtandao_app/screens/Authentication/profile_completion_page.dart';
import 'package:mtandao_app/screens/student/home_page.dart';
import 'package:mtandao_app/screens/teacher/TeacherDashboard.dart';

class Registerpage extends StatefulWidget {
  const Registerpage({super.key});

  @override
  State<Registerpage> createState() => _RegisterpageState();
}

class _RegisterpageState extends State<Registerpage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String role = 'Student';
  String? level;
  String? subLevel;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Text editing controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final phoneController = TextEditingController();
  final schoolController = TextEditingController();

  // New teacher-specific controllers
  final qualificationController = TextEditingController();
  final experienceController = TextEditingController();

  // Subjects management
  List<String> selectedSubjects = [];
  final TextEditingController _subjectController = TextEditingController();

  final AuthService _authService = AuthService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Dropdown data
  final List<String> levels = ['Primary', 'O-Level', 'A-Level'];
  final Map<String, List<String>> subLevels = {
    'Primary': [
      'Standard 1',
      'Standard 2',
      'Standard 3',
      'Standard 4',
      'Standard 5',
      'Standard 6',
      'Standard 7',
    ],
    'O-Level': ['Form 1', 'Form 2', 'Form 3', 'Form 4'],
    'A-Level': ['Form 5', 'Form 6'],
  };

  // Common subjects for teachers
  final List<String> commonSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Kiswahili',
    'History',
    'Geography',
    'Civics',
    'Computer Science',
    'Commerce',
    'Book Keeping',
    'Bible Knowledge',
    'Islamic Knowledge',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    phoneController.dispose();
    schoolController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _addSubject() {
    final subject = _subjectController.text.trim();
    if (subject.isNotEmpty && !selectedSubjects.contains(subject)) {
      setState(() {
        selectedSubjects.add(subject);
        _subjectController.clear();
      });
    }
  }

  void _removeSubject(String subject) {
    setState(() {
      selectedSubjects.remove(subject);
    });
  }

  void _selectCommonSubject(String subject) {
    if (!selectedSubjects.contains(subject)) {
      setState(() {
        selectedSubjects.add(subject);
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for teacher fields
    if (role == 'Teacher') {
      if (qualificationController.text.isEmpty) {
        _showErrorSnackBar('Please enter your qualification');
        return;
      }
      if (experienceController.text.isEmpty) {
        _showErrorSnackBar('Please enter your teaching experience');
        return;
      }
      if (selectedSubjects.isEmpty) {
        _showErrorSnackBar('Please add at least one subject you teach');
        return;
      }
    }

    setState(() => _isLoading = true);

    final Map<String, dynamic> body = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
      'role': role.toUpperCase(), // matches backend enum (STUDENT/TEACHER)
      'school': schoolController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      if (role == 'Student') ...{
        'level': level, // e.g. "O-Level" or "Primary"
        'sub_level': subLevel, // e.g. "Form 2" or "Standard 7"
      },
      if (role == 'Teacher') ...{
        'qualification': qualificationController.text.trim(),
        'experience': experienceController.text.trim(),
        'subjects': selectedSubjects,
      },
    };

    try {
      final success = await _authService.register(body);
      if (success && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'TEACHER') {
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
        _showErrorSnackBar('Registration failed, please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final success = await _authService.googleLogin(googleAuth.idToken!);

      if (success && mounted) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Google Sign-in successful!'),
            backgroundColor: Colors.green,
          ),
        );

        if (role == 'TEACHER') {
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
        _showErrorSnackBar('Google Sign-in failed.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section - Matching Login Page
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Animated decorative elements
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1000),
                    top: 40,
                    right: 40,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 1200),
                    bottom: 50,
                    left: 30,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  Positioned(
                    top: 70,
                    child: Column(
                      children: [
                        Image.asset('assets/logo.png', height: 80),
                        const SizedBox(height: 10),
                        const Text(
                          'Mtandao Academy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Create Your Account',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form Section with Animations
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role Selection
                            const Text(
                              'Register as:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ToggleButtons(
                                borderRadius: BorderRadius.circular(12),
                                isSelected: [
                                  role == 'Student',
                                  role == 'Teacher',
                                ],
                                onPressed: (index) {
                                  setState(() {
                                    role = index == 0 ? 'Student' : 'Teacher';
                                    level = null;
                                    subLevel = null;
                                    selectedSubjects.clear();
                                  });
                                },
                                selectedColor: Colors.white,
                                fillColor: primaryColor,
                                color: Colors.black87,
                                constraints: const BoxConstraints(
                                  minHeight: 45,
                                  minWidth: 100,
                                ),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    child: Text(
                                      'Student',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 25,
                                    ),
                                    child: Text(
                                      'Teacher',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // Name Field
                            _buildTextField(
                              'Full Name',
                              nameController,
                              Icons.person_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            _buildTextField(
                              'Email Address',
                              emailController,
                              Icons.email_outlined,
                              keyboard: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(val)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Phone Field
                            _buildTextField(
                              'Phone Number',
                              phoneController,
                              Icons.phone_outlined,
                              keyboard: TextInputType.phone,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // School Field
                            _buildTextField(
                              'School',
                              schoolController,
                              Icons.school_outlined,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter your school';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Teacher-specific fields
                            if (role == 'Teacher') ...[
                              _buildTextField(
                                'Qualification',
                                qualificationController,
                                Icons.school_outlined,
                                hintText: 'e.g., B.Ed Mathematics, MSc Physics',
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your qualification';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              _buildTextField(
                                'Teaching Experience',
                                experienceController,
                                Icons.work_outline,
                                hintText: 'e.g., 5 years',
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your teaching experience';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Subjects Section
                              const Text(
                                'Subjects You Teach',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add subjects you are qualified to teach:',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Add subject input
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _subjectController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter subject name',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 12,
                                            ),
                                      ),
                                      onFieldSubmitted: (_) => _addSubject(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: _addSubject,
                                      icon: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Common subjects quick selection
                              SizedBox(
                                height: 40,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      commonSubjects.map((subject) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: FilterChip(
                                            label: Text(subject),
                                            selected: selectedSubjects.contains(
                                              subject,
                                            ),
                                            onSelected: (selected) {
                                              if (selected) {
                                                _selectCommonSubject(subject);
                                              } else {
                                                _removeSubject(subject);
                                              }
                                            },
                                            backgroundColor: Colors.grey[200],
                                            selectedColor: primaryColor
                                                .withOpacity(0.2),
                                            labelStyle: TextStyle(
                                              color:
                                                  selectedSubjects.contains(
                                                        subject,
                                                      )
                                                      ? primaryColor
                                                      : Colors.black87,
                                              fontWeight:
                                                  selectedSubjects.contains(
                                                        subject,
                                                      )
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Selected subjects display
                              if (selectedSubjects.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      selectedSubjects.map((subject) {
                                        return Chip(
                                          label: Text(subject),
                                          backgroundColor: primaryColor
                                              .withOpacity(0.1),
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                          onDeleted:
                                              () => _removeSubject(subject),
                                        );
                                      }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No subjects added yet. Add subjects you teach.',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ],

                            // Password Field
                            _buildPasswordField(
                              'Password',
                              passwordController,
                              _obscurePassword,
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please enter password';
                                }
                                if (val.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm Password Field
                            _buildPasswordField(
                              'Confirm Password',
                              confirmController,
                              _obscureConfirmPassword,
                              () => setState(
                                () =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (val != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Education Level (Student only)
                            if (role == 'Student') ...[
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Education Level',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      value: level,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 5,
                                            ),
                                      ),
                                      hint: const Text('Select level'),
                                      items:
                                          levels
                                              .map(
                                                (lvl) => DropdownMenuItem(
                                                  value: lvl,
                                                  child: Text(lvl),
                                                ),
                                              )
                                              .toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          level = val;
                                          subLevel = null;
                                        });
                                      },
                                      validator:
                                          (val) =>
                                              val == null
                                                  ? 'Please select education level'
                                                  : null,
                                    ),
                                    const SizedBox(height: 15),
                                    if (level != null)
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        opacity: level != null ? 1.0 : 0.0,
                                        child: DropdownButtonFormField<String>(
                                          value: subLevel,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 15,
                                                  vertical: 5,
                                                ),
                                          ),
                                          hint: const Text('Select class/form'),
                                          items:
                                              subLevels[level]!
                                                  .map(
                                                    (s) => DropdownMenuItem(
                                                      value: s,
                                                      child: Text(s),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged:
                                              (val) => setState(
                                                () => subLevel = val,
                                              ),
                                          validator:
                                              (val) =>
                                                  val == null
                                                      ? 'Please select class/form'
                                                      : null,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Register Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: _isLoading ? 10 : 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _register,
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                          : Text(
                                            'Create ${role} Account',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // OR Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[400]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[400]),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Google Sign-Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[400]!),
                                  ),
                                  onPressed:
                                      _isLoading ? null : _signUpWithGoogle,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/search.png',
                                        height: 20,
                                        width: 20,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.account_circle,
                                                  size: 20,
                                                ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Sign up with Google',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Login Prompt
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    text: 'Already have an account? ',
                                    style: TextStyle(color: Colors.grey),
                                    children: [
                                      TextSpan(
                                        text: 'Log In',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            27,
                                            88,
                                            138,
                                          ),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback onToggle, {
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}
