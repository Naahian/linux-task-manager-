import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_model.dart';
import 'task_controller.dart';

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({Key? key}) : super(key: key);

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> {
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TaskController>();
      if (controller.taskGroups.isNotEmpty && _selectedGroupId == null) {
        setState(() {
          _selectedGroupId = controller.taskGroups.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskController, _) {
        if (taskController.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_selectedGroupId == null && taskController.taskGroups.isNotEmpty) {
          _selectedGroupId = taskController.taskGroups.first.id;
        }

        return Scaffold(
          body: Row(
            children: [
              _buildSidebar(context, taskController),
              Expanded(child: _buildMainContent(context, taskController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, TaskController controller) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TaskFlow',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your work beautifully',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: controller.taskGroups.length,
              itemBuilder: (context, index) {
                final group = controller.taskGroups[index];
                final isSelected = group.id == _selectedGroupId;
                return _buildGroupTile(context, group, isSelected, controller);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddGroupDialog(context, controller),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Group'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(
    BuildContext context,
    TaskGroup group,
    bool isSelected,
    TaskController controller,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(
            Icons.folder_outlined,
            size: 20,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade400,
          ),
          title: Text(
            group.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade700,
            ),
          ),
          trailing: PopupMenuButton(
            icon: Icon(Icons.more_horiz, size: 18, color: Colors.grey.shade500),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditGroupDialog(context, group, controller);
              } else if (value == 'delete') {
                controller.deleteTaskGroup(group.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          selected: isSelected,
          selectedTileColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.08),
          onTap: () {
            setState(() {
              _selectedGroupId = group.id;
            });
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, TaskController controller) {
    if (_selectedGroupId == null) {
      return const Center(child: Text('Select a group'));
    }

    final group = controller.getTaskGroupById(_selectedGroupId!);
    if (group == null) {
      return const Center(child: Text('Group not found'));
    }

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${group.taskIds.length} tasks',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FilledButton.icon(
                    onPressed: () => _showAddTaskDialog(context, controller),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Task'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  _buildBoard(
                    context,
                    controller,
                    'Not Started',
                    BoardStatus.notStarted,
                    group.id,
                    Icons.circle_outlined,
                  ),
                  const SizedBox(width: 24),
                  _buildBoard(
                    context,
                    controller,
                    'In Progress',
                    BoardStatus.inProgress,
                    group.id,
                    Icons.play_circle_outline,
                  ),
                  const SizedBox(width: 24),
                  _buildBoard(
                    context,
                    controller,
                    'Completed',
                    BoardStatus.completed,
                    group.id,
                    Icons.check_circle_outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(
    BuildContext context,
    TaskController controller,
    String title,
    BoardStatus status,
    String groupId,
    IconData icon,
  ) {
    final tasks = controller.getTasksByGroupAndStatus(groupId, status);
    final count = tasks.length;

    return Expanded(
      child: DragTarget<BoardStatus>(
        onWillAccept: (data) {
          return data != null && data != status;
        },
        onAccept: (data) {
          // This will be handled by the drag target of the specific task
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: status == BoardStatus.completed
                              ? Colors.green.shade50
                              : status == BoardStatus.inProgress
                              ? Colors.blue.shade50
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          size: 18,
                          color: status == BoardStatus.completed
                              ? Colors.green.shade600
                              : status == BoardStatus.inProgress
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$count ${count == 1 ? 'task' : 'tasks'}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DragTarget<Map<String, dynamic>>(
                    onWillAccept: (data) {
                      if (data == null) return false;
                      final taskStatus = data['status'] as BoardStatus;
                      return taskStatus != status;
                    },
                    onAccept: (data) {
                      final taskId = data['taskId'] as String;
                      controller.moveTaskToStatus(taskId, status);
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: candidateData.isNotEmpty
                              ? Colors.blue.shade50
                              : Colors.transparent,
                        ),
                        child: tasks.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 48,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No tasks',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade400,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  return _buildTaskCard(
                                    context,
                                    tasks[index],
                                    controller,
                                    status,
                                  );
                                },
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    TaskController controller,
    BoardStatus currentStatus,
  ) {
    return Draggable<Map<String, dynamic>>(
      data: {'taskId': task.id, 'status': currentStatus},
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.25,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: task.status == BoardStatus.completed
                            ? Colors.green.shade400
                            : task.status == BoardStatus.inProgress
                            ? Colors.blue.shade400
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (task.todos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: task.completionPercentage / 100,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(
                        task.status == BoardStatus.completed
                            ? Colors.green.shade400
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildTaskCardContent(context, task, controller),
      ),
      child: _buildTaskCardContent(context, task, controller),
    );
  }

  Widget _buildTaskCardContent(
    BuildContext context,
    Task task,
    TaskController controller,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade50,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTaskDetailsDialog(context, task, controller),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: task.status == BoardStatus.completed
                            ? Colors.green.shade400
                            : task.status == BoardStatus.inProgress
                            ? Colors.blue.shade400
                            : Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton(
                      icon: Icon(
                        Icons.more_horiz,
                        size: 18,
                        color: Colors.grey.shade500,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          controller.deleteTask(task.id);
                        } else if (value == 'notStarted') {
                          controller.moveTaskToStatus(
                            task.id,
                            BoardStatus.notStarted,
                          );
                        } else if (value == 'inProgress') {
                          controller.moveTaskToStatus(
                            task.id,
                            BoardStatus.inProgress,
                          );
                        } else if (value == 'completed') {
                          controller.moveTaskToStatus(
                            task.id,
                            BoardStatus.completed,
                          );
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        if (task.status != BoardStatus.notStarted)
                          const PopupMenuItem(
                            value: 'notStarted',
                            child: Text('Move to Not Started'),
                          ),
                        if (task.status != BoardStatus.inProgress)
                          const PopupMenuItem(
                            value: 'inProgress',
                            child: Text('Move to In Progress'),
                          ),
                        if (task.status != BoardStatus.completed)
                          const PopupMenuItem(
                            value: 'completed',
                            child: Text('Move to Completed'),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (task.todos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: task.completionPercentage / 100,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(
                        task.status == BoardStatus.completed
                            ? Colors.green.shade400
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.checklist,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.completedTodosCount}/${task.todos.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (task.todos.isNotEmpty && task.todos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...task.todos.take(2).map((todo) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            todo.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 14,
                            color: todo.isCompleted
                                ? Colors.green.shade400
                                : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              todo.title,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    decoration: todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: todo.isCompleted
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade700,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (task.todos.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '+${task.todos.length - 2} more',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddGroupDialog(BuildContext context, TaskController controller) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Task Group'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Group name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                context.read<TaskController>().createTaskGroup(
                  textController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(
    BuildContext context,
    TaskGroup group,
    TaskController controller,
  ) {
    final textController = TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Task Group'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Group name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                controller.updateTaskGroup(group.id, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, TaskController controller) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Task'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Task title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (textController.text.isNotEmpty && _selectedGroupId != null) {
                controller.createTask(_selectedGroupId!, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsDialog(
    BuildContext context,
    Task task,
    TaskController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: TaskDetailsDialog(task: task, controller: controller),
      ),
    );
  }
}

class TaskDetailsDialog extends StatefulWidget {
  final Task task;
  final TaskController controller;

  const TaskDetailsDialog({
    Key? key,
    required this.task,
    required this.controller,
  }) : super(key: key);

  @override
  State<TaskDetailsDialog> createState() => _TaskDetailsDialogState();
}

class _TaskDetailsDialogState extends State<TaskDetailsDialog> {
  late TextEditingController _todoController;

  @override
  void initState() {
    super.initState();
    _todoController = TextEditingController();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 540,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.task.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.task.todos.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.trending_up,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: widget.task.completionPercentage / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.task.completedTodosCount}/${widget.task.todos.length} completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.checklist,
                          size: 20,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Todo Items',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.task.todos.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No todos yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: widget.task.todos.map((todo) {
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: todo != widget.task.todos.last
                                    ? BorderSide(color: Colors.grey.shade100)
                                    : BorderSide.none,
                              ),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.isCompleted,
                                onChanged: (value) {
                                  widget.controller.toggleTodoCompletion(
                                    widget.task.id,
                                    todo.id,
                                  );
                                  setState(() {});
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              title: Text(
                                todo.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      decoration: todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: todo.isCompleted
                                          ? Colors.grey.shade500
                                          : null,
                                    ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  widget.controller.deleteTodoFromTask(
                                    widget.task.id,
                                    todo.id,
                                  );
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _todoController,
                            decoration: InputDecoration(
                              hintText: 'Add a todo...',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(6),
                          child: FilledButton.icon(
                            onPressed: () {
                              if (_todoController.text.isNotEmpty) {
                                widget.controller.addTodoToTask(
                                  widget.task.id,
                                  _todoController.text,
                                );
                                _todoController.clear();
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
