import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/task_controller.dart';

class TaskTopbar extends StatelessWidget {
  const TaskTopbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
        final group = controller.getTaskGroupById(controller.selectedGroupId!);
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    group?.name ?? 'Unknown Group',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group?.taskIds.length} tasks',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              FilledButton.icon(
                onPressed: () => _showAddTaskDialog(context, controller),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Task'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
              if (textController.text.isNotEmpty &&
                  controller.selectedGroupId != null) {
                controller.createTask(
                  controller.selectedGroupId!,
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
}
