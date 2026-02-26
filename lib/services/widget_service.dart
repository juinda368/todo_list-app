import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class WidgetService {
  static const String appGroupId = 'group.com.example.todo';
  static const String widgetName = 'TodoWidgetProvider';
  static const String apiUrl = 'http://10.0.2.2:5000/api/todos/today-widget';

  /// 更新小组件数据
  static Future<void> updateWidget() async {
    try {
      // 获取本地存储的token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print('用户未登录，无法更新小组件');
        return;
      }

      // 从后端获取今日待办数据
      final response = await Dio().get(
        apiUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final todos = data['todos'] as List;

          // 保存待办数量
          await HomeWidget.saveWidgetData<int>('todo_count', todos.length);

          // 保存待办列表数据
          for (int i = 0; i < todos.length && i < 5; i++) {
            await HomeWidget.saveWidgetData<String>(
              'todo_${i}_title',
              todos[i]['title'] ?? '',
            );
            await HomeWidget.saveWidgetData<bool>(
              'todo_${i}_completed',
              todos[i]['completed'] ?? false,
            );
          }

          // 通知小组件更新
          await HomeWidget.updateWidget(
            androidName: widgetName,
          );
        }
      }
    } catch (e) {
      print('更新小组件失败: $e');
    }
  }

  /// 初始化小组件
  static Future<void> initWidget() async {
    try {
      // 注册小组件更新回调
      HomeWidget.widgetClicked.listen((uri) async {
        // 点击小组件时的处理
        print('小组件被点击: $uri');
      });
    } catch (e) {
      print('初始化小组件失败: $e');
    }
  }
}
