import 'package:flutter/material.dart';

// Floating Dock Widget
class FloatingDock extends StatelessWidget {
  final TabController tabController;

  const FloatingDock({Key? key, required this.tabController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDockItem(
                    icon: Icons.task_alt,
                    label: 'Tasks',
                    index: 0,
                    context: context,
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade200),
                  _buildDockItem(
                    icon: Icons.note_alt,
                    label: 'Notes',
                    index: 1,
                    context: context,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDockItem({
    required IconData icon,
    required String label,
    required int index,
    required BuildContext context,
  }) {
    final isSelected = tabController.index == index;

    return GestureDetector(
      onTap: () {
        tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
