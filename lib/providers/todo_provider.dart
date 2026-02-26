import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/widget_service.dart';

enum TodoFilter { all, active, completed }

enum SortBy { createdAt, dueDate, priority }

class TodoProvider extends ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<Todo> _todos = [];
  bool _isLoading = false;
  String? _error;
  TodoFilter _filter = TodoFilter.all;
  SortBy _sortBy = SortBy.createdAt;
  bool _sortAscending = false;
  String? _priorityFilter;
  String? _categoryFilter;
  int _syncVersion = 0;
  bool _isOffline = false;

  TodoProvider({
    required ApiService apiService,
    required StorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  List<Todo> get todos => _getFilteredTodos();
  bool get isLoading => _isLoading;
  String? get error => _error;
  TodoFilter get filter => _filter;
  SortBy get sortBy => _sortBy;
  bool get sortAscending => _sortAscending;
  String? get priorityFilter => _priorityFilter;
  String? get categoryFilter => _categoryFilter;
  int get syncVersion => _syncVersion;
  bool get isOffline => _isOffline;

  /// 设置认证Token
  void setToken(String? token) {
    _apiService.setToken(token);
  }

  /// 设置离线状态
  void setOffline(bool offline) {
    _isOffline = offline;
    notifyListeners();
  }

  List<Todo> _getFilteredTodos() {
    List<Todo> filtered = List.from(_todos);

    // Apply status filter
    switch (_filter) {
      case TodoFilter.active:
        filtered = filtered.where((t) => !t.completed).toList();
        break;
      case TodoFilter.completed:
        filtered = filtered.where((t) => t.completed).toList();
        break;
      case TodoFilter.all:
        break;
    }

    // Apply priority filter
    if (_priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == _priorityFilter).toList();
    }

    // Apply category filter
    if (_categoryFilter != null) {
      filtered = filtered.where((t) => t.category == _categoryFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int result;
      switch (_sortBy) {
        case SortBy.createdAt:
          result = a.createdAt.compareTo(b.createdAt);
          break;
        case SortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            result = 0;
          } else if (a.dueDate == null) {
            result = 1;
          } else if (b.dueDate == null) {
            result = -1;
          } else {
            result = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case SortBy.priority:
          const order = {'high': 0, 'medium': 1, 'low': 2};
          result = (order[a.priority] ?? 1).compareTo(order[b.priority] ?? 1);
          break;
      }
      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  void setFilter(TodoFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSortBy(SortBy sortBy) {
    if (_sortBy == sortBy) {
      _sortAscending = !_sortAscending;
    } else {
      _sortBy = sortBy;
      _sortAscending = false;
    }
    notifyListeners();
  }

  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    notifyListeners();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearFilters() {
    _filter = TodoFilter.all;
    _priorityFilter = null;
    _categoryFilter = null;
    notifyListeners();
  }

  Future<void> loadTodos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 尝试同步
      if (!_isOffline) {
        await syncTodos();
      } else {
        _todos = await _apiService.getTodos();
        await _storageService.cacheTodos(_todos);
      }
    } catch (e) {
      _error = e.toString();
      // 离线模式：尝试从缓存加载
      try {
        _todos = await _storageService.getCachedTodos();
      } catch (_) {
        // 忽略缓存错误
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// 同步待办数据
  Future<void> syncTodos() async {
    try {
      // 获取本地缓存的待办
      final cachedTodos = await _storageService.getCachedTodos();
      
      // 准备同步数据
      final syncData = cachedTodos.map((t) => t.toJson()).toList();
      
      // 调用同步API
      final result = await _apiService.syncTodos(
        todos: syncData,
        lastSyncVersion: _syncVersion,
      );
      
      if (result['success'] == true) {
        // 更新同步版本
        _syncVersion = result['sync_version'] as int? ?? _syncVersion + 1;
        
        // 更新本地数据
        final serverTodos = (result['todos'] as List)
            .map((json) => Todo.fromJson(json as Map<String, dynamic>))
            .toList();
        
        _todos = serverTodos;
        await _storageService.cacheTodos(_todos);
      }
    } catch (e) {
      _error = e.toString();
      // 同步失败，尝试普通加载
      _todos = await _apiService.getTodos();
      await _storageService.cacheTodos(_todos);
    }
  }

  Future<bool> createTodo({
    required String title,
    String? description,
    String priority = 'medium',
    String category = 'general',
    DateTime? dueDate,
  }) async {
    try {
      final todo = await _apiService.createTodo(
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
      );
      _todos.insert(0, todo);
      await _storageService.cacheTodo(todo);
      notifyListeners();
      // 更新桌面小组件
      WidgetService.updateWidget();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodo(int id, Map<String, dynamic> data) async {
    try {
      final updatedTodo = await _apiService.updateTodo(id, data);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        await _storageService.cacheTodo(updatedTodo);
        notifyListeners();
        // 更新桌面小组件
        WidgetService.updateWidget();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo(int id) async {
    try {
      await _apiService.deleteTodo(id);
      _todos.removeWhere((t) => t.id == id);
      await _storageService.deleteCachedTodo(id);
      notifyListeners();
      // 更新桌面小组件
      WidgetService.updateWidget();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTodo(int id) async {
    try {
      final updatedTodo = await _apiService.toggleTodo(id);
      final index = _todos.indexWhere((t) => t.id == id);
      if (index != -1) {
        _todos[index] = updatedTodo;
        await _storageService.cacheTodo(updatedTodo);
        notifyListeners();
        // 更新桌面小组件
        WidgetService.updateWidget();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Todo? getTodoById(int id) {
    try {
      return _todos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
