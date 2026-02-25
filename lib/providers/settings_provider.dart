import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  String _serverUrl = '';
  bool _isDarkMode = false;
  bool _isInitialized = false;

  SettingsProvider({required StorageService storageService})
      : _storageService = storageService;

  String get serverUrl => _serverUrl;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _serverUrl = await _storageService.getServerUrl() ?? '';
    _isDarkMode = await _storageService.isDarkMode();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    await _storageService.setServerUrl(url);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _storageService.setDarkMode(isDark);
    notifyListeners();
  }
}
