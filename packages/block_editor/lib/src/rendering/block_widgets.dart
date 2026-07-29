library;

import 'package:flutter/material.dart';
import 'package:block_editor/block_editor.dart';
import 'editor_span_builder.dart';

int _resolveOffset(
  GlobalKey key,
  Offset globalPosition,
  TextDelta delta,
  TextStyle baseStyle,
  Map<String, String> variables,
) {
  final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return 0;

  final localPosition = renderBox.globalToLocal(globalPosition);
  final constrainedWidth = renderBox.size.width;
  final renderedHeight = renderBox.size.height;

  final span = buildMeasurementSpan(delta, baseStyle, variables);
  final painter = TextPainter(text: span, textDirection: TextDirection.ltr)
    ..layout(maxWidth: constrainedWidth);

  final scale = renderedHeight > 0 && painter.height > 0
      ? painter.height / renderedHeight
      : 1.0;
  final scaledPosition = Offset(localPosition.dx, localPosition.dy * scale);

  final visualOffset = painter.getPositionForOffset(scaledPosition).offset;
  return visualToModelOffset(delta, visualOffset, variables);
}

/// A paragraph block widget.
class ParagraphWidget extends StatefulWidget {
  /// Creates a [ParagraphWidget] for the block identified by [blockId].
  const ParagraphWidget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<ParagraphWidget> createState() => _ParagraphWidgetState();
}

