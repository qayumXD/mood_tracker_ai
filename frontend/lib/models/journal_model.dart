class Journal {
  final int id;
  final String userId;
  final String title;
  final String content;
  final int? moodLevel;
  final List<String> tags;
  final bool isPrivate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Journal({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.moodLevel,
    this.tags = const [],
    this.isPrivate = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Journal.fromJson(Map<String, dynamic> json) {
    return Journal(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      moodLevel: json['mood_level'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      isPrivate: json['is_private'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood_level': moodLevel,
      'tags': tags,
      'is_private': isPrivate,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Journal copyWith({
    int? id,
    String? userId,
    String? title,
    String? content,
    int? moodLevel,
    List<String>? tags,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Journal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      moodLevel: moodLevel ?? this.moodLevel,
      tags: tags ?? this.tags,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
