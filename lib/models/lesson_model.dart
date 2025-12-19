class Lesson {
  final String lessonId;
  final String lessonTitle;
  final String associatedSyllabusUnit;
  final bool isLocked;
  // NEW: A list of materials (e.g., PDFs, Audio files)
  final List<Map<String, String>> materials;

  Lesson({
    required this.lessonId,
    required this.lessonTitle,
    required this.associatedSyllabusUnit,
    required this.isLocked,
    this.materials = const [], // Default to empty list
  });
}