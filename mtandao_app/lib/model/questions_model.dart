class Question {
  final int id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String type; // "mcq" or "true_false"
  final String? mediaUrl; // for pdf or image question

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.type,
    this.mediaUrl,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
      type: json['type'],
      mediaUrl: json['mediaUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'questionText': questionText,
    'options': options,
    'correctAnswer': correctAnswer,
    'type': type,
    'mediaUrl': mediaUrl,
  };

  Question copyWith({
    int? id,
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    String? type,
    String? mediaUrl,
  }) {
    return Question(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}
