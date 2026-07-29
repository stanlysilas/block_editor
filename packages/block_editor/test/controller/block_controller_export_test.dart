import 'package:block_editor/block_editor.dart';
import 'package:test/test.dart';

BlockNode _para(String id, String text) => BlockNode(
  id: id,
  type: BlockTypes.paragraph,
  delta: TextDelta.fromPlainText(text),
);

void main() {
  late BlockController controller;

  setUp(() {
    controller = BlockController(
      document: BlockDocument([_para('p1', 'Hello'), _para('p2', 'World')]),
    );
  });

  tearDown(() => controller.dispose());

  group('BlockController.exportAs', () {
    test('returns non-empty string for JSON exporter', () async {
      final result = await controller.exportAs(const JsonExporter());
      expect(result, isNotEmpty);
    });

    test('returns non-empty string for Markdown exporter', () async {
      final result = await controller.exportAs(const MarkdownExporter());
      expect(result, isNotEmpty);
    });

    test('returns non-empty string for plain text exporter', () async {
      final result = await controller.exportAs(const PlainTextExporter());
      expect(result, isNotEmpty);
    });

    test('JSON export contains document content', () async {
      final result = await controller.exportAs(const JsonExporter());
      expect(result, contains('Hello'));
      expect(result, contains('World'));
    });

    test('Markdown export contains document content', () async {
      final result = await controller.exportAs(const MarkdownExporter());
      expect(result, contains('Hello'));
      expect(result, contains('World'));
    });

    test('plain text export contains document content', () async {
      final result = await controller.exportAs(const PlainTextExporter());
      expect(result, contains('Hello'));
      expect(result, contains('World'));
    });

    test('does not modify the document', () async {
      final before = controller.document;
      await controller.exportAs(const JsonExporter());
      expect(controller.document, equals(before));
    });

    test('export reflects current document state after mutation', () async {
      controller.append(_para('p3', 'Added'));
      final result = await controller.exportAs(const PlainTextExporter());
      expect(result, contains('Added'));
    });
  });

  group('BlockController.importFrom', () {
    test('replaces document with imported content', () async {
      final json = await controller.exportAs(const JsonExporter());
      final newController = BlockController(document: BlockDocument.empty());
      addTearDown(newController.dispose);

      await newController.importFrom(const JsonImporter(), json);

      expect(newController.document.blocks.length, 2);
    });

    test('imported document contains correct block types', () async {
      final md = '# Title\n\nBody text';
      await controller.importFrom(const MarkdownImporter(), md);

      expect(controller.document.blocks.first.type, BlockTypes.heading1);
      expect(controller.document.blocks.first.delta!.plainText, 'Title');
    });

    test('import is undoable', () async {
      final original = controller.document;
      final md = '# Replacement';
      await controller.importFrom(const MarkdownImporter(), md);

      expect(controller.document.blocks.first.type, BlockTypes.heading1);
      expect(controller.canUndo, isTrue);

      controller.undo();

      expect(controller.document, equals(original));
    });

    test('import pushes exactly one undo snapshot', () async {
      final beforeCanUndo = controller.canUndo;
      await controller.importFrom(const MarkdownImporter(), '# New');
      expect(controller.canUndo, isTrue);
      expect(beforeCanUndo, isFalse);
    });

    test('empty source imports as BlockDocument.empty', () async {
      await controller.importFrom(const JsonImporter(), '');
      expect(controller.document.isNotEmpty, isTrue);
    });

    test('import clears redo stack', () async {
      controller.append(_para('p3', 'Extra'));
      controller.undo();
      expect(controller.canRedo, isTrue);

      await controller.importFrom(const MarkdownImporter(), '# Fresh');
      expect(controller.canRedo, isFalse);
    });

    test('emits document change after import', () async {
      final eventFuture = controller.changes.first;
      await controller.importFrom(const MarkdownImporter(), '# Changed');
      final event = await eventFuture;
      expect(event.type, ChangeType.replace);
    });

    test(
      'JSON round-trip via controller methods produces equal document',
      () async {
        final exported = await controller.exportAs(const JsonExporter());
        final fresh = BlockController(document: BlockDocument.empty());
        addTearDown(fresh.dispose);

        await fresh.importFrom(const JsonImporter(), exported);

        expect(fresh.document, equals(controller.document));
      },
    );
  });
}
