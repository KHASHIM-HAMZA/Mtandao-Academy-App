import 'package:flutter/material.dart';
import 'package:mtandao_app/screens/Authentication/register_page.dart';
import 'package:mtandao_app/screens/Authentication/profile_completion_page.dart';
import 'package:mtandao_app/screens/student/home_page.dart';
import 'package:mtandao_app/screens/teacher/TeacherDashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mtandao_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
  bool _isLoading = false;
  bool _obscurePassword = true;
  String userType = 'Student'; // 'Student' or 'Teacher'

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // serverClientId: 'YOUR_SERVER_CLIENT_ID', // Add this for production
  );

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

    // Check if user is already logged in
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      final String? savedUserType = prefs.getString('userType');
      final bool profileCompleted = prefs.getBool('profileCompleted') ?? false;

      if (token != null && savedUserType != null && profileCompleted) {
        // Verify token is still valid with API
        final bool isValid = await _verifyToken(token);
        if (isValid && mounted) {
          _navigateToDashboard(savedUserType);
        } else {
          // Token is invalid, clear stored data
          await prefs.clear();
        }
      } else if (token != null && !profileCompleted) {
        // User needs to complete profile
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfileCompletionPage()),
          );
        }
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<bool> _verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://your-api-domain.com/api/auth/verify-token'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // cancelled
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

      print('Google User Data: $googleUserData');

      // Send Google token to your backend
      final response = await http.post(
        Uri.parse('https://your-api-domain.com/api/auth/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': googleAuth.idToken,
          'userType': userType.toLowerCase(),
          'googleUserData': googleUserData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        await _handleLoginSuccess(responseData);
      } else if (response.statusCode == 201) {
        // New user created - needs profile completion
        final Map<String, dynamic> responseData = json.decode(response.body);
        await _handleNewGoogleUser(responseData);
      } else {
        _handleLoginError('Google Sign-In failed. Please try again.');
      }
    } catch (error) {
      print('Google Sign-In error: $error');
      _handleLoginError('Google Sign-In failed. Please try again.');
    }
  }

  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final success = await _authService.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('role');
        final email = prefs.getString('email') ?? '';
        final name = prefs.getString('name') ?? '';

        // Validate user type selection matches actual role
        final bool isTeacherSelected = userType == 'Teacher';
        final bool isActualTeacher = role == 'TEACHER';
        final bool isActualStudent = role == 'STUDENT';

        // Role validation
        if ((isTeacherSelected && !isActualTeacher) ||
            (!isTeacherSelected && !isActualStudent)) {
          // Show detailed error dialog
          await _showRoleMismatchDialog(
            selectedType: userType,
            actualType: isActualTeacher ? 'Teacher' : 'Student',
            email: email,
            name: name,
          );

          // Clear the invalid login data
          await _authService.logout();
          return;
        }

        // Successful login with correct role
        _showSuccessSnackBar('Welcome back, $name!');

        // Navigate based on role
        if (isActualTeacher) {
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
        _showErrorSnackBar('Invalid credentials or user not found.');
      }
    } catch (e) {
      _showErrorSnackBar(
        'Login error: Please check your connection and try again.',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show role mismatch dialog
  Future<void> _showRoleMismatchDialog({
    required String selectedType,
    required String actualType,
    required String email,
    required String name,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Account Type Mismatch'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You selected "$selectedType" but your account "$email" is registered as a "$actualType".',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 12),
                Text('Please:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('• Go back to login'),
                Text('• Select "$actualType" as your user type'),
                Text('• Login again with your credentials'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Clear form
                  passwordController.clear();
                  // Auto-select correct user type
                  setState(() {
                    userType = actualType;
                  });
                },
                child: Text('OK, I\'LL FIX IT'),
              ),
            ],
          ),
    );
  }

  // Add success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool _validateForm() {
    if (emailController.text.isEmpty) {
      _showErrorSnackBar('Please enter your email');
      return false;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(emailController.text)) {
      _showErrorSnackBar('Please enter a valid email');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showErrorSnackBar('Please enter your password');
      return false;
    }

    if (passwordController.text.length < 6) {
      _showErrorSnackBar('Password must be at least 6 characters');
      return false;
    }

    return true;
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> responseData) async {
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
      _navigateToDashboard(responseData['user']['userType']);
    }
  }

  Future<void> _handleNewGoogleUser(Map<String, dynamic> responseData) async {
    // Save basic user data to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', responseData['token']);
    await prefs.setString('userType', responseData['user']['userType']);
    await prefs.setString('userId', responseData['user']['id']);
    await prefs.setString('email', responseData['user']['email']);
    await prefs.setString('name', responseData['user']['name']);
    await prefs.setBool('profileCompleted', false);
    await prefs.setBool('isGoogleUser', true);

    if (mounted) {
      setState(() => _isLoading = false);
      // Redirect to profile completion page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ProfileCompletionPage()),
      );
    }
  }

  void _handleLoginError(String message) {
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

  void _forgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Reset Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter your email to receive a password reset link for your $userType account:',
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    // Implement actual password reset API call here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password reset link sent to your $userType email!',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Send Link',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
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
            // Header Section - Matching Register Page
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
                          'Login to Continue',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Type Selection
                          const Text(
                            'Login as:',
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
                                userType == 'Student',
                                userType == 'Teacher',
                              ],
                              onPressed: (index) {
                                setState(() {
                                  userType = index == 0 ? 'Student' : 'Teacher';
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
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  child: Text(
                                    'Student',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
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

                          // Email Field
                          const Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'example@gmail.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Password Field
                          const Text(
                            'Password',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              hintText: '********',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Forgot Password & Create Account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => _forgotPasswordDialog(context),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Registerpage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Create an account',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Sign In Button
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
                                onPressed: _isLoading ? null : _login,
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                        : Text(
                                          'Sign in as $userType',
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
                              Expanded(child: Divider(color: Colors.grey[400])),
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
                              Expanded(child: Divider(color: Colors.grey[400])),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Google Sign-In Button
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
                                    _isLoading ? null : _signInWithGoogle,
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
                                    Text(
                                      'Sign in with Google',
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

                          const SizedBox(height: 30),
                        ],
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
}
