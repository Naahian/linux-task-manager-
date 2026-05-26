enum BoardStatus { notStarted, inProgress, completed }

class TodoItem {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Task {
  String id;
  String title;
  BoardStatus status;
  List<TodoItem> todos;
  DateTime createdAt;
  DateTime? dueDate;
  String groupId;

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.todos,
    required this.createdAt,
    required this.groupId,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      status: BoardStatus.values.firstWhere(
        (e) => e.toString() == 'BoardStatus.${json['status']}',
      ),
      todos: (json['todos'] as List)
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      groupId: json['groupId'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status.toString().split('.').last,
      'todos': todos.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'groupId': groupId,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    BoardStatus? status,
    List<TodoItem>? todos,
    DateTime? createdAt,
    DateTime? dueDate,
    String? groupId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      todos: todos ?? this.todos,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      groupId: groupId ?? this.groupId,
    );
  }

  int get completedTodosCount => todos.where((todo) => todo.isCompleted).length;

  double get completionPercentage =>
      todos.isEmpty ? 0 : (completedTodosCount / todos.length) * 100;
}

class TaskGroup {
  String id;
  String name;
  DateTime createdAt;
  List<String> taskIds;
  String? notes;

  TaskGroup({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.taskIds,
    this.notes,
  });

  factory TaskGroup.fromJson(Map<String, dynamic> json) {
    return TaskGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      taskIds: List<String>.from(json['taskIds'] as List),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'taskIds': taskIds,
      'notes': notes,
    };
  }

  TaskGroup copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<String>? taskIds,
    String? notes,
  }) {
    return TaskGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      taskIds: taskIds ?? this.taskIds,
      notes: notes ?? this.notes,
    );
  }
}
