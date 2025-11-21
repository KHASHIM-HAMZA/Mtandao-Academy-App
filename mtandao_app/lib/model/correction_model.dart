class Correction {
  final int? id;
  final String title;
  final String subject;
  final String educationLevel;
  final String sublevel;
  final int year;

  // File-based solution (PDF)
  final String? fileName;
  final String? fileUrl;

  // Video-based solution (YouTube)
  final String? videoTitle;
  final String? youtubeUrl;
  final String? videoThumbnail;

  // Correction type
  final CorrectionType type;

  final String uploadedBy;
  final DateTime? uploadedAt;
  final int? pastPaperId;

  Correction({
    this.id,
    required this.title,
    required this.subject,
    required this.educationLevel,
    required this.sublevel,
    required this.year,
    this.fileName,
    this.fileUrl,
    this.videoTitle,
    this.youtubeUrl,
    this.videoThumbnail,
    this.type = CorrectionType.PDF,
    required this.uploadedBy,
    this.uploadedAt,
    this.pastPaperId,
  });

  // Factory method to create Correction from JSON
  factory Correction.fromJson(Map<String, dynamic> json) {
    return Correction(
      id: json['id'] as int?,
      title: json['title'] as String? ?? 'Untitled',
      subject: json['subject'] as String? ?? 'No Subject',
      educationLevel: json['educationLevel'] as String? ?? 'Unknown Level',
      sublevel: json['sublevel'] as String? ?? 'Unknown Class',
      year: json['year'] as int? ?? DateTime.now().year,
      fileName: json['fileName'] as String?,
      fileUrl: json['fileUrl'] as String?,
      videoTitle: json['videoTitle'] as String?,
      youtubeUrl: json['youtubeUrl'] as String?,
      videoThumbnail: json['videoThumbnail'] as String?,
      type: _parseCorrectionType(json['type']),
      uploadedBy: json['uploadedBy'] as String? ?? 'Unknown Teacher',
      uploadedAt:
          json['uploadedAt'] != null
              ? DateTime.parse(json['uploadedAt'])
              : null,
      pastPaperId:
          json['pastPaper'] != null
              ? (json['pastPaper'] is Map
                  ? (json['pastPaper']['id'] as int?)
                  : (json['pastPaper'] as int?))
              : null,
    );
  }
}

_parseCorrectionType(json) {}

enum CorrectionType { PDF, VIDEO, HYBRID }
