import 'dart:async';
import 'dart:convert';

import 'package:block_editor/block_editor.dart';
import 'package:flutter/material.dart';

import '../shell/export_modal.dart';
import '../theme/app_theme.dart';
import '../utils/markdown_exporter.dart' as md;
import 'editor_top_bar.dart';
import 'tag_strip.dart';

/// The main editing surface section.
///
/// Owns a [BlockController] seeded with a starter document. Mounts a live
/// [BlockEditorWidget] and wires up the top bar, export modals, read-only
/// toggle, document clear, and tag strip. The [themeMode] and [onToggleTheme]
/// are forwarded from [App] so the theme toggle button works from within the
/// editor surface.
class EditorSection extends StatefulWidget {
  /// Creates an [EditorSection].
  const EditorSection({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<EditorSection> createState() => _EditorSectionState();
}

class _EditorSectionState extends State<EditorSection> {
  late final BlockController _controller;
  late final TextEditingController _titleController;
  late final StreamSubscription<DocumentChange> _changesSub;
  bool _readOnly = false;
  Set<String> _tags = {};

  static const Map<String, String> _variables = {
    'authorName': 'Stanly Silas',
    'packageName': 'block_editor',
    'version': '0.0.4-dev.1',
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: 'Getting started');
    _controller = BlockController(document: _starterDocument());
    _tags = _controller.tags;
    _changesSub = _controller.changes.listen((_) {
      if (mounted) setState(() => _tags = _controller.tags);
    });
  }

  @override
  void dispose() {
    _changesSub.cancel();
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  BlockDocument _starterDocument() {
    return BlockDocument([
      BlockNode(
        type: BlockTypes.heading1,
        delta: TextDelta([
          const TextOp('Welcome to '),
          const VariableOp('packageName'),
        ]),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp('Built by '),
          const VariableOp('authorName'),
          const TextOp(' · version '),
          const VariableOp('version'),
          const TextOp('. Try the slash command menu by typing '),
          TextOp('/', attributes: const InlineAttributes(inlineCode: true)),
          const TextOp(' anywhere in the editor.'),
        ]),
      ),
      BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'info'},
        delta: TextDelta.fromPlainText(
          'This editor supports inline tags. Try typing #flutter or #dart to see them appear in the tag strip below.',
        ),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp('Start writing here. Use '),
          TextOp('Cmd/Ctrl+B', attributes: const InlineAttributes(bold: true)),
          const TextOp(' for bold, '),
          TextOp(
            'Cmd/Ctrl+I',
            attributes: const InlineAttributes(italic: true),
          ),
          const TextOp(' for italic. Tag this document with '),
          const TagOp('gettingstarted'),
          const TextOp('.'),
        ]),
      ),
    ]);
  }

  void _exportJson() {
    final json = const JsonEncoder.withIndent(
      '  ',
    ).convert(_controller.document.toJson());
    ExportModal.show(context, title: 'Export JSON', content: json);
  }

  void _exportMarkdown() {
    final markdown = md.MarkdownExporter.export(_controller.document);
    ExportModal.show(context, title: 'Export Markdown', content: markdown);
  }

  void _toggleReadOnly() {
    setState(() => _readOnly = !_readOnly);
  }

  void _clearDocument() {
    showDialog<void>(
      context: context,
      builder: (ctx) => _ClearConfirmDialog(
        onConfirm: () {
          _controller.replaceDocument(BlockDocument.empty());
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      children: [
        EditorTopBar(
          titleController: _titleController,
          readOnly: _readOnly,
          themeMode: widget.themeMode,
          onExportJson: _exportJson,
          onExportMarkdown: _exportMarkdown,
          onToggleReadOnly: _toggleReadOnly,
          onClear: _clearDocument,
          onToggleTheme: widget.onToggleTheme,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hPad = (constraints.maxWidth * 0.08).clamp(16.0, 64.0);
              return BlockEditorWidget(
                controller: _controller,
                readOnly: _readOnly,
                variables: _variables,
                cursorColor: colors.accent,
                selectionColor: colors.accent.withValues(alpha: 0.20),
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
              );
            },
          ),
        ),
        TagStrip(tags: _tags),
      ],
    );
  }
}

class _ClearConfirmDialog extends StatelessWidget {
  const _ClearConfirmDialog({required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AlertDialog(
      title: const Text('Clear document?'),
      content: const Text(
        'All blocks will be removed. This cannot be undone once the undo stack is cleared.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
        ),
        TextButton(
          onPressed: onConfirm,
          child: const Text(
            'Clear',
            style: TextStyle(color: Color(0xFFEF4444)),
          ),
        ),
      ],
    );
  }
}
