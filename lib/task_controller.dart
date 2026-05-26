import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'task_model.dart';

class TaskController extends ChangeNotifier {
  late SharedPreferences _prefs;
  List<TaskGroup> _taskGroups = [];
  List<Task> _tasks = [];
  String? _selectedGroupId;

  bool _isLoading = true;

  // Getters
  List<TaskGroup> get taskGroups => _taskGroups;
  List<Task> get tasks => _tasks;
  String? get selectedGroupId => _selectedGroupId;
  bool get isLoading => _isLoading;

  // Storage keys
  static const String _taskGroupsKey = 'task_groups';
  static const String _tasksKey = 'tasks';

  // Initialize
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing TaskController: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      // Save task groups (without notes - they're saved separately)
      final groupsJson = _taskGroups.map((g) {
        debugPrint('Saving group ${g.name} (notes saved separately)');
        return jsonEncode(g.toJson());
      }).toList();
      await _prefs.setStringList(_taskGroupsKey, groupsJson);

      // Save notes separately for each group to avoid size limits
      for (var group in _taskGroups) {
        if (group.notes != null && group.notes!.isNotEmpty) {
          final notesKey = 'group_notes_${group.id}';
          await _prefs.setString(notesKey, group.notes!);
          debugPrint(
            'Saved notes for group ${group.name} (${group.notes!.length} bytes)',
          );
        }
      }

      final tasksJson = _tasks.map((t) => jsonEncode(t.toJson())).toList();
      await _prefs.setStringList(_tasksKey, tasksJson);

