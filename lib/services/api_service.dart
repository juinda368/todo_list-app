import 'package:dio/dio.dart';
import '../models/todo.dart';
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  String _baseUrl;
  String? _token;

  ApiService({String? baseUrl}) : _baseUrl = ApiConfig.getBaseUrl(baseUrl) {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  void updateBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    _dio.options.baseUrl = newBaseUrl;
  }

  void setToken(String? token) {
    _token = token;
  }

  String get baseUrl => _baseUrl;

  Map<String, dynamic> get _authHeaders {
    final headers = <String, dynamic>{};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<Todo>> getTodos({
    String? completed,
    String? priority,
    String? category,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (completed != null) queryParams['completed'] = completed;
      if (priority != null) queryParams['priority'] = priority;
      if (category != null) queryParams['category'] = category;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final response = await _dio.get(
        '/api/todos',
        queryParameters: queryParams,
        options: Options(headers: _authHeaders),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => Todo.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> createTodo({
    required String title,
    String? description,
    String priority = 'medium',
    String category = 'general',
    DateTime? dueDate,
    String? localId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/todos',
        data: {
          'title': title,
          'description': description,
          'priority': priority,
          'category': category,
          'due_date': dueDate?.toIso8601String(),
          'local_id': localId,
        },
        options: Options(headers: _authHeaders),
      );
      return Todo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> getTodo(int id) async {
    try {
      final response = await _dio.get(
        '/api/todos/$id',
        options: Options(headers: _authHeaders),
      );
      return Todo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> updateTodo(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/todos/$id',
        data: data,
        options: Options(headers: _authHeaders),
      );
      return Todo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      await _dio.delete(
        '/api/todos/$id',
        options: Options(headers: _authHeaders),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Todo> toggleTodo(int id) async {
    try {
      final response = await _dio.patch(
        '/api/todos/$id/toggle',
        options: Options(headers: _authHeaders),
      );
      return Todo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 同步待办数据
  Future<Map<String, dynamic>> syncTodos({
    required List<Map<String, dynamic>> todos,
    required int lastSyncVersion,
  }) async {
    try {
      final response = await _dio.post(
        '/api/sync',
        data: {
          'todos': todos,
          'last_sync_version': lastSyncVersion,
        },
        options: Options(headers: _authHeaders),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '连接超时，请检查网络';
        break;
      case DioExceptionType.connectionError:
        message = '无法连接服务器，请检查网络';
        break;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map) {
          message = (data['message'] ?? data['error'] ?? '请求失败') as String;
        } else if (statusCode == 404) {
          message = '资源未找到';
        } else if (statusCode == 401) {
          message = '登录已过期，请重新登录';
        } else if (statusCode == 500) {
          message = '服务器内部错误';
        } else {
          message = '请求失败 ($statusCode)';
        }
        break;
      default:
        message = '网络请求失败';
    }
    return Exception(message);
  }
}
