import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood.dart';

class LocalCacheService {
  static const String _moodsCacheKey = 'moods_cache';
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> cacheMoods(List<Mood> moods) async {
    final json = jsonEncode(moods.map((m) => m.toJson()).toList());
    await _prefs.setString(_moodsCacheKey, json);
  }

  static List<Mood> getCachedMoods() {
    final json = _prefs.getString(_moodsCacheKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List;
      return list.map((e) => Mood.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearCache() async {
    await _prefs.remove(_moodsCacheKey);
  }
}
