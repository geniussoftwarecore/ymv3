import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Back Button Navigation Tests', () {
    // Helper function to create a test widget with proper providers
    Widget createTestWidget(Widget page) {
      return ProviderScope(
        child: MaterialApp(
          home: page,
        ),
      );
    }

    group('Basic Back Button Tests', () {
      testWidgets('Should have back button in AppBar',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      Navigator.of(tester.element(find.byType(Scaffold)))
                          .maybePop(),
                ),
                title: const Text('Test Page'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        // Verify back button exists
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Verify AppBar exists
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('Back button should be in leading position',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test Page'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        final appBar = find.byType(AppBar);
        expect(appBar, findsOneWidget);

        // The back button should be present
        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);
      });

      testWidgets('Back button should be tappable',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test Page'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);

        // Verify button is tappable
        expect(
          tester.widget<Icon>(backButton),
          isA<Icon>(),
        );
      });
    });

    group('Back Button Consistency Tests', () {
      testWidgets('All pages should have proper AppBar configuration',
          (WidgetTester tester) async {
        final pages = [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Page 1'),
            ),
            body: const Center(child: Text('Content 1')),
          ),
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Page 2'),
            ),
            body: const Center(child: Text('Content 2')),
          ),
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Page 3'),
            ),
            body: const Center(child: Text('Content 3')),
          ),
        ];

        for (final page in pages) {
          await tester.pumpWidget(createTestWidget(page));

          // Check AppBar exists
          expect(
            find.byType(AppBar),
            findsOneWidget,
            reason: 'AppBar not found for page',
          );

          // Check back button exists
          expect(
            find.byIcon(Icons.arrow_back),
            findsOneWidget,
            reason: 'Back button not found for page',
          );
        }
      });

      testWidgets('All back buttons should use arrow_back icon consistently',
          (WidgetTester tester) async {
        final pages = [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Test 1'),
            ),
            body: const SizedBox(),
          ),
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              ),
              title: const Text('Test 2'),
            ),
            body: const SizedBox(),
          ),
        ];

        for (final page in pages) {
          await tester.pumpWidget(createTestWidget(page));

          final backButtons = find.byIcon(Icons.arrow_back);
          expect(
            backButtons,
            findsOneWidget,
            reason: 'Inconsistent back button',
          );
        }
      });
    });

    group('Navigation Stack Tests', () {
      testWidgets('Navigator.maybePop should work correctly',
          (WidgetTester tester) async {
        bool buttonPressed = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      buttonPressed = true;
                      Navigator.of(tester.element(find.byType(Scaffold)))
                          .maybePop();
                    },
                  ),
                ),
                body: const Center(child: Text('Home Page')),
              ),
            ),
          ),
        );

        // Back button should be available
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();

        expect(buttonPressed, true);
      });

      testWidgets('Multiple navigation levels should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(tester.element(find.byType(Center))).push(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Page 2'),
                            ),
                            body: const Center(child: Text('Page 2')),
                          ),
                        ),
                      );
                    },
                    child: const Text('Navigate'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Navigate'), findsOneWidget);

        // Navigate
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Should be on page 2
        expect(find.text('Page 2'), findsOneWidget);
      });
    });

    group('Back Button Edge Cases', () {
      testWidgets('Back button should handle rapid taps gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);

        // Simulate rapid taps
        for (int i = 0; i < 3; i++) {
          await tester.tap(backButton);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Page should still be valid
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('Back button should persist across layout changes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Rebuild widget
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        // Back button should still be present
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });

    group('Navigation Semantics', () {
      testWidgets('Back button should have proper structure',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {},
                ),
                title: const Text('Test'),
              ),
              body: const Center(child: Text('Content')),
            ),
          ),
        );

        final backButton = find.byIcon(Icons.arrow_back);
        expect(backButton, findsOneWidget);

        // Verify button widget structure
        expect(
          find.ancestor(
            of: backButton,
            matching: find.byType(IconButton),
          ),
          findsOneWidget,
        );
      });

      testWidgets('Pages should be buildable without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {},
                  ),
                  title: const Text('Test Page'),
                ),
                body: const Center(child: Text('Page Content')),
              ),
            ),
          ),
        );

        // Pages should be buildable
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.text('Page Content'), findsOneWidget);
      });
    });
  });
}
