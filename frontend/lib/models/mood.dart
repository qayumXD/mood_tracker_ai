class Mood {
  final int id;
  final int level; // 1-5: terrible, sad, okay, good, amazing
  final String? note;
  final String? aiSuggestion;
  final DateTime createdAt;
  final String? userId;

  Mood({
    required this.id,
    required this.level,
    this.note,
    this.aiSuggestion,
    required this.createdAt,
    this.userId,
  });

  String get moodLabel {
    switch (level) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Sad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Amazing';
      default:
        return 'Unknown';
    }
  }

  String get moodEmoji {
    switch (level) {
      case 1:
        return '😢';
      case 2:
        return '😔';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '😐';
    }
  }

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as int? ?? 0,
      level: json['level'] as int? ?? 3,
      note: json['note'] as String?,
      aiSuggestion: json['ai_suggestion'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      userId: json['user_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'note': note,
      'ai_suggestion': aiSuggestion,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
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

  int get totalEntries => total;
  double get averageMood => avgLevel;
  int get bestMoodLevel => total > 0 ? 5 : 0;

  Map<String, int> get moodCounts {
    return {
      'happy': positiveCount,
      'neutral': neutralCount,
      'sad': negativeCount,
      'anxious': 0,
    };
  }

  List<int>? get recentMoodLevels {
    return [avgLevel.toInt()];
  }
}
