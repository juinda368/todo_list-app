import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _useCodeLogin = false;
  bool _isLoading = false;
  int _countdown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('请输入邮箱地址');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendCode(email, 'login');
    
    if (success) {
      _showSuccess('验证码已发送');
      setState(() => _countdown = 60);
      _startCountdown();
    } else {
      _showError(authProvider.error ?? '发送失败');
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    bool success;

    if (_useCodeLogin) {
      success = await authProvider.loginWithCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );
    } else {
      success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      _showError(authProvider.error ?? '登录失败');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
            child: const Text('注册'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 登录方式切换
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('密码登录')),
                  ButtonSegment(value: true, label: Text('验证码登录')),
                ],
                selected: {_useCodeLogin},
                onSelectionChanged: (value) {
                  setState(() => _useCodeLogin = value.first);
                },
              ),
              const SizedBox(height: 24),

              // 邮箱
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '邮箱',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 验证码输入（仅验证码登录时显示）
              if (_useCodeLogin) ...[
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: '验证码',
                    prefixIcon: const Icon(Icons.code),
                    border: const OutlineInputBorder(),
                    suffixIcon: TextButton(
                      onPressed: _countdown > 0 ? null : _sendCode,
                      child: Text(_countdown > 0 ? '${_countdown}s' : '发送验证码'),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  validator: (value) {
                    if (_useCodeLogin && (value == null || value.isEmpty)) {
                      return '请输入验证码';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // 密码输入（仅密码登录时显示）
              if (!_useCodeLogin)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!_useCodeLogin && (value == null || value.isEmpty)) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
              
              const SizedBox(height: 24),

              // 登录按钮
              FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('登录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
