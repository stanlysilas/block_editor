library;

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentExporter] that converts a [BlockDocument] to plain text.
///
/// All inline formatting — bold, italic, underline, color, and so on — is
/// stripped. Each block contributes its content followed by a newline. Blocks
/// with no textual content contribute a single representative string such as
/// `---` for dividers or `[Image]` for image blocks.
///
/// [VariableOp] embeds render as `{{variableName}}`. [TagOp] embeds render as
/// `#tag`. Custom block types call [BlockPlugin.exportAsPlainText] first; a
/// null return falls back to the block's delta plain text.
///
/// Usage:
/// ```dart
/// final text = await controller.exportAs(PlainTextExporter());
/// ```
final class PlainTextExporter implements BlockDocumentExporter {
  /// Creates a [PlainTextExporter].
  const PlainTextExporter();

  @override
  String get formatName => 'plain_text';

  @override
  Future<String> export(BlockDocument document) async {
    final buffer = StringBuffer();
    for (final node in document.flatten()) {
      final line = _convertBlock(node);
      if (line != null) {
        buffer.writeln(line);
      }
    }
    return buffer.toString().trimRight();
  }

  String? _convertBlock(BlockNode node) {
    final plugin = BlockRegistry.instance.resolve(node.type);
    final customResult = plugin?.exportAsPlainText(node);
    if (customResult != null) return customResult;

    final deltaText = _deltaToPlainText(node.delta);

    return switch (node.type) {
      BlockTypes.paragraph => deltaText,
      BlockTypes.heading1 => deltaText,
      BlockTypes.heading2 => deltaText,
      BlockTypes.heading3 => deltaText,
      BlockTypes.bulletList => '• $deltaText',
      BlockTypes.numberedList => deltaText,
      BlockTypes.todo => _todoLine(node, deltaText),
      BlockTypes.quote => deltaText,
      BlockTypes.callout => deltaText,
      BlockTypes.code =>
        node.attributes['code'] as String? ?? deltaText,
      BlockTypes.divider => '---',
      BlockTypes.image => '[Image]',
      BlockTypes.video => '[Video]',
      BlockTypes.youtube => '[YouTube]',
      BlockTypes.file =>
        '[File: ${node.attributes['filename'] as String? ?? ''}]',
      BlockTypes.link =>
        node.attributes['url'] as String? ?? deltaText,
      _ => deltaText,
    };
  }

  String _todoLine(BlockNode node, String text) {
    final checked = node.attributes['checked'] == true;
    return '${checked ? '[x]' : '[ ]'} $text';
  }

  String _deltaToPlainText(TextDelta? delta) {
    if (delta == null) return '';
    final buffer = StringBuffer();
    for (final op in delta.ops) {
      switch (op) {
        case TextOp():
          buffer.write(op.text);
        case VariableOp():
          buffer.write('{{${op.variableName}}}');
        case TagOp():
          buffer.write('#${op.tag}');
      }
    }
    return buffer.toString();
  }
}