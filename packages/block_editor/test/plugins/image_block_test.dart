import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_editor/block_editor.dart';

Widget wrap(Widget child) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

BlockNode imageNode({
  String source = 'network',
  String url = '',
  String path = '',
}) {
  return BlockNode(
    type: BlockTypes.image,
    attributes: {
      'source': source,
      if (url.isNotEmpty) 'url': url,
      if (path.isNotEmpty) 'path': path,
    },
  );
}

void main() {
  group('ImageBlock — plugin contract', () {
    test('blockType is image', () {
      expect(ImageBlock().blockType, BlockTypes.image);
    });

    test('serialize round-trips via toJson', () {
      final node = imageNode(
        source: 'network',
        url: 'https://example.com/img.png',
      );
      final json = ImageBlock().serialize(node);
      expect(json['type'], BlockTypes.image);
    });

    test('deserialize produces correct type', () {
      final node = imageNode();
      final json = ImageBlock().serialize(node);
      final restored = ImageBlock().deserialize(json);
      expect(restored.type, BlockTypes.image);
    });

    test('slashCommandItem label is Image', () {
      expect(ImageBlock().slashCommandItem().label, 'Image');
    });

    test('slashCommandGroup is Media', () {
      expect(ImageBlock().slashCommandGroup(), 'Media');
    });
  });

  group('ImageBlock — export hooks', () {
    test('exportAsPlainText with url returns [Image: url]', () {
      final node = imageNode(url: 'https://example.com/img.png');
      expect(
        ImageBlock().exportAsPlainText(node),
        '[Image: https://example.com/img.png]',
      );
    });

    test('exportAsPlainText without url returns [Image]', () {
      final node = imageNode();
      expect(ImageBlock().exportAsPlainText(node), '[Image]');
    });

    test('exportAsMarkdown with url returns markdown image syntax', () {
      final node = BlockNode(
        type: BlockTypes.image,
        attributes: const {
          'url': 'https://example.com/img.png',
          'alt': 'photo',
          'source': 'network',
        },
      );
      expect(
        ImageBlock().exportAsMarkdown(node),
        '![photo](https://example.com/img.png)',
      );
    });

    test('exportAsMarkdown without url returns null', () {
      final node = imageNode();
      expect(ImageBlock().exportAsMarkdown(node), isNull);
    });

    test('exportAsHtml with url returns img tag', () {
      final node = BlockNode(
        type: BlockTypes.image,
        attributes: const {
          'url': 'https://example.com/img.png',
          'alt': 'photo',
          'source': 'network',
        },
      );
      expect(
        ImageBlock().exportAsHtml(node),
        '<img src="https://example.com/img.png" alt="photo">',
      );
    });

    test('exportAsHtml without url returns null', () {
      final node = imageNode();
      expect(ImageBlock().exportAsHtml(node), isNull);
    });
  });

  group('ImageBlock — rendered state', () {
    testWidgets('renders without error for network source with url', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(
                  source: 'network',
                  url: 'https://example.com/img.png',
                ),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders loading widget for upload_pending source', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'upload_pending'),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('Loading…'), findsOneWidget);
    });

    testWidgets('emits image_upload_requested for local source', (
      tester,
    ) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'local', path: '/tmp/photo.jpg'),
                EditorSelection.none,
                (e) => received = e,
              ),
            ),
          ),
        ),
      );
      expect(received, isA<CustomBlockEvent>());
      expect(
        (received as CustomBlockEvent).eventType,
        'image_upload_requested',
      );
      expect((received as CustomBlockEvent).payload, '/tmp/photo.jpg');
    });

    testWidgets('custom onLoading builder is used for upload_pending', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            imageConfig: ImageBlockConfig(
              onLoading: (ctx) => const Text('custom loading'),
            ),
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'upload_pending'),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('custom loading'), findsOneWidget);
    });

    testWidgets('borderRadius is applied via ClipRRect', (tester) async {
      const radius = BorderRadius.all(Radius.circular(12));
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            imageConfig: const ImageBlockConfig(borderRadius: radius),
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'upload_pending'),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, radius);
    });
  });

  group('ImageBlock — placeholder state (editable)', () {
    testWidgets('shows TabBar with URL and Upload tabs when no url', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'network', url: ''),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      expect(find.text('URL'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('URL tab shows text field and embed button', (tester) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'network', url: ''),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Embed'), findsOneWidget);
    });

    testWidgets('confirming URL fires image_url_confirmed event', (
      tester,
    ) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'network', url: ''),
                EditorSelection.none,
                (e) => received = e,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(
        find.byType(TextField),
        'https://example.com/img.png',
      );
      await tester.tap(find.text('Embed'));
      await tester.pump();
      expect(received, isA<CustomBlockEvent>());
      final event = received as CustomBlockEvent;
      expect(event.eventType, 'image_url_confirmed');
      final payload = event.payload as Map<String, dynamic>;
      expect(payload['url'], 'https://example.com/img.png');
      expect(payload['source'], 'network');
    });

    testWidgets('tapping Upload tab shows file pick button', (tester) async {
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'network', url: ''),
                EditorSelection.none,
                (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(find.text('Choose image file'), findsOneWidget);
    });

    testWidgets('tapping file pick button fires image_file_pick_requested', (
      tester,
    ) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          BlockEditorScope(
            child: Builder(
              builder: (context) => ImageBlock().build(
                imageNode(source: 'network', url: ''),
                EditorSelection.none,
                (e) => received = e,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose image file'));
      await tester.pump();
      expect(received, isA<CustomBlockEvent>());
      expect(
        (received as CustomBlockEvent).eventType,
        'image_file_pick_requested',
      );
    });
  });

  group('ImageBlock — placeholder state (read-only)', () {
    testWidgets(
      'shows neutral placeholder icon in read-only mode with no url',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            BlockEditorScope(
              readOnly: true,
              child: Builder(
                builder: (context) => ImageBlock().build(
                  imageNode(source: 'network', url: ''),
                  EditorSelection.none,
                  (_) {},
                ),
              ),
            ),
          ),
        );
        expect(find.byIcon(Icons.image_outlined), findsOneWidget);
        expect(find.byType(TabBar), findsNothing);
      },
    );
  });
}
