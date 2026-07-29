library;

import 'package:meta/meta.dart';

import 'block_node.dart';

/// An immutable, ordered collection of [BlockNode] objects representing a
/// complete block-based document.
///
/// [BlockDocument] is the root of the document model. All exporters, importers,
/// and rendering pipelines operate on a [BlockDocument] instance.
///
/// The document supports nested blocks via [BlockNode.children]. The two
/// traversal utilities — [flatten] and [flattenWithDepth] — both perform
/// depth-first traversal and are the canonical entry points for all code that
/// must visit every block in order.
@immutable
final class BlockDocument {
  /// Creates a [BlockDocument] from an existing list of root-level blocks.
  const BlockDocument(this.blocks);

  /// Creates an empty document seeded with a single empty paragraph block.
  factory BlockDocument.empty() {
    return BlockDocument([BlockNode(type: 'paragraph')]);
  }

  /// Deserializes a [BlockDocument] from a JSON-compatible map produced by
  /// [toJson].
  factory BlockDocument.fromJson(Map<String, dynamic> json) {
    final list = json['blocks'] as List<dynamic>;
    return BlockDocument(
      list.map((e) => BlockNode.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// The ordered list of root-level blocks in this document.
  final List<BlockNode> blocks;

  /// Whether this document contains no blocks.
  bool get isEmpty => blocks.isEmpty;

  /// Whether this document contains at least one block.
  bool get isNotEmpty => blocks.isNotEmpty;

  /// Returns the [BlockNode] with the given [id], searching recursively through
  /// all nested children, or null if no block with that id exists.
  BlockNode? findById(String id) => _findById(blocks, id);

  static BlockNode? _findById(List<BlockNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      final found = _findById(node.children, id);
      if (found != null) return found;
    }
    return null;
  }

  /// Returns every block in the document as a flat list in depth-first order,
  /// without depth metadata.
  ///
  /// Root-level blocks appear before their children. Siblings appear in their
  /// original order. The returned list includes blocks at every nesting level.
  ///
  /// Use [flattenWithDepth] when the nesting level of each block is needed,
  /// for example in exporters that produce indented output or nested HTML lists.
  List<BlockNode> flatten() {
    final result = <BlockNode>[];
    _flatten(blocks, result);
    return result;
  }

  static void _flatten(List<BlockNode> nodes, List<BlockNode> result) {
    for (final node in nodes) {
      result.add(node);
      _flatten(node.children, result);
    }
  }

  /// Returns every block in the document as a flat list in depth-first order,
  /// with each entry paired with its nesting depth.
  ///
  /// Root-level blocks have depth 0. Each level of [BlockNode.children]
  /// increments the depth by one. Siblings at the same nesting level share the
  /// same depth value.
  ///
  /// The records in the returned list use named fields: `node` for the
  /// [BlockNode] and `depth` for the zero-based nesting level.
  ///
  /// This method is the canonical entry point for any code that must produce
  /// indented or hierarchically structured output from a [BlockDocument],
  /// including the Markdown and HTML exporters and the document outline panel.
  ///
  /// Example:
  /// ```dart
  /// for (final entry in document.flattenWithDepth()) {
  ///   final indent = '  ' * entry.depth;
  ///   print('$indent${entry.node.type}');
  /// }
  /// ```
  List<({BlockNode node, int depth})> flattenWithDepth() {
    final result = <({BlockNode node, int depth})>[];
    _flattenWithDepth(blocks, 0, result);
    return result;
  }

  static void _flattenWithDepth(
    List<BlockNode> nodes,
    int depth,
    List<({BlockNode node, int depth})> result,
  ) {
    for (final node in nodes) {
      result.add((node: node, depth: depth));
      _flattenWithDepth(node.children, depth + 1, result);
    }
  }

  /// Returns a copy of this document with [blocks] replaced when provided.
  BlockDocument copyWith({List<BlockNode>? blocks}) {
    return BlockDocument(blocks ?? List.of(this.blocks));
  }

  /// Serializes this document to a JSON-compatible map.
  ///
  /// The resulting map is deserializable via [BlockDocument.fromJson].
  Map<String, dynamic> toJson() {
    return {'blocks': blocks.map((b) => b.toJson()).toList()};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BlockDocument || other.blocks.length != blocks.length) {
      return false;
    }
    for (var i = 0; i < blocks.length; i++) {
      if (blocks[i] != other.blocks[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(blocks);

  @override
  String toString() => 'BlockDocument(${blocks.length} blocks)';
}
