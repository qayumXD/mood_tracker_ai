class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String themePreference; // 'light', 'dark', 'system'
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.themePreference = 'system',
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      themePreference: json['theme_preference'] as String? ?? 'system',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'theme_preference': themePreference,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? themePreference,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themePreference: themePreference ?? this.themePreference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
