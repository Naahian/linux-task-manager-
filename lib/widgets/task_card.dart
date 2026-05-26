import 'package:flutter/material.dart';
import 'package:task_manager/task_controller.dart';
import 'package:task_manager/task_model.dart';
import 'package:task_manager/widgets/task_details_dialog.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final BoardStatus currentStatus;
  final TaskController controller;

  const TaskCard({
    super.key,
    required this.task,
    required this.currentStatus,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
    ;
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
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 2,
                      ),
                    ),
                    _buildPopupMenuBtn(controller, task),
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
                      SelectableText(
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
                      child: SelectableText(
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

  PopupMenuButton<String> _buildPopupMenuBtn(
    TaskController controller,
    Task task,
  ) {
    return PopupMenuButton(
      icon: Icon(Icons.more_horiz, size: 18, color: Colors.grey.shade500),
      onSelected: (value) {
        if (value == 'delete') {
          controller.deleteTask(task.id);
        } else if (value == 'notStarted') {
          controller.moveTaskToStatus(task.id, BoardStatus.notStarted);
        } else if (value == 'inProgress') {
          controller.moveTaskToStatus(task.id, BoardStatus.inProgress);
        } else if (value == 'completed') {
          controller.moveTaskToStatus(task.id, BoardStatus.completed);
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
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
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
