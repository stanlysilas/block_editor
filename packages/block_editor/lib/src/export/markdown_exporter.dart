library;

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentExporter] that converts a [BlockDocument] to a Markdown
/// string.
///
/// Block-level mappings:
/// - Paragraph → plain text
/// - H1 / H2 / H3 → `#` / `##` / `###`
/// - Bullet list → `- ` with two-space indent per depth level
/// - Numbered list → `1. ` with two-space indent per depth level
/// - Todo → `- [ ] ` or `- [x] `
/// - Quote → `> `
/// - Divider → `---`
/// - Code → fenced block with language identifier
/// - Callout → blockquote with emoji variant prefix (ℹ️ / ⚠️ / ❌)
/// - Image → `![alt](url)`
/// - Video → `[Video](url)`
/// - YouTube → `[YouTube](https://youtu.be/{videoId})`
/// - File → `[filename](path)`
/// - Link → `[displayText](url)`
///
/// Inline formatting mappings:
/// - Bold → `**text**`
/// - Italic → `_text_`
/// - Bold and italic → `**_text_**`
/// - Strikethrough → `~~text~~`
/// - Inline code → `` `text` ``
/// - Link → `[text](url)`
/// - Text color and background color → stripped (no Markdown equivalent)
///
/// [VariableOp] embeds render as `{{variableName}}` literally.
/// [TagOp] embeds render as `#tag` literally.
///
/// Nested [BlockNode.children] are indented two spaces per depth level,
/// enabling correct rendering of nested lists in Markdown parsers that
/// support them.
///
/// Custom block types call [BlockPlugin.exportAsMarkdown] first; a null
/// return falls back to the block's delta plain text wrapped in a paragraph.
///
/// Usage:
/// ```dart
/// final markdown = await controller.exportAs(MarkdownExporter());
/// ```
final class MarkdownExporter implements BlockDocumentExporter {
  /// Creates a [MarkdownExporter].
  const MarkdownExporter();

  @override
  String get formatName => 'markdown';

  @override
  Future<String> export(BlockDocument document) async {
    final buffer = StringBuffer();
    final entries = document.flattenWithDepth();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final line = _convertBlock(entry.node, entry.depth);
      if (line == null) continue;

      buffer.write(line);

      final needsBlankLine = _needsTrailingBlankLine(entry.node.type);
      final isLast = i == entries.length - 1;

      if (!isLast) {
        buffer.writeln();
        if (needsBlankLine) buffer.writeln();
      }
    }

    return buffer.toString().trimRight();
  }

  String? _convertBlock(BlockNode node, int depth) {
    final plugin = BlockRegistry.instance.resolve(node.type);
    final customResult = plugin?.exportAsMarkdown(node);
    if (customResult != null) return customResult;

    final indent = '  ' * depth;
    final deltaText = _convertDelta(node.delta);

    return switch (node.type) {
      BlockTypes.paragraph => '$indent$deltaText',
      BlockTypes.heading1 => '# $deltaText',
      BlockTypes.heading2 => '## $deltaText',
      BlockTypes.heading3 => '### $deltaText',
      BlockTypes.bulletList => '$indent- $deltaText',
      BlockTypes.numberedList => '${indent}1. $deltaText',
      BlockTypes.todo => _todoLine(node, deltaText, indent),
      BlockTypes.quote => '> $deltaText',
      BlockTypes.callout => _calloutLine(node, deltaText),
      BlockTypes.code => _codeBlock(node),
      BlockTypes.divider => '---',
      BlockTypes.image => _imageBlock(node),
      BlockTypes.video => _videoBlock(node),
      BlockTypes.youtube => _youtubeBlock(node),
      BlockTypes.file => _fileBlock(node),
      BlockTypes.link => _linkBlock(node, deltaText),
      _ => '$indent$deltaText',
    };
  }

  String _todoLine(BlockNode node, String text, String indent) {
    final checked = node.attributes['checked'] == true;
    return '$indent- [${checked ? 'x' : ' '}] $text';
  }

  String _calloutLine(BlockNode node, String text) {
    final variant = node.attributes['variant'] as String? ?? 'info';
    final prefix = switch (variant) {
      'warning' => '⚠️',
      'error' => '❌',
      _ => 'ℹ️',
    };
    return '> $prefix $text';
  }

  String _codeBlock(BlockNode node) {
    final language = node.attributes['language'] as String? ?? '';
    final code =
        node.attributes['code'] as String? ?? node.delta?.plainText ?? '';
    return '```$language\n$code\n```';
  }

  String _imageBlock(BlockNode node) {
    final url = node.attributes['url'] as String? ?? '';
    final alt = node.attributes['alt'] as String? ?? 'image';
    return '![$alt]($url)';
  }

  String _videoBlock(BlockNode node) {
    final url = node.attributes['url'] as String? ?? '';
    return '[Video]($url)';
  }

  String _youtubeBlock(BlockNode node) {
    final videoId = node.attributes['videoId'] as String? ?? '';
    return '[YouTube](https://youtu.be/$videoId)';
  }

  String _fileBlock(BlockNode node) {
    final filename = node.attributes['filename'] as String? ?? 'file';
    final path =
        node.attributes['path'] as String? ??
        node.attributes['url'] as String? ??
        '';
    return '[$filename]($path)';
  }

  String _linkBlock(BlockNode node, String deltaText) {
    final url = node.attributes['url'] as String? ?? '';
    final display =
        node.attributes['displayText'] as String? ??
        (deltaText.isNotEmpty ? deltaText : url);
    return '[$display]($url)';
  }

  String _convertDelta(TextDelta? delta) {
    if (delta == null) return '';
    final buffer = StringBuffer();
    for (final op in delta.ops) {
      switch (op) {
        case TextOp():
          buffer.write(_applyInlineFormatting(op));
        case VariableOp():
          buffer.write('{{${op.variableName}}}');
        case TagOp():
          buffer.write('#${op.tag}');
      }
    }
    return buffer.toString();
  }

  String _applyInlineFormatting(TextOp op) {
    final attrs = op.attributes;
    var text = op.text;

    if (attrs.link != null && attrs.link!.isNotEmpty) {
      text = '[$text](${attrs.link})';
      return text;
    }

    if (attrs.inlineCode == true) {
      return '`$text`';
    }

    final isBold = attrs.bold == true;
    final isItalic = attrs.italic == true;

    if (isBold && isItalic) {
      text = '**_${text}_**';
    } else if (isBold) {
      text = '**$text**';
    } else if (isItalic) {
      text = '_${text}_';
    }

    if (attrs.strikethrough == true) {
      text = '~~$text~~';
    }

    return text;
  }

  bool _needsTrailingBlankLine(String type) {
    return type == BlockTypes.heading1 ||
        type == BlockTypes.heading2 ||
        type == BlockTypes.heading3 ||
        type == BlockTypes.code ||
        type == BlockTypes.divider;
  }
}
