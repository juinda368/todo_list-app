import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'providers/todo_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = StorageService();
  final settingsProvider = SettingsProvider(storageService: storageService);
  await settingsProvider.init();

  // Initialize API service with saved server URL
  final apiService = ApiService(baseUrl: settingsProvider.serverUrl);
  final authService = AuthService(baseUrl: settingsProvider.serverUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsProvider),
        ChangeNotifierProvider(
          create: (_) => TodoProvider(
            apiService: apiService,
            storageService: storageService,
          )..setToken(null), // 初始无token
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storageService: storageService,
          ),
        ),
      ],
      child: const AuthSyncWrapper(),
    ),
  );
}

/// 同步认证状态的包装器
class AuthSyncWrapper extends StatefulWidget {
  const AuthSyncWrapper({super.key});

  @override
  State<AuthSyncWrapper> createState() => _AuthSyncWrapperState();
}

class _AuthSyncWrapperState extends State<AuthSyncWrapper> {
  @override
  void initState() {
    super.initState();
    // 监听认证状态变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToken();
      context.read<AuthProvider>().addListener(_syncToken);
    });
  }

  void _syncToken() {
    final authProvider = context.read<AuthProvider>();
    final todoProvider = context.read<TodoProvider>();
    todoProvider.setToken(authProvider.token);
  }

  @override
  void dispose() {
    context.read<AuthProvider>().removeListener(_syncToken);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        // 当认证状态变化时，同步token
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<TodoProvider>().setToken(auth.token);
        });
        
        return Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return MaterialApp(
              title: '待办事项',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const HomeScreen(),
            );
          },
        );
      },
    );
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: '待办事项',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}
