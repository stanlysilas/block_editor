import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

BlockDocument _richDocument() {
  return BlockDocument([
    BlockNode(
      id: 'h1',
      type: BlockTypes.heading1,
      delta: TextDelta([
        const TextOp('Hello ', attributes: InlineAttributes(bold: true)),
        const TextOp('world'),
      ]),
    ),
    BlockNode(
      id: 'p1',
      type: BlockTypes.paragraph,
      delta: TextDelta([
        const TextOp('Plain text with '),
        const TextOp('italic', attributes: InlineAttributes(italic: true)),
      ]),
    ),
    BlockNode(
      id: 'todo1',
      type: BlockTypes.todo,
      attributes: const {'checked': true},
      delta: TextDelta.fromPlainText('A checked task'),
    ),
    BlockNode(id: 'div1', type: BlockTypes.divider),
    BlockNode(
      id: 'parent1',
      type: BlockTypes.bulletList,
      delta: TextDelta.fromPlainText('Parent item'),
      children: [
        BlockNode(
          id: 'child1',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Child item'),
        ),
      ],
    ),
  ]);
}

void main() {
  group('JsonExporter', () {
    test('formatName is json', () {
      expect(const JsonExporter().formatName, 'json');
    });

    test('export produces a non-empty string', () async {
      final result = await const JsonExporter().export(BlockDocument.empty());
      expect(result, isNotEmpty);
    });

    test('export output contains blocks key', () async {
      final result = await const JsonExporter().export(BlockDocument.empty());
      expect(result, contains('"blocks"'));
    });

    test('export produces pretty-printed JSON', () async {
      final result = await const JsonExporter().export(BlockDocument.empty());
      expect(result, contains('\n'));
    });

    test('export of empty document produces valid JSON', () async {
      const doc = BlockDocument([]);
      final result = await const JsonExporter().export(doc);
      expect(result, contains('"blocks"'));
      expect(result, contains('[]'));
    });

    test('export preserves block type', () async {
      final doc = BlockDocument([
        BlockNode(id: 'b1', type: BlockTypes.heading1),
      ]);
      final result = await const JsonExporter().export(doc);
      expect(result, contains('heading1'));
    });

    test('export preserves inline attributes', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'b1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('bold', attributes: InlineAttributes(bold: true)),
          ]),
        ),
      ]);
      final result = await const JsonExporter().export(doc);
      expect(result, contains('"bold"'));
      expect(result, contains('true'));
    });

    test('export preserves block attributes', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'b1',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
        ),
      ]);
      final result = await const JsonExporter().export(doc);
      expect(result, contains('"checked"'));
    });

    test('export preserves nested children', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'parent',
          type: BlockTypes.bulletList,
          children: [BlockNode(id: 'child', type: BlockTypes.bulletList)],
        ),
      ]);
      final result = await const JsonExporter().export(doc);
      expect(result, contains('"children"'));
      expect(result, contains('"child"'));
    });
  });

  group('JsonImporter', () {
    test('formatName is json', () {
      expect(const JsonImporter().formatName, 'json');
    });

    test('import of empty string returns BlockDocument.empty', () async {
      final result = await const JsonImporter().import('');
      expect(result.blocks.length, 1);
      expect(result.blocks.first.type, BlockTypes.paragraph);
    });

    test(
      'import of whitespace-only string returns BlockDocument.empty',
      () async {
        final result = await const JsonImporter().import('   ');
        expect(result.isNotEmpty, isTrue);
      },
    );

    test('import of invalid JSON returns BlockDocument.empty', () async {
      final result = await const JsonImporter().import('not json {{');
      expect(result.isNotEmpty, isTrue);
    });

    test('import restores block types', () async {
      final json = '{"blocks":[{"id":"b1","type":"heading1"}]}';
      final result = await const JsonImporter().import(json);
      expect(result.blocks.first.type, BlockTypes.heading1);
    });
  });

  group('JSON round-trip', () {
    test('empty document survives round-trip', () async {
      const original = BlockDocument([]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
    });

    test('single paragraph survives round-trip', () async {
      final original = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Hello world'),
        ),
      ]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
    });

    test('rich document with inline attributes survives round-trip', () async {
      final original = _richDocument();
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
    });

    test('block attributes survive round-trip', () async {
      final original = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: TextDelta.fromPlainText('Done'),
        ),
      ]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored.blocks.first.attributes['checked'], isTrue);
    });

    test('nested children survive round-trip', () async {
      final original = BlockDocument([
        BlockNode(
          id: 'parent',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Parent'),
          children: [
            BlockNode(
              id: 'child',
              type: BlockTypes.bulletList,
              delta: TextDelta.fromPlainText('Child'),
            ),
          ],
        ),
      ]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
      expect(restored.blocks.first.children.first.id, 'child');
    });

    test('variable and tag ops survive round-trip', () async {
      final original = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('Hello '),
            const VariableOp('name'),
            const TextOp(' tagged with '),
            const TagOp('flutter'),
          ]),
        ),
      ]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
    });

    test('all sixteen built-in block types survive round-trip', () async {
      final original = BlockDocument([
        BlockNode(id: 'a', type: BlockTypes.paragraph),
        BlockNode(id: 'b', type: BlockTypes.heading1),
        BlockNode(id: 'c', type: BlockTypes.heading2),
        BlockNode(id: 'd', type: BlockTypes.heading3),
        BlockNode(id: 'e', type: BlockTypes.bulletList),
        BlockNode(id: 'f', type: BlockTypes.numberedList),
        BlockNode(id: 'g', type: BlockTypes.todo),
        BlockNode(id: 'h', type: BlockTypes.quote),
        BlockNode(
          id: 'i',
          type: BlockTypes.callout,
          attributes: const {'variant': 'info'},
        ),
        BlockNode(
          id: 'j',
          type: BlockTypes.code,
          attributes: const {'code': 'x = 1', 'language': 'python'},
        ),
        BlockNode(id: 'k', type: BlockTypes.divider),
        BlockNode(
          id: 'l',
          type: BlockTypes.image,
          attributes: const {
            'url': 'https://example.com/img.png',
            'source': 'network',
          },
        ),
        BlockNode(
          id: 'm',
          type: BlockTypes.video,
          attributes: const {
            'url': 'https://example.com/v.mp4',
            'source': 'network',
          },
        ),
        BlockNode(
          id: 'n',
          type: BlockTypes.youtube,
          attributes: const {'videoId': 'dQw4w9WgXcQ'},
        ),
        BlockNode(
          id: 'o',
          type: BlockTypes.file,
          attributes: const {'filename': 'doc.pdf', 'path': '/tmp/doc.pdf'},
        ),
        BlockNode(
          id: 'p2',
          type: BlockTypes.link,
          attributes: const {
            'url': 'https://pub.dev',
            'displayText': 'pub.dev',
          },
        ),
      ]);
      final exported = await const JsonExporter().export(original);
      final restored = await const JsonImporter().import(exported);
      expect(restored, equals(original));
    });
  });
}
