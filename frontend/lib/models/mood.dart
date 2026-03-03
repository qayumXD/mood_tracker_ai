class Mood {
  final int id;
  final int level;
  final String? note;
  final String? aiSuggestion;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.level,
    this.note,
    this.aiSuggestion,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as int,
      level: json['level'] as int,
      note: json['note'] as String?,
      aiSuggestion: json['ai_suggestion'] as String?,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}

class MoodStats {
  final int total;
  final double avgLevel;
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  MoodStats({
    required this.total,
    required this.avgLevel,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  factory MoodStats.fromJson(Map<String, dynamic> json) {
    return MoodStats(
      total: int.parse(json['total'].toString()),
      avgLevel: double.parse(json['avg_level']?.toString() ?? '0'),
      positiveCount: int.parse(json['positive_count'].toString()),
      neutralCount: int.parse(json['neutral_count'].toString()),
      negativeCount: int.parse(json['negative_count'].toString()),
    );
  }
}
