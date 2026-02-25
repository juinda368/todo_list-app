import 'package:dio/dio.dart';
import '../models/user.dart';

/// 认证服务
class AuthService {
  late Dio _dio;

  AuthService({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://localhost:5000',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// 发送验证码
  Future<Map<String, dynamic>> sendCode(String email, String purpose) async {
    try {
      final response = await _dio.post(
        '/api/auth/send-code',
        data: {'email': email, 'purpose': purpose},
      );
      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? '',
        'code': response.data['code'], // 开发模式下返回验证码
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 密码登录
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'token': response.data['token'] as String,
          'user': User.fromJson(response.data['user'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '登录失败',
        };
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 验证码登录
  Future<Map<String, dynamic>> loginWithCode(String email, String code) async {
    try {
      final response = await _dio.post(
        '/api/auth/login-with-code',
        data: {'email': email, 'code': code},
      );
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'token': response.data['token'] as String,
          'user': User.fromJson(response.data['user'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '登录失败',
        };
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 注册
  Future<Map<String, dynamic>> register(
    String email,
    String code,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'email': email,
          'code': code,
          'password': password,
        },
      );
      
      if (response.data['success'] == true) {
        return {
          'success': true,
          'token': response.data['token'] as String,
          'user': User.fromJson(response.data['user'] as Map<String, dynamic>),
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? '注册失败',
        };
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取当前用户信息
  Future<User> getMe(String token) async {
    try {
      final response = await _dio.get(
        '/api/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data['success'] == true) {
        return User.fromJson(response.data['user'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? '获取用户信息失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 更新用户信息
  Future<User> updateMe(String token, {String? username, String? avatarUrl}) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _dio.put(
        '/api/auth/me',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data['success'] == true) {
        return User.fromJson(response.data['user'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? '更新失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 上传头像
  Future<String> uploadAvatar(String token, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '/api/auth/avatar',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data['success'] == true) {
        return response.data['avatar_url'] as String;
      } else {
        throw Exception(response.data['message'] ?? '上传失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// 刷新Token
  Future<String> refreshToken(String token) async {
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.data['success'] == true) {
        return response.data['token'] as String;
      } else {
        throw Exception('Token刷新失败');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'] as String;
      }
      return '服务器错误: ${e.response?.statusCode}';
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '连接超时，请检查网络';
      case DioExceptionType.connectionError:
        return '无法连接服务器';
      default:
        return '网络错误';
    }
  }
}
