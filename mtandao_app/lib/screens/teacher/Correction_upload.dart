import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtandao_app/providers/pastpaper_provider.dart';

class UploadCorrectionPage extends StatefulWidget {
  const UploadCorrectionPage({super.key});

  @override
  State<UploadCorrectionPage> createState() => _UploadCorrectionPageState();
}

class _UploadCorrectionPageState extends State<UploadCorrectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _youtubeUrlController = TextEditingController();
  final _videoTitleController = TextEditingController();

  String? _selectedSubject;
  String? _selectedLevel;
  int? _selectedPastPaperId;
  File? _selectedFile;
  bool _isLoading = false;
  String? _selectedSubLevel;
  String _correctionType = 'PDF'; // 'PDF' or 'VIDEO'

  List<dynamic> _pastPapers = [];
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

  @override
  void initState() {
    super.initState();
    _loadTeacherSubjects();
    _fetchPastPapers();
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

  Future<void> _fetchPastPapers() async {
    try {
      await Provider.of<PastPaperProvider>(
        context,
        listen: false,
      ).fetchPapers();
      setState(() {
        _pastPapers =
            Provider.of<PastPaperProvider>(context, listen: false).papers;
      });
    } catch (e) {
      debugPrint("⚠️ Error fetching past papers: $e");
    }
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

    if (_correctionType == 'PDF' && _selectedFile == null) {
      _showErrorDialog('Please select a PDF file for the correction');
      return;
    }

    if (_correctionType == 'VIDEO' &&
        (_youtubeUrlController.text.isEmpty ||
            _videoTitleController.text.isEmpty)) {
      _showErrorDialog('Please provide YouTube URL and video title');
      return;
    }

    if (_selectedPastPaperId == null) {
      _showErrorDialog('Please select the past paper for this correction');
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
        'pastPaperId': _selectedPastPaperId.toString(),
        'type': _correctionType,
      };

      // Add video-specific fields if it's a video correction
      if (_correctionType == 'VIDEO') {
        fields['youtubeUrl'] = _youtubeUrlController.text.trim();
        fields['videoTitle'] = _videoTitleController.text.trim();
      }

      final provider = Provider.of<PastPaperProvider>(context, listen: false);

      final success = await provider.uploadCorrection(
        fields: fields,
        filePath: _correctionType == 'PDF' ? _selectedFile!.path : null,
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
              'Your ${_correctionType.toLowerCase()} correction has been uploaded successfully!\n\nStudents can now access this solution.',
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
    _youtubeUrlController.clear();
    _videoTitleController.clear();
    setState(() {
      _selectedFile = null;
      _selectedPastPaperId = null;
      _selectedSubject = teacherSubjects.isNotEmpty ? teacherSubjects[0] : null;
      _correctionType = 'PDF';
    });
  }

  Widget _buildCorrectionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correction Type *',
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
          child: Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  'PDF',
                  Icons.picture_as_pdf,
                  'Upload PDF Solution',
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  'VIDEO',
                  Icons.video_library,
                  'YouTube Explanation',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String type, IconData icon, String label) {
    final isSelected = _correctionType == type;
    return GestureDetector(
      onTap: () => setState(() => _correctionType = type),
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    if (_correctionType != 'PDF') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select PDF File *',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose the PDF file containing the solution',
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
                      ? 'Tap to select PDF file'
                      : 'PDF File Selected',
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
                ] else ...[
                  const SizedBox(height: 8),
                  Text(
                    'PDF files only (Max 10MB)',
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

  Widget _buildVideoInputSection() {
    if (_correctionType != 'VIDEO') return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Explanation *',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide YouTube video details for the solution explanation',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _videoTitleController,
          label: 'Video Title *',
          hintText: 'e.g., Mathematics 2024 Solutions Walkthrough',
          icon: Icons.title,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _youtubeUrlController,
          label: 'YouTube URL *',
          hintText: 'https://youtube.com/watch?v=...',
          icon: Icons.link,
        ),
        const SizedBox(height: 8),
        Text(
          'Paste the full YouTube video URL',
          style: GoogleFonts.poppins(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  // ... Keep all your existing _buildDropdown, _buildTextField, _buildPastPaperDropdown methods
  // They remain the same as in your original UploadPastPaperPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Upload Correction',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 32),
              _buildCorrectionTypeSelector(),
              const SizedBox(height: 24),
              _buildPastPaperDropdown(),
              const SizedBox(height: 20),
              _buildEducationLevelSection(),
              const SizedBox(height: 20),
              _buildSubjectSection(),
              const SizedBox(height: 20),
              _buildTitleYearSection(),
              const SizedBox(height: 24),
              _buildFilePickerSection(),
              _buildVideoInputSection(),
              const SizedBox(height: 40),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Add these helper build methods that are similar to your original page
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
                'Upload Correction',
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
            'Upload solutions and explanations for past papers. Choose between PDF solutions or YouTube video explanations.',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastPaperDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Past Paper *',
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
          child: DropdownButtonFormField<int>(
            value: _selectedPastPaperId,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Icon(Icons.assignment_outlined, color: primaryColor),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items:
                _pastPapers.map((paper) {
                  return DropdownMenuItem<int>(
                    value: paper['id'],
                    child: Text(
                      '${paper['title']} (${paper['year']})',
                      style: GoogleFonts.poppins(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => _selectedPastPaperId = value),
            style: GoogleFonts.poppins(color: Colors.black87),
            dropdownColor: Colors.white,
            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
            isExpanded: true,
            validator:
                (value) => value == null ? 'Please select a past paper' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationLevelSection() {
    return Column(
      children: [
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
        if (_selectedLevel != null) const SizedBox(height: 20),
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
      ],
    );
  }

  Widget _buildSubjectSection() {
    return teacherSubjects.isNotEmpty
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
        );
  }

  Widget _buildTitleYearSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTextField(
            controller: _titleController,
            label: 'Correction Title *',
            hintText:
                _correctionType == 'VIDEO'
                    ? 'e.g., Mathematics 2024 Video Solutions'
                    : 'e.g., Mathematics 2024 PDF Solutions',
            icon: Icons.title,
          ),
        ),
        const SizedBox(width: 16),
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
    );
  }

  Widget _buildUploadButton() {
    final bool isFormValid =
        _selectedPastPaperId != null &&
        _selectedLevel != null &&
        _selectedSubLevel != null &&
        _selectedSubject != null &&
        _titleController.text.trim().isNotEmpty &&
        _yearController.text.trim().isNotEmpty &&
        ((_correctionType == 'PDF' && _selectedFile != null) ||
            (_correctionType == 'VIDEO' &&
                _youtubeUrlController.text.trim().isNotEmpty &&
                _videoTitleController.text.trim().isNotEmpty));

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
                      'Upload ${_correctionType} Correction',
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

  // ... Keep your existing _buildDropdown, _buildTextField methods
  // They remain exactly the same as in your original UploadPastPaperPage
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

  @override
  void dispose() {
    _titleController.dispose();
    _yearController.dispose();
    _youtubeUrlController.dispose();
    _videoTitleController.dispose();
    super.dispose();
  }
}
