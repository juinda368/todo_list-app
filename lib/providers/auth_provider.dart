import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

/// 认证状态管理
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required AuthService authService,
    required StorageService storageService,
  })  : _authService = authService,
        _storageService = storageService {
    _loadStoredAuth();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _user != null;
  String? get error => _error;

  /// 从本地存储加载认证信息
  Future<void> _loadStoredAuth() async {
    final token = await _storageService.getToken();
    final userJson = await _storageService.getUser();
    
    if (token != null && userJson != null) {
      _token = token;
      _user = User.fromJson(userJson);
      notifyListeners();
    }
  }

  /// 发送验证码
  Future<bool> sendCode(String email, String purpose) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.sendCode(email, purpose);
      _isLoading = false;
      
      if (result['success'] == true) {
        return true;
      } else {
        _error = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 密码登录
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _isLoading = false;

      if (result['success'] == true) {
        _token = result['token'] as String;
        _user = result['user'] as User;
        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!.toJson());
        notifyListeners();
        return true;
      } else {
        _error = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 验证码登录
  Future<bool> loginWithCode(String email, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.loginWithCode(email, code);
      _isLoading = false;

      if (result['success'] == true) {
        _token = result['token'] as String;
        _user = result['user'] as User;
        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!.toJson());
        notifyListeners();
        return true;
      } else {
        _error = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 注册
  Future<bool> register(String email, String code, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(email, code, password);
      _isLoading = false;

      if (result['success'] == true) {
        _token = result['token'] as String;
        _user = result['user'] as User;
        await _storageService.saveToken(_token!);
        await _storageService.saveUser(_user!.toJson());
        notifyListeners();
        return true;
      } else {
        _error = result['message'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _storageService.deleteToken();
    await _storageService.deleteUser();
    _token = null;
    _user = null;
    notifyListeners();
  }

  /// 更新用户信息
  Future<bool> updateProfile({String? username, String? avatarUrl}) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.updateMe(
        _token!,
        username: username,
        avatarUrl: avatarUrl,
      );
      await _storageService.saveUser(_user!.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 上传头像
  Future<bool> uploadAvatar(String filePath) async {
    if (_token == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final avatarUrl = await _authService.uploadAvatar(_token!, filePath);
      _user = _user!.copyWith(avatarUrl: avatarUrl);
      await _storageService.saveUser(_user!.toJson());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// 刷新用户信息
  Future<void> refreshUser() async {
    if (_token == null) return;

    try {
      _user = await _authService.getMe(_token!);
      await _storageService.saveUser(_user!.toJson());
      notifyListeners();
    } catch (e) {
      // Token可能过期，退出登录
      if (e.toString().contains('401')) {
        await logout();
      }
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
