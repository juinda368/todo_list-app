import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'todo_card.dart';

class SwipeableTodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const SwipeableTodoCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todo_${todo.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        return await _showActionDialog(context);
      },
      onDismissed: (direction) {
        onDelete?.call();
      },
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        child: Row(
          children: const [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text(
              '完成',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Delete button behind
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    '删除',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.delete, color: Colors.white),
                ],
              ),
            ),
          ),
          // Card
          TodoCard(todo: todo, onTap: onTap),
        ],
      ),
    );
  }

  Future<bool?> _showActionDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择操作'),
        content: const Text('请选择要对此待办事项执行的操作'),
        actions: [
          TextButton(
            onPressed: () {
              onComplete?.call();
              Navigator.of(context).pop(false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 4),
                Text('完成'),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              onDelete?.call();
              Navigator.of(context).pop(false);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 4),
                Text('删除'),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
