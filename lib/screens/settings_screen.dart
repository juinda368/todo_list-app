import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:home_widget/home_widget.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _serverUrlController.text = settings.serverUrl;
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              // Server URL
              ListTile(
                leading: const Icon(Icons.dns),
                title: const Text('服务器地址'),
                subtitle: Text(
                  settings.serverUrl.isEmpty
                      ? '未设置'
                      : settings.serverUrl,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _showServerUrlDialog(settings),
              ),
              const Divider(),

              // Theme
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('深色模式'),
                subtitle: const Text('切换应用主题'),
                value: settings.isDarkMode,
                onChanged: (value) => settings.setDarkMode(value),
              ),
              const Divider(),

              // Add widget (Android only)
              ListTile(
                leading: const Icon(Icons.widgets),
                title: const Text('添加桌面组件'),
                subtitle: const Text('将待办小组件添加到桌面'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _addWidget,
              ),
              const Divider(),

              // About
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('关于'),
                subtitle: const Text('版本 1.0.0'),
                onTap: () => _showAboutDialog(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showServerUrlDialog(SettingsProvider settings) {
    _serverUrlController.text = settings.serverUrl;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置服务器地址'),
        content: TextField(
          controller: _serverUrlController,
          decoration: const InputDecoration(
            labelText: '服务器地址',
            hintText: 'http://49.232.224.106:5000', // TC Server
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final url = _serverUrlController.text.trim();
              await settings.setServerUrl(url);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('服务器地址已保存')),
                );
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _addWidget() async {
    if (Platform.isAndroid) {
      try {
        // 提示用户手动添加小组件
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '请在手机桌面长按空白区域，选择"小部件"，找到"待办事项"并添加',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        // 如果失败，显示引导信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '请手动添加桌面小组件：设置 > 桌面 > 小部件 > 待办事项',
              ),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '知道了',
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('桌面小组件仅支持Android系统'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '待办事项',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 待办事项团队',
      children: [
        const SizedBox(height: 16),
        const Text('一个简洁高效的待办事项管理应用'),
      ],
    );
  }
}
