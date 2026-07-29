library;

import 'dart:convert';

import 'package:block_editor/block_editor.dart';

/// A [BlockDocumentExporter] that serializes a [BlockDocument] to a JSON
/// string.
///
/// The output is a pretty-printed JSON string produced by serializing the
/// document via [BlockDocument.toJson]. The result is deserializable back to
/// an identical [BlockDocument] via [JsonImporter], making this the canonical
/// lossless persistence format for block editor documents.
///
/// Usage:
/// ```dart
/// final json = await controller.exportAs(JsonExporter());
/// ```
final class JsonExporter implements BlockDocumentExporter {
  /// Creates a [JsonExporter].
  const JsonExporter();

  @override
  String get formatName => 'json';

  @override
  Future<String> export(BlockDocument document) async {
    return const JsonEncoder.withIndent('  ').convert(document.toJson());
  }
}
