# Todo Mobile - 待办事项应用 (Flutter)

一个基于 Flutter 的跨平台待办事项管理移动应用，支持 iOS、Android。

## 与 todo_app 的关系

| 项目 | 说明 |
|------|------|
| **todo_app** | 后端 API 服务（Flask + PostgreSQL + Docker），提供 REST API |
| **todo_mobile** | 移动端应用（Flutter），作为客户端消费 todo_app 提供的 API |

移动端通过 HTTP API 与后端服务通信，实现用户认证、待办 CRUD、数据同步等功能。

## 技术栈

| 类别 | 技术 |
|-----|------|
| 框架 | Flutter 3.x |
| 状态管理 | Provider |
| HTTP 客户端 | Dio |
| 本地存储 | SQLite (sqflite) |
| 状态持久化 | shared_preferences |

## 功能特性

### 用户功能
- 用户注册/登录
- JWT Token 认证
- 头像查看与修改
- 用户名修改
- 登出功能

### 待办功能
- 待办事项 CRUD（创建、读取、更新、删除）
- 优先级分类（高/中/低）
- 截止日期设置
- 完成状态切换
- 列表筛选与排序

### 移动端特色
- 深色/浅色主题切换
- Android 桌面小组件（需 Android 12+）
- 离线操作支持
- 与 todo_app 后端数据同步

## 项目结构

```
todo_mobile/
├── lib/
│   ├── main.dart              # 应用入口
│   ├── config/                # 配置
│   │   ├── api_config.dart    # API 配置
│   │   └── theme.dart         # 主题配置
│   ├── models/                # 数据模型
│   │   ├── user.dart          # 用户模型
│   │   └── todo.dart          # 待办模型
│   ├── providers/             # 状态管理
│   │   ├── auth_provider.dart # 认证状态
│   │   ├── todo_provider.dart # 待办状态
│   │   └── settings_provider.dart # 设置状态
│   ├── services/              # 服务层
│   │   ├── api_service.dart   # API 服务
│   │   ├── auth_service.dart  # 认证服务
│   │   └── storage_service.dart # 本地存储
│   ├── screens/               # 页面
│   │   ├── login_screen.dart      # 登录页
│   │   ├── register_screen.dart  # 注册页
│   │   ├── home_screen.dart      # 首页
│   │   ├── create_todo_screen.dart # 创建待办
│   │   ├── edit_todo_screen.dart  # 编辑待办
│   │   ├── detail_screen.dart     # 待办详情
│   │   ├── profile_screen.dart    # 个人资料
│   │   └── settings_screen.dart   # 设置页
│   └── widgets/               # 组件
│       ├── filter_bar.dart         # 筛选栏
│       ├── priority_badge.dart     # 优先级标签
│       ├── swipeable_todo_card.dart # 可滑动待办卡片
│       ├── todo_card.dart          # 待办卡片
│       └── todo_list.dart          # 待办列表
├── pubspec.yaml               # 依赖配置
├── android/                   # Android 配置
└── ios/                       # iOS 配置
```

## 快速开始

### 环境要求

- Flutter SDK 3.x
- Dart 3.x

### 安装依赖

```bash
cd todo_mobile
flutter pub get
```

### 运行应用

```bash
# 运行调试版本
flutter run

# 构建 APK
flutter build apk

# 构建 iOS
flutter build ios
```


## API 配置

应用默认连接 `http://49.232.224.106:5000`（TC Server），可在设置中修改服务器地址。

## 依赖包

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  dio: ^5.0.0
  sqflite: ^2.0.0
  shared_preferences: ^2.0.0
  intl: ^0.18.0
  image_picker: ^1.0.0
```

## 许可证

MIT License
