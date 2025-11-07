import 'package:mtandao_app/model/questions_model.dart';

class TestModel {
  final int id;
  final String title;
  final String subject;
  final String level;
  final int duration;
  final List<Question> questions;
  final String creator;
  final DateTime createdAt;
  final bool published; // visible to students or not

  TestModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.duration,
    required this.questions,
    required this.creator,
    required this.createdAt,
    required this.published,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      level: json['level'],
      duration: json['duration'],
      creator: json['creator'],
      createdAt: json["created at"],
      published: json["published"],
      questions:
          (json['questions'] as List<dynamic>)
              .map((q) => Question.fromJson(q))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subject': subject,
    'level': level,
    'duration': duration,
    'creator': creator,
    'published': published,
    'createdAt': createdAt?.toIso8601String(),
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  TestModel copyWith({
    int? id,
    String? title,
    String? subject,
    String? level,
    int? duration,
    List<Question>? questions,
    String? creator,
    bool? published,
    DateTime? createdAt,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      questions: questions ?? this.questions,
      creator: creator ?? this.creator,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
