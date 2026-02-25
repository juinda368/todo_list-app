import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../config/theme.dart';
import 'priority_badge.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.completed;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.completed
                            ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                            : null,
                      ),
                    ),
                  ),
                  PriorityBadge(priority: todo.priority),
                ],
              ),
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip(
                    context,
                    AppTheme.getCategoryLabel(todo.category),
                    Icons.category_outlined,
                  ),
                  const SizedBox(width: 8),
                  if (todo.dueDate != null)
                    _buildChip(
                      context,
                      DateFormat('MM/dd HH:mm').format(todo.dueDate!),
                      Icons.schedule,
                      isOverdue: isOverdue,
                    ),
                  const Spacer(),
                  if (todo.completed)
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon,
      {bool isOverdue = false}) {
    final color = isOverdue
        ? Colors.red
        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }
}
