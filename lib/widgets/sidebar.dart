import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/task_controller.dart';
import 'package:task_manager/task_model.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, controller, child) {
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Organize your work beautifully',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade500,
                      ),
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
                    final isSelected = group.id == controller.selectedGroupId;
                    return _buildGroupTile(
                      context,
                      group,
                      isSelected,
                      controller,
                    );
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
      },
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
            controller.updateGroupSelection(group.id);
          },
        ),
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
        title: const SelectableText('Edit Task Group'),
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

  void _showAddGroupDialog(BuildContext context, TaskController controller) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const SelectableText('New Task Group'),
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
}
