library;

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentImporter] that parses a Markdown string into a
/// [BlockDocument].
///
/// Supported block-level constructs:
/// - `# ` / `## ` / `### ` → H1 / H2 / H3
/// - `- text` → bullet list
/// - `1. text` → numbered list
/// - `- [ ] text` / `- [x] text` → todo (unchecked / checked)
/// - `> text` → quote (callout variants detected by emoji prefix)
/// - `---` → divider
/// - ` ```lang ` ... ` ``` ` → code block
/// - `![alt](url)` → image
/// - `[text](url)` on its own line → link block
/// - Indented list items (two spaces per level) → nested children
/// - All other lines → paragraph
///
/// Supported inline formatting:
/// - `**text**` or `__text__` → bold
/// - `_text_` or `*text*` → italic
/// - `**_text_**` → bold and italic
/// - `~~text~~` → strikethrough
/// - `` `text` `` → inline code
/// - `[text](url)` → link
/// - `{{variableName}}` → [VariableOp]
/// - `#tag` (word characters only) → [TagOp]
///
/// Callout detection: blockquotes whose text begins with ℹ️, ⚠️, or ❌ are
/// imported as callout blocks with the corresponding variant attribute.
///
/// When source is empty or contains no recognisable content,
/// [import] returns [BlockDocument.empty].
///
/// Usage:
/// ```dart
/// await controller.importFrom(MarkdownImporter(), markdownString);
/// ```
final class MarkdownImporter implements BlockDocumentImporter {
  /// Creates a [MarkdownImporter].
  const MarkdownImporter();

  @override
  String get formatName => 'markdown';

  @override
  Future<BlockDocument> import(String source) async {
    if (source.trim().isEmpty) return BlockDocument.empty();

    final lines = source.split('\n');
    final flat = <BlockNode>[];
    var i = 0;

    while (i < lines.length) {
      final line = lines[i];

      if (_isFenceStart(line)) {
        final result = _parseCodeBlock(lines, i);
        flat.add(result.node);
        i = result.nextIndex;
        continue;
      }

      final node = _parseLine(line);
      if (node != null) flat.add(node);
      i++;
    }

    final assembled = _assembleNesting(flat);
    return assembled.isEmpty ? BlockDocument.empty() : BlockDocument(assembled);
  }

  bool _isFenceStart(String line) => line.trimLeft().startsWith('```');

  _ParseResult _parseCodeBlock(List<String> lines, int startIndex) {
    final firstLine = lines[startIndex].trimLeft();
    final language = firstLine.substring(3).trim();
    final codeLines = <String>[];
    var i = startIndex + 1;

    while (i < lines.length) {
      if (lines[i].trimLeft().startsWith('```')) {
        i++;
        break;
      }
      codeLines.add(lines[i]);
      i++;
    }

    return _ParseResult(
      node: BlockNode(
        type: BlockTypes.code,
        attributes: {'language': language, 'code': codeLines.join('\n')},
      ),
      nextIndex: i,
    );
  }

