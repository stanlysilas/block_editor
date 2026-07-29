import 'package:block_editor/block_editor.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A read-only showcase document demonstrating every built-in block type.
///
/// The demo document is constructed once and never mutated. Every block type
/// is shown with realistic content so developers evaluating the package can
/// see exactly what each block looks like in a real document context.
/// [readOnly] is always true — this section has no editing capability.
class DemoBlocksSection extends StatefulWidget {
  /// Creates a [DemoBlocksSection].
  const DemoBlocksSection({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<DemoBlocksSection> createState() => _DemoBlocksSectionState();
}

class _DemoBlocksSectionState extends State<DemoBlocksSection> {
  late final BlockController _controller;

  static const Map<String, String> _variables = {
    'authorName': 'Stanly Silas',
    'packageName': 'block_editor',
    'version': '0.0.4-dev.1',
  };

  @override
  void initState() {
    super.initState();
    _controller = BlockController(document: _demoDocument());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BlockDocument _demoDocument() {
    return BlockDocument([
      BlockNode(
        type: BlockTypes.heading1,
        delta: TextDelta([const TextOp('Block type showcase')]),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp(
            'Every built-in block type rendered with realistic content. '
            'This document is read-only. Built by ',
          ),
          const VariableOp('authorName'),
          const TextOp(' using '),
          const VariableOp('packageName'),
          const TextOp(' v'),
          const VariableOp('version'),
          const TextOp('.'),
        ]),
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Text blocks'),
      ),
      BlockNode(
        type: BlockTypes.heading1,
        delta: TextDelta.fromPlainText('Heading 1 — the document title'),
      ),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Heading 2 — section titles'),
      ),
      BlockNode(
        type: BlockTypes.heading3,
        delta: TextDelta.fromPlainText('Heading 3 — subsection titles'),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp(
            'Paragraph blocks support full inline formatting. '
            'Text can be ',
          ),
          TextOp('bold', attributes: const InlineAttributes(bold: true)),
          const TextOp(', '),
          TextOp('italic', attributes: const InlineAttributes(italic: true)),
          const TextOp(', '),
          TextOp(
            'underlined',
            attributes: const InlineAttributes(underline: true),
          ),
          const TextOp(', '),
          TextOp(
            'strikethrough',
            attributes: const InlineAttributes(strikethrough: true),
          ),
          const TextOp(', or '),
          TextOp(
            'inline code',
            attributes: const InlineAttributes(inlineCode: true),
          ),
          const TextOp('. Multiple styles combine freely: '),
          TextOp(
            'bold and italic',
            attributes: const InlineAttributes(bold: true, italic: true),
          ),
          const TextOp(' work together without conflict.'),
        ]),
      ),
      BlockNode(
        type: BlockTypes.quote,
        delta: TextDelta.fromPlainText(
          'The best tools disappear into the work. A great editor should feel '
          'like an extension of thought, not a piece of software you operate.',
        ),
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('List blocks'),
      ),
      BlockNode(
        type: BlockTypes.bulletList,
        delta: TextDelta.fromPlainText(
          'Fully custom hit-testing — no SelectionArea',
        ),
      ),
      BlockNode(
        type: BlockTypes.bulletList,
        delta: TextDelta.fromPlainText(
          'Per-block streams replace full document rebuilds',
        ),
      ),
      BlockNode(
        type: BlockTypes.bulletList,
        delta: TextDelta.fromPlainText(
          'Drag and drop reordering with ghost preview',
        ),
      ),
      BlockNode(
        type: BlockTypes.bulletList,
        delta: TextDelta.fromPlainText(
          'Plugin system — register any block in one line',
        ),
      ),
      BlockNode(
        type: BlockTypes.numberedList,
        delta: TextDelta.fromPlainText('Define a BlockPlugin implementation'),
      ),
      BlockNode(
        type: BlockTypes.numberedList,
        delta: TextDelta.fromPlainText(
          'Call BlockRegistry.instance.register(plugin)',
        ),
      ),
      BlockNode(
        type: BlockTypes.numberedList,
        delta: TextDelta.fromPlainText(
          'The block type is immediately available in the editor',
        ),
      ),
      BlockNode(
        type: BlockTypes.todo,
        attributes: const {'checked': true},
        delta: TextDelta.fromPlainText(
          'Phase 1 — Document model and core engine',
        ),
      ),
      BlockNode(
        type: BlockTypes.todo,
        attributes: const {'checked': true},
        delta: TextDelta.fromPlainText(
          'Phase 2 — Rendering engine and selection',
        ),
      ),
      BlockNode(
        type: BlockTypes.todo,
        attributes: const {'checked': true},
        delta: TextDelta.fromPlainText('Phase 3 — Block plugin system'),
      ),
      BlockNode(
        type: BlockTypes.todo,
        attributes: const {'checked': false},
        delta: TextDelta.fromPlainText('Phase 4 — Toolbar and slash commands'),
      ),
      BlockNode(
        type: BlockTypes.todo,
        attributes: const {'checked': false},
        delta: TextDelta.fromPlainText('Phase 5 — Export and import'),
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Callout blocks'),
      ),
      BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'info'},
        delta: TextDelta.fromPlainText(
          'Info callout — use this for tips, context, and supplementary '
          'information that supports the main content without interrupting it.',
        ),
      ),
      BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'warning'},
        delta: TextDelta.fromPlainText(
          'Warning callout — use this when something requires attention before '
          'the reader proceeds. Common in API docs and setup guides.',
        ),
      ),
      BlockNode(
        type: BlockTypes.callout,
        attributes: const {'variant': 'error'},
        delta: TextDelta.fromPlainText(
          'Error callout — use this for breaking changes, deprecated APIs, '
          'or anything that will cause a failure if ignored.',
        ),
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Code block'),
      ),
      BlockNode(
        type: BlockTypes.code,
        attributes: const {
          'language': 'dart',
          'code': '''final controller = BlockController(
  document: BlockDocument([
    BlockNode(
      type: BlockTypes.paragraph,
      delta: TextDelta.fromPlainText('Hello, block_editor'),
    ),
  ]),
);

BlockRegistry.instance.register(MyCustomBlock());

runApp(MaterialApp(
  home: Scaffold(
    body: BlockEditorWidget(controller: controller),
  ),
));''',
        },
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Media blocks'),
      ),
      BlockNode(
        type: BlockTypes.image,
        attributes: const {
          'source': 'network',
          'url': 'https://picsum.photos/seed/blockeditor/800/400',
          'alt': 'A sample image loaded from the network',
        },
      ),
      BlockNode(
        type: BlockTypes.video,
        attributes: const {
          'source': 'network',
          'url': 'https://example.com/sample-video.mp4',
        },
      ),
      BlockNode(
        type: BlockTypes.youtube,
        attributes: const {'videoId': 'dQw4w9WgXcQ'},
      ),
      BlockNode(
        type: BlockTypes.file,
        attributes: const {
          'filename': 'block_editor_architecture.pdf',
          'size': '1.2 MB',
          'path': 'https://example.com/block_editor_architecture.pdf',
        },
      ),
      BlockNode(
        type: BlockTypes.link,
        attributes: const {
          'url': 'https://pub.dev/packages/block_editor',
          'displayText': 'block_editor on pub.dev',
        },
      ),
      BlockNode(type: BlockTypes.divider),
      BlockNode(
        type: BlockTypes.heading2,
        delta: TextDelta.fromPlainText('Inline embeds'),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp(
            'Variable embeds resolve at render time without '
            'touching the document. This sentence was written by ',
          ),
          const VariableOp('authorName'),
          const TextOp(' and the package is called '),
          const VariableOp('packageName'),
          const TextOp('.'),
        ]),
      ),
      BlockNode(
        type: BlockTypes.paragraph,
        delta: TextDelta([
          const TextOp(
            'Tag embeds are queryable via the controller. '
            'This document is tagged with ',
          ),
          const TagOp('showcase'),
          const TextOp(', '),
          const TagOp('flutter'),
          const TextOp(', and '),
          const TagOp('blockeditor'),
          const TextOp(
            '. The tags appear in the strip below the editor in the '
            'Editor section.',
          ),
        ]),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DemoHeader(colors: colors),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final hPad = (constraints.maxWidth * 0.08).clamp(16.0, 64.0);
              return BlockEditorWidget(
                controller: _controller,
                readOnly: true,
                variables: _variables,
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 32),
                onCustomEvent: (event) {
                  if (event.eventType == 'video_play_requested') {
                    final url = event.eventType;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Play video: $url')));
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Demo Blocks',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Every built-in block type — read only',
                style: TextStyle(color: colors.textMuted, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 12,
                  color: colors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  'Read only',
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
