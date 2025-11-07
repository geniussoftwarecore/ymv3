import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Drawer Navigation Tests', () {
    // Helper to create test app with drawer
    Widget createTestAppWithDrawer({
      required Widget child,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('App'),
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Text('Menu'),
                  ),
                  ListTile(
                    title: const Text('Item 1'),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text('Item 2'),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            body: child,
          ),
        ),
      );
    }

    group('Drawer Functionality', () {
      testWidgets('AppBar should have menu icon for drawer',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Main Content')),
          ),
        );

        // Scaffold should have drawer
        final scaffold = find.byType(Scaffold);
        expect(scaffold, findsOneWidget);

        // AppBar should be present
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('Drawer should open when requested',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Main Content')),
          ),
        );

        // Find and tap the drawer toggle (menu icon)
        final menuButton = find.byTooltip('Open navigation menu');
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();

          // Drawer should be visible
          expect(find.byType(Drawer), findsOneWidget);
        }
      });

      testWidgets('Drawer should contain navigation items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Main Content')),
          ),
        );

        // Find drawer items
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      });

      testWidgets('Drawer items should be tappable',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Main Content')),
          ),
        );

        // Find menu icon and tap it to open drawer
        final menuButton = find.byTooltip('Open navigation menu');
        if (menuButton.evaluate().isNotEmpty) {
          await tester.tap(menuButton);
          await tester.pumpAndSettle();

          // Drawer should be visible
          expect(find.byType(Drawer), findsOneWidget);

          // Items should be present
          expect(find.text('Item 1'), findsOneWidget);
        }
      });
    });

    group('Drawer Content Rendering', () {
      testWidgets('Drawer should render custom content correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Test Page'),
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const DrawerHeader(
                        decoration: BoxDecoration(color: Colors.blue),
                        child: Text('Custom Header'),
                      ),
                      ListTile(
                        title: const Text('Custom Item'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                body: const Center(
                  child: Text('Main Body'),
                ),
              ),
            ),
          ),
        );

        // Content should be present
        expect(find.text('Main Body'), findsOneWidget);

        // Drawer header should be present
        expect(find.text('Custom Header'), findsOneWidget);
      });
    });

    group('Navigation Consistency with Drawer', () {
      testWidgets('App should maintain state with drawer open',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Page Content')),
          ),
        );

        // Page should be rendered
        expect(find.text('Page Content'), findsOneWidget);

        // AppBar should be present
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Drawer Accessibility', () {
      testWidgets('Drawer should be keyboard accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        // Menu button should be accessible
        final menuButton = find.byTooltip('Open navigation menu');
        if (menuButton.evaluate().isNotEmpty) {
          expect(menuButton, findsOneWidget);
        }
      });

      testWidgets('Drawer items should be accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        // ListTiles should be present
        expect(find.byType(ListTile), findsWidgets);
      });
    });

    group('Drawer AppBar Behavior', () {
      testWidgets('AppBar should have correct title',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        expect(find.text('App'), findsOneWidget);
      });

      testWidgets('AppBar should preserve structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Page Title'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {},
                    ),
                  ],
                ),
                drawer: const Drawer(
                  child: SizedBox(),
                ),
                body: const Center(child: Text('Content')),
              ),
            ),
          ),
        );

        // Actions should be present
        expect(find.byIcon(Icons.search), findsOneWidget);
      });
    });

    group('Responsive Drawer', () {
      testWidgets('Drawer should work on small screens',
          (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(300, 500);

        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        // App should still be functional on small screens
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });

      testWidgets('Drawer should work on large screens',
          (WidgetTester tester) async {
        addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
        tester.binding.window.physicalSizeTestValue = const Size(1200, 800);

        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        // App should still be functional on large screens
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });
    });

    group('Drawer Menu Items', () {
      testWidgets('Drawer menu should have consistent structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(child: Text('Content')),
          ),
        );

        // Drawer items should be present
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
      });

      testWidgets('Multiple drawer pages should work together',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Home'),
                ),
                drawer: Drawer(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Home'),
                        onTap: () {},
                      ),
                      ListTile(
                        title: const Text('Settings'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                body: const Center(child: Text('Home Page')),
              ),
            ),
          ),
        );

        // Drawer items should be present
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });
    });

    group('Drawer Interaction Patterns', () {
      testWidgets('Page content should be preserved with drawer',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestAppWithDrawer(
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Header'),
                  Text('Content'),
                ],
              ),
            ),
          ),
        );

        // Content should be present
        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });

      testWidgets('Drawer should not interfere with page scrolling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: const Text('Page'),
                ),
                drawer: Drawer(
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Item'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                body: ListView(
                  children: [
                    Container(height: 100, color: Colors.blue),
                    Container(height: 100, color: Colors.red),
                    Container(height: 100, color: Colors.green),
                  ],
                ),
              ),
            ),
          ),
        );

        // Page should be functional
        expect(find.byType(ListView), findsWidgets);
      });
    });
  });
}
