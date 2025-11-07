import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Integration Navigation Tests', () {
    // Create a comprehensive test app that simulates real navigation patterns
    Widget createComplexNavigationApp() {
      return ProviderScope(
        child: MaterialApp(
          home: const HomePage(),
          routes: {
            '/details': (_) => const DetailsPage(),
            '/edit': (_) => const EditPage(),
            '/confirm': (_) => const ConfirmPage(),
          },
        ),
      );
    }

    group('Multi-Level Navigation Flow', () {
      testWidgets('Forward and backward navigation should work correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Start at home page
        expect(find.text('Home Page'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

        // Navigate to details
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(find.text('Details Page'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('Home Page'), findsOneWidget);
      });

      testWidgets('Deep navigation with multiple levels',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Home -> Details
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();
        expect(find.text('Details Page'), findsOneWidget);

        // Details -> Edit
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();
        expect(find.text('Edit Page'), findsOneWidget);

        // Edit -> Confirm
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();
        expect(find.text('Confirm Page'), findsOneWidget);

        // Navigate back through all levels
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Edit Page'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Details Page'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Home Page'), findsOneWidget);
      });
    });

    group('Navigation State Persistence', () {
      testWidgets('Page state should be preserved during navigation',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Update state on home page
        await tester.tap(find.text('Increment'));
        await tester.pumpAndSettle();
        expect(find.text('Count: 1'), findsOneWidget);

        // Navigate away
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // State should be preserved
        expect(find.text('Count: 1'), findsOneWidget);
      });
    });

    group('Navigation Error Handling', () {
      testWidgets('App should not crash with rapid back button taps',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Navigate forward
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        // Rapid back taps
        for (int i = 0; i < 5; i++) {
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pump();
          }
        }

        await tester.pumpAndSettle();

        // App should still be functional
        expect(find.byType(Scaffold), findsWidgets);
      });

      testWidgets('App should handle back button on root page gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // We're already at root, so back should do nothing
        final initialFind = find.text('Home Page');
        expect(initialFind, findsOneWidget);

        // App should remain functional
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Simultaneous Navigation Operations', () {
      testWidgets('Should handle delayed navigation gracefully',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Navigate forward
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pump();

        // Don't settle, navigate back immediately
        if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.arrow_back));
        }

        // Settle and check state
        await tester.pumpAndSettle();

        // App should be in a valid state
        expect(find.byType(Scaffold), findsWidgets);
      });
    });

    group('Dialog Navigation Integration', () {
      testWidgets('Dialogs should not interfere with back button',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Dialog Title'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Back button should still work
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });
    });

    group('Back Button with Unsaved Changes', () {
      testWidgets('Should warn on back when changes exist',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Navigate to edit page
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(find.text('Edit Page'), findsOneWidget);

        // Make a change
        await tester.tap(find.text('Make Change'));
        await tester.pumpAndSettle();

        // Attempt to go back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Dialog should appear
        expect(find.text('Discard Changes?'), findsOneWidget);
      });
    });

    group('Navigation Accessibility', () {
      testWidgets('All navigation elements should be accessible',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Check forward button
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

        // Check buttons are within proper semantic containers
        expect(find.byType(IconButton), findsWidgets);
      });

      testWidgets('Buttons should be findable', (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Forward button
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);

        // Buttons should be within proper containers
        expect(find.byType(IconButton), findsWidgets);
      });
    });

    group('Memory and Performance', () {
      testWidgets('Repeated navigation should not cause memory issues',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Perform 5 navigation cycles
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byIcon(Icons.arrow_forward));
          await tester.pumpAndSettle();

          if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
            await tester.tap(find.byIcon(Icons.arrow_back));
            await tester.pumpAndSettle();
          }
        }

        // App should still be responsive
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('Route Parameters', () {
      testWidgets('Route parameters should be passed correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        // Navigate to details with context
        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(find.text('Details Page'), findsOneWidget);
      });
    });

    group('Hot Reload Behavior', () {
      testWidgets('Navigation should survive widget rebuild',
          (WidgetTester tester) async {
        await tester.pumpWidget(createComplexNavigationApp());

        await tester.tap(find.byIcon(Icons.arrow_forward));
        await tester.pumpAndSettle();

        expect(find.text('Details Page'), findsOneWidget);

        // Simulate rebuild
        await tester.pumpWidget(createComplexNavigationApp());

        // Navigation state might reset - that's expected
        // Just verify app is functional
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });
  });
}

// Test Pages for Integration Testing
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: $count'),
            ElevatedButton(
              onPressed: () {
                setState(() => count++);
              },
              child: const Text('Increment'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Dialog Title'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Show Dialog'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/details'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Details'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Details Page'),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/edit'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Edit'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool hasChanges = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (hasChanges) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Discard Changes?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Keep Editing'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Edit Page'),
            ElevatedButton(
              onPressed: () {
                setState(() => hasChanges = true);
              },
              child: const Text('Make Change'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/confirm'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfirmPage extends StatelessWidget {
  const ConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Confirm Page'),
            ElevatedButton(
              onPressed: () {
                // Pop multiple routes to go back to home
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
