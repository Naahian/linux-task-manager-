import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';

import 'package:flutter_quill/quill_delta.dart';

class QuillMarkdownEditor extends StatefulWidget {
  final String groupName;
  final String initialText;
  final ValueChanged<String> onTextChanged;
  final String hintText;

  const QuillMarkdownEditor({
    Key? key,
    required this.groupName,
    this.initialText = '',
    required this.onTextChanged,
    this.hintText = 'Start writing...',
  }) : super(key: key);

  @override
  State<QuillMarkdownEditor> createState() => _QuillMarkdownEditorState();
}

class _QuillMarkdownEditorState extends State<QuillMarkdownEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _isPreviewMode = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    // Initialize controller with initial text
    if (widget.initialText.isEmpty) {
      _controller = QuillController.basic();
    } else {
      try {
        // Try to parse as Delta JSON (from Quill editor)
        final List<dynamic> deltaJson = jsonDecode(widget.initialText);
        final delta = Delta.fromJson(deltaJson);
        _controller = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
        debugPrint(
          'Initialized editor with Delta JSON (${widget.initialText.length} bytes)',
        );
      } catch (e) {
        // Fallback: treat as plain text
        debugPrint('Failed to parse Delta JSON, treating as plain text: $e');
        final delta = Delta()..insert(widget.initialText);
        _controller = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      }
    }

    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final delta = _controller.document.toDelta();
    final encoded = jsonEncode(delta.toJson());
    widget.onTextChanged(encoded);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.groupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Preview toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildViewToggle(
                      icon: Icons.edit,
                      label: 'Edit',
                      isActive: !_isPreviewMode,
                      onTap: () => setState(() => _isPreviewMode = false),
                    ),
                    _buildViewToggle(
                      icon: Icons.visibility,
                      label: 'Preview',
                      isActive: _isPreviewMode,
                      onTap: () => setState(() => _isPreviewMode = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!_isPreviewMode) _buildToolbar(),
        // Editor area
        Expanded(child: _isPreviewMode ? _buildPreview() : _buildQuillEditor()),
      ],
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.grey.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? null : Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? null : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuillEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: QuillEditor(
        controller: _controller,
        focusNode: _focusNode,
        config: QuillEditorConfig(
          autoFocus: true,
          expands: true,
          padding: const EdgeInsets.all(16),
          placeholder: 'Start writing...',
          scrollable: true,
          showCursor: true,
        ),
        scrollController: _scrollController,
      ),
    );
  }

  Container _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: QuillSimpleToolbar(
        controller: _controller,
        config: const QuillSimpleToolbarConfig(
          showFontFamily: false,
          showFontSize: false,
          showStrikeThrough: false,
          showBackgroundColorButton: true,
          showListNumbers: true,
          showListBullets: true,
          showListCheck: false,
          showSubscript: false,
          showSuperscript: false,
          showUndo: true,
          showRedo: true,
          showLink: true,
          showQuote: true,
          showIndent: false,
          showCodeBlock: true,
          showSearchButton: false,
          showColorButton: false,
          showClearFormat: true,
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final plainText = _controller.document.toPlainText();

    if (plainText.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_note, size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'Nothing to preview',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              const SizedBox(height: 8),
              Text(
                'Start writing in Edit mode',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.preview, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: QuillEditor(
              controller: _controller,
              focusNode: _focusNode,
              config: const QuillEditorConfig(
                expands: true,
                padding: EdgeInsets.all(20),
                scrollable: true,
                showCursor: false,
              ),
              scrollController: _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
