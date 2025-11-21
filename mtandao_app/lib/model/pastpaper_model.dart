class PastPaper {
  final String id;
  final String title;
  final String subject;
  final String educationLevel;
  final String sublevel;
  final int year;
  final String fileUrl;
  final String fileName;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String? fileSize;

  PastPaper({
    required this.sublevel,
    required this.id,
    required this.title,
    required this.subject,
    required this.educationLevel,
    required this.year,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    required this.uploadedAt,
    this.fileSize,
  });

  factory PastPaper.fromJson(Map<String, dynamic> json) {
    return PastPaper(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      subject: json['subject'] ?? 'Unknown Subject',
      educationLevel: json['educationLevel'] ?? 'Unknown Level',
      sublevel: json['sublevel'] ?? ['Unknown Sublevel'],
      year: json['year'] ?? DateTime.now().year,
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'] ?? '',
      uploadedBy: json['uploadedBy'] ?? 'Unknown',
      uploadedAt:
          json['uploadedAt'] != null
              ? DateTime.parse(json['uploadedAt'])
              : DateTime.now(),
      fileSize: json['fileSize'],
    );
  }

  // Helper method to get display name
  String get displayName {
    return '$title ($year)';
  }

  // Helper method to check if file is PDF
  bool get isPdf {
    return fileUrl.toLowerCase().endsWith('.pdf') ||
        fileName.toLowerCase().endsWith('.pdf');
  }
}
