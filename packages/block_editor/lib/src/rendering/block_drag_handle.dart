library;

import 'package:flutter/material.dart';
import 'package:block_editor/block_editor.dart';

/// The drag handle icon rendered to the left of each block.
///
/// The handle fades in on pointer hover and is hidden entirely when
/// [readOnly] is true or when the available width is below 600 logical
/// pixels. The drag feedback is wrapped in a [SizedBox] sized to the
/// actual rendered row width via a [GlobalKey] measurement.
///
/// When [onActionMenuRequested] is non-null, clicking the handle icon invokes
/// it with the block id and the global tap position. [BlockEditorWidget] uses
/// this to show the [BlockActionMenu] overlay.
class BlockDragHandle extends StatefulWidget {
  /// Creates a [BlockDragHandle] for the block at [index].
  const BlockDragHandle({
    super.key,
    required this.index,
    required this.blockId,
    required this.child,
    required this.onEvent,
    required this.feedbackWidget,
    this.readOnly = false,
    this.onActionMenuRequested,
  });

  /// The current index of this block in the root block list.
  final int index;

  /// The id of the block this handle belongs to.
  final String blockId;

  /// The block widget rendered inside this row.
  final Widget child;

  /// Called when a drag completes with a [BlockReorderedEvent].
  final void Function(BlockEvent) onEvent;

  /// The widget shown under the pointer during drag.
  final Widget feedbackWidget;

  /// When true the drag handle is hidden and drag is disabled.
  final bool readOnly;

  /// Called when the handle icon is tapped, with the block id and the global
  /// position of the tap. Used by [BlockEditorWidget] to show the
  /// [BlockActionMenu].
  final void Function(String blockId, Offset globalPosition)?
  onActionMenuRequested;

  @override
  State<BlockDragHandle> createState() => _BlockDragHandleState();
}

class _BlockDragHandleState extends State<BlockDragHandle> {
  bool _hovering = false;
  final _rowKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width;
    final tooNarrow = availableWidth < 600;

    final handleIcon = (widget.readOnly || tooNarrow)
        ? const SizedBox(width: 24)
        : MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            cursor: SystemMouseCursors.grab,
            child: Draggable<int>(
              data: widget.index,
              feedback: widget.feedbackWidget,
              child: GestureDetector(
                onTapUp: widget.onActionMenuRequested != null
                    ? (details) => widget.onActionMenuRequested!(
                        widget.blockId,
                        details.globalPosition,
                      )
                    : null,
                child: AnimatedOpacity(
                  opacity: _hovering ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Color(0xFF999999),
                  ),
                ),
              ),
            ),
          );

    return Row(
      key: _rowKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        handleIcon,
        Expanded(child: widget.child),
      ],
    );
  }
}

/// Wraps a block row with a [DragTarget] that accepts dropped block indices.
///
/// When a dragged block is dropped onto this target, a [BlockReorderedEvent]
/// is emitted with the resolved block id and the computed newIndex.
class BlockDropTarget extends StatefulWidget {
  /// Creates a [BlockDropTarget] for the block at [index].
  const BlockDropTarget({
    super.key,
    required this.index,
    required this.blockId,
    required this.child,
    required this.onEvent,
    required this.totalBlocks,
    required this.blockIdResolver,
  });

  /// The index of this block in the root block list.
  final int index;

  /// The id of this block.
  final String blockId;

  /// The block row widget.
  final Widget child;

  /// Called when a block is dropped onto this target.
  final void Function(BlockEvent) onEvent;

  /// The total number of blocks in the document.
  final int totalBlocks;

  /// Resolves a block id from a dragged index.
  final String? Function(int dragIndex) blockIdResolver;

  @override
  State<BlockDropTarget> createState() => _BlockDropTargetState();
}

class _BlockDropTargetState extends State<BlockDropTarget> {
  bool _isOver = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != widget.index,
      onAcceptWithDetails: (details) {
        final draggedIndex = details.data;
        var targetIndex = widget.index;
        if (draggedIndex < targetIndex) {
          targetIndex = targetIndex - 1;
        }
        final blockId = widget.blockIdResolver(draggedIndex);
        if (blockId != null) {
          widget.onEvent(
            BlockReorderedEvent(blockId: blockId, newIndex: targetIndex),
          );
        }
      },
      onLeave: (_) => setState(() => _isOver = false),
      onMove: (_) => setState(() => _isOver = true),
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isOver && candidateData.isNotEmpty) const _DropIndicator(),
            widget.child,
          ],
        );
      },
    );
  }
}

class _DropIndicator extends StatelessWidget {
  const _DropIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

/// The ghost widget shown under the pointer during a block drag.
///
/// Renders [node] via [BlockRenderer] at reduced opacity inside a
/// [Material] card with a soft shadow. [BlockDragHandle] wraps this
/// in an additional [SizedBox] with the measured row width so the
/// ghost always matches the actual editor content width.
class BlockGhost extends StatelessWidget {
  /// Creates a [BlockGhost] for [node].
  const BlockGhost({super.key, required this.node, required this.width});

  /// The block node to render in the ghost.
  final BlockNode node;

  /// The width of the ghost, matching the editor content width.
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(4),
        child: Opacity(
          opacity: 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlockRenderer(node: node, onEvent: (_) {}),
          ),
        ),
      ),
    );
  }
}
