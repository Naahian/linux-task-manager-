import 'package:flutter/material.dart';
import 'package:task_manager/task_controller.dart';
import 'package:task_manager/task_model.dart';
import 'package:task_manager/widgets/task_card.dart';

class Board extends StatelessWidget {
  const Board({
    super.key,
    required this.context,
    required this.controller,
    required this.title,
    required this.status,
    required this.groupId,
    required this.icon,
  });

  final BuildContext context;
  final TaskController controller;
  final String title;
  final BoardStatus status;
  final String groupId;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
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
                                    SelectableText(
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
                                  return TaskCard(
                                    task: tasks[index],
                                    currentStatus: status,
                                    controller: controller,
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
}
