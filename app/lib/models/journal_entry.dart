class JournalEntry {
  static const String TYPE_DIARY = 'diary'; // Constant for diary entry type.
  static const String TYPE_MOOD_SURVEY = 'mood_survey'; // Constant for mood survey entry type.

  final String id;
  final String title;
  final String content;
  final DateTime date;
  final String mood;
  final String type;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.mood,
    required this.type,
  });

  // Factory method to create a diary entry.
  factory JournalEntry.diary({
    required String id,
    required String title,
    required String content,
    required DateTime date,
    required String mood,
  }) {
    return JournalEntry(
      id: id,
      title: title,
      content: content,
      date: date,
      mood: mood,
      type: TYPE_DIARY,
    );
  }

  // Factory method to create a mood survey entry.
  factory JournalEntry.survey({
    required String id,
    required String title,
    required String content,
    required DateTime date,
    required String mood,
  }) {
    return JournalEntry(
      id: id,
      title: title,
      content: content,
      date: date,
      mood: mood,
      type: TYPE_MOOD_SURVEY,
    );
  }

  // Convert JournalEntry to a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'mood': mood,
      'type': type,
    };
  }

  // Create a JournalEntry from a Map.
  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
      mood: map['mood'],
      type: map['type'] ?? TYPE_DIARY,
    );
  }
}
