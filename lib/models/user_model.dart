// lib/models/user_model.dart

class UserModel {
  final String userId;
  final String userName;
  final String userEmail;
  final int streakCount;

  // ✅ Keep it as a List to match your Class Diagram
  // But we will strictly enforce it contains only Mandarin for now.
  final List<String> selectedLanguages;

  // userPreferences can remain null for now
  final Map<String, dynamic>? userPreferences;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.streakCount = 0,
    // ✅ DEFAULT VALUE IS MANDARIN
    this.selectedLanguages = const ['Mandarin'],
    this.userPreferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'streakCount': streakCount,
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
      // Handle the list conversion safely
      selectedLanguages: List<String>.from(map['selectedLanguages'] ?? ['Mandarin']),
      userPreferences: map['userPreferences'],
    );
  }
}