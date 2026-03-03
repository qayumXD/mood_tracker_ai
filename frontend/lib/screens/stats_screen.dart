import 'package:flutter/material.dart';
import '../models/mood.dart';
import '../services/api_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ApiService _apiService = ApiService();
  MoodStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final stats = await _apiService.fetchStats();
      if (mounted)
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          _error = 'Could not load stats.';
          _isLoading = false;
        });
    }
  }

  String _moodLevelLabel(double avg) {
    if (avg >= 4.5) return 'Amazing';
    if (avg >= 3.5) return 'Good';
    if (avg >= 2.5) return 'Okay';
    if (avg >= 1.5) return 'Sad';
    return 'Terrible';
  }

  Color _avgColor(double avg) {
    if (avg >= 4) return const Color(0xFFFFA726);
    if (avg >= 3) return const Color(0xFF66BB6A);
    if (avg >= 2) return const Color(0xFF78909C);
    return const Color(0xFF42A5F5);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownBar(String label, int count, int total, Color color) {
    final pct = total == 0 ? 0.0 : count / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            const Spacer(),
            Text(
              '$count  (${(pct * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (_, constraints) {
            return Stack(
              children: [
                Container(
                  height: 12,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  height: 12,
                  width: constraints.maxWidth * pct,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildInsightChip(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSmartInsights(MoodStats stats) {
    final insights = <Widget>[];
    if (stats.total == 0) return insights;

    final pctPositive = stats.total == 0
        ? 0
        : (stats.positiveCount / stats.total * 100).round();
    if (pctPositive >= 70) {
      insights.add(
        _buildInsightChip(
          'You\'re mostly positive — $pctPositive% of your logs are Good or Amazing! Keep it up.',
          Icons.emoji_events_rounded,
        ),
      );
    } else if (pctPositive < 30) {
      insights.add(
        _buildInsightChip(
          'You\'ve been going through a tough time. Consider reaching out to someone you trust.',
          Icons.favorite_border_rounded,
        ),
      );
    }

    if (stats.avgLevel >= 4.0) {
      insights.add(
        _buildInsightChip(
          'Your average mood score of ${stats.avgLevel.toStringAsFixed(1)} is excellent!',
          Icons.star_rounded,
        ),
      );
    } else if (stats.avgLevel < 2.5) {
      insights.add(
        _buildInsightChip(
          'Your average mood is low. Small habits like a 10-min walk can lift your spirits.',
          Icons.directions_walk_rounded,
        ),
      );
    }

    if (stats.total >= 7) {
      insights.add(
        _buildInsightChip(
          'Great habit! You\'ve logged ${stats.total} moods. Consistency is key to self-awareness.',
          Icons.trending_up_rounded,
        ),
      );
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mood Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _fetchStats();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: _stats == null || _stats!.total == 0
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            children: [
                              Icon(
                                Icons.bar_chart_rounded,
                                size: 72,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No data yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Log some moods to see stats here!',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Your Overview',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on ${_stats!.total} mood entries',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              _buildStatCard(
                                title: 'Total Logs',
                                value: '${_stats!.total}',
                                icon: Icons.edit_note_rounded,
                                color: Colors.deepPurple,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                title:
                                    'Avg Mood\n${_moodLevelLabel(_stats!.avgLevel)}',
                                value: _stats!.avgLevel.toStringAsFixed(1),
                                icon: Icons.mood_rounded,
                                color: _avgColor(_stats!.avgLevel),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Mood Breakdown',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildBreakdownBar(
                            'Positive (Good + Amazing)',
                            _stats!.positiveCount,
                            _stats!.total,
                            const Color(0xFF66BB6A),
                          ),
                          _buildBreakdownBar(
                            'Neutral (Okay)',
                            _stats!.neutralCount,
                            _stats!.total,
                            const Color(0xFF78909C),
                          ),
                          _buildBreakdownBar(
                            'Negative (Sad + Terrible)',
                            _stats!.negativeCount,
                            _stats!.total,
                            const Color(0xFF42A5F5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Smart Insights',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._buildSmartInsights(_stats!),
                        ],
                      ),
              ),
            ),
    );
  }
}
