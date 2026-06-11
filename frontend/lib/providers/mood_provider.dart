import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../services/api_service.dart';

class MoodsNotifier extends AsyncNotifier<List<Mood>> {
  late ApiService _apiService;

  @override
  Future<List<Mood>> build() async {
    _apiService = ApiService();
    return _apiService.fetchMoods();
  }

  Future<void> addMood(int level, String note) async {
    await _apiService.logMood(level, note);
    ref.invalidateSelf();
  }

  Future<void> deleteMood(int id) async {
    await _apiService.deleteMood(id);
    ref.invalidateSelf();
  }
}

class StatsNotifier extends AsyncNotifier<MoodStats> {
  late ApiService _apiService;

  @override
  Future<MoodStats> build() async {
    _apiService = ApiService();
    return _apiService.fetchStats();
  }
}

final moodsProvider = AsyncNotifierProvider<MoodsNotifier, List<Mood>>(
  MoodsNotifier.new,
);

final statsProvider = AsyncNotifierProvider<StatsNotifier, MoodStats>(
  StatsNotifier.new,
);
