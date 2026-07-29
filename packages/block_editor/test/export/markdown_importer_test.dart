import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

Future<BlockDocument> _import(String md) => const MarkdownImporter().import(md);

Future<String> _export(BlockDocument doc) =>
    const MarkdownExporter().export(doc);

void main() {
  group('MarkdownImporter', () {
    test('formatName is markdown', () {
      expect(const MarkdownImporter().formatName, 'markdown');
    });

    test('empty string returns BlockDocument.empty', () async {
      final result = await _import('');
      expect(result.isNotEmpty, isTrue);
    });

    test('whitespace-only string returns BlockDocument.empty', () async {
      final result = await _import('   \n  \n');
      expect(result.isNotEmpty, isTrue);
    });

    group('block-level parsing', () {
      test('plain line becomes paragraph', () async {
        final doc = await _import('Hello world');
        expect(doc.blocks.first.type, BlockTypes.paragraph);
        expect(doc.blocks.first.delta!.plainText, 'Hello world');
      });

      test('# becomes heading1', () async {
        final doc = await _import('# Title');
        expect(doc.blocks.first.type, BlockTypes.heading1);
        expect(doc.blocks.first.delta!.plainText, 'Title');
      });

      test('## becomes heading2', () async {
        final doc = await _import('## Section');
        expect(doc.blocks.first.type, BlockTypes.heading2);
        expect(doc.blocks.first.delta!.plainText, 'Section');
      });

      test('### becomes heading3', () async {
        final doc = await _import('### Subsection');
        expect(doc.blocks.first.type, BlockTypes.heading3);
        expect(doc.blocks.first.delta!.plainText, 'Subsection');
      });

      test('- becomes bullet list', () async {
        final doc = await _import('- Item');
        expect(doc.blocks.first.type, BlockTypes.bulletList);
        expect(doc.blocks.first.delta!.plainText, 'Item');
      });

      test('1. becomes numbered list', () async {
        final doc = await _import('1. First');
        expect(doc.blocks.first.type, BlockTypes.numberedList);
        expect(doc.blocks.first.delta!.plainText, 'First');
      });

      test('- [ ] becomes unchecked todo', () async {
        final doc = await _import('- [ ] Task');
        expect(doc.blocks.first.type, BlockTypes.todo);
        expect(doc.blocks.first.attributes['checked'], isFalse);
        expect(doc.blocks.first.delta!.plainText, 'Task');
      });

      test('- [x] becomes checked todo', () async {
        final doc = await _import('- [x] Done');
        expect(doc.blocks.first.type, BlockTypes.todo);
        expect(doc.blocks.first.attributes['checked'], isTrue);
        expect(doc.blocks.first.delta!.plainText, 'Done');
      });

      test('> becomes quote', () async {
        final doc = await _import('> A quote');
        expect(doc.blocks.first.type, BlockTypes.quote);
        expect(doc.blocks.first.delta!.plainText, 'A quote');
      });

      test('--- becomes divider', () async {
        final doc = await _import('---');
        expect(doc.blocks.first.type, BlockTypes.divider);
      });

      test('fenced code block becomes code', () async {
        final doc = await _import('```python\nx = 1\n```');
        expect(doc.blocks.first.type, BlockTypes.code);
        expect(doc.blocks.first.attributes['language'], 'python');
        expect(doc.blocks.first.attributes['code'], 'x = 1');
      });

      test('fenced code block with no language uses empty string', () async {
        final doc = await _import('```\nhello\n```');
        expect(doc.blocks.first.type, BlockTypes.code);
        expect(doc.blocks.first.attributes['language'], '');
        expect(doc.blocks.first.attributes['code'], 'hello');
      });

      test('multiline code block captures all lines', () async {
        final doc = await _import('```dart\nline1\nline2\nline3\n```');
        expect(doc.blocks.first.attributes['code'], 'line1\nline2\nline3');
      });

      test('image line becomes image block', () async {
        final doc = await _import('![A photo](https://example.com/img.png)');
        expect(doc.blocks.first.type, BlockTypes.image);
        expect(
          doc.blocks.first.attributes['url'],
          'https://example.com/img.png',
        );
        expect(doc.blocks.first.attributes['alt'], 'A photo');
      });

      test('standalone link becomes link block', () async {
        final doc = await _import('[pub.dev](https://pub.dev)');
        expect(doc.blocks.first.type, BlockTypes.link);
        expect(doc.blocks.first.attributes['url'], 'https://pub.dev');
        expect(doc.blocks.first.attributes['displayText'], 'pub.dev');
      });
    });

    group('callout detection', () {
      test('> ℹ️ becomes info callout', () async {
        final doc = await _import('> ℹ️ Note this');
        expect(doc.blocks.first.type, BlockTypes.callout);
        expect(doc.blocks.first.attributes['variant'], 'info');
        expect(doc.blocks.first.delta!.plainText, 'Note this');
      });

      test('> ⚠️ becomes warning callout', () async {
        final doc = await _import('> ⚠️ Be careful');
        expect(doc.blocks.first.type, BlockTypes.callout);
        expect(doc.blocks.first.attributes['variant'], 'warning');
      });

      test('> ❌ becomes error callout', () async {
        final doc = await _import('> ❌ Fatal error');
        expect(doc.blocks.first.type, BlockTypes.callout);
        expect(doc.blocks.first.attributes['variant'], 'error');
      });

      test('> without emoji becomes quote', () async {
        final doc = await _import('> Just a quote');
        expect(doc.blocks.first.type, BlockTypes.quote);
      });
    });

    group('inline formatting', () {
      test('**text** parses as bold', () async {
        final doc = await _import('**bold**');
        final op = doc.blocks.first.delta!.ops.first as TextOp;
        expect(op.text, 'bold');
        expect(op.attributes.bold, isTrue);
      });

      test('_text_ parses as italic', () async {
        final doc = await _import('_italic_');
        final op = doc.blocks.first.delta!.ops.first as TextOp;
        expect(op.text, 'italic');
        expect(op.attributes.italic, isTrue);
      });

      test('**_text_** parses as bold and italic', () async {
        final doc = await _import('**_both_**');
        final op = doc.blocks.first.delta!.ops.first as TextOp;
        expect(op.text, 'both');
        expect(op.attributes.bold, isTrue);
        expect(op.attributes.italic, isTrue);
      });

      test('~~text~~ parses as strikethrough', () async {
        final doc = await _import('~~struck~~');
        final op = doc.blocks.first.delta!.ops.first as TextOp;
        expect(op.text, 'struck');
        expect(op.attributes.strikethrough, isTrue);
      });

      test('`text` parses as inline code', () async {
        final doc = await _import('`code`');
        final op = doc.blocks.first.delta!.ops.first as TextOp;
        expect(op.text, 'code');
        expect(op.attributes.inlineCode, isTrue);
      });

      test('[text](url) parses as link', () async {
        final doc = await _import('Click [here](https://example.com) now');
        final ops = doc.blocks.first.delta!.ops;
        final linkOp = ops.whereType<TextOp>().firstWhere(
          (o) => o.attributes.link != null,
        );
        expect(linkOp.text, 'here');
        expect(linkOp.attributes.link, 'https://example.com');
      });

      test('{{variableName}} parses as VariableOp', () async {
        final doc = await _import('Hello {{userName}}');
        final ops = doc.blocks.first.delta!.ops;
        expect(
          ops.any((o) => o is VariableOp && o.variableName == 'userName'),
          isTrue,
        );
      });

      test('#tag parses as TagOp', () async {
        final doc = await _import('Tagged #flutter');
        final ops = doc.blocks.first.delta!.ops;
        expect(ops.any((o) => o is TagOp && o.tag == 'flutter'), isTrue);
      });

      test('mixed inline ops preserve surrounding plain text', () async {
        final doc = await _import('plain **bold** plain');
        final ops = doc.blocks.first.delta!.ops;
        expect(ops.length, 3);
        expect((ops[0] as TextOp).text, 'plain ');
        expect((ops[1] as TextOp).attributes.bold, isTrue);
        expect((ops[2] as TextOp).text, ' plain');
      });
    });

    group('nesting', () {
      test('indented bullet becomes child of preceding bullet', () async {
        final doc = await _import('- Parent\n  - Child');
        expect(doc.blocks.length, 1);
        expect(doc.blocks.first.type, BlockTypes.bulletList);
        expect(doc.blocks.first.children.length, 1);
        expect(doc.blocks.first.children.first.delta!.plainText, 'Child');
      });

      test('doubly indented item nests two levels deep', () async {
        final doc = await _import('- A\n  - B\n    - C');
        expect(doc.blocks.length, 1);
        expect(doc.blocks.first.children.length, 1);
        expect(doc.blocks.first.children.first.children.length, 1);
        expect(
          doc.blocks.first.children.first.children.first.delta!.plainText,
          'C',
        );
      });
    });

    group('blank lines', () {
      test('blank lines between blocks are ignored', () async {
        final doc = await _import('First\n\nSecond');
        expect(doc.blocks.length, 2);
        expect(doc.blocks[0].delta!.plainText, 'First');
        expect(doc.blocks[1].delta!.plainText, 'Second');
      });
    });

    group('Markdown round-trip', () {
      test('heading1 survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'h1',
            type: BlockTypes.heading1,
            delta: TextDelta.fromPlainText('Title'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.heading1);
        expect(restored.blocks.first.delta!.plainText, 'Title');
      });

      test('checked todo survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 't1',
            type: BlockTypes.todo,
            attributes: const {'checked': true},
            delta: TextDelta.fromPlainText('Done'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.todo);
        expect(restored.blocks.first.attributes['checked'], isTrue);
      });

      test('code block survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'language': 'dart', 'code': 'void main() {}'},
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.code);
        expect(restored.blocks.first.attributes['language'], 'dart');
        expect(restored.blocks.first.attributes['code'], 'void main() {}');
      });

      test('info callout survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'info'},
            delta: TextDelta.fromPlainText('Note'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.callout);
        expect(restored.blocks.first.attributes['variant'], 'info');
        expect(restored.blocks.first.delta!.plainText, 'Note');
      });

      test('warning callout survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'warning'},
            delta: TextDelta.fromPlainText('Careful'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.attributes['variant'], 'warning');
      });

      test('error callout survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'error'},
            delta: TextDelta.fromPlainText('Fatal'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.attributes['variant'], 'error');
      });

      test('bold inline survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp('bold', attributes: InlineAttributes(bold: true)),
            ]),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        final op = restored.blocks.first.delta!.ops.first as TextOp;
        expect(op.attributes.bold, isTrue);
      });

      test('italic inline survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'italic',
                attributes: InlineAttributes(italic: true),
              ),
            ]),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        final op = restored.blocks.first.delta!.ops.first as TextOp;
        expect(op.attributes.italic, isTrue);
      });

      test('strikethrough inline survives export→import', () async {
        final original = BlockDocument([
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
        final md = await _export(original);
        final restored = await _import(md);
        final op = restored.blocks.first.delta!.ops.first as TextOp;
        expect(op.attributes.strikethrough, isTrue);
      });

      test('inline code survives export→import', () async {
        final original = BlockDocument([
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
        final md = await _export(original);
        final restored = await _import(md);
        final op = restored.blocks.first.delta!.ops.first as TextOp;
        expect(op.attributes.inlineCode, isTrue);
      });

      test('nested bullet list survives export→import', () async {
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
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.length, 1);
        expect(restored.blocks.first.children.length, 1);
        expect(restored.blocks.first.children.first.delta!.plainText, 'Child');
      });

      test('divider survives export→import', () async {
        final original = BlockDocument([
          BlockNode(id: 'd1', type: BlockTypes.divider),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.divider);
      });

      test('image survives export→import', () async {
        final original = BlockDocument([
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
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.image);
        expect(
          restored.blocks.first.attributes['url'],
          'https://example.com/img.png',
        );
      });

      test('quote survives export→import', () async {
        final original = BlockDocument([
          BlockNode(
            id: 'q1',
            type: BlockTypes.quote,
            delta: TextDelta.fromPlainText('Wise words'),
          ),
        ]);
        final md = await _export(original);
        final restored = await _import(md);
        expect(restored.blocks.first.type, BlockTypes.quote);
        expect(restored.blocks.first.delta!.plainText, 'Wise words');
      });
    });
  });
}
