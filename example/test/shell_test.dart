import 'package:block_editor/block_editor.dart';
import 'package:block_editor_example/app.dart';
import 'package:block_editor_example/plugins/callout_with_author_block.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    BlockRegistry.instance.register(CalloutWithAuthorBlock());
  });

  group('ShellScaffold navigation', () {
    testWidgets('renders on wide screen with sidebar visible', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      expect(find.text('block_editor'), findsOneWidget);
      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Demo Blocks'), findsOneWidget);
      expect(find.text('Custom Block'), findsOneWidget);
    });

    testWidgets('renders on narrow screen with bottom bar visible', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      expect(find.text('Editor'), findsOneWidget);
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
    });

    testWidgets('navigates to Demo Blocks section', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      await tester.tap(find.text('Demo Blocks'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Demo Blocks'), findsWidgets);
    });

    testWidgets('navigates to Custom Block section', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      await tester.tap(find.text('Custom Block'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Custom Block Demo'), findsOneWidget);
    });

    testWidgets('navigates back to Editor section', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      await tester.tap(find.text('Demo Blocks'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Editor'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Getting started'), findsOneWidget);
    });

    testWidgets('theme toggle switches between light and dark mode', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const App());
      await tester.pump();

      final MaterialApp appBefore = tester.widget(find.byType(MaterialApp));
      expect(appBefore.themeMode, ThemeMode.system);

      await tester.tap(find.byTooltip('Switch to dark mode'));
      await tester.pump(const Duration(milliseconds: 500));

      final MaterialApp appAfter = tester.widget(find.byType(MaterialApp));
      expect(appAfter.themeMode, ThemeMode.dark);
    });
  });
}