class _ParagraphWidgetState extends State<ParagraphWidget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapDown: (details) {
          final offset = _resolveOffset(
            _textKey,
            details.globalPosition,
            widget.delta,
            const TextStyle(fontSize: 16),
            BlockEditorScope.maybeOf(context)?.variables ?? const {},
          );
          widget.onEvent(TapEvent(blockId: widget.blockId, offset: offset));
        },
        child: RichTextRenderer(
          key: _textKey,
          delta: widget.delta,
          blockId: widget.blockId,
          selection: widget.selection,
          baseStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

/// A heading level 1 block widget.
class H1Widget extends StatefulWidget {
  /// Creates an [H1Widget] for the block identified by [blockId].
  const H1Widget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<H1Widget> createState() => _H1WidgetState();
}

class _H1WidgetState extends State<H1Widget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapDown: (details) {
          final offset = _resolveOffset(
            _textKey,
            details.globalPosition,
            widget.delta,
            const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            BlockEditorScope.maybeOf(context)?.variables ?? const {},
          );
          widget.onEvent(TapEvent(blockId: widget.blockId, offset: offset));
        },
        child: RichTextRenderer(
          key: _textKey,
          delta: widget.delta,
          blockId: widget.blockId,
          selection: widget.selection,
          baseStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A heading level 2 block widget.
class H2Widget extends StatefulWidget {
  /// Creates an [H2Widget] for the block identified by [blockId].
  const H2Widget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<H2Widget> createState() => _H2WidgetState();
}

class _H2WidgetState extends State<H2Widget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapDown: (details) {
          final offset = _resolveOffset(
            _textKey,
            details.globalPosition,
            widget.delta,
            const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            BlockEditorScope.maybeOf(context)?.variables ?? const {},
          );
          widget.onEvent(TapEvent(blockId: widget.blockId, offset: offset));
        },
        child: RichTextRenderer(
          key: _textKey,
          delta: widget.delta,
          blockId: widget.blockId,
          selection: widget.selection,
          baseStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A heading level 3 block widget.
class H3Widget extends StatefulWidget {
  /// Creates an [H3Widget] for the block identified by [blockId].
  const H3Widget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<H3Widget> createState() => _H3WidgetState();
}

class _H3WidgetState extends State<H3Widget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapDown: (details) {
          final offset = _resolveOffset(
            _textKey,
            details.globalPosition,
            widget.delta,
            const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            BlockEditorScope.maybeOf(context)?.variables ?? const {},
          );
          widget.onEvent(TapEvent(blockId: widget.blockId, offset: offset));
        },
        child: RichTextRenderer(
          key: _textKey,
          delta: widget.delta,
          blockId: widget.blockId,
          selection: widget.selection,
          baseStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// A bullet list item block widget.
class BulletListWidget extends StatefulWidget {
  /// Creates a [BulletListWidget] for the block identified by [blockId].
  const BulletListWidget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.attributes,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// The block attributes. Used to read the indent level.
  final Map<String, dynamic> attributes;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<BulletListWidget> createState() => _BulletListWidgetState();
}

class _BulletListWidgetState extends State<BulletListWidget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final indent = (widget.attributes['indent'] as int? ?? 0).clamp(0, 10);
    return Padding(
      padding: EdgeInsets.only(left: indent * 24.0),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            child: Text('•', style: TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: GestureDetector(
                onTapDown: (details) {
                  final offset = _resolveOffset(
                    _textKey,
                    details.globalPosition,
                    widget.delta,
                    const TextStyle(fontSize: 16),
                    BlockEditorScope.maybeOf(context)?.variables ?? const {},
                  );
                  widget.onEvent(
                    TapEvent(blockId: widget.blockId, offset: offset),
                  );
                },
                child: RichTextRenderer(
                  key: _textKey,
                  delta: widget.delta,
                  blockId: widget.blockId,
                  selection: widget.selection,
                  baseStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A numbered list item block widget.
class NumberedListWidget extends StatefulWidget {
  /// Creates a [NumberedListWidget] for the block identified by [blockId].
  const NumberedListWidget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.attributes,
    required this.number,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// The block attributes. Used to read the indent level.
  final Map<String, dynamic> attributes;

  /// The visible ordinal number shown to the left of the content.
  final int number;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<NumberedListWidget> createState() => _NumberedListWidgetState();
}

class _NumberedListWidgetState extends State<NumberedListWidget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final indent = (widget.attributes['indent'] as int? ?? 0).clamp(0, 10);
    return Padding(
      padding: EdgeInsets.only(left: indent * 24.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '${widget.number}.',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: GestureDetector(
                onTapDown: (details) {
                  final offset = _resolveOffset(
                    _textKey,
                    details.globalPosition,
                    widget.delta,
                    const TextStyle(fontSize: 16),
                    BlockEditorScope.maybeOf(context)?.variables ?? const {},
                  );
                  widget.onEvent(
                    TapEvent(blockId: widget.blockId, offset: offset),
                  );
                },
                child: RichTextRenderer(
                  key: _textKey,
                  delta: widget.delta,
                  blockId: widget.blockId,
                  selection: widget.selection,
                  baseStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A todo (checkbox) block widget.
class TodoWidget extends StatefulWidget {
  /// Creates a [TodoWidget] for the block identified by [blockId].
  const TodoWidget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.checked,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Whether the todo item is currently checked.
  final bool checked;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onEvent(
              CheckboxToggledEvent(
                blockId: widget.blockId,
                checked: !widget.checked,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 8, top: 2),
              child: _Checkbox(checked: widget.checked),
            ),
          ),
        ),
        Expanded(
          child: MouseRegion(
            cursor: SystemMouseCursors.text,
            child: GestureDetector(
              onTapDown: (details) {
                final offset = _resolveOffset(
                  _textKey,
                  details.globalPosition,
                  widget.delta,
                  const TextStyle(fontSize: 16),
                  BlockEditorScope.maybeOf(context)?.variables ?? const {},
                );
                widget.onEvent(
                  TapEvent(blockId: widget.blockId, offset: offset),
                );
              },
              child: RichTextRenderer(
                key: _textKey,
                delta: widget.delta,
                blockId: widget.blockId,
                selection: widget.selection,
                baseStyle: TextStyle(
                  fontSize: 16,
                  decoration: widget.checked
                      ? TextDecoration.lineThrough
                      : null,
                  color: widget.checked ? const Color(0xFF999999) : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF999999), width: 1.5),
        borderRadius: BorderRadius.circular(3),
        color: checked ? const Color(0xFF2196F3) : null,
      ),
      child: checked
          ? const Icon(
              IconData(0xe156, fontFamily: 'MaterialIcons'),
              size: 14,
              color: Color(0xFFFFFFFF),
            )
          : null,
    );
  }
}

/// A block quote widget.
class QuoteWidget extends StatefulWidget {
  /// Creates a [QuoteWidget] for the block identified by [blockId].
  const QuoteWidget({
    super.key,
    required this.blockId,
    required this.delta,
    required this.onEvent,
    this.selection = EditorSelection.none,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// The inline content to render.
  final TextDelta delta;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  /// The current editor selection.
  final EditorSelection selection;

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  final _textKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.text,
      child: GestureDetector(
        onTapDown: (details) {
          final offset = _resolveOffset(
            _textKey,
            details.globalPosition,
            widget.delta,
            const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            BlockEditorScope.maybeOf(context)?.variables ?? const {},
          );
          widget.onEvent(TapEvent(blockId: widget.blockId, offset: offset));
        },
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFFCCCCCC), width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: RichTextRenderer(
              key: _textKey,
              delta: widget.delta,
              blockId: widget.blockId,
              selection: widget.selection,
              baseStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal divider block widget.
class DividerWidget extends StatelessWidget {
  /// Creates a [DividerWidget] for the block identified by [blockId].
  const DividerWidget({
    super.key,
    required this.blockId,
    required this.onEvent,
  });

  /// The id of the block this widget represents.
  final String blockId;

  /// Called when the user interacts with this block.
  final void Function(BlockEvent) onEvent;

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0));
  }
}
