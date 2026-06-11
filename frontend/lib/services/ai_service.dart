import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AiService {
  static String get _base =>
      kIsWeb ? 'http://localhost:5000/api' : 'http://10.0.2.2:5000/api';

  static const _timeout = Duration(seconds: 15);

  /// Send a POST /api/ai/insight and return the supportive message text.
  Future<String> getAiInsight(String mood, String note) async {
    final response = await http
        .post(
          Uri.parse('$_base/ai/insight'),
          headers: {'Content-Type': 'application/json'},
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

  /// POST /api/ai/chat — emotional support chat, returns the AI reply text.
  Future<String> chatWithAi(String message) async {
    final response = await http
        .post(
          Uri.parse('$_base/ai/chat'),
          headers: {'Content-Type': 'application/json'},
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

  /// POST /api/ai/sentiment — returns predicted mood label from free text.
  Future<String> predictMood(String note) async {
    if (note.trim().isEmpty) return 'okay';
    final response = await http
        .post(
          Uri.parse('$_base/ai/sentiment'),
          headers: {'Content-Type': 'application/json'},
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
