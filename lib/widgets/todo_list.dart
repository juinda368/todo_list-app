import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'swipeable_todo_card.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final bool isLoading;
  final ValueChanged<Todo> onTap;
  final ValueChanged<Todo> onComplete;
  final ValueChanged<Todo> onDelete;

  const TodoList({
    super.key,
    required this.todos,
    required this.isLoading,
    required this.onTap,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && todos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '暂无待办事项',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方 + 按钮创建新待办',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh is handled by the parent
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return SwipeableTodoCard(
            todo: todo,
            onTap: () => onTap(todo),
            onComplete: () => onComplete(todo),
            onDelete: () => onDelete(todo),
          );
        },
      ),
    );
  }
}
