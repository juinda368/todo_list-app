import 'package:flutter/material.dart';
import '../config/theme.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.getPriorityColor(priority).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        AppTheme.getPriorityLabel(priority),
        style: TextStyle(
          color: AppTheme.getPriorityColor(priority),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
