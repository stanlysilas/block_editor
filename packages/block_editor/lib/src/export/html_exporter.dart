library;

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentExporter] that converts a [BlockDocument] to an HTML
/// fragment string.
///
/// The output is a semantic HTML5 fragment. No `<html>`, `<head>`, or `<body>`
/// wrapper tags are emitted. The fragment is suitable for embedding directly
/// in a web page or for passing to an HTML renderer.
///
/// Block-level mappings:
/// - Paragraph → `<p>`
/// - H1 / H2 / H3 → `<h1>` / `<h2>` / `<h3>`
/// - Bullet list → `<ul><li>` with nested `<ul>` for children
/// - Numbered list → `<ol><li>` with nested `<ol>` for children
/// - Todo → `<ul class="todo"><li data-checked="true|false">`
/// - Quote → `<blockquote>`
/// - Divider → `<hr>`
/// - Code → `<pre><code class="language-x">`
/// - Callout → `<div class="callout callout-{variant}">`
/// - Image → `<img src="..." alt="...">`
/// - Video → `<p><a href="...">Video</a></p>`
/// - YouTube → `<p><a href="https://youtu.be/{videoId}">YouTube</a></p>`
/// - File → `<p><a href="...">{filename}</a></p>`
/// - Link → `<p><a href="...">{displayText}</a></p>`
///
/// Inline formatting mappings:
/// - Bold → `<strong>`
/// - Italic → `<em>`
/// - Underline → `<u>`
/// - Strikethrough → `<s>`
/// - Inline code → `<code>`
/// - Link → `<a href="...">`
/// - Text color → `style="color: #rrggbb"`
/// - Background color → `style="background-color: #rrggbb"`
///
/// [VariableOp] embeds render as `{{variableName}}` literally.
/// [TagOp] embeds render as `#tag` literally.
///
/// Nested [BlockNode.children] produce correctly nested `<ul>` and `<ol>`
/// elements using [BlockDocument.flattenWithDepth] for depth information.
///
/// Custom block types call BlockPlugin.exportAsHtml first; a null return
/// falls back to `<p>` wrapping the block's delta plain text.
///
/// Usage:
/// ```dart
/// final html = await controller.exportAs(HtmlExporter());
/// ```
final class HtmlExporter implements BlockDocumentExporter {
  /// Creates an [HtmlExporter].
  const HtmlExporter();

  @override
  String get formatName => 'html';

  @override
  Future<String> export(BlockDocument document) async {
    final entries = document.flattenWithDepth();
    if (entries.isEmpty) return '';

    final buffer = StringBuffer();
    final listStack = <_ListFrame>[];

    for (final entry in entries) {
      final node = entry.node;
      final depth = entry.depth;

      final plugin = BlockRegistry.instance.resolve(node.type);
      final customResult = plugin?.exportAsHtml(node);
      if (customResult != null) {
        _closeAllLists(buffer, listStack);
        buffer.writeln(customResult);
        continue;
      }

      final isListType = _isListType(node.type);

      if (!isListType) {
        _closeAllLists(buffer, listStack);
        buffer.writeln(_convertBlock(node));
        continue;
      }

      _syncListStack(buffer, listStack, node.type, depth);
      buffer.writeln('  ' * (depth + 1) + _listItem(node));
    }

    _closeAllLists(buffer, listStack);
    return buffer.toString().trimRight();
  }

  bool _isListType(String type) =>
      type == BlockTypes.bulletList ||
      type == BlockTypes.numberedList ||
      type == BlockTypes.todo;

  void _syncListStack(
    StringBuffer buffer,
    List<_ListFrame> stack,
    String type,
    int depth,
  ) {
    while (stack.isNotEmpty && stack.last.depth > depth) {
      final frame = stack.removeLast();
      buffer.writeln('  ' * frame.depth + frame.closeTag);
    }

    if (stack.isNotEmpty && stack.last.depth == depth) {
      if (stack.last.type != type) {
        final frame = stack.removeLast();
        buffer.writeln('  ' * frame.depth + frame.closeTag);
        _openList(buffer, stack, type, depth);
      }
    } else {
      _openList(buffer, stack, type, depth);
    }
  }

  void _openList(
    StringBuffer buffer,
    List<_ListFrame> stack,
    String type,
    int depth,
  ) {
    final indent = '  ' * depth;
    if (type == BlockTypes.bulletList) {
      buffer.writeln('$indent<ul>');
      stack.add(_ListFrame(type: type, depth: depth, closeTag: '</ul>'));
    } else if (type == BlockTypes.numberedList) {
      buffer.writeln('$indent<ol>');
      stack.add(_ListFrame(type: type, depth: depth, closeTag: '</ol>'));
    } else {
      buffer.writeln('$indent<ul class="todo">');
      stack.add(_ListFrame(type: type, depth: depth, closeTag: '</ul>'));
    }
  }

