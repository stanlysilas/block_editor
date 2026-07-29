import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

void main() {
  group('PlainTextExporter', () {
    test('formatName is plain_text', () {
      expect(const PlainTextExporter().formatName, 'plain_text');
    });

    test('empty document produces empty string', () async {
      const doc = BlockDocument([]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, isEmpty);
    });

    test('paragraph renders plain text', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Hello world'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Hello world');
    });

    test('heading1 renders plain text without prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h1',
          type: BlockTypes.heading1,
          delta: TextDelta.fromPlainText('Title'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Title');
    });

    test('heading2 renders plain text without prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h2',
          type: BlockTypes.heading2,
          delta: TextDelta.fromPlainText('Section'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Section');
    });

    test('heading3 renders plain text without prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'h3',
          type: BlockTypes.heading3,
          delta: TextDelta.fromPlainText('Subsection'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Subsection');
    });

    test('bullet list renders with bullet prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'b1',
          type: BlockTypes.bulletList,
          delta: TextDelta.fromPlainText('Item'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '• Item');
    });

    test('numbered list renders plain text', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'n1',
          type: BlockTypes.numberedList,
          delta: TextDelta.fromPlainText('First'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'First');
    });

    test('unchecked todo renders with [ ] prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': false},
          delta: TextDelta.fromPlainText('Task'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[ ] Task');
    });

    test('checked todo renders with [x] prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 't1',
          type: BlockTypes.todo,
          attributes: const {'checked': true},
          delta: TextDelta.fromPlainText('Done task'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[x] Done task');
    });

    test('quote renders plain text without prefix', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'q1',
          type: BlockTypes.quote,
          delta: TextDelta.fromPlainText('A wise saying'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'A wise saying');
    });

    test('callout renders plain text', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'c1',
          type: BlockTypes.callout,
          attributes: const {'variant': 'info'},
          delta: TextDelta.fromPlainText('Watch out'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Watch out');
    });

    test('code renders code attribute content', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'code1',
          type: BlockTypes.code,
          attributes: const {'code': 'print("hi")', 'language': 'python'},
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'print("hi")');
    });

    test('divider renders as ---', () async {
      final doc = BlockDocument([
        BlockNode(id: 'd1', type: BlockTypes.divider),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '---');
    });

    test('image renders as [Image]', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'img1',
          type: BlockTypes.image,
          attributes: const {
            'url': 'https://example.com/img.png',
            'source': 'network',
          },
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[Image]');
    });

    test('video renders as [Video]', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'v1',
          type: BlockTypes.video,
          attributes: const {
            'url': 'https://example.com/v.mp4',
            'source': 'network',
          },
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[Video]');
    });

    test('youtube renders as [YouTube]', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'yt1',
          type: BlockTypes.youtube,
          attributes: const {'videoId': 'dQw4w9WgXcQ'},
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[YouTube]');
    });

    test('file renders as [File: filename]', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'f1',
          type: BlockTypes.file,
          attributes: const {
            'filename': 'report.pdf',
            'path': '/tmp/report.pdf',
          },
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[File: report.pdf]');
    });

    test('file with no filename renders as [File: ]', () async {
      final doc = BlockDocument([BlockNode(id: 'f1', type: BlockTypes.file)]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, '[File: ]');
    });

    test('link renders as url', () async {
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
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'https://pub.dev');
    });

    test('inline bold formatting is stripped', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('plain '),
            const TextOp('bold', attributes: InlineAttributes(bold: true)),
            const TextOp(' plain'),
          ]),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'plain bold plain');
    });

    test('VariableOp renders as {{variableName}}', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('Hello '),
            const VariableOp('userName'),
          ]),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Hello {{userName}}');
    });

    test('TagOp renders as #tag', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta([
            const TextOp('Tagged with '),
            const TagOp('flutter'),
          ]),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Tagged with #flutter');
    });

    test('multiple blocks are separated by newlines', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('First'),
        ),
        BlockNode(
          id: 'p2',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Second'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'First\nSecond');
    });

    test('output has no trailing newline', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'p1',
          type: BlockTypes.paragraph,
          delta: TextDelta.fromPlainText('Only'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result.endsWith('\n'), isFalse);
    });

    test('block with null delta renders empty string', () async {
      final doc = BlockDocument([
        BlockNode(id: 'd1', type: BlockTypes.paragraph),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, isEmpty);
    });

    test('nested children are included in document order', () async {
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
      final result = await const PlainTextExporter().export(doc);
      expect(result, '• Parent\n• Child');
    });

    test('custom block falls back to delta plain text', () async {
      final doc = BlockDocument([
        BlockNode(
          id: 'unknown1',
          type: 'my_custom_type',
          delta: TextDelta.fromPlainText('Custom content'),
        ),
      ]);
      final result = await const PlainTextExporter().export(doc);
      expect(result, 'Custom content');
    });
  });
}
