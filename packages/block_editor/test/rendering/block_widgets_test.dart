import 'package:block_editor/block_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) {
  return Directionality(textDirection: TextDirection.ltr, child: child);
}

void main() {
  final helloDelta = TextDelta.fromPlainText('hello');

  group('ParagraphWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          ParagraphWidget(blockId: 'b1', delta: helloDelta, onEvent: (_) {}),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          ParagraphWidget(
            blockId: 'b1',
            delta: helloDelta,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(ParagraphWidget));
      expect(received, isA<TapEvent>());
      expect((received as TapEvent).blockId, 'b1');
    });
  });

  group('H1Widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(H1Widget(blockId: 'b1', delta: helloDelta, onEvent: (_) {})),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          H1Widget(
            blockId: 'b1',
            delta: helloDelta,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(H1Widget));
      expect(received, isA<TapEvent>());
    });
  });

  group('H2Widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(H2Widget(blockId: 'b1', delta: helloDelta, onEvent: (_) {})),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          H2Widget(
            blockId: 'b1',
            delta: helloDelta,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(H2Widget));
      expect(received, isA<TapEvent>());
    });
  });

  group('H3Widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(H3Widget(blockId: 'b1', delta: helloDelta, onEvent: (_) {})),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          H3Widget(
            blockId: 'b1',
            delta: helloDelta,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(H3Widget));
      expect(received, isA<TapEvent>());
    });
  });

  group('BulletListWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          BulletListWidget(
            blockId: 'b1',
            delta: helloDelta,
            attributes: const {},
            onEvent: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders bullet marker', (tester) async {
      await tester.pumpWidget(
        wrap(
          BulletListWidget(
            blockId: 'b1',
            delta: helloDelta,
            attributes: const {},
            onEvent: (_) {},
          ),
        ),
      );
      expect(find.text('•'), findsOneWidget);
    });

    testWidgets('applies indent padding', (tester) async {
      await tester.pumpWidget(
        wrap(
          BulletListWidget(
            blockId: 'b1',
            delta: helloDelta,
            attributes: const {'indent': 2},
            onEvent: (_) {},
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, const EdgeInsets.only(left: 48.0));
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 400,
            height: 50,
            child: BulletListWidget(
              blockId: 'b1',
              delta: helloDelta,
              attributes: const {},
              onEvent: (e) => received = e,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RichTextRenderer));
      expect(received, isA<TapEvent>());
    });
  });

  group('NumberedListWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberedListWidget(
            blockId: 'b1',
            delta: helloDelta,
            attributes: const {},
            number: 1,
            onEvent: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders number marker', (tester) async {
      await tester.pumpWidget(
        wrap(
          NumberedListWidget(
            blockId: 'b1',
            delta: helloDelta,
            attributes: const {},
            number: 3,
            onEvent: (_) {},
          ),
        ),
      );
      expect(find.text('3.'), findsOneWidget);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 400,
            height: 50,
            child: NumberedListWidget(
              blockId: 'b1',
              delta: helloDelta,
              attributes: const {},
              number: 1,
              onEvent: (e) => received = e,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(RichTextRenderer));
      expect(received, isA<TapEvent>());
    });
  });

  group('TodoWidget', () {
    testWidgets('renders unchecked without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: false,
            onEvent: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders checked without error', (tester) async {
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: true,
            onEvent: (_) {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping checkbox emits CheckboxToggledEvent with true', (
      tester,
    ) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: false,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(Container).first);
      expect(received, isA<CheckboxToggledEvent>());
      expect((received as CheckboxToggledEvent).checked, isTrue);
    });

    testWidgets('tapping checkbox emits CheckboxToggledEvent with false', (
      tester,
    ) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: true,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(Container).first);
      expect((received as CheckboxToggledEvent).checked, isFalse);
    });

    testWidgets('tapping text area emits TapEvent', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: false,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.text('hello', findRichText: true));
      expect(received, isA<TapEvent>());
    });

    testWidgets('checked state renders strikethrough on text', (tester) async {
      await tester.pumpWidget(
        wrap(
          TodoWidget(
            blockId: 'b1',
            delta: helloDelta,
            checked: true,
            onEvent: (_) {},
          ),
        ),
      );
      final text = tester.widget<Text>(find.byType(Text).first);
      expect(text.textSpan!.style!.decoration, TextDecoration.lineThrough);
    });
  });

  group('QuoteWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(QuoteWidget(blockId: 'b1', delta: helloDelta, onEvent: (_) {})),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('emits TapEvent on tap', (tester) async {
      BlockEvent? received;
      await tester.pumpWidget(
        wrap(
          QuoteWidget(
            blockId: 'b1',
            delta: helloDelta,
            onEvent: (e) => received = e,
          ),
        ),
      );
      await tester.tap(find.byType(QuoteWidget));
      expect(received, isA<TapEvent>());
    });
  });

  group('DividerWidget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        wrap(DividerWidget(blockId: 'b1', onEvent: (_) {})),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a Divider widget', (tester) async {
      await tester.pumpWidget(
        wrap(DividerWidget(blockId: 'b1', onEvent: (_) {})),
      );
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('BlockEvent', () {
    test('TapEvent carries blockId and offset', () {
      const e = TapEvent(blockId: 'b1', offset: 5);
      expect(e.blockId, 'b1');
      expect(e.offset, 5);
    });

    test('CheckboxToggledEvent carries blockId and checked', () {
      const e = CheckboxToggledEvent(blockId: 'b1', checked: true);
      expect(e.blockId, 'b1');
      expect(e.checked, isTrue);
    });
  });
}
