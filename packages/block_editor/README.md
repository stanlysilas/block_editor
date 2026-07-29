# block_editor

A Notion-inspired, block-based rich text editor for Flutter, built entirely from scratch.
No dependency on AppFlowy, flutter_quill, super_editor, or any existing editor package.

## Status

Pre-release (`0.0.4-dev.1`) — the public API is available and documented but **breaking changes will occur** in future pre-release versions before `1.0.0`. Do not use in production applications yet.

## Installation

```yaml
dependencies:
  block_editor: ^0.0.4-dev.1
```

Since this is a pre-release version, you must explicitly request it:

```bash
flutter pub add block_editor:0.0.4-dev.1
```

---

## Features

- **Block-based document model** — every piece of content is a `BlockNode` with a typed structure, serialisable to and from plain JSON
- **Rich inline text** — bold, italic, underline, strikethrough, inline code, links, text color, and background color via `TextDelta` and `InlineAttributes`
- **Plugin system** — every block type is a `BlockPlugin`; built-in blocks are pre-registered, custom blocks registered with a single line
- **Slash command menu** — `/` opens a data-driven block insertion menu grouped by category; fully extensible with custom block types
- **Formatting toolbar** — context-sensitive floating toolbar over text selections with toggle semantics for all inline attributes
- **Block action menu** — per-block actions: delete, duplicate, turn into, move up, move down
- **Keyboard shortcuts** — full desktop shortcut support: bold, italic, underline, strikethrough, inline code, undo, redo, select all, word jump, line jump, document jump, cross-block selection extension
- **Drag and drop** — reorder blocks by dragging with ghost preview and drop indicator
- **Read-only mode** — clean viewer mode with text selection but no editing, activated by a single flag
- **Per-block streams** — subscribe to changes on individual blocks without rebuilding the entire document
- **IME support** — mobile soft keyboard input via `TextInputConnection`

---

## Built-in Block Types

Paragraph, H1, H2, H3, Bullet List, Numbered List, Todo (checkbox), Quote, Divider, Image, Video, YouTube embed, File attachment, Code (syntax highlighted with language selector), Callout (info / warning / error), Link.

---

## Quick Start

```dart
import 'package:block_editor/block_editor.dart';
import 'package:flutter/material.dart';

class MyEditor extends StatefulWidget {
  const MyEditor({super.key});

  @override
  State<MyEditor> createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  late final BlockController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BlockController(document: BlockDocument.empty());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlockEditorWidget(controller: _controller);
  }
}
```

---

## Registering a Custom Block

```dart
class MyCustomPlugin extends BlockPlugin {
  @override
  String get blockType => 'my_custom_block';

  @override
  Widget build(BuildContext context, BlockNode node, BlockEditorScope scope) {
    return Text('Custom: ${node.attributes['content'] ?? ''}');
  }

  @override
  Map<String, dynamic> serialize(BlockNode node) => node.attributes;

  @override
  BlockNode deserialize(Map<String, dynamic> data) =>
      BlockNode(type: blockType, attributes: data);

  @override
  SlashCommandConfig? slashCommandItem() => SlashCommandConfig(
        label: 'My Custom Block',
        icon: Icons.star,
        group: 'Custom',
      );
}

// Register at app startup — before the editor is mounted
BlockRegistry.instance.register(MyCustomPlugin());
```

---

## Read-Only Mode

```dart
BlockEditorWidget(
  controller: _controller,
  readOnly: true,
)
```

---

## Custom Color Picker

```dart
BlockEditorWidget(
  controller: _controller,
  onColorPickerRequested: (Color? current) async {
    return await showMyColorPicker(context, current);
  },
)
```

When `onColorPickerRequested` is null the built-in 12-swatch palette is used.

---

## Toolbar Breakpoint

```dart
BlockEditorWidget(
  controller: _controller,
  toolbarBreakpoint: 600.0,
)
```

Above the threshold the formatting toolbar floats above the text selection. Below it pins to the bottom of the editor. Default is `768.0` logical pixels.

---

## Document Serialisation

```dart
final json = _controller.document.toJson();
final restored = BlockDocument.fromJson(json);
```

The document model is plain JSON — storable in Firestore, SQLite, or any backend without transformation.

---

## Roadmap

| Phase | Description | Status |
|---|---|---|
| 1 | Document Model & Core Engine | ✅ Complete |
| 2 | Rendering Engine | ✅ Complete |
| 3 | Block Plugin System | ✅ Complete |
| 4 | Toolbar & Commands | ✅ Complete |
| 5 | Export & Import (JSON, Markdown, HTML, plain text, PDF) | 🚧 In progress |
| 6 | Differentiating Features (variables, tags, conditional blocks, comments) | ⏳ Pending |
| 7 | Polish & `1.0.0` stable release | ⏳ Pending |

---

## Platform Support

Android, iOS, macOS, Windows, Linux, Web.

---

## Example App

In the meantime, see the [example app](https://stanlysilas.github.io/block_editor/).

---

## API Reference

Full dartdoc API reference is available on [pub.dev](https://pub.dev/documentation/block_editor/latest/).

A dedicated documentation site will be built as part of Phase 7.

---

## Contributing

The API is not yet stable. Please open an issue before submitting a pull request.
This project uses [Conventional Commits](https://www.conventionalcommits.org/).

---

## License

[MIT](LICENSE)