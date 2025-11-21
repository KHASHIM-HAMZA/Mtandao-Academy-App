class Student {
  final String id;
  final String name;
  final String email;
  final String level;
  final String subLevel;
  final String school;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.level,
    required this.subLevel,
    required this.school,
    required this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      level: json['level'] ?? '',
      subLevel: json['sub_level'] ?? '',
      school: json['school'] ?? '',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }
}
