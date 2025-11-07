import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final phoneController = TextEditingController();
  final schoolController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // dropdown data
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
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Prepare registration data
        final Map<String, dynamic> registrationData = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'password': passwordController.text,
          'userType': role.toLowerCase(),
          'phoneNumber': phoneController.text.trim(),
          'school': schoolController.text.trim(),
        };

        // Add education level for students
        if (role == 'Student') {
          registrationData['level'] = subLevel ?? level;
        }

        final response = await http.post(
          Uri.parse('https://your-api-domain.com/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(registrationData),
        );

        if (response.statusCode == 201) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          await _handleRegistrationSuccess(responseData);
        } else if (response.statusCode == 409) {
          _handleRegistrationError(
            'Email already exists. Please login instead.',
          );
        } else {
          _handleRegistrationError('Registration failed. Please try again.');
        }
      } catch (error) {
        print('Registration error: $error');
        _handleRegistrationError(
          'Network error. Please check your connection.',
        );
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get Google user data
      final Map<String, dynamic> googleUserData = {
        'email': googleUser.email,
        'name': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
        'googleId': googleUser.id,
      };

      // Send Google token to your backend
      final response = await http.post(
        Uri.parse('https://your-api-domain.com/api/auth/google-register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': googleAuth.idToken,
          'userType': role.toLowerCase(),
          'googleUserData': googleUserData,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        await _handleGoogleRegistrationSuccess(responseData);
      } else {
        _handleRegistrationError('Google Sign-Up failed. Please try again.');
      }
    } catch (error) {
      print('Google Sign-Up error: $error');
      _handleRegistrationError('Google Sign-Up failed. Please try again.');
    }
  }

  Future<void> _handleRegistrationSuccess(
    Map<String, dynamic> responseData,
  ) async {
    // Save user data to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', responseData['token']);
    await prefs.setString('userType', responseData['user']['userType']);
    await prefs.setString('userId', responseData['user']['id']);
    await prefs.setString('email', responseData['user']['email']);
    await prefs.setString('name', responseData['user']['name']);
    await prefs.setBool(
      'profileCompleted',
      responseData['user']['profileCompleted'] ?? true,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Navigate to dashboard
      _navigateToDashboard(responseData['user']['userType']);
    }
  }

  Future<void> _handleGoogleRegistrationSuccess(
    Map<String, dynamic> responseData,
  ) async {
    // Save user data to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', responseData['token']);
    await prefs.setString('userType', responseData['user']['userType']);
    await prefs.setString('userId', responseData['user']['id']);
    await prefs.setString('email', responseData['user']['email']);
    await prefs.setString('name', responseData['user']['name']);
    await prefs.setBool(
      'profileCompleted',
      responseData['user']['profileCompleted'] ?? false,
    );
    await prefs.setBool('isGoogleUser', true);

    if (mounted) {
      setState(() => _isLoading = false);

      // Check if profile needs completion
      if (responseData['user']['profileCompleted'] == true) {
        _navigateToDashboard(responseData['user']['userType']);
      } else {
        // Redirect to profile completion page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileCompletionPage()),
        );
      }
    }
  }

  void _handleRegistrationError(String message) {
    if (mounted) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(message);
    }
  }

  void _navigateToDashboard(String userType) {
    if (userType.toLowerCase() == 'teacher') {
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
                                          : const Text(
                                            'Create Account',
                                            style: TextStyle(
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
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
