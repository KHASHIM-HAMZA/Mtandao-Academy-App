import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/model/resource_model.dart';
import 'package:mtandao_app/providers/resource_provder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherUploadResourcePage extends StatefulWidget {
  const TeacherUploadResourcePage({super.key});

  @override
  State<TeacherUploadResourcePage> createState() =>
      _TeacherUploadResourcePageState();
}

class _TeacherUploadResourcePageState extends State<TeacherUploadResourcePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedType;
  String? _selectedLevel;
  String? _selectedSubject;
  String? _selectedSubLevel;

  File? _file;
  bool _isUploading = false;

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
  final levels = ['primary', 'olevel', 'alevel'];
  final types = ['books', 'notes'];
  List<String> teacherSubjects = [];

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

  void _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _file = File(result.files.single.path!));
      }
    } catch (e) {
      _showErrorDialog('File selection failed: $e');
    }
  }

  void _upload() async {
    if (_file == null ||
        _selectedType == null ||
        _selectedLevel == null ||
        _selectedSubLevel == null || // NEW REQUIRED FIELD
        _selectedSubject == null) {
      _showErrorDialog(
        'Please fill all fields including sub-level and select a file',
      );
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a title for the resource');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final resource = Resource(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        type: _selectedType!,
        educationLevel: _selectedLevel!,
        subLevel: _selectedSubLevel!, // ✅ NEW FIELD
        subject: _selectedSubject!,
        fileUrl: '', // backend will fill
        creator: '', // provider fills teacher name
        createdAt: DateTime.now(),
      );

      final success = await Provider.of<ResourceProvider>(
        context,
        listen: false,
      ).uploadResource(_file!, resource);

      if (success) {
        _showSuccessDialog();
        _resetForm();
      } else {
        _showErrorDialog('Upload failed. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Upload failed: $e');
    } finally {
      setState(() => _isUploading = false);
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
                  'Success!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            content: Text(
              'Resource uploaded successfully!\n\nStudents can now access this material.',
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
    _descController.clear();
    setState(() {
      _file = null;
      _selectedType = null;
      _selectedLevel = null;
      _selectedSubject = teacherSubjects.isNotEmpty ? teacherSubjects[0] : null;
    });
  }

  String _getFileTypeIcon() {
    if (_file == null) return '📁';
    final ext = _file!.path.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'png':
      case 'jpg':
      case 'jpeg':
        return '🖼️';
      default:
        return '📁';
    }
  }

  String _getFileSize() {
    if (_file == null) return '';
    final size = _file!.lengthSync();
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
          'Upload Resource',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 27, 88, 138),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              Icon(Icons.cloud_upload, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Share Educational Resources',
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
            'Upload books, notes, and learning materials for your students. Supported formats: PDF, DOC, PNG, JPG (Max 10MB)',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 14,
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
        const SizedBox(height: 15),

        // Title Field
        _buildTextField(
          controller: _titleController,
          label: 'Resource Title *',
          hintText: 'e.g., Mathematics Notes Chapter 1',
          icon: Icons.title,
        ),
        const SizedBox(height: 20),

        // Description Field
        _buildTextField(
          controller: _descController,
          label: 'Description',
          hintText: 'Brief description of the resource content...',
          icon: Icons.description,
          maxLines: 3,
        ),
        const SizedBox(height: 20),

        // Type, Level, and Subject Selection
        Column(
          children: [
            Row(
              children: [
                // Type Dropdown
                Expanded(
                  child: _buildDropdown(
                    value: _selectedType,
                    items: types,
                    label: 'Resource Type *',
                    icon: Icons.category,
                    onChanged: (value) => setState(() => _selectedType = value),
                  ),
                ),
                const SizedBox(width: 16),

                // Level Dropdown
                Expanded(
                  child: _buildDropdown(
                    value: _selectedLevel,
                    items: levels,
                    label: 'Education Level *',
                    icon: Icons.school,
                    onChanged: (value) {
                      setState(() {
                        _selectedLevel = value;
                        _selectedSubLevel = null; // reset sub-level
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_selectedLevel != null)
              _buildDropdown(
                value: _selectedSubLevel,
                items: subLevels[_selectedLevel]!,
                label: 'Sub Level (Class) *',
                icon: Icons.class_,
                onChanged: (value) => setState(() => _selectedSubLevel = value),
              ),

            const SizedBox(height: 20),

            // Subject Dropdown
            if (teacherSubjects.isNotEmpty)
              _buildDropdown(
                value: _selectedSubject,
                items: teacherSubjects,
                label: 'Subject *',
                icon: Icons.subject,
                onChanged: (value) => setState(() => _selectedSubject = value),
              )
            else
              _buildTextField(
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
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
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
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.poppins(color: Colors.black87),
            readOnly: readOnly,
            onTap: onTap,
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
                      _formatDropdownText(item),
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
            hint: Text(
              'Select $label',
              style: GoogleFonts.poppins(color: Colors.grey.shade500),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDropdownText(String text) {
    switch (text) {
      case 'primary':
        return 'Primary Level';
      case 'olevel':
        return 'O-Level';
      case 'alevel':
        return 'A-Level';
      case 'books':
        return 'Books';
      case 'notes':
        return 'Notes';
      default:
        return text;
    }
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
                color: _file == null ? Colors.grey.shade300 : primaryColor,
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
                  _file == null
                      ? Icons.cloud_upload_outlined
                      : Icons.check_circle,
                  size: 48,
                  color: _file == null ? Colors.grey.shade400 : primaryColor,
                ),
                const SizedBox(height: 12),
                Text(
                  _file == null ? 'Tap to select file' : 'File Selected',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: _file == null ? Colors.grey.shade600 : primaryColor,
                    fontSize: 16,
                  ),
                ),
                if (_file != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _file!.path.split('/').last,
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getFileTypeIcon(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getFileSize(),
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'PDF, DOC, PNG, JPG (Max 10MB)',
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
        _file != null &&
        _selectedType != null &&
        _selectedLevel != null &&
        _selectedSubject != null &&
        _titleController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid && !_isUploading ? _upload : null,
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
            _isUploading
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
                      'Upload Resource',
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
    _descController.dispose();
    super.dispose();
  }
}
