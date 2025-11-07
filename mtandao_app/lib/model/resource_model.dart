class Resource {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String type; // "Book" or "Note"
  final String educationLevel; // "Primary", "O-level", "A-level"
  final String teacherId;
  final String fileUrl;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.educationLevel,
    required this.teacherId,
    required this.fileUrl,
    required this.createdAt,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      type: json['type'] ?? '',
      educationLevel: json['educationLevel'] ?? '',
      teacherId: json['teacherId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'subject': subject,
    'type': type,
    'educationLevel': educationLevel,
    'teacherId': teacherId,
    'fileUrl': fileUrl,
    'createdAt': createdAt.toIso8601String(),
  };
}
