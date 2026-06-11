import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/mood.dart';
import '../models/user_model.dart';
import '../models/journal_model.dart';
import 'auth_service.dart';

class ApiService {
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  static const _timeout = Duration(seconds: 15);
  late AuthService _authService;

  ApiService({AuthService? authService}) {
    _authService = authService ?? AuthService();
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    final token = _authService.token;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ─── Authentication ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String? fullName,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
            'full_name': fullName,
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        await _authService.saveToken(data['token']);
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await _authService.saveUser(user);
        }
      }
      return data;
    }
    throw Exception('Registration failed: ${response.body}');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'email': email, 'password': password}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['token'] != null) {
        await _authService.saveToken(data['token']);
        if (data['user'] != null) {
          final user = User.fromJson(data['user']);
          await _authService.saveUser(user);
        }
      }
      return data;
    }
    throw Exception('Login failed: ${response.body}');
  }

  Future<User> getCurrentUser() async {
    final response = await http
        .get(Uri.parse('$baseUrl/auth/me'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));
      await _authService.saveUser(user);
      return user;
    }
    throw Exception('Failed to fetch user: ${response.body}');
  }

  // ─── Moods ───────────────────────────────────────────────────────────────

  Future<List<Mood>> fetchMoods() async {
    final response = await http
        .get(Uri.parse('$baseUrl/moods'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Mood.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load moods: ${response.body}');
    }
  }

  Future<MoodStats> fetchStats() async {
    final response = await http
        .get(Uri.parse('$baseUrl/moods/stats'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      return MoodStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load stats: ${response.body}');
    }
  }

  Future<Mood> logMood(int level, String note) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/moods'),
          headers: _getHeaders(),
          body: json.encode({'level': level, 'note': note}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to log mood: ${response.body}');
    }
    return Mood.fromJson(json.decode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteMood(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/moods/$id'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete mood: ${response.body}');
    }
  }

  // ─── Journals ────────────────────────────────────────────────────────────

  Future<List<Journal>> fetchJournals() async {
    final response = await http
        .get(Uri.parse('$baseUrl/journals'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((j) => Journal.fromJson(j)).toList();
    }
    throw Exception('Failed to fetch journals: ${response.body}');
  }

  Future<Journal> createJournal(
    String title,
    String content, {
    int? moodLevel,
    List<String>? tags,
    bool? isPrivate,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/journals'),
          headers: _getHeaders(),
          body: json.encode({
            'title': title,
            'content': content,
            'mood_level': moodLevel,
            'tags': tags,
            'is_private': isPrivate ?? false,
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      return Journal.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create journal: ${response.body}');
  }

  Future<Journal> fetchJournal(int id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/journals/$id'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      return Journal.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to fetch journal: ${response.body}');
  }

  Future<Journal> updateJournal(
    int id, {
    String? title,
    String? content,
    int? moodLevel,
    List<String>? tags,
    bool? isPrivate,
  }) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/journals/$id'),
          headers: _getHeaders(),
          body: json.encode({
            'title': title,
            'content': content,
            'mood_level': moodLevel,
            'tags': tags,
            'is_private': isPrivate,
          }),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode == 200) {
      return Journal.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update journal: ${response.body}');
  }

  Future<void> deleteJournal(int id) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/journals/$id'), headers: _getHeaders())
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete journal: ${response.body}');
    }
  }

  // ─── AI Services ─────────────────────────────────────────────────────────

  Future<String> getAiInsight(String mood, String note) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/ai/insight'),
          headers: _getHeaders(),
          body: json.encode({'mood': mood, 'note': note}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['insight'] as String?) ?? 'No insight returned.';
    }
    throw Exception('AI insight failed: ${response.body}');
  }

  Future<String> chatWithAi(String message) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/ai/chat'),
          headers: _getHeaders(),
          body: json.encode({'message': message}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['reply'] as String?) ?? 'No reply returned.';
    }
    throw Exception('Chat failed: ${response.body}');
  }

  Future<String> predictMood(String note) async {
    if (note.trim().isEmpty) return 'okay';
    final response = await http
        .post(
          Uri.parse('$baseUrl/ai/sentiment'),
          headers: _getHeaders(),
          body: json.encode({'note': note}),
        )
        .timeout(
          _timeout,
          onTimeout: () => throw Exception('Request timed out'),
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['mood'] as String?) ?? 'okay';
    }
    return 'okay';
  }
}
