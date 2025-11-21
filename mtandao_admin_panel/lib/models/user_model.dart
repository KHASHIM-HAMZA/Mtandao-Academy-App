class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String level;
  final String subLevel;
  final String school;
  final String region;
  final DateTime joinDate;
  final bool isActive;
  final String status;
  final int resourcesDownloaded;
  final int testsCompleted;
  final DateTime? lastLogin;
  final String subscriptionStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.level,
    required this.subLevel,
    required this.school,
    required this.region,
    required this.joinDate,
    required this.isActive,
    required this.status,
    required this.resourcesDownloaded,
    required this.testsCompleted,
    this.lastLogin,
    required this.subscriptionStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? json['studentName'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? 'Not provided',
      level: json['level'] ?? 'Not specified',
      subLevel: json['subLevel'] ?? json['grade'] ?? 'Not specified',
      school: json['school'] ?? 'Not specified',
      region: json['region'] ?? 'Not specified',
      joinDate:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      isActive: json['isActive'] ?? true,
      status: json['status'] ?? 'active',
      resourcesDownloaded: json['resourcesDownloaded'] ?? 0,
      testsCompleted: json['testsCompleted'] ?? 0,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      subscriptionStatus: json['subscriptionStatus'] ?? 'inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'level': level,
      'subLevel': subLevel,
      'school': school,
      'region': region,
      'joinDate': joinDate.toIso8601String(),
      'isActive': isActive,
      'status': status,
      'resourcesDownloaded': resourcesDownloaded,
      'testsCompleted': testsCompleted,
      'lastLogin': lastLogin?.toIso8601String(),
      'subscriptionStatus': subscriptionStatus,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? level,
    String? subLevel,
    String? school,
    String? region,
    DateTime? joinDate,
    bool? isActive,
    String? status,
    int? resourcesDownloaded,
    int? testsCompleted,
    DateTime? lastLogin,
    String? subscriptionStatus,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      level: level ?? this.level,
      subLevel: subLevel ?? this.subLevel,
      school: school ?? this.school,
      region: region ?? this.region,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      resourcesDownloaded: resourcesDownloaded ?? this.resourcesDownloaded,
      testsCompleted: testsCompleted ?? this.testsCompleted,
      lastLogin: lastLogin ?? this.lastLogin,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
    );
  }
}
