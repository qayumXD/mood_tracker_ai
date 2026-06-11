import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_styles.dart';

class DashboardCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppStyles.borderRadius)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
