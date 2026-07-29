library;

import 'package:block_editor/block_editor.dart';

/// The contract every document importer implements.
///
/// Implement this class to parse a [String] into a [BlockDocument]. The
/// built-in importers cover JSON and Markdown. Third-party developers can
/// implement this interface to support additional input formats.
///
/// ## Implementing a custom importer
///
/// ```dart
/// class MyImporter implements BlockDocumentImporter {
///   @override
///   String get formatName => 'my_format';
///
///   @override
///   Future<BlockDocument> import(String source) async {
///     // Parse source and return a BlockDocument.
///     return BlockDocument.empty();
///   }
/// }
/// ```
///
/// Call the importer via BlockController.importFrom rather than calling
/// [import] directly. BlockController.importFrom pushes an undo snapshot
/// before replacing the document so the import operation is undoable.
abstract class BlockDocumentImporter {
  /// A short human-readable identifier for this import format.
  ///
  /// Used for logging and display purposes. Examples: `'json'`, `'markdown'`.
  String get formatName;

  /// Parses [source] and returns the resulting [BlockDocument].
  ///
  /// The returned [Future] completes with the parsed document. Implementations
  /// should return [BlockDocument.empty] rather than throwing when [source] is
  /// empty or contains no recognisable content.
  Future<BlockDocument> import(String source);
}
