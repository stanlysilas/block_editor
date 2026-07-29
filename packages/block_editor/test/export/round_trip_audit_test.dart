import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

const _jsonExporter = JsonExporter();
const _jsonImporter = JsonImporter();
const _mdExporter = MarkdownExporter();
const _mdImporter = MarkdownImporter();

Future<BlockDocument> _jsonRoundTrip(BlockDocument doc) async {
  final exported = await _jsonExporter.export(doc);
  return _jsonImporter.import(exported);
}

Future<BlockDocument> _mdRoundTrip(BlockDocument doc) async {
  final exported = await _mdExporter.export(doc);
  return _mdImporter.import(exported);
}

Future<BlockDocument> _jsonDoubleRoundTrip(BlockDocument doc) async {
  final first = await _jsonRoundTrip(doc);
  return _jsonRoundTrip(first);
}

Future<BlockDocument> _mdDoubleRoundTrip(BlockDocument doc) async {
  final first = await _mdRoundTrip(doc);
  return _mdRoundTrip(first);
}

void main() {
  group('Round-trip audit — JSON', () {
    test('empty document', () async {
      const doc = BlockDocument([]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('single paragraph', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Hello world'),
        ),
      ]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('all sixteen built-in block types', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'a',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Paragraph'),
        ),
        BlockNode(
          id: 'b',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('H1'),
        ),
        BlockNode(
          id: 'c',
          type: BlockTypes.heading2,
          delta: TextDelta.fromPlainText('H2'),
        ),
        BlockNode(
          id: 'd',
          type: BlockTypes.heading3,
          delta: TextDelta.fromPlainText('H3'),
        ),
        BlockNode(
          id: 'e',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Bullet'),
        ),
        BlockNode(
          id: 'f',
          type: BlockTypes.numberedList,
          delta: TextDelta.fromPlainText('Numbered'),
        ),
        BlockNode(
          id: 'g',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: TextDelta.fromPlainText('Todo'),
        ),
        BlockNode(
          id: 'h',
          type: BlockTypes.quote,
          delta: TextDelta.fromPlainText('Quote'),
        ),
        BlockNode(
          id: 'i',
          type: BlockTypes.callout,
          attributes: const {'variant': 'warning'},
          delta: TextDelta.fromPlainText('Callout'),
        ),
        BlockNode(
          id: 'j',
          type: BlockTypes.code,
          attributes: const {'language': 'dart', 'code': 'void main() {}'},
        ),
        BlockNode(id: 'k', type: BlockTypes.divider),
        BlockNode(
          id: 'l',
          type: BlockTypes.image,
          attributes: const {
            'url': 'https://example.com/img.png',
            'alt': 'photo',
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
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('all inline attributes', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('bold', attributes: InlineAttributes(bold: true)),
            const TextOp('italic', attributes: InlineAttributes(italic: true)),
            const TextOp(
              'underline',
              attributes: InlineAttributes(underline: true),
            ),
            const TextOp(
              'strike',
              attributes: InlineAttributes(strikethrough: true),
            ),
            const TextOp(
              'code',
              attributes: InlineAttributes(inlineCode: true),
            ),
            const TextOp(
              'link',
              attributes: InlineAttributes(link: 'https://example.com'),
            ),
            const TextOp(
              'colored',
              attributes: InlineAttributes(color: '#ff0000'),
            ),
            const TextOp(
              'bg',
              attributes: InlineAttributes(backgroundColor: '#00ff00'),
            ),
          ]),
        ),
      ]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('VariableOp and TagOp', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('Hello '),
            const VariableOp('userName'),
            const TextOp(' tagged '),
            const TagOp('flutter'),
          ]),
        ),
      ]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('nested children one level deep', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'parent',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Parent'),
          children: [
            BlockNode(
              id: 'child1',
              type: BlockTypes.bulletList,
              delta: TextDelta.fromPlainText('Child 1'),
            ),
            BlockNode(
              id: 'child2',
              type: BlockTypes.bulletList,
              delta: TextDelta.fromPlainText('Child 2'),
            ),
          ],
        ),
      ]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('nested children two levels deep', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'a',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('A'),
          children: [
            BlockNode(
              id: 'b',
              type: BlockTypes.bulletList,
              delta: TextDelta.fromPlainText('B'),
              children: [
                BlockNode(
                  id: 'c',
                  type: BlockTypes.bulletList,
                  delta: TextDelta.fromPlainText('C'),
                ),
              ],
            ),
          ],
        ),
      ]);
      expect(await _jsonRoundTrip(doc), equals(doc));
    });

    test('block attributes preserved', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: TextDelta.fromPlainText('Done'),
        ),
        BlockNode(
          id: 'ca1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'error'},
          delta: TextDelta.fromPlainText('Error'),
        ),
      ]);
      final restored = await _jsonRoundTrip(doc);
      expect(restored.blocks[0].attributes['checked'], isTrue);
      expect(restored.blocks[1].attributes['variant'], 'error');
    });

    test('double round-trip produces identical result', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h1',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('Title'),
        ),
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('plain '),
            const TextOp('bold', attributes: InlineAttributes(bold: true)),
          ]),
        ),
        BlockNode(id: 'd1', type: BlockTypes.divider),
      ]);
      final single = await _jsonRoundTrip(doc);
      final doubleTripResult = await _jsonDoubleRoundTrip(doc);
      expect(single, equals(doubleTripResult));
    });

    test('large document preserves block order', () async {
      final blocks = List.generate(
        20,
        (i) => BlockNode(
          id: 'b$i',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Block $i'),
        ),
      );
      final doc = BlockDocument(blocks);
      final restored = await _jsonRoundTrip(doc);
      for (var i = 0; i < 20; i++) {
        expect(restored.blocks[i].delta!.plainText, 'Block $i');
      }
    });
  });

  group('Round-trip audit — Markdown', () {
    test('paragraph', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Hello'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.paragraph);
      expect(restored.blocks.first.delta!.plainText, 'Hello');
    });

    test('heading1', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h1',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('Title'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.heading1);
      expect(restored.blocks.first.delta!.plainText, 'Title');
    });

    test('heading2', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h2',
          type: BlockTypes.heading2,
          delta: TextDelta.fromPlainText('Section'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.heading2);
      expect(restored.blocks.first.delta!.plainText, 'Section');
    });

    test('heading3', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h3',
          type: BlockTypes.heading3,
          delta: TextDelta.fromPlainText('Subsection'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.heading3);
      expect(restored.blocks.first.delta!.plainText, 'Subsection');
    });

    test('bullet list', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'b1',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Item'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.bulletList);
      expect(restored.blocks.first.delta!.plainText, 'Item');
    });

    test('numbered list', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'n1',
          type: BlockTypes.numberedList,
          delta: TextDelta.fromPlainText('First'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.numberedList);
      expect(restored.blocks.first.delta!.plainText, 'First');
    });

    test('unchecked todo', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': false},
          delta: TextDelta.fromPlainText('Task'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.todo);
      expect(restored.blocks.first.attributes['checked'], isFalse);
      expect(restored.blocks.first.delta!.plainText, 'Task');
    });

    test('checked todo', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: TextDelta.fromPlainText('Done'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.todo);
      expect(restored.blocks.first.attributes['checked'], isTrue);
    });

    test('quote', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'q1',
          type: BlockTypes.quote,
          delta: TextDelta.fromPlainText('Wise words'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.quote);
      expect(restored.blocks.first.delta!.plainText, 'Wise words');
    });

    test('divider', () async {
      final doc = BlockDocument([
        BlockNode(id: 'd1', type: BlockTypes.divider),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.divider);
    });

    test('code block with language', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'c1',
          type: BlockTypes.code,
          attributes: const {'language': 'dart', 'code': 'void main() {}'},
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.code);
      expect(restored.blocks.first.attributes['language'], 'dart');
      expect(restored.blocks.first.attributes['code'], 'void main() {}');
    });

    test('info callout', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'ca1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'info'},
          delta: TextDelta.fromPlainText('Note'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.callout);
      expect(restored.blocks.first.attributes['variant'], 'info');
      expect(restored.blocks.first.delta!.plainText, 'Note');
    });

    test('warning callout', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'ca1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'warning'},
          delta: TextDelta.fromPlainText('Careful'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.attributes['variant'], 'warning');
    });

    test('error callout', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'ca1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'error'},
          delta: TextDelta.fromPlainText('Fatal'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.attributes['variant'], 'error');
    });

    test('image', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'img1',
          type: BlockTypes.image,
          attributes: const {
            'url': 'https://example.com/img.png',
            'alt': 'photo',
            'source': 'network',
          },
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.image);
      expect(
        restored.blocks.first.attributes['url'],
        'https://example.com/img.png',
      );
      expect(restored.blocks.first.attributes['alt'], 'photo');
    });

    test('link block', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'l1',
          type: BlockTypes.link,
          attributes: const {
            'url': 'https://pub.dev',
            'displayText': 'pub.dev',
          },
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.link);
      expect(restored.blocks.first.attributes['url'], 'https://pub.dev');
      expect(restored.blocks.first.attributes['displayText'], 'pub.dev');
    });

    test('bold inline', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('bold', attributes: InlineAttributes(bold: true)),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final op = restored.blocks.first.delta!.ops.first as TextOp;
      expect(op.attributes.bold, isTrue);
    });

    test('italic inline', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('italic', attributes: InlineAttributes(italic: true)),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final op = restored.blocks.first.delta!.ops.first as TextOp;
      expect(op.attributes.italic, isTrue);
    });

    test('bold and italic inline', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp(
              'both',
              attributes: InlineAttributes(bold: true, italic: true),
            ),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final op = restored.blocks.first.delta!.ops.first as TextOp;
      expect(op.attributes.bold, isTrue);
      expect(op.attributes.italic, isTrue);
    });

    test('strikethrough inline', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp(
              'struck',
              attributes: InlineAttributes(strikethrough: true),
            ),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final op = restored.blocks.first.delta!.ops.first as TextOp;
      expect(op.attributes.strikethrough, isTrue);
    });

    test('inline code', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp(
              'code',
              attributes: InlineAttributes(inlineCode: true),
            ),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final op = restored.blocks.first.delta!.ops.first as TextOp;
      expect(op.attributes.inlineCode, isTrue);
    });

    test('inline link', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('See '),
            const TextOp(
              'click',
              attributes: InlineAttributes(link: 'https://example.com'),
            ),
            const TextOp(' here'),
          ]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.first.type, BlockTypes.paragraph);
      final ops = restored.blocks.first.delta!.ops;
      final linkOp = ops.whereType<TextOp>().firstWhere(
        (o) => o.attributes.link != null,
      );
      expect(linkOp.text, 'click');
      expect(linkOp.attributes.link, 'https://example.com');
    });

    test('VariableOp', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([const TextOp('Hello '), const VariableOp('name')]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final ops = restored.blocks.first.delta!.ops;
      expect(
        ops.any((o) => o is VariableOp && o.variableName == 'name'),
        isTrue,
      );
    });

    test('TagOp', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([const TextOp('Tagged '), const TagOp('flutter')]),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      final ops = restored.blocks.first.delta!.ops;
      expect(ops.any((o) => o is TagOp && o.tag == 'flutter'), isTrue);
    });

    test('nested bullet list one level', () async {
      final doc = BlockDocument([
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
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks.length, 1);
      expect(restored.blocks.first.children.length, 1);
      expect(restored.blocks.first.children.first.delta!.plainText, 'Child');
    });

    test('double round-trip heading is stable', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h1',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('Stable'),
        ),
      ]);
      final single = await _mdRoundTrip(doc);
      final doubleTripResult = await _mdDoubleRoundTrip(doc);
      expect(single.blocks.first.type, doubleTripResult.blocks.first.type);
      expect(
        single.blocks.first.delta!.plainText,
        doubleTripResult.blocks.first.delta!.plainText,
      );
    });

    test('double round-trip callout is stable', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'ca1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'warning'},
          delta: TextDelta.fromPlainText('Watch out'),
        ),
      ]);
      final single = await _mdRoundTrip(doc);
      final doubleTripResult = await _mdDoubleRoundTrip(doc);
      expect(
        single.blocks.first.attributes['variant'],
        doubleTripResult.blocks.first.attributes['variant'],
      );
      expect(
        single.blocks.first.delta!.plainText,
        doubleTripResult.blocks.first.delta!.plainText,
      );
    });

    test('mixed document block order is preserved', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h1',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('Title'),
        ),
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Body'),
        ),
        BlockNode(id: 'd1', type: BlockTypes.divider),
        BlockNode(
          id: 'b1',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Item'),
        ),
      ]);
      final restored = await _mdRoundTrip(doc);
      expect(restored.blocks[0].type, BlockTypes.heading1);
      expect(restored.blocks[1].type, BlockTypes.paragraph);
      expect(restored.blocks[2].type, BlockTypes.divider);
      expect(restored.blocks[3].type, BlockTypes.bulletList);
    });
  });
}
