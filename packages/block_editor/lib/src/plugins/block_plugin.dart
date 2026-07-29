library;

import 'package:flutter/widgets.dart';
import 'package:block_editor/block_editor.dart';

/// The contract every block type must implement to participate in the editor.
///
/// A [BlockPlugin] is fully self-contained. A developer in a separate Dart
/// package imports only `block_editor`, implements this class, and registers
/// the plugin with [BlockRegistry.register]. The plugin is then
/// indistinguishable from a built-in block type at runtime.
abstract class BlockPlugin {
  /// The unique string identifier for the block type this plugin handles.
  ///
  /// Must match a [BlockTypes] constant for built-in plugins. Third-party
  /// plugins choose their own collision-resistant string.
  String get blockType;

  /// Builds the widget that renders [node] inside the editor.
  ///
  /// [selection] is the current editor selection, forwarded so the widget
  /// can compute its own highlight state without querying the controller.
  ///
  /// [onEvent] is the callback through which all user interactions travel
  /// upward to [BlockEditorWidget]. The plugin never imports or touches
  /// [BlockController] directly.
  Widget build(
    BlockNode node,
    EditorSelection selection,
    void Function(BlockEvent) onEvent,
  );

  /// Serializes [node] to a JSON-compatible map.
  ///
  /// The returned map must be deserializable by [deserialize].
  Map<String, dynamic> serialize(BlockNode node);

  /// Deserializes a [BlockNode] from a JSON-compatible map produced by
  /// [serialize].
  BlockNode deserialize(Map<String, dynamic> json);

  /// Returns the [ToolbarButtonConfig] this plugin contributes to the
  /// formatting toolbar, or null if it contributes none.
  ToolbarButtonConfig? toolbarButton() => null;

  /// Returns the [SlashCommandConfig] this plugin contributes to the
  /// trigger-character menu, or null if it contributes none.
  SlashCommandConfig? slashCommandItem() => null;

  /// Returns the slash menu section name under which this plugin's entry
  /// appears, or null to fall under a default group.
  ///
  /// Built-in plugins return fixed group names. External plugins return
  /// their chosen group name.
  String? slashCommandGroup() => null;

  /// Returns a plain-text representation of [node] for use by
  /// [PlainTextExporter], or null to use the exporter's default rendering
  /// for this block type.
  ///
  /// Implement this method when the default plain-text fallback — which
  /// uses [BlockNode.delta] plain text — does not produce adequate output
  /// for your block type. Return null to accept the default.
  String? exportAsPlainText(BlockNode node) => null;

  /// Returns a Markdown representation of [node] for use by
  /// [MarkdownExporter], or null to use the exporter's default rendering
  /// for this block type.
  ///
  /// Return null to accept the default Markdown rendering. Implement this
  /// when your block type requires custom Markdown output that the default
  /// delta-to-Markdown conversion cannot produce.
  String? exportAsMarkdown(BlockNode node) => null;

  /// Returns an HTML fragment representing [node] for use by [HtmlExporter],
  /// or null to use the exporter's default rendering for this block type.
  ///
  /// The returned string should be a complete HTML element with no surrounding
  /// whitespace. Return null to accept the default HTML rendering.
  String? exportAsHtml(BlockNode node) => null;
}
