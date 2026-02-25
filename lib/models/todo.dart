class Todo {
  final int? id; // 服务器ID，离线时可能为null
  final String? localId; // 本地ID，用于离线同步
  final String title;
  final String? description;
  final bool completed;
  final String priority;
  final String category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int syncVersion;

  Todo({
    this.id,
    this.localId,
    required this.title,
    this.description,
    required this.completed,
    required this.priority,
    required this.category,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.syncVersion = 1,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int?,
      localId: json['local_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String? ?? 'general',
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      syncVersion: json['sync_version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'local_id': localId,
      'title': title,
      'description': description,
      'completed': completed,
      'priority': priority,
      'category': category,
      'due_date': dueDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_version': syncVersion,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id ?? 0,
      'local_id': localId,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'priority': priority,
      'category': category,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'sync_version': syncVersion,
    };
  }

  factory Todo.fromDbMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int?,
      localId: map['local_id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      completed: (map['completed'] as int) == 1,
      priority: map['priority'] as String,
      category: map['category'] as String,
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncVersion: map['sync_version'] as int? ?? 1,
    );
  }

  Todo copyWith({
    int? id,
    String? localId,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncVersion,
  }) {
    return Todo(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }

  static const List<String> validPriorities = ['low', 'medium', 'high'];
  static const List<String> validCategories = [
    'general',
    'work',
    'personal',
    'study',
    'other'
  ];
}
