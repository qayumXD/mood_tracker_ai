import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/mood.dart';

class ApiService {
  // Use localhost for web (Chrome), 10.0.2.2 for Android Emulator.
  // If using a physical Android device, replace with your PC's local IP (e.g. http://192.168.x.x:5000/api)
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  Future<List<Mood>> fetchMoods() async {
    final response = await http.get(Uri.parse('$baseUrl/moods'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mood.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load moods: ${response.body}');
    }
  }

  Future<MoodStats> fetchStats() async {
    final response = await http.get(Uri.parse('$baseUrl/moods/stats'));
    if (response.statusCode == 200) {
      return MoodStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Future<void> logMood(int level, String note) async {
    final response = await http.post(
      Uri.parse('$baseUrl/moods'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'level': level, 'note': note}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to log mood: ${response.body}');
    }
  }

  Future<void> deleteMood(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/moods/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete mood');
    }
  }
}
