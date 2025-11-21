import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';
import 'package:mtandao_app/screens/teacher/Correction_upload.dart'; // Import the new correction page

class UploadPastPaperPage extends StatefulWidget {
  const UploadPastPaperPage({super.key});

  @override
  State<UploadPastPaperPage> createState() => _UploadPastPaperPageState();
}

class _UploadPastPaperPageState extends State<UploadPastPaperPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  String? _selectedSubject;
  String? _selectedLevel;
  String? _selectedType; // Past Paper or Correction
  File? _selectedFile;
  bool _isLoading = false;
  String? _selectedSubLevel;

  List<String> teacherSubjects = [];

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
  final levels = ['primary', 'olevel', 'alevel'];
  final Map<String, List<String>> subLevels = {
    'primary': [
      'Standard 1',
      'Standard 2',
      'Standard 3',
      'Standard 4',
      'Standard 5',
      'Standard 6',
      'Standard 7',
    ],
    'olevel': ['Form 1', 'Form 2', 'Form 3', 'Form 4'],
    'alevel': ['Form 5', 'Form 6'],
  };
  final types = ['Past Paper', 'Correction'];

  @override
  void initState() {
    super.initState();
    _loadTeacherSubjects();
  }

  Future<void> _loadTeacherSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsString = prefs.getString('subjects');
    if (subjectsString != null && subjectsString.isNotEmpty) {
      setState(() {
        teacherSubjects = List<String>.from(json.decode(subjectsString));
        if (teacherSubjects.isNotEmpty) {
          _selectedSubject = teacherSubjects[0];
        }
      });
    }
  }

  // NEW: Navigate to correction upload page
  void _navigateToCorrectionUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadCorrectionPage()),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _selectedFile = File(result.files.single.path!));
      }
    } catch (e) {
      _showErrorDialog('File selection failed: $e');
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    if (_selectedFile == null) {
      _showErrorDialog('Please select a file to upload');
      return;
    }

    if (_selectedSubLevel == null) {
      _showErrorDialog('Please select sub level');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final teacherName = prefs.getString('name') ?? 'Unknown Teacher';

      final Map<String, String> fields = {
        'title': _titleController.text.trim(),
        'subject': _selectedSubject!,
        'educationLevel': _selectedLevel!,
        'sublevel': _selectedSubLevel!,
        'year': _yearController.text.trim(),
        'uploadedBy': teacherName,
      };

      final provider = Provider.of<PastPaperProvider>(context, listen: false);

      final success = await provider.uploadPastPaper(
        fields,
        _selectedFile!.path,
      );

      if (success) {
        _showSuccessDialog();
        _resetForm();
      } else {
        _showErrorDialog('Upload failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Upload failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Upload Successful!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your past paper has been uploaded successfully!\n\nStudents can now access this material.',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(color: primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Upload Failed',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
            content: Text(
              message,
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(color: primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  void _resetForm() {
    _titleController.clear();
    _yearController.clear();
    setState(() {
      _selectedFile = null;
      _selectedType = null;
      _selectedSubject = teacherSubjects.isNotEmpty ? teacherSubjects[0] : null;
    });
  }

  String _getFileSize() {
    if (_selectedFile == null) return '';
    final size = _selectedFile!.lengthSync();
    if (size < 1024) {
      return '${size} B';
    } else if (size < 1048576) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(size / 1048576).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Upload Past Papers',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Correction Upload Button
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assignment_outlined, size: 20),
            ),
            tooltip: 'Upload Correction',
            onPressed: _navigateToCorrectionUpload,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),
              const SizedBox(height: 32),

              // Form Section
              _buildFormSection(),
              const SizedBox(height: 32),

              // File Picker Section
              _buildFilePickerSection(),
              const SizedBox(height: 40),

              // Upload Button
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_outlined, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Upload Past Papers',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload past examination papers for students. Supported formats: PDF, DOC, DOCX (Max 10MB)',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // Correction Upload Prompt
          GestureDetector(
            onTap: _navigateToCorrectionUpload,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment_turned_in,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need to upload corrections?',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Tap here to upload PDF solutions or YouTube video explanations',
                          style: GoogleFonts.poppins(
                            color: Colors.green.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Education Level Dropdown
        _buildDropdown(
          value: _selectedLevel,
          items: levels,
          label: 'Education Level *',
          icon: Icons.school,
          onChanged: (value) {
            setState(() {
              _selectedLevel = value;
              _selectedSubLevel = null;
            });
          },
        ),
        const SizedBox(height: 20),

        // Sub Level Dropdown (Shown only when level selected)
        if (_selectedLevel != null)
          _buildDropdown(
            value: _selectedSubLevel,
            items: subLevels[_selectedLevel]!,
            label: 'Sub Level (Class) *',
            icon: Icons.class_,
            onChanged: (value) {
              setState(() {
                _selectedSubLevel = value;
              });
            },
          ),
        if (_selectedLevel != null) const SizedBox(height: 20),

        // Subject Dropdown
        teacherSubjects.isNotEmpty
            ? _buildDropdown(
              value: _selectedSubject,
              items: teacherSubjects,
              label: 'Subject *',
              icon: Icons.subject,
              onChanged: (value) {
                setState(() => _selectedSubject = value);
              },
            )
            : _buildTextField(
              controller: TextEditingController(),
              label: 'Subject *',
              hintText: 'Enter subject name',
              icon: Icons.subject,
              readOnly: true,
              onTap: () {
                _showErrorDialog(
                  'No subjects found. Please complete your profile setup.',
                );
              },
            ),
        const SizedBox(height: 20),

        // Title and Year in a Row
        Row(
          children: [
            // Title Field
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _titleController,
                label: 'Title *',
                hintText: 'e.g., Mathematics 2024 Past Paper',
                icon: Icons.title,
              ),
            ),
            const SizedBox(width: 16),

            // Year Field
            Expanded(
              flex: 1,
              child: _buildTextField(
                controller: _yearController,
                label: 'Year *',
                hintText: '2024',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.poppins(color: Colors.black87),
            readOnly: readOnly,
            onTap: onTap,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (label.contains('Year') && int.tryParse(value) == null) {
                return 'Please enter a valid year';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
              prefixIcon: Icon(icon, color: primaryColor),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: maxLines > 1 ? 16 : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(icon, color: primaryColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: onChanged,
            style: GoogleFonts.poppins(color: Colors.black87),
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            isExpanded: true,
            validator: (value) => value == null ? 'Please select $label' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select File *',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose the file you want to upload',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),

        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    _selectedFile == null ? Colors.grey.shade300 : primaryColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  _selectedFile == null
                      ? Icons.attach_file_outlined
                      : Icons.check_circle,
                  size: 48,
                  color:
                      _selectedFile == null
                          ? Colors.grey.shade400
                          : primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedFile == null
                      ? 'Tap to select file'
                      : 'File Selected',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color:
                        _selectedFile == null
                            ? Colors.grey.shade600
                            : primaryColor,
                    fontSize: 16,
                  ),
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _selectedFile!.path.split('/').last,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFileSize(),
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'PDF, DOC, DOCX (Max 10MB)',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    final bool isFormValid =
        _selectedFile != null &&
        _selectedLevel != null &&
        _selectedSubLevel != null &&
        _selectedSubject != null &&
        _titleController.text.trim().isNotEmpty &&
        _yearController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid && !_isLoading ? _upload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          disabledBackgroundColor: primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
        child:
            _isLoading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Uploading...',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Upload Past Paper',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
