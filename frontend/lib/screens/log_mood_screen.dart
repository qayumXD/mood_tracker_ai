import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mood_provider.dart';
import '../services/ai_service.dart';

class LogMoodScreen extends ConsumerStatefulWidget {
  const LogMoodScreen({super.key});

  @override
  ConsumerState<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends ConsumerState<LogMoodScreen> {
  String selectedMood = 'neutral';
  final _noteController = TextEditingController();
  String? _predictedMood;
  bool _isLoading = false;

  final moodEmojis = {
    'happy': '😊',
    'neutral': '😐',
    'sad': '😢',
    'anxious': '😰',
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _predictMoodFromNote() async {
    if (_noteController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final aiService = AiService();
      final predicted = await aiService.predictMood(_noteController.text);
      setState(() {
        _predictedMood = predicted;
        selectedMood = predicted;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logMood() async {
    setState(() => _isLoading = true);
    try {
      // Convert mood string to level number (1-5)
      final moodLevelMap = {
        'anxious': 1,
        'sad': 2,
        'neutral': 3,
        'happy': 4,
        'amazing': 5,
      };
      final level = moodLevelMap[selectedMood] ?? 3;

      await ref
          .read(moodsProvider.notifier)
          .addMood(level, _noteController.text);
      _noteController.clear();
      setState(() {
        selectedMood = 'neutral';
        _predictedMood = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mood logged!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Mood'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: moodEmojis.entries.map((e) {
                final isSelected = selectedMood == e.key;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = e.key),
                  child: Transform.scale(
                    scale: isSelected ? 1.2 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              'Add a note (optional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write about what\'s on your mind...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (_noteController.text.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _predictMoodFromNote,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Analyze Sentiment'),
                ),
              ),
            if (_predictedMood != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Theme.of(
                          context,
                        ).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Detected: $_predictedMood',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _logMood,
                icon: const Icon(Icons.check_circle),
                label: const Text('Log Mood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
