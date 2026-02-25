import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/todo_provider.dart';
import '../config/theme.dart';

class EditTodoScreen extends StatefulWidget {
  final int todoId;

  const EditTodoScreen({super.key, required this.todoId});

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = 'medium';
  String _category = 'general';
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadTodo();
      _isInitialized = true;
    }
  }

  void _loadTodo() {
    final provider = context.read<TodoProvider>();
    final todo = provider.getTodoById(widget.todoId);
    if (todo != null) {
      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _priority = todo.priority;
      _category = todo.category;
      _dueDate = todo.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑待办'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveTodo,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题 *',
                hintText: '请输入待办事项标题',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '标题不能为空';
                }
                if (value.length > 200) {
                  return '标题不能超过200字符';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述',
                hintText: '请输入待办事项描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Priority
            Text(
              '优先级',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('低'),
                  selected: _priority == 'low',
                  onSelected: (_) => setState(() => _priority = 'low'),
                  selectedColor: AppTheme.priorityLow.withOpacity(0.3),
                ),
                ChoiceChip(
                  label: const Text('中'),
                  selected: _priority == 'medium',
                  onSelected: (_) => setState(() => _priority = 'medium'),
                  selectedColor: AppTheme.priorityMedium.withOpacity(0.3),
                ),
                ChoiceChip(
                  label: const Text('高'),
                  selected: _priority == 'high',
                  onSelected: (_) => setState(() => _priority = 'high'),
                  selectedColor: AppTheme.priorityHigh.withOpacity(0.3),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category
            Text(
              '分类',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('通用'),
                  selected: _category == 'general',
                  onSelected: (_) => setState(() => _category = 'general'),
                ),
                ChoiceChip(
                  label: const Text('工作'),
                  selected: _category == 'work',
                  onSelected: (_) => setState(() => _category = 'work'),
                ),
                ChoiceChip(
                  label: const Text('个人'),
                  selected: _category == 'personal',
                  onSelected: (_) => setState(() => _category = 'personal'),
                ),
                ChoiceChip(
                  label: const Text('学习'),
                  selected: _category == 'study',
                  onSelected: (_) => setState(() => _category = 'study'),
                ),
                ChoiceChip(
                  label: const Text('其他'),
                  selected: _category == 'other',
                  onSelected: (_) => setState(() => _category = 'other'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Due Date
            Text(
              '截止日期',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _dueDate != null
                    ? DateFormat('yyyy-MM-dd HH:mm').format(_dueDate!)
                    : '设置截止日期',
              ),
              trailing: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : null,
              onTap: _selectDueDate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
      );

      if (time != null && mounted) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate due date
    if (_dueDate != null && _dueDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('截止时间必须晚于当前时间')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<TodoProvider>();
    final success = await provider.updateTodo(widget.todoId, {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'priority': _priority,
      'category': _category,
      'due_date': _dueDate?.toIso8601String(),
    });

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('更新成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error ?? '更新失败')),
        );
      }
    }
  }
}
