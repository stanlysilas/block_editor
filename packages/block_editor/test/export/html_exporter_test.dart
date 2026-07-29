import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

Future<String> _export(List<BlockNode> blocks) =>
    const HtmlExporter().export(BlockDocument(blocks));

void main() {
  group('HtmlExporter', () {
    test('formatName is html', () {
      expect(const HtmlExporter().formatName, 'html');
    });

    test('empty document produces empty string', () async {
      const doc = BlockDocument([]);
      final result = await const HtmlExporter().export(doc);
      expect(result, isEmpty);
    });

    group('block-level mappings', () {
      test('paragraph renders as <p>', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('Hello'),
          ),
        ]);
        expect(result, '<p>Hello</p>');
      });

      test('heading1 renders as <h1>', () async {
        final result = await _export([
          BlockNode(
            id: 'h1',
            type: BlockTypes.heading1,
            delta: TextDelta.fromPlainText('Title'),
          ),
        ]);
        expect(result, '<h1>Title</h1>');
      });

      test('heading2 renders as <h2>', () async {
        final result = await _export([
          BlockNode(
            id: 'h2',
            type: BlockTypes.heading2,
            delta: TextDelta.fromPlainText('Section'),
          ),
        ]);
        expect(result, '<h2>Section</h2>');
      });

      test('heading3 renders as <h3>', () async {
        final result = await _export([
          BlockNode(
            id: 'h3',
            type: BlockTypes.heading3,
            delta: TextDelta.fromPlainText('Subsection'),
          ),
        ]);
        expect(result, '<h3>Subsection</h3>');
      });

      test('quote renders as <blockquote>', () async {
        final result = await _export([
          BlockNode(
            id: 'q1',
            type: BlockTypes.quote,
            delta: TextDelta.fromPlainText('A quote'),
          ),
        ]);
        expect(result, '<blockquote>A quote</blockquote>');
      });

      test('divider renders as <hr>', () async {
        final result = await _export([
          BlockNode(id: 'd1', type: BlockTypes.divider),
        ]);
        expect(result, '<hr>');
      });

      test('code renders as <pre><code> with language class', () async {
        final result = await _export([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'code': 'x = 1', 'language': 'python'},
          ),
        ]);
        expect(result, '<pre><code class="language-python">x = 1</code></pre>');
      });

      test('code with no language omits class attribute', () async {
        final result = await _export([
          BlockNode(
            id: 'c1',
            type: BlockTypes.code,
            attributes: const {'code': 'hello'},
          ),
        ]);
        expect(result, '<pre><code>hello</code></pre>');
      });

      test('info callout renders with correct classes', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'info'},
            delta: TextDelta.fromPlainText('Note'),
          ),
        ]);
        expect(result, '<div class="callout callout-info">Note</div>');
      });

      test('warning callout renders with correct classes', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'warning'},
            delta: TextDelta.fromPlainText('Careful'),
          ),
        ]);
        expect(result, '<div class="callout callout-warning">Careful</div>');
      });

      test('error callout renders with correct classes', () async {
        final result = await _export([
          BlockNode(
            id: 'ca1',
            type: BlockTypes.callout,
            attributes: const {'variant': 'error'},
            delta: TextDelta.fromPlainText('Fatal'),
          ),
        ]);
        expect(result, '<div class="callout callout-error">Fatal</div>');
      });

      test('image renders as <img>', () async {
        final result = await _export([
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
        expect(result, '<img src="https://example.com/img.png" alt="photo">');
      });

      test('video renders as <p><a href>', () async {
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
        expect(result, '<p><a href="https://example.com/v.mp4">Video</a></p>');
      });

      test('youtube renders as <p><a href youtu.be>', () async {
        final result = await _export([
          BlockNode(
            id: 'yt1',
            type: BlockTypes.youtube,
            attributes: const {'videoId': 'dQw4w9WgXcQ'},
          ),
        ]);
        expect(
          result,
          '<p><a href="https://youtu.be/dQw4w9WgXcQ">YouTube</a></p>',
        );
      });

      test('file renders as <p><a href> with filename', () async {
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
        expect(result, '<p><a href="/tmp/report.pdf">report.pdf</a></p>');
      });

      test('link renders as <p><a href> with displayText', () async {
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
        expect(result, '<p><a href="https://pub.dev">pub.dev</a></p>');
      });
    });

    group('list rendering', () {
      test('bullet list items wrapped in <ul>', () async {
        final result = await _export([
          BlockNode(
            id: 'b1',
            type: BlockTypes.bulletList,
            delta: TextDelta.fromPlainText('Item'),
          ),
        ]);
        expect(result, contains('<ul>'));
        expect(result, contains('<li>Item</li>'));
        expect(result, contains('</ul>'));
      });

      test('numbered list items wrapped in <ol>', () async {
        final result = await _export([
          BlockNode(
            id: 'n1',
            type: BlockTypes.numberedList,
            delta: TextDelta.fromPlainText('First'),
          ),
        ]);
        expect(result, contains('<ol>'));
        expect(result, contains('<li>First</li>'));
        expect(result, contains('</ol>'));
      });

      test(
        'unchecked todo wrapped in <ul class="todo"> with data-checked false',
        () async {
          final result = await _export([
            BlockNode(
              id: 't1',
              type: BlockTypes.todo,
              attributes: const {'checked': false},
              delta: TextDelta.fromPlainText('Task'),
            ),
          ]);
          expect(result, contains('<ul class="todo">'));
          expect(result, contains('data-checked="false"'));
        },
      );

      test('checked todo has data-checked true', () async {
        final result = await _export([
          BlockNode(
            id: 't1',
            type: BlockTypes.todo,
            attributes: const {'checked': true},
            delta: TextDelta.fromPlainText('Done'),
          ),
        ]);
        expect(result, contains('data-checked="true"'));
      });

      test('multiple bullet items share one <ul>', () async {
        final result = await _export([
          BlockNode(
            id: 'b1',
            type: BlockTypes.bulletList,
            delta: TextDelta.fromPlainText('One'),
          ),
          BlockNode(
            id: 'b2',
            type: BlockTypes.bulletList,
            delta: TextDelta.fromPlainText('Two'),
          ),
        ]);
        expect('<ul>'.allMatches(result).length, 1);
        expect('</ul>'.allMatches(result).length, 1);
        expect(result, contains('<li>One</li>'));
        expect(result, contains('<li>Two</li>'));
      });

      test('nested bullet list produces nested <ul>', () async {
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
        expect('<ul>'.allMatches(result).length, 2);
        expect('</ul>'.allMatches(result).length, 2);
        expect(result, contains('<li>Parent</li>'));
        expect(result, contains('<li>Child</li>'));
      });

      test('list closed before non-list block', () async {
        final result = await _export([
          BlockNode(
            id: 'b1',
            type: BlockTypes.bulletList,
            delta: TextDelta.fromPlainText('Item'),
          ),
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('After'),
          ),
        ]);
        final ulClose = result.indexOf('</ul>');
        final pOpen = result.indexOf('<p>After</p>');
        expect(ulClose, lessThan(pOpen));
      });
    });

    group('inline formatting', () {
      test('bold renders as <strong>', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp('bold', attributes: InlineAttributes(bold: true)),
            ]),
          ),
        ]);
        expect(result, '<p><strong>bold</strong></p>');
      });

      test('italic renders as <em>', () async {
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
        expect(result, '<p><em>italic</em></p>');
      });

      test('underline renders as <u>', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'underlined',
                attributes: InlineAttributes(underline: true),
              ),
            ]),
          ),
        ]);
        expect(result, '<p><u>underlined</u></p>');
      });

      test('strikethrough renders as <s>', () async {
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
        expect(result, '<p><s>struck</s></p>');
      });

      test('inline code renders as <code>', () async {
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
        expect(result, '<p><code>code</code></p>');
      });

      test('link renders as <a href>', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'click',
                attributes: InlineAttributes(link: 'https://example.com'),
              ),
            ]),
          ),
        ]);
        expect(result, '<p><a href="https://example.com">click</a></p>');
      });

      test('text color renders as style attribute', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'colored',
                attributes: InlineAttributes(color: '#ff0000'),
              ),
            ]),
          ),
        ]);
        expect(result, contains('style="color: #ff0000"'));
      });

      test('background color renders as style attribute', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp(
                'highlighted',
                attributes: InlineAttributes(backgroundColor: '#ffff00'),
              ),
            ]),
          ),
        ]);
        expect(result, contains('style="background-color: #ffff00"'));
      });

      test('VariableOp renders as {{variableName}}', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([
              const TextOp('Hello '),
              const VariableOp('name'),
            ]),
          ),
        ]);
        expect(result, contains('{{name}}'));
      });

      test('TagOp renders as #tag', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta([const TextOp('Tagged '), const TagOp('flutter')]),
          ),
        ]);
        expect(result, contains('#flutter'));
      });

      test('HTML special characters are escaped', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('<script>alert("xss")</script>'),
          ),
        ]);
        expect(result, contains('&lt;script&gt;'));
        expect(result, isNot(contains('<script>')));
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

      test('no wrapper html/head/body tags', () async {
        final result = await _export([
          BlockNode(
            id: 'p1',
            type: BlockTypes.paragraph,
            delta: TextDelta.fromPlainText('Content'),
          ),
        ]);
        expect(result, isNot(contains('<html')));
        expect(result, isNot(contains('<body')));
        expect(result, isNot(contains('<head')));
      });

      test('custom block falls back to <p> with plain text', () async {
        final result = await _export([
          BlockNode(
            id: 'x1',
            type: 'my_custom_type',
            delta: TextDelta.fromPlainText('Custom'),
          ),
        ]);
        expect(result, '<p>Custom</p>');
      });
    });
  });
}
