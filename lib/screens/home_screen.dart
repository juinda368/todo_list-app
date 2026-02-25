import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/filter_bar.dart';
import '../widgets/todo_list.dart';
import 'create_todo_screen.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('待办事项'),
        actions: [
          // 用户头像或登录按钮
          if (authProvider.isLoggedIn)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: authProvider.user?.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            authProvider.user!.avatarUrl!,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              authProvider.user?.username?.substring(0, 1) ?? '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : Text(
                          authProvider.user?.username?.substring(0, 1) ?? '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              tooltip: '登录',
            ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
            tooltip: '排序',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: '设置',
          ),
        ],
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              FilterBar(
                filter: provider.filter,
                priorityFilter: provider.priorityFilter,
                categoryFilter: provider.categoryFilter,
                onFilterChanged: provider.setFilter,
                onPriorityChanged: provider.setPriorityFilter,
                onCategoryChanged: provider.setCategoryFilter,
                onClearFilters: provider.clearFilters,
              ),
              Expanded(
                child: TodoList(
                  todos: provider.todos,
                  isLoading: provider.isLoading,
                  onTap: (todo) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(todoId: todo.id),
                    ),
                  ),
                  onComplete: (todo) => provider.toggleTodo(todo.id),
                  onDelete: (todo) => provider.deleteTodo(todo.id),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTodoScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showSortDialog() {
    final provider = context.read<TodoProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<SortBy>(
              title: const Text('创建时间'),
              value: SortBy.createdAt,
              groupValue: provider.sortBy,
              onChanged: (value) {
                provider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortBy>(
              title: const Text('截止日期'),
              value: SortBy.dueDate,
              groupValue: provider.sortBy,
              onChanged: (value) {
                provider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<SortBy>(
              title: const Text('优先级'),
              value: SortBy.priority,
              groupValue: provider.sortBy,
              onChanged: (value) {
                provider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
}
