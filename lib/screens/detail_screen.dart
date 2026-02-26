import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';
import '../config/theme.dart';
import 'edit_todo_screen.dart';

class DetailScreen extends StatelessWidget {
  final int todoId;

  const DetailScreen({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        final todo = provider.getTodoById(todoId);

        if (todo == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('待办详情')),
            body: const Center(child: Text('待办事项不存在')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('待办详情'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTodoScreen(todoId: todoId),
                  ),
                ),
                tooltip: '编辑',
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider, todo),
                tooltip: '删除',
              ),
            ],
          ),
          body: _buildContent(context, todo, provider),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Todo todo, TodoProvider provider) {
    final theme = Theme.of(context);
    final isOverdue = todo.dueDate != null &&
        todo.dueDate!.isBefore(DateTime.now()) &&
        !todo.completed;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  todo.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.completed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    todo.completed ? '已完成' : '进行中',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => provider.toggleTodo(todo.id!),
                  icon: Icon(todo.completed ? Icons.undo : Icons.check),
                  label: Text(todo.completed ? '撤销' : '完成'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Title
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '标题',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  todo.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Description
        if (todo.description != null && todo.description!.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '描述',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(todo.description!),
                ],
              ),
            ),
          ),
        if (todo.description != null && todo.description!.isNotEmpty)
          const SizedBox(height: 12),

        // Priority and Category
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  '优先级',
                  AppTheme.getPriorityLabel(todo.priority),
                  AppTheme.getPriorityColor(todo.priority),
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  '分类',
                  AppTheme.getCategoryLabel(todo.category),
                  null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Due Date
        if (todo.dueDate != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '截止日期',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: isOverdue ? Colors.red : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm').format(todo.dueDate!),
                        style: TextStyle(
                          color: isOverdue ? Colors.red : null,
                          fontWeight: isOverdue ? FontWeight.bold : null,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '已过期',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (todo.dueDate != null) const SizedBox(height: 12),

        // Timestamps
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  '创建时间',
                  DateFormat('yyyy-MM-dd HH:mm').format(todo.createdAt),
                  null,
                ),
                const Divider(),
                _buildInfoRow(
                  context,
                  '更新时间',
                  DateFormat('yyyy-MM-dd HH:mm').format(todo.updatedAt),
                  null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    Color? valueColor,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    TodoProvider provider,
    Todo todo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 "${todo.title}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.deleteTodo(todo.id!);
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error ?? '删除失败')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
