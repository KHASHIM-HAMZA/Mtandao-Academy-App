import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtandao_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:mtandao_app/providers/scheme_provider.dart';

class TeacherSchemePage extends StatefulWidget {
  const TeacherSchemePage({super.key});

  @override
  State<TeacherSchemePage> createState() => _TeacherSchemePageState();
}

class _TeacherSchemePageState extends State<TeacherSchemePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? teacherEmail;
  String? teacherName;
  List<String> teacherSubjects = [];

  // Upload form controllers
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedLevel;
  String? _selectedTerm;
  String? _selectedSubject;
  String? _selectedVisibility;
  int? _selectedYear;
  int? _selectedWeek;
  File? _selectedFile;
  bool _isUploading = false;

  final Color primaryColor = const Color.fromARGB(255, 27, 88, 138);
  final levels = ['primary', 'olevel', 'alevel'];
  final terms = ['Term 1', 'Term 2', 'Term 3'];
  final visibilityOptions = ['PUBLIC', 'PRIVATE'];
  final currentYear = DateTime.now().year;
  final List<int> years = List.generate(
    5,
    (index) => DateTime.now().year - 2 + index,
  );

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherEmail = prefs.getString('email');
      teacherName = prefs.getString('name');
    });

    if (teacherEmail != null) {
      // Load schemes immediately
      _loadSchemes();
    }
  }

  Future<void> _loadSchemes() async {
    if (teacherEmail != null) {
      await Provider.of<SchemeProvider>(
        context,
        listen: false,
      ).fetchMySchemes(teacherEmail!);
    }
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeacherData();
    _initializeForm();
    _loadTeacherSubjects();
  }

  void _initializeForm() {
    setState(() {
      _selectedYear = currentYear;
      _selectedVisibility = 'PUBLIC';
    });
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

  Future<void> _uploadScheme() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorDialog('Please fill all required fields');
      return;
    }

    if (_selectedFile == null) {
      _showErrorDialog('Please select a file to upload');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final Map<String, String> fields = {
        'title': _titleController.text.trim(),
        'subject': _selectedSubject!,
        'educationLevel': _selectedLevel!,
        'term': _selectedTerm!,
        'year': _selectedYear.toString(),
        if (_selectedWeek != null) 'week': _selectedWeek.toString(),
        'description': _descriptionController.text.trim(),
        'uploadedBy': teacherEmail!,
        'visibility': _selectedVisibility!,
      };

      final success = await Provider.of<SchemeProvider>(
        context,
        listen: false,
      ).uploadScheme(fields, _selectedFile!.path);

      if (success) {
        _showSuccessDialog();
        _resetForm();
        _tabController.animateTo(1);

        // Force reload schemes after successful upload
        await _loadSchemes();
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
                  'Upload Successful!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            content: Text(
              'Your scheme of work has been uploaded successfully!\n\nIt is now ${_selectedVisibility == 'PUBLIC' ? 'visible to students and other teachers' : 'private to you only'}.',
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
    _formKey.currentState?.reset();
    _titleController.clear();
    _subjectController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedFile = null;
      _selectedLevel = null;
      _selectedTerm = null;
      _selectedWeek = null;
      _selectedYear = currentYear;
      _selectedVisibility = 'PUBLIC';
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
          'Scheme of Work',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.upload_file), text: "Upload"),
            Tab(icon: Icon(Icons.list_alt), text: "My Schemes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUploadForm(), _buildMySchemesList()],
      ),
    );
  }

  Widget _buildUploadForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeaderSection(),
          const SizedBox(height: 32),

          // Form Section
          _buildFormSection(),
        ],
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
              Icon(Icons.schedule_outlined, color: primaryColor, size: 28),
              const SizedBox(width: 12),
              Text(
                'Upload Scheme of Work',
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
            'Create and upload your teaching schedule, lesson plans, and work schemes. You can choose to make them public for students or keep them private.',
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          Text(
            'Scheme Details',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Title Field
          _buildTextField(
            controller: _titleController,
            label: 'Scheme Title *',
            hintText: 'e.g., Mathematics Term 1 Lesson Plan',
            icon: Icons.title,
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
            _buildTextFieldx(
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

          // Level and Term Selection
          Row(
            children: [
              // Level Dropdown
              Expanded(
                child: _buildDropdown(
                  value: _selectedLevel,
                  items: levels,
                  label: 'Education Level *',
                  icon: Icons.school,
                  onChanged: (value) => setState(() => _selectedLevel = value),
                ),
              ),
              const SizedBox(width: 16),

              // Term Dropdown
              Expanded(
                child: _buildDropdown(
                  value: _selectedTerm,
                  items: terms,
                  label: 'Term *',
                  icon: Icons.calendar_view_month,
                  onChanged: (value) => setState(() => _selectedTerm = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Year and Week Selection
          Row(
            children: [
              // Year Dropdown
              Expanded(
                child: _buildDropdown(
                  value: _selectedYear?.toString(),
                  items: years.map((y) => y.toString()).toList(),
                  label: 'Year *',
                  icon: Icons.calendar_today,
                  onChanged:
                      (value) =>
                          setState(() => _selectedYear = int.tryParse(value!)),
                ),
              ),
              const SizedBox(width: 16),

              // Week Field (Optional)
              Expanded(
                child: _buildTextField(
                  controller: TextEditingController(
                    text: _selectedWeek?.toString() ?? '',
                  ),
                  label: 'Week (Optional)',
                  hintText: 'e.g., 1, 2, 3',
                  icon: Icons.date_range,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _selectedWeek = value.isEmpty ? null : int.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Description Field
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hintText: 'Brief description of this scheme of work...',
            icon: Icons.description,
            maxLines: 3,
          ),
          const SizedBox(height: 20),

          // Visibility Selection
          _buildDropdown(
            value: _selectedVisibility,
            items: visibilityOptions,
            label: 'Visibility *',
            icon: _selectedVisibility == 'PUBLIC' ? Icons.public : Icons.lock,
            onChanged: (value) => setState(() => _selectedVisibility = value),
          ),
          const SizedBox(height: 20),

          // File Picker Section
          _buildFilePickerSection(),
          const SizedBox(height: 32),

          // Upload Button
          _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
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
            onChanged: onChanged,
            validator: (value) {
              if (label.contains('*') && (value == null || value.isEmpty)) {
                return 'This field is required';
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
              fillColor: Colors.white,
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
            validator: (value) => value == null ? 'Please select $label' : null,
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
      case 'PUBLIC':
        return 'Public (Visible to all)';
      case 'PRIVATE':
        return 'Private (Only me)';
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
          'Choose the scheme file (PDF, DOC, DOCX)',
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
        _titleController.text.trim().isNotEmpty &&
        _selectedSubject != null &&
        _selectedLevel != null &&
        _selectedTerm != null &&
        _selectedYear != null &&
        _selectedVisibility != null;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isFormValid && !_isUploading ? _uploadScheme : null,
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
                      'Upload Scheme',
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

  Widget _buildMySchemesList() {
    final provider = Provider.of<SchemeProvider>(context);

    return Column(
      children: [
        // Header with reload button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Text(
                'My Schemes',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.refresh, color: primaryColor),
                onPressed: () => _loadSchemes(),
                tooltip: 'Reload Schemes',
              ),
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 8),
              Text(
                '${provider.mySchemes.length}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildSchemesContent(provider)),
      ],
    );
  }

  Widget _buildSchemesContent(SchemeProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final schemes = provider.mySchemes;

    if (schemes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Schemes Uploaded",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Your uploaded schemes will appear here",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _tabController.animateTo(0),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: Text(
                'Upload Your First Scheme',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _loadSchemes(),
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchMySchemes(teacherEmail!),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: schemes.length,
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      scheme['visibility'] == 'PUBLIC'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  scheme['visibility'] == 'PUBLIC' ? Icons.public : Icons.lock,
                  color:
                      scheme['visibility'] == 'PUBLIC'
                          ? Colors.green
                          : Colors.orange,
                  size: 24,
                ),
              ),
              title: Text(
                scheme['title'],
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    scheme['description']?.isNotEmpty == true
                        ? scheme['description']
                        : 'No description',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildSchemeChip(
                        scheme['subject'],
                        Icons.subject_outlined,
                      ),
                      _buildSchemeChip(
                        scheme['educationLevel'],
                        Icons.school_outlined,
                      ),
                      _buildSchemeChip(
                        scheme['term'],
                        Icons.calendar_view_month,
                      ),
                      _buildSchemeChip(
                        '${scheme['year']}',
                        Icons.calendar_today,
                      ),
                      if (scheme['week'] != null)
                        _buildSchemeChip(
                          'Week ${scheme['week']}',
                          Icons.date_range,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Uploaded on ${_formatDate(DateTime.parse(scheme['createdAt']))}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                onSelected: (value) {
                  if (value == "view") {
                    _viewSchemeDetails(context, scheme);
                  } else if (value == "preview" && scheme['fileUrl'] != null) {
                    _viewPdf(context, scheme['title'], scheme['fileUrl']);
                  } else if (value == "delete") {
                    _showDeleteDialog(context, scheme);
                  }
                },
                itemBuilder:
                    (context) => [
                      if (scheme['fileUrl'] != null &&
                          scheme['fileUrl'].toString().toLowerCase().endsWith(
                            '.pdf',
                          ))
                        PopupMenuItem(
                          value: "preview",
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf_outlined, size: 20),
                              const SizedBox(width: 8),
                              Text("View PDF"),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: "view",
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined, size: 20),
                            const SizedBox(width: 8),
                            Text("View Details"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text("Delete", style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSchemeChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewSchemeDetails(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Scheme Details",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSchemeDetailRow("Title", scheme['title']),
                _buildSchemeDetailRow("Subject", scheme['subject']),
                _buildSchemeDetailRow(
                  "Education Level",
                  scheme['educationLevel'],
                ),
                _buildSchemeDetailRow("Term", scheme['term']),
                _buildSchemeDetailRow("Year", scheme['year'].toString()),
                if (scheme['week'] != null)
                  _buildSchemeDetailRow("Week", scheme['week'].toString()),
                _buildSchemeDetailRow(
                  "Description",
                  scheme['description']?.isNotEmpty == true
                      ? scheme['description']
                      : 'No description',
                ),
                _buildSchemeDetailRow("Visibility", scheme['visibility']),
                _buildSchemeDetailRow(
                  "Uploaded By",
                  scheme['uploadedBy'] ?? 'Unknown',
                ),
                _buildSchemeDetailRow(
                  "Upload Date",
                  _formatDate(DateTime.parse(scheme['createdAt'])),
                ),
              ],
            ),
            actions: [
              if (scheme['fileUrl'] != null &&
                  scheme['fileUrl'].toString().toLowerCase().endsWith('.pdf'))
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _viewPdf(context, scheme['title'], scheme['fileUrl']);
                  },
                  child: Text("View PDF"),
                ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Close"),
              ),
            ],
          ),
    );
  }

  Widget _buildSchemeDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> scheme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              "Delete Scheme?",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: Text(
              "Are you sure you want to delete \"${scheme['title']}\"? This action cannot be undone.",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Implement delete functionality when backend supports it
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Delete functionality coming soon"),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  Widget _buildTextFieldx({
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

  void _viewPdf(BuildContext context, String title, String fileUrl) {
    const String baseUrl = AppConstants.openeurl;
    final fullUrl = '$baseUrl$fileUrl';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              appBar: AppBar(title: Text(title), backgroundColor: primaryColor),
              body: SfPdfViewer.network(
                fullUrl,
                pageLayoutMode: PdfPageLayoutMode.single,
                canShowScrollHead: true,
                canShowScrollStatus: true,
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
