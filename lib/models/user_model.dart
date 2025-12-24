// lib/models/user_model.dart

class UserModel {
  final String userId;
  final String userName;
  final String userEmail;
  final int streakCount;
  final int lessonsCompleted;
  final String? profileImageUrl;
  final List<String> selectedLanguages;

  // userPreferences can remain null for now
  final Map<String, dynamic>? userPreferences;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.streakCount = 0,
    this.lessonsCompleted = 0,
    this.profileImageUrl,
    this.selectedLanguages = const ['Mandarin'],
    this.userPreferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'streakCount': streakCount,
      'lessonsCompleted': lessonsCompleted,
      'profileImageUrl': profileImageUrl,
      'selectedLanguages': selectedLanguages,
      'userPreferences': userPreferences,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      streakCount: map['streakCount']?.toInt() ?? 0,
      lessonsCompleted: map['lessonsCompleted']?.toInt() ?? 0,
      profileImageUrl: map['profileImageUrl'],
      selectedLanguages: List<String>.from(map['selectedLanguages'] ?? ['Mandarin']),
      userPreferences: map['userPreferences'],
    );
  }
}