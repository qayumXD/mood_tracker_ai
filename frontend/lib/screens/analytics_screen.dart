import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood.dart';
import '../providers/mood_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics'), centerTitle: true),
      body: statsState.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatCard(
                            label: 'Total Entries',
                            value: stats.totalEntries.toString(),
                          ),
                          _StatCard(
                            label: 'Average Mood',
                            value: stats.averageMood.toStringAsFixed(1),
                          ),
                          _StatCard(
                            label: 'Best Day',
                            value: stats.bestMoodLevel.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Distribution',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(sections: _buildPieSections(stats)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mood Trend',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _buildTrendSpots(stats),
                                isCurved: true,
                                color: Theme.of(context).colorScheme.primary,
                                barWidth: 2,
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(MoodStats stats) {
    return [
      PieChartSectionData(
        value: (stats.moodCounts['happy'] ?? 0).toDouble(),
        color: Colors.green,
        title: 'Happy',
      ),
      PieChartSectionData(
        value: (stats.moodCounts['neutral'] ?? 0).toDouble(),
        color: Colors.blue,
        title: 'Neutral',
      ),
      PieChartSectionData(
        value: (stats.moodCounts['sad'] ?? 0).toDouble(),
        color: Colors.red,
        title: 'Sad',
      ),
      PieChartSectionData(
        value: (stats.moodCounts['anxious'] ?? 0).toDouble(),
        color: Colors.orange,
        title: 'Anxious',
      ),
    ];
  }

  List<FlSpot> _buildTrendSpots(MoodStats stats) {
    final moodLevels = stats.recentMoodLevels ?? [];
    return List.generate(
      moodLevels.length,
      (i) => FlSpot(i.toDouble(), moodLevels[i].toDouble()),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
