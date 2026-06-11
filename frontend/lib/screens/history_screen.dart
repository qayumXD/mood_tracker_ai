import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../providers/mood_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodsState = ref.watch(moodsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mood History'), centerTitle: true),
      body: moodsState.when(
        data: (moods) => moods.isEmpty
            ? const Center(child: Text('No mood entries yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: moods.length,
                itemBuilder: (context, index) => _MoodHistoryItem(
                  mood: moods[index],
                  onDelete: () {
                    ref
                        .read(moodsProvider.notifier)
                        .deleteMood(moods[index].id);
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MoodHistoryItem extends StatelessWidget {
  final Mood mood;
  final VoidCallback onDelete;

  const _MoodHistoryItem({required this.mood, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const moodEmojis = {
      5: '🤩',
      4: '😊',
      3: '😐',
      2: '😢',
      1: '😰',
    };

    final emoji = moodEmojis[mood.level] ?? '😐';

    return Dismissible(
      key: Key('mood_${mood.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.moodLabel.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          mood.createdAt.toLocal().toString().split('.')[0],
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (mood.note != null && mood.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(mood.note!, style: Theme.of(context).textTheme.bodyMedium),
              ],
              if (mood.aiSuggestion != null &&
                  mood.aiSuggestion!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'AI: ${mood.aiSuggestion}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
