import 'package:flutter/material.dart';
import 'package:task_manager/task_controller.dart';
import 'package:task_manager/task_model.dart';

// Task Details Dialog
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
    return SizedBox(
      width: 640,
      child: Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),

            const Divider(height: 1),
            SizedBox(height: 16),
            _buildAddTodo(),
            // Content
            Expanded(child: _buldTasks(context)),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView _buldTasks(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          if (widget.task.todos.isNotEmpty) ...[
            Text('Progress', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: widget.task.completionPercentage / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surface,
                valueColor: AlwaysStoppedAnimation(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.task.completedTodosCount}/${widget.task.todos.length} completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 20),
          ],
          // Todos list
          Text('Todo Items', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 12),
          if (widget.task.todos.isEmpty)
            Text(
              'No todos yet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.5),
              ),
            )
          else
            Column(
              children: widget.task.todos.map((todo) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) {
                          widget.controller.toggleTodoCompletion(
                            widget.task.id,
                            todo.id,
                          );
                          setState(() {});
                        },
                      ),
                      Expanded(
                        child: Text(
                          todo.title,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.5)
                                    : null,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          widget.controller.deleteTodoFromTask(
                            widget.task.id,
                            todo.id,
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete, size: 18),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          // Add todo
        ],
      ),
    );
  }

  SizedBox _buildAddTodo() {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _todoController,
              decoration: InputDecoration(
                hintText: 'Add a todo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
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
          ),
        ],
      ),
    );
  }

  Padding _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.task.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
