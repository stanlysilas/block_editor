import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

Future<String> _export(List<BlockNode> blocks) =>
    const MarkdownExporter().export(BlockDocument(blocks));

void main() {
  group('MarkdownExporter', () {
    test('formatName is markdown', () {
      expect(const MarkdownExporter().formatName, 'markdown');
    });

    test('empty document produces empty string', () async {
      const doc = BlockDocument([]);
      final result = await const MarkdownExporter().export(doc);
      expect(result, isEmpty);
    });

    group('block-level mappings', () {
      test('paragraph renders plain text', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('Hello world'),
          ),
        ]);
        expect(result, 'Hello world');
      });

      test('heading1 renders with # prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'h1',
            type: BlockTypes.heading1,
            delta: TextDelta.fromPlainText('Title'),
          ),
        ]);
        expect(result, '# Title');
      });

      test('heading2 renders with ## prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'h2',
            type: BlockTypes.heading2,
            delta: TextDelta.fromPlainText('Section'),
          ),
        ]);
        expect(result, '## Section');
      });

      test('heading3 renders with ### prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'h3',
            type: BlockTypes.heading3,
            delta: TextDelta.fromPlainText('Subsection'),
          ),
        ]);
        expect(result, '### Subsection');
      });

      test('bullet list renders with - prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'b1',
            type: BlockTypes.bulletList,
            delta: TextDelta.fromPlainText('Item'),
          ),
        ]);
        expect(result, '- Item');
      });

      test('numbered list renders with 1. prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'n1',
            type: BlockTypes.numberedList,
            delta: TextDelta.fromPlainText('First'),
          ),
        ]);
        expect(result, '1. First');
      });

      test('unchecked todo renders with - [ ]', () async {
        final result = await _export([
          BlockNode(
            id: 't1',
            type: BlockTypes.todo,
            attributes: const {'checked': false},
            delta: TextDelta.fromPlainText('Task'),
          ),
        ]);
        expect(result, '- [ ] Task');
      });

      test('checked todo renders with - [x]', () async {
        final result = await _export([
          BlockNode(
            id: 't1',
            type: BlockTypes.todo,
            attributes: const {'checked': true},
            delta: TextDelta.fromPlainText('Done'),
          ),
        ]);
        expect(result, '- [x] Done');
      });

      test('quote renders with > prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'q1',
            type: BlockTypes.quote,
            delta: TextDelta.fromPlainText('A quote'),
          ),
        ]);
        expect(result, '> A quote');
      });

      test('divider renders as ---', () async {
        final result = await _export([
          BlockNode(id: 'd1', type: BlockTypes.divider),
        ]);
        expect(result, '---');
      });

      test('code renders as fenced block with language', () async {
        final result = await _export([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'code': 'x = 1', 'language': 'python'},
          ),
        ]);
        expect(result, '```python\nx = 1\n```');
      });

      test('code with no language uses empty fence identifier', () async {
        final result = await _export([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'code': 'hello'},
          ),
        ]);
        expect(result, '```\nhello\n```');
      });

      test('info callout renders with ℹ️ prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'info'},
            delta: TextDelta.fromPlainText('Note this'),
          ),
        ]);
        expect(result, '> ℹ️ Note this');
      });

      test('warning callout renders with ⚠️ prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'warning'},
            delta: TextDelta.fromPlainText('Be careful'),
          ),
        ]);
        expect(result, '> ⚠️ Be careful');
      });

      test('error callout renders with ❌ prefix', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'error'},
            delta: TextDelta.fromPlainText('Fatal error'),
          ),
        ]);
        expect(result, '> ❌ Fatal error');
      });

      test('image renders as ![alt](url)', () async {
        final result = await _export([
          BlockNode(
            id: 'img1',
            type: BlockTypes.image,
            attributes: const {
              'url': 'https://example.com/img.png',
              'alt': 'A photo',
              'source': 'network',
            },
          ),
        ]);
        expect(result, '![A photo](https://example.com/img.png)');
      });

      test('image with no alt uses default alt text', () async {
        final result = await _export([
          BlockNode(
            id: 'img1',
            type: BlockTypes.image,
            attributes: const {
              'url': 'https://example.com/img.png',
              'source': 'network',
            },
          ),
        ]);
        expect(result, '![image](https://example.com/img.png)');
      });

      test('video renders as [Video](url)', () async {
        final result = await _export([
          BlockNode(
            id: 'v1',
            type: BlockTypes.video,
            attributes: const {
              'url': 'https://example.com/v.mp4',
              'source': 'network',
            },
          ),
        ]);
        expect(result, '[Video](https://example.com/v.mp4)');
      });

      test('youtube renders as [YouTube](youtu.be url)', () async {
        final result = await _export([
          BlockNode(
            id: 'yt1',
            type: BlockTypes.youtube,
            attributes: const {'videoId': 'dQw4w9WgXcQ'},
          ),
        ]);
        expect(result, '[YouTube](https://youtu.be/dQw4w9WgXcQ)');
      });

      test('file renders as [filename](path)', () async {
        final result = await _export([
          BlockNode(
            id: 'f1',
            type: BlockTypes.file,
            attributes: const {
              'filename': 'report.pdf',
              'path': '/tmp/report.pdf',
            },
          ),
        ]);
        expect(result, '[report.pdf](/tmp/report.pdf)');
      });

      test('link renders as [displayText](url)', () async {
        final result = await _export([
          BlockNode(
            id: 'l1',
            type: BlockTypes.link,
            attributes: const {
              'url': 'https://pub.dev',
              'displayText': 'pub.dev',
            },
          ),
        ]);
        expect(result, '[pub.dev](https://pub.dev)');
      });
    });

    group('inline formatting', () {
      test('bold renders as **text**', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp('bold', attributes: InlineAttributes(bold: true)),
            ]),
          ),
        ]);
        expect(result, '**bold**');
      });

      test('italic renders as _text_', () async {
        final result = await _export([
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
        expect(result, '_italic_');
      });

      test('bold and italic renders as **_text_**', () async {
        final result = await _export([
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
        expect(result, '**_both_**');
      });

      test('strikethrough renders as ~~text~~', () async {
        final result = await _export([
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
        expect(result, '~~struck~~');
      });

      test('inline code renders as `text`', () async {
        final result = await _export([
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
        expect(result, '`code`');
      });

      test('inline link renders as [text](url)', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'click here',
                attributes: InlineAttributes(link: 'https://example.com'),
              ),
            ]),
          ),
        ]);
        expect(result, '[click here](https://example.com)');
      });

      test('VariableOp renders as {{variableName}}', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp('Hello '),
              const VariableOp('userName'),
            ]),
          ),
        ]);
        expect(result, 'Hello {{userName}}');
      });

      test('TagOp renders as #tag', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([const TextOp('Tagged '), const TagOp('flutter')]),
          ),
        ]);
        expect(result, 'Tagged #flutter');
      });
    });

    group('nesting and depth', () {
      test('nested bullet list is indented two spaces per depth', () async {
        final result = await _export([
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
        expect(result, '- Parent\n  - Child');
      });

      test('doubly nested list indents four spaces', () async {
        final result = await _export([
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
        expect(result, '- A\n  - B\n    - C');
      });

      test('numbered list nesting indents two spaces per depth', () async {
        final result = await _export([
          BlockNode(
            id: 'n1',
            type: BlockTypes.numberedList,
            delta: TextDelta.fromPlainText('First'),
            children: [
              BlockNode(
                id: 'n2',
                type: BlockTypes.numberedList,
                delta: TextDelta.fromPlainText('Nested'),
              ),
            ],
          ),
        ]);
        expect(result, '1. First\n  1. Nested');
      });
    });

    group('blank lines', () {
      test('heading is followed by blank line when not last', () async {
        final result = await _export([
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
        ]);
        expect(result, '# Title\n\nBody');
      });

      test('code block is followed by blank line when not last', () async {
        final result = await _export([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'code': 'x = 1', 'language': 'python'},
          ),
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('After'),
          ),
        ]);
        expect(result, '```python\nx = 1\n```\n\nAfter');
      });

      test('divider is followed by blank line when not last', () async {
        final result = await _export([
          BlockNode(id: 'd1', type: BlockTypes.divider),
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('After'),
          ),
        ]);
        expect(result, '---\n\nAfter');
      });
    });

    group('output format', () {
      test('no trailing newline', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('Only'),
          ),
        ]);
        expect(result.endsWith('\n'), isFalse);
      });

      test('custom block falls back to plain delta text', () async {
        final result = await _export([
          BlockNode(
            id: 'x1',
            type: 'my_custom_type',
            delta: TextDelta.fromPlainText('Custom content'),
          ),
        ]);
        expect(result, 'Custom content');
      });
    });
  });
}
