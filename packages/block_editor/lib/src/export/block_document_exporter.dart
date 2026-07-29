library;

import 'package:block_editor/block_editor.dart';

/// The contract every string-based document exporter implements.
///
/// Implement this class to produce a [String] representation of a
/// [BlockDocument] in any format — Markdown, HTML, plain text, or a custom
/// format defined by a third-party developer.
///
/// All built-in exporters except the PDF exporter implement this interface.
/// The PDF exporter implements BlockDocumentPdfExporter instead, because it
/// returns a binary document object rather than a [String].
///
/// ## Implementing a custom exporter
///
/// ```dart
/// class MyExporter implements BlockDocumentExporter {
///   @override
///   String get formatName => 'my_format';
///
///   @override
///   Future<String> export(BlockDocument document) async {
///     final buffer = StringBuffer();
///     for (final node in document.flatten()) {
///       buffer.writeln(node.delta?.plainText ?? '');
///     }
///     return buffer.toString();
///   }
/// }
/// ```
///
/// Call the exporter via BlockController.exportAs rather than calling
/// [export] directly.
abstract class BlockDocumentExporter {
  /// A short human-readable identifier for this export format.
  ///
  /// Used for logging and display purposes. Examples: `'json'`, `'markdown'`,
  /// `'html'`, `'plain_text'`.
  String get formatName;

  /// Converts [document] to a [String] in this exporter's target format.
  ///
  /// The returned [Future] completes with the full export output as a single
  /// string. Implementations should use [BlockDocument.flatten] for formats
  /// that do not require depth information, and [BlockDocument.flattenWithDepth]
  /// for formats that produce indented or hierarchically structured output.
  Future<String> export(BlockDocument document);
}
