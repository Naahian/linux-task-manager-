import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/widgets/board.dart';
import 'package:task_manager/widgets/floating_dock.dart';
import 'package:task_manager/widgets/sidebar.dart';
import 'package:task_manager/widgets/markdown_editor.dart';
import 'package:task_manager/widgets/task_topbar.dart';
import 'task_model.dart';
import 'task_controller.dart';

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({super.key});

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to trigger rebuild
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Handle initial group selection after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<TaskController>();
      if (controller.taskGroups.isNotEmpty &&
          controller.selectedGroupId == null) {
        controller.updateGroupSelection(controller.taskGroups.first.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

        return Scaffold(
          body: Row(
            children: [
              const Sidebar(),
              Expanded(child: _buildMainContent(context, taskController)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainContent(BuildContext context, TaskController controller) {
    // Don't call updateGroupSelection here - it's handled in initState

    if (controller.selectedGroupId == null) {
      return const Center(child: SelectableText('Select a group'));
    }

    final group = controller.getTaskGroupById(controller.selectedGroupId!);
    if (group == null) {
      return const Center(child: SelectableText('Group not found'));
    }

    return Container(
      color: Colors.grey.shade50,
      child: Stack(
        children: [
          Column(
            children: [
              if (_tabController.index == 0) const TaskTopbar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tasks Tab
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Row(
                        children: [
                          Board(
                            context: context,
                            controller: controller,
                            title: 'Not Started',
                            status: BoardStatus.notStarted,
                            groupId: group.id,
                            icon: Icons.circle_outlined,
                          ),
                          const SizedBox(width: 24),
                          Board(
                            context: context,
                            controller: controller,
                            title: 'In Progress',
                            status: BoardStatus.inProgress,
                            groupId: group.id,
                            icon: Icons.play_circle_outline,
                          ),
                          const SizedBox(width: 24),
                          Board(
                            context: context,
                            controller: controller,
                            title: 'Completed',
                            status: BoardStatus.completed,
                            groupId: group.id,
                            icon: Icons.check_circle_outline,
                          ),
                        ],
                      ),
                    ),
                    // Notes Tab - Group level notes with key to force rebuild
                    _buildNotesTab(controller, group),
                  ],
                ),
              ),
            ],
          ),
          // Floating Dock
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(child: FloatingDock(tabController: _tabController)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab(TaskController controller, TaskGroup group) {
    print("initial value");
    print(controller.getGroupNotes(group.id) ?? "None Found");
    return Padding(
      padding: const EdgeInsets.all(32),
      child: QuillMarkdownEditor(
        key: ValueKey('notes_${group.id}'),
        groupName: group.name,
        initialText: controller.getGroupNotes(group.id) ?? '',
        onTextChanged: (notesDelta) {
          controller.updateGroupNotes(group.id, notesDelta);
        },
        hintText: 'Start writing your notes...',
      ),
    );
  }
}
