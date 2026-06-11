import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood.dart';
import '../core/constants/app_colors.dart';

class MoodChart extends StatelessWidget {
  final List<Mood> moods;

  const MoodChart({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    final lastSeven = moods.take(7).toList();
    final spots = List.generate(lastSeven.length, (i) => FlSpot(i.toDouble(), lastSeven[i].level.toDouble()));
    final counts = <int, int>{1:0,2:0,3:0,4:0,5:0};
    for (var m in moods) {
      counts[m.level] = (counts[m.level] ?? 0) + 1;
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(spots: spots, isCurved: true, color: AppColors.primary, barWidth: 3, dotData: FlDotData(show: true)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sections: counts.entries.map((e) => PieChartSectionData(value: e.value.toDouble(), title: e.key.toString())).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