  BlockNode? _parseLine(String line) {
    final depth = _indentDepth(line);
    final trimmed = line.trimLeft();

    if (trimmed.isEmpty) return null;
    if (trimmed == '---') {
      return _withDepth(BlockNode(type: BlockTypes.divider), depth);
    }

    if (trimmed.startsWith('### ')) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.heading3,
          delta: _parseDelta(trimmed.substring(4)),
        ),
        depth,
      );
    }
    if (trimmed.startsWith('## ')) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.heading2,
          delta: _parseDelta(trimmed.substring(3)),
        ),
        depth,
      );
    }
    if (trimmed.startsWith('# ')) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.heading1,
          delta: _parseDelta(trimmed.substring(2)),
        ),
        depth,
      );
    }

    final todoUnchecked = RegExp(r'^- \[ \] (.*)$').firstMatch(trimmed);
    if (todoUnchecked != null) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.todo,
          attributes: const {'checked': false},
          delta: _parseDelta(todoUnchecked.group(1)!),
        ),
        depth,
      );
    }

    final todoChecked = RegExp(r'^- \[x\] (.*)$').firstMatch(trimmed);
    if (todoChecked != null) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: _parseDelta(todoChecked.group(1)!),
        ),
        depth,
      );
    }

    if (trimmed.startsWith('- ')) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.bulletList,
          delta: _parseDelta(trimmed.substring(2)),
        ),
        depth,
      );
    }

    final numbered = RegExp(r'^\d+\. (.*)$').firstMatch(trimmed);
    if (numbered != null) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.numberedList,
          delta: _parseDelta(numbered.group(1)!),
        ),
        depth,
      );
    }

    if (trimmed.startsWith('> ')) {
      return _withDepth(_parseBlockquote(trimmed.substring(2)), depth);
    }

    final image = RegExp(r'^!\[([^\]]*)\]\(([^)]*)\)$').firstMatch(trimmed);
    if (image != null) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.image,
          attributes: {
            'alt': image.group(1)!,
            'url': image.group(2)!,
            'source': 'network',
          },
        ),
        depth,
      );
    }

    final linkLine = RegExp(r'^\[([^\]]*)\]\(([^)]*)\)$').firstMatch(trimmed);
    if (linkLine != null) {
      return _withDepth(
        BlockNode(
          type: BlockTypes.link,
          attributes: {
            'displayText': linkLine.group(1)!,
            'url': linkLine.group(2)!,
          },
        ),
        depth,
      );
    }

    return _withDepth(
      BlockNode(type: BlockTypes.paragraph, delta: _parseDelta(trimmed)),
      depth,
    );
  }

  BlockNode _parseBlockquote(String content) {
    if (content.startsWith('ℹ️ ')) {
      return BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'info'},
        delta: _parseDelta(content.substring('ℹ️ '.length)),
      );
    }
    if (content.startsWith('⚠️ ')) {
      return BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'warning'},
        delta: _parseDelta(content.substring('⚠️ '.length)),
      );
    }
    if (content.startsWith('❌ ')) {
      return BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'error'},
        delta: _parseDelta(content.substring('❌ '.length)),
      );
    }
    return BlockNode(type: BlockTypes.quote, delta: _parseDelta(content));
  }

  int _indentDepth(String line) {
    var spaces = 0;
    for (final ch in line.runes) {
      if (ch == 0x20) {
        spaces++;
      } else {
        break;
      }
    }
    return spaces ~/ 2;
  }

  BlockNode _withDepth(BlockNode node, int depth) {
    if (depth == 0) return node;
    return node.copyWith(attributes: {...node.attributes, '_depth': depth});
  }

  List<BlockNode> _assembleNesting(List<BlockNode> flat) {
    final root = <BlockNode>[];

    for (final node in flat) {
      final depth = node.attributes['_depth'] as int? ?? 0;
      final clean = node.copyWith(
        attributes: Map.of(node.attributes)..remove('_depth'),
      );

      if (depth == 0) {
        root.add(clean);
        continue;
      }

      _insertAtDepth(root, clean, depth);
    }

    return root;
  }

  void _insertAtDepth(List<BlockNode> siblings, BlockNode node, int depth) {
    if (depth == 1) {
      if (siblings.isNotEmpty) {
        final parent = siblings.last;
        siblings[siblings.length - 1] = parent.copyWith(
          children: [...parent.children, node],
        );
      } else {
        siblings.add(node);
      }
      return;
    }

    if (siblings.isNotEmpty) {
      final parent = siblings.last;
      final updatedChildren = List<BlockNode>.of(parent.children);
      _insertAtDepth(updatedChildren, node, depth - 1);
      siblings[siblings.length - 1] = parent.copyWith(
        children: updatedChildren,
      );
    } else {
      siblings.add(node);
    }
  }

  TextDelta _parseDelta(String text) {
    if (text.isEmpty) return TextDelta.empty();
    final ops = <DeltaOp>[];
    _parseInline(text, ops);
    return ops.isEmpty ? TextDelta.empty() : TextDelta(ops);
  }

  void _parseInline(String text, List<DeltaOp> ops) {
    if (text.isEmpty) return;

    final patterns = <_InlinePattern>[
      _InlinePattern(
        RegExp(r'\*\*_(.+?)_\*\*'),
        (m) => TextOp(
          m.group(1)!,
          attributes: const InlineAttributes(bold: true, italic: true),
        ),
      ),
      _InlinePattern(
        RegExp(r'\*\*(.+?)\*\*'),
        (m) =>
            TextOp(m.group(1)!, attributes: const InlineAttributes(bold: true)),
      ),
      _InlinePattern(
        RegExp(r'__(.+?)__'),
        (m) =>
            TextOp(m.group(1)!, attributes: const InlineAttributes(bold: true)),
      ),
      _InlinePattern(
        RegExp(r'~~(.+?)~~'),
        (m) => TextOp(
          m.group(1)!,
          attributes: const InlineAttributes(strikethrough: true),
        ),
      ),
      _InlinePattern(
        RegExp(r'`(.+?)`'),
        (m) => TextOp(
          m.group(1)!,
          attributes: const InlineAttributes(inlineCode: true),
        ),
      ),
      _InlinePattern(
        RegExp(r'\[(.+?)\]\((.+?)\)'),
        (m) => TextOp(
          m.group(1)!,
          attributes: InlineAttributes(link: m.group(2)!),
        ),
      ),
      _InlinePattern(
        RegExp(r'_(.+?)_'),
        (m) => TextOp(
          m.group(1)!,
          attributes: const InlineAttributes(italic: true),
        ),
      ),
      _InlinePattern(
        RegExp(r'\*(.+?)\*'),
        (m) => TextOp(
          m.group(1)!,
          attributes: const InlineAttributes(italic: true),
        ),
      ),
      _InlinePattern(RegExp(r'\{\{(\w+)\}\}'), (m) => VariableOp(m.group(1)!)),
      _InlinePattern(RegExp(r'#(\w+)'), (m) => TagOp(m.group(1)!)),
    ];

    var remaining = text;

    while (remaining.isNotEmpty) {
      int? earliest;
      _InlinePattern? matchedPattern;
      RegExpMatch? matchResult;

      for (final p in patterns) {
        final m = p.pattern.firstMatch(remaining);
        if (m != null && (earliest == null || m.start < earliest)) {
          earliest = m.start;
          matchedPattern = p;
          matchResult = m;
        }
      }

      if (matchedPattern == null || matchResult == null) {
        ops.add(TextOp(remaining));
        break;
      }

      if (matchResult.start > 0) {
        ops.add(TextOp(remaining.substring(0, matchResult.start)));
      }

      ops.add(matchedPattern.build(matchResult));
      remaining = remaining.substring(matchResult.end);
    }
  }
}

class _ParseResult {
  const _ParseResult({required this.node, required this.nextIndex});
  final BlockNode node;
  final int nextIndex;
}

class _InlinePattern {
  const _InlinePattern(this.pattern, this.build);
  final RegExp pattern;
  final DeltaOp Function(RegExpMatch) build;
}