      debugPrint('Data saved successfully');
    } catch (e) {
      debugPrint('Error saving data: $e');
    }
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      debugPrint('=== LOADING DATA ===');

      // Load task groups
      final groupsJson = _prefs.getStringList(_taskGroupsKey) ?? [];
      debugPrint('Raw groups JSON count: ${groupsJson.length}');

      _taskGroups = groupsJson
          .map((json) => TaskGroup.fromJson(jsonDecode(json)))
          .toList();

      // Load notes separately for each group
      for (var group in _taskGroups) {
        final notesKey = 'group_notes_${group.id}';
        final savedNotes = _prefs.getString(notesKey);
        if (savedNotes != null) {
          group.notes = savedNotes;
          debugPrint(
            'Loaded notes for group ${group.name} (${savedNotes.length} bytes)',
          );
        }
      }

      debugPrint('Loaded ${_taskGroups.length} task groups');
      for (var group in _taskGroups) {
        debugPrint(
          'Group: ${group.name}, Notes length: ${group.notes?.length ?? 0}',
        );
        if (group.notes != null && group.notes!.isNotEmpty) {
          debugPrint(
            '  Notes (first 100 chars): ${group.notes!.substring(0, group.notes!.length > 100 ? 100 : group.notes!.length)}',
          );
        }
      }

      // Load tasks
      final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
      _tasks = tasksJson
          .map((json) => Task.fromJson(jsonDecode(json)))
          .toList();

      debugPrint('Loaded ${_tasks.length} tasks');
      debugPrint('=== DATA LOADING COMPLETE ===');

      // Create default group if none exists
      if (_taskGroups.isEmpty) {
        await createTaskGroup('Default');
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      debugPrint(e.toString());
    }
  }

  // GROUP Operations
  // ===========================================================

  Future<void> createTaskGroup(String name) async {
    const uuid = Uuid();
    final group = TaskGroup(
      id: uuid.v4(),
      name: name,
      createdAt: DateTime.now(),
      taskIds: [],
    );
    _taskGroups.add(group);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateTaskGroup(String groupId, String newName) async {
    final index = _taskGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      _taskGroups[index] = _taskGroups[index].copyWith(name: newName);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTaskGroup(String groupId) async {
    // Delete all tasks in this group
    _tasks.removeWhere((task) => task.groupId == groupId);
    _taskGroups.removeWhere((g) => g.id == groupId);

    // Delete notes for this group
    final notesKey = 'group_notes_$groupId';
    await _prefs.remove(notesKey);

    await _saveData();
    notifyListeners();
  }

  void updateGroupSelection(String? groupId) {
    _selectedGroupId = groupId;
    notifyListeners();
  }

  // NOTE Operations
  // ===========================================================

  Future<void> updateGroupNotes(String groupId, String notesDelta) async {
    final index = _taskGroups.indexWhere((g) => g.id == groupId);
    if (index != -1) {
      debugPrint('=== UPDATING NOTES ===');
      debugPrint('Group ID: $groupId');
      debugPrint('Notes Delta Length: ${notesDelta.length}');
      debugPrint(
        'Notes Content (first 100 chars): ${notesDelta.substring(0, notesDelta.length > 100 ? 100 : notesDelta.length)}',
      );

      _taskGroups[index] = _taskGroups[index].copyWith(notes: notesDelta);

      debugPrint('Updated in memory, now saving...');
      await _saveData();
      debugPrint('Save completed, notifying listeners...');
      notifyListeners();
      debugPrint('=== NOTES UPDATE COMPLETE ===');
    } else {
      debugPrint('Group $groupId not found!');
    }
  }

  String? getGroupNotes(String groupId) {
    final group = getTaskGroupById(groupId);
    debugPrint('=== RETRIEVING NOTES ===');
    debugPrint('Group ID: $groupId');
    debugPrint('Notes exists: ${group?.notes != null}');
    debugPrint('Notes length: ${group?.notes?.length ?? 0}');
    if (group?.notes != null) {
      debugPrint(
        'Notes (first 100 chars): ${group!.notes!.substring(0, group.notes!.length > 100 ? 100 : group.notes!.length)}',
      );
    }
    return group?.notes;
  }

  // TASK Operations
  // ===========================================================

  Future<void> createTask(String groupId, String title) async {
    const uuid = Uuid();
    final task = Task(
      id: uuid.v4(),
      title: title,
      status: BoardStatus.notStarted,
      todos: [],
      createdAt: DateTime.now(),
      groupId: groupId,
    );
    _tasks.add(task);

    // Add task to group
    final groupIndex = _taskGroups.indexWhere((g) => g.id == groupId);
    if (groupIndex != -1) {
      _taskGroups[groupIndex].taskIds.add(task.id);
    }

    await _saveData();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);

    // Remove from group
    final groupIndex = _taskGroups.indexWhere((g) => g.id == task.groupId);
    if (groupIndex != -1) {
      _taskGroups[groupIndex].taskIds.remove(taskId);
    }

    _tasks.removeWhere((t) => t.id == taskId);
    await _saveData();
    notifyListeners();
  }

  Future<void> moveTaskToStatus(String taskId, BoardStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: newStatus);
      await _saveData();
      notifyListeners();
    }
  }

  // Todo Operations
  Future<void> addTodoToTask(String taskId, String todoTitle) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      const uuid = Uuid();
      final newTodo = TodoItem(
        id: uuid.v4(),
        title: todoTitle,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      _tasks[taskIndex].todos.add(newTodo);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> toggleTodoCompletion(String taskId, String todoId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final todoIndex = _tasks[taskIndex].todos.indexWhere(
        (todo) => todo.id == todoId,
      );
      if (todoIndex != -1) {
        final todo = _tasks[taskIndex].todos[todoIndex];
        _tasks[taskIndex].todos[todoIndex] = todo.copyWith(
          isCompleted: !todo.isCompleted,
        );
        await _saveData();
        notifyListeners();
      }
    }
  }

  Future<void> deleteTodoFromTask(String taskId, String todoId) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].todos.removeWhere((todo) => todo.id == todoId);
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> updateTodoTitle(
    String taskId,
    String todoId,
    String newTitle,
  ) async {
    final taskIndex = _tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex != -1) {
      final todoIndex = _tasks[taskIndex].todos.indexWhere(
        (todo) => todo.id == todoId,
      );
      if (todoIndex != -1) {
        final todo = _tasks[taskIndex].todos[todoIndex];
        _tasks[taskIndex].todos[todoIndex] = todo.copyWith(title: newTitle);
        await _saveData();
        notifyListeners();
      }
    }
  }

  // Utility methods
  List<Task> getTasksByGroupAndStatus(String groupId, BoardStatus status) {
    return _tasks
        .where((task) => task.groupId == groupId && task.status == status)
        .toList();
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  TaskGroup? getTaskGroupById(String groupId) {
    try {
      return _taskGroups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  int getTaskCountByStatus(String groupId, BoardStatus status) {
    return getTasksByGroupAndStatus(groupId, status).length;
  }
}
