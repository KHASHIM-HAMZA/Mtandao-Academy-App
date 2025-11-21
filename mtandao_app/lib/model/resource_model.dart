class Resource {
  final String id;
  final String title;
  final String description;
  final String type;
  final String educationLevel;
  final String subLevel;
  final String subject;
  final String fileUrl;
  final String? fileName;
  final String? fileSize;
  final String creator;
  final DateTime createdAt;

  Resource({
    required this.subLevel,
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.educationLevel,
    required this.subject,
    required this.fileUrl,
    this.fileName,
    this.fileSize,
    required this.creator,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      educationLevel: json['educationLevel'] ?? '',
      subLevel: json['sublevel'] ?? '',
      subject: json['subject'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      creator: json['creator'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'educationLevel': educationLevel,
      'subject': subject,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'creator': creator,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
