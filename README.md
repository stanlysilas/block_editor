# block_editor

A Notion-inspired, block-based rich text editor built entirely from scratch in Flutter and Dart.
No dependency on AppFlowy, flutter_quill, super_editor, or any existing editor package.
Everything is custom-built for maximum flexibility.

> **Status:** Active development — pre-release. API is unstable until v1.0.0.

---

## Packages

This repository is a mono-repo managed with [Melos](https://melos.invertase.dev/).

| Package | Description | Version |
|---|---|---|
| [`block_editor`](packages/block_editor) | Core editor package | ![pub.dev](https://img.shields.io/pub/v/block_editor) |
| [`block_editor_plugins`](packages/block_editor_plugins) | Extended block plugins *(coming soon)* | — |

---

## Repository Structure

```
block_editor/
├── packages/
│   ├── block_editor/          # Core package
│   └── block_editor_plugins/  # Companion plugins package (placeholder)
├── example/                   # Example Flutter app
└── .github/                   # CI workflows and issue templates
```

---

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) `>=3.27.0`
- [Dart](https://dart.dev/get-dart) `>=3.11.0`
- [Melos](https://melos.invertase.dev/) — install globally once:

```bash
dart pub global activate melos
```

### Bootstrap the workspace

```bash
git clone https://github.com/stanlysilas/block_editor.git
cd block_editor
melos bootstrap
```

### Run the example app

```bash
cd example
flutter run
```

### Run all tests

```bash
melos run test
```

### Run the full lint suite

```bash
melos run lint
```

---

## Build Phases

| Phase | Description | Status |
|---|---|---|
| 1 | Document Model & Core Engine | ✅ Complete |
| 2 | Rendering Engine | ✅ Complete |
| 3 | Block Plugin System | ✅ Complete |
| 4 | Toolbar & Commands | ✅ Complete |
| 5 | Export & Import | 🚧 In progress |
| 6 | Differentiating Features | ⏳ Pending |
| 7 | Polish & Release | ⏳ Pending |

---

## Contributing

Contributions are welcome once the project reaches a stable API (v1.0.0).
In the meantime, please open an issue to discuss any changes before submitting a pull request.

This project uses [Conventional Commits](https://www.conventionalcommits.org/) for all commit messages.

---

## License

[MIT](LICENSE)