  void _closeAllLists(StringBuffer buffer, List<_ListFrame> stack) {
    while (stack.isNotEmpty) {
      final frame = stack.removeLast();
      buffer.writeln('  ' * frame.depth + frame.closeTag);
    }
  }

  String _listItem(BlockNode node) {
    final inner = _convertDelta(node.delta);
    if (node.type == BlockTypes.todo) {
      final checked = node.attributes['checked'] == true;
      return '<li data-checked="$checked">$inner</li>';
    }
    return '<li>$inner</li>';
  }

  String _convertBlock(BlockNode node) {
    return switch (node.type) {
      BlockTypes.paragraph => '<p>${_convertDelta(node.delta)}</p>',
      BlockTypes.heading1 => '<h1>${_convertDelta(node.delta)}</h1>',
      BlockTypes.heading2 => '<h2>${_convertDelta(node.delta)}</h2>',
      BlockTypes.heading3 => '<h3>${_convertDelta(node.delta)}</h3>',
      BlockTypes.quote =>
        '<blockquote>${_convertDelta(node.delta)}</blockquote>',
      BlockTypes.divider => '<hr>',
      BlockTypes.code => _codeBlock(node),
      BlockTypes.callout => _calloutBlock(node),
      BlockTypes.image => _imageBlock(node),
      BlockTypes.video => _videoBlock(node),
      BlockTypes.youtube => _youtubeBlock(node),
      BlockTypes.file => _fileBlock(node),
      BlockTypes.link => _linkBlock(node),
      _ => '<p>${_escapeHtml(node.delta?.plainText ?? '')}</p>',
    };
  }

  String _codeBlock(BlockNode node) {
    final language = node.attributes['language'] as String? ?? '';
    final code = _escapeHtml(
      node.attributes['code'] as String? ?? node.delta?.plainText ?? '',
    );
    final cls = language.isNotEmpty ? ' class="language-$language"' : '';
    return '<pre><code$cls>$code</code></pre>';
  }

  String _calloutBlock(BlockNode node) {
    final variant = node.attributes['variant'] as String? ?? 'info';
    final inner = _convertDelta(node.delta);
    return '<div class="callout callout-$variant">$inner</div>';
  }

  String _imageBlock(BlockNode node) {
    final url = _escapeHtml(node.attributes['url'] as String? ?? '');
    final alt = _escapeHtml(node.attributes['alt'] as String? ?? '');
    return '<img src="$url" alt="$alt">';
  }

  String _videoBlock(BlockNode node) {
    final url = _escapeHtml(node.attributes['url'] as String? ?? '');
    return '<p><a href="$url">Video</a></p>';
  }

  String _youtubeBlock(BlockNode node) {
    final videoId = node.attributes['videoId'] as String? ?? '';
    return '<p><a href="https://youtu.be/$videoId">YouTube</a></p>';
  }

  String _fileBlock(BlockNode node) {
    final filename = _escapeHtml(
      node.attributes['filename'] as String? ?? 'File',
    );
    final path = _escapeHtml(
      node.attributes['path'] as String? ??
          node.attributes['url'] as String? ??
          '',
    );
    return '<p><a href="$path">$filename</a></p>';
  }

  String _linkBlock(BlockNode node) {
    final url = _escapeHtml(node.attributes['url'] as String? ?? '');
    final display = _escapeHtml(
      node.attributes['displayText'] as String? ?? url,
    );
    return '<p><a href="$url">$display</a></p>';
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
    var text = _escapeHtml(op.text);

    final styleParts = <String>[];
    if (attrs.color != null) styleParts.add('color: ${attrs.color}');
    if (attrs.backgroundColor != null) {
      styleParts.add('background-color: ${attrs.backgroundColor}');
    }

    if (attrs.link != null && attrs.link!.isNotEmpty) {
      final href = _escapeHtml(attrs.link!);
      final style = styleParts.isNotEmpty
          ? ' style="${styleParts.join('; ')}"'
          : '';
      return '<a href="$href"$style>$text</a>';
    }

    if (attrs.inlineCode == true) return '<code>$text</code>';
    if (attrs.bold == true) text = '<strong>$text</strong>';
    if (attrs.italic == true) text = '<em>$text</em>';
    if (attrs.underline == true) text = '<u>$text</u>';
    if (attrs.strikethrough == true) text = '<s>$text</s>';

    if (styleParts.isNotEmpty) {
      text = '<span style="${styleParts.join('; ')}">$text</span>';
    }

    return text;
  }

  String _escapeHtml(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

class _ListFrame {
  const _ListFrame({
    required this.type,
    required this.depth,
    required this.closeTag,
  });

  final String type;
  final int depth;
  final String closeTag;
}
