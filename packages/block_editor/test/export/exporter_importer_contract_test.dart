import 'package:block_editor/block_editor.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubExporter implements BlockDocumentExporter {
  @override
  String get formatName => 'stub';

  @override
  Future<String> export(BlockDocument document) async =>
      document.blocks.length.toString();
}

class _StubImporter implements BlockDocumentImporter {
  @override
  String get formatName => 'stub';

  @override
  Future<BlockDocument> import(String source) async => BlockDocument.empty();
}

void main() {
  group('BlockDocumentExporter contract', () {
    test('formatName is accessible', () {
      expect(_StubExporter().formatName, 'stub');
    });

    test('export returns a Future<String>', () async {
      final doc = BlockDocument([
        BlockNode(type: BlockTypes.paragraph),
        BlockNode(type: BlockTypes.paragraph),
      ]);
      final result = await _StubExporter().export(doc);
      expect(result, '2');
    });

    test('export receives the full document', () async {
      const doc = BlockDocument([]);
      final result = await _StubExporter().export(doc);
      expect(result, '0');
    });
  });

  group('BlockDocumentImporter contract', () {
    test('formatName is accessible', () {
      expect(_StubImporter().formatName, 'stub');
    });

    test('import returns a Future<BlockDocument>', () async {
      final result = await _StubImporter().import('anything');
      expect(result, isA<BlockDocument>());
    });

    test('import receives the source string', () async {
      final result = await _StubImporter().import('');
      expect(result.isNotEmpty, isTrue);
    });
  });
}
