import 'package:flutter/material.dart';

class FormatToolbar extends StatelessWidget {
  final TextEditingController _controller;
  const FormatToolbar({super.key, required this._controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFormatButton(
              icon: Icons.looks_one,
              label: 'H1',
              onTap: () => _insertMarkdown('# '),
            ),
            _buildFormatButton(
              icon: Icons.looks_two,
              label: 'H2',
              onTap: () => _insertMarkdown('## '),
            ),
            _buildFormatButton(
              icon: Icons.looks_3,
              label: 'H3',
              onTap: () => _insertMarkdown('### '),
            ),
            _buildDivider(),
            _buildFormatButton(
              icon: Icons.format_bold,
              label: 'Bold',
              onTap: () => _insertMarkdown('**', '**'),
              shortcut: '⌘B',
            ),
            _buildFormatButton(
              icon: Icons.format_italic,
              label: 'Italic',
              onTap: () => _insertMarkdown('*', '*'),
              shortcut: '⌘I',
            ),
            _buildDivider(),
            _buildFormatButton(
              icon: Icons.format_list_bulleted,
              label: 'List',
              onTap: () => _insertMarkdown('- '),
            ),
            _buildFormatButton(
              icon: Icons.format_list_numbered,
              label: 'Numbered',
              onTap: () => _insertMarkdown('1. '),
            ),
            _buildDivider(),

            _buildFormatButton(
              icon: Icons.code,
              label: 'Code Block',
              onTap: () => _insertMarkdown('```\n', '\n```'),
            ),
            _buildDivider(),
            _buildFormatButton(
              icon: Icons.link,
              label: 'Link',
              onTap: () => _insertMarkdown('[', '](url)'),
              shortcut: '⌘K',
            ),
            _buildFormatButton(
              icon: Icons.horizontal_rule,
              label: 'Divider',
              onTap: () => _insertMarkdown('\n---\n'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? shortcut,
  }) {
    return Tooltip(
      message: '$label${shortcut != null ? ' ($shortcut)' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade200,
    );
  }

  void _insertMarkdown(String prefix, [String suffix = '']) {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start;
    final end = selection.end;

    String newText;
    int newCursorPosition;

    if (selection.isCollapsed) {
      newText =
          text.substring(0, start) + prefix + suffix + text.substring(start);
      newCursorPosition = start + prefix.length;
    } else {
      final selectedText = text.substring(start, end);
      newText =
          text.substring(0, start) +
          prefix +
          selectedText +
          suffix +
          text.substring(end);
      newCursorPosition = end + prefix.length + suffix.length;
    }

    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: newCursorPosition);
  }
}
