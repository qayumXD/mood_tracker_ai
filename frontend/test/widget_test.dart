import 'package:flutter_test/flutter_test.dart';

import 'package:mood_tracker_app/models/mood.dart';

void main() {
  test('Mood.fromJson parses API payloads', () {
    final mood = Mood.fromJson({
      'id': 42,
      'level': 4,
      'note': 'Feeling good',
      'ai_suggestion': 'Keep that momentum going.',
      'created_at': '2026-04-18T08:30:00.000Z',
    });

    expect(mood.id, 42);
    expect(mood.level, 4);
    expect(mood.note, 'Feeling good');
    expect(mood.aiSuggestion, 'Keep that momentum going.');
    expect(mood.createdAt.isUtc, isFalse);
  });
}
