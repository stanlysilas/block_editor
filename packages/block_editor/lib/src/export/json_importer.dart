library;

import 'dart:convert';

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentImporter] that parses a JSON string into a [BlockDocument].
///
/// The input must be a JSON string previously produced by JsonExporter or
/// by any code that serializes a [BlockDocument] via [BlockDocument.toJson].
/// When source is empty or cannot be parsed as valid JSON, [import] returns
/// [BlockDocument.empty] rather than throwing.
///
/// Usage:
/// ```dart
/// await controller.importFrom(JsonImporter(), jsonString);
/// ```
final class JsonImporter implements BlockDocumentImporter {
  /// Creates a [JsonImporter].
  const JsonImporter();

  @override
  String get formatName => 'json';

  @override
  Future<BlockDocument> import(String source) async {
    if (source.trim().isEmpty) return BlockDocument.empty();
    try {
      final map = jsonDecode(source) as Map<String, dynamic>;
      return BlockDocument.fromJson(map);
    } catch (_) {
      return BlockDocument.empty();
    }
  }
}
