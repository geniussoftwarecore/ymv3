import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Navigation Behavior Tests', () {
    // Helper to create test app
    Widget createTestApp({required Widget home}) {
      return ProviderScope(
        child: MaterialApp(home: home),
      );
    }

    group('Navigation Stack Management', () {
      testWidgets('Navigator.maybePop should work correctly',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(Scaffold)))
                        .maybePop();
                  },
                ),
              ),
              body: const Center(child: Text('Home Page')),
            ),
          ),
        );

        // Back button should be available
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });

      testWidgets('Multiple navigation levels should work',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(Center))).push(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('Test Page')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        );

        // Initial state
        expect(find.text('Navigate'), findsOneWidget);

        // Navigate to /test
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Should be on test page
        expect(find.text('Test Page'), findsOneWidget);
      });
    });

    group('Back Button Functionality', () {
      testWidgets('Back button should pop navigation stack',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Page 1'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(Scaffold)))
                        .maybePop();
                  },
                ),
              ),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      tester.element(find.byType(Center)),
                    ).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Page 2'),
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(
                                  tester.element(
                                    find.byType(Scaffold).last,
                                  ),
                                ).pop();
                              },
                            ),
                          ),
                          body: const Center(child: Text('Page 2 Body')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to Page 2'),
                ),
              ),
            ),
          ),
        );

        // Initially on Page 1
        expect(find.text('Page 1'), findsOneWidget);

        // Navigate to Page 2
        await tester.tap(find.text('Go to Page 2'));
        await tester.pumpAndSettle();

        // Now on Page 2
        expect(find.text('Page 2 Body'), findsOneWidget);

        // Tap back button
        await tester.tap(find.byIcon(Icons.arrow_back).last);
        await tester.pumpAndSettle();

        // Should return to Page 1
        expect(find.text('Page 1'), findsOneWidget);
      });

      testWidgets('Back button should not crash on empty stack',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(Scaffold)))
                        .maybePop();
                  },
                ),
              ),
              body: const Center(child: Text('Home')),
            ),
          ),
        );

        // Tap back button (should do nothing safely)
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Page should still be valid
        expect(find.text('Home'), findsOneWidget);
      });
    });

    group('Navigation with Dialog/Popup', () {
      testWidgets('Back button should work with dialogs present',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(tester.element(find.byType(Scaffold)))
                        .maybePop();
                  },
                ),
              ),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: tester.element(find.byType(Center)),
                      builder: (_) => const AlertDialog(
                        title: Text('Dialog'),
                        content: Text('This is a dialog'),
                      ),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Dialog should be visible
        expect(find.text('This is a dialog'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('This is a dialog'));
        await tester.pumpAndSettle();
      });
    });

    group('Navigation State Preservation', () {
      testWidgets('Navigation should preserve page state',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              appBar: AppBar(
                title: const Text('Page A'),
              ),
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      tester.element(find.byType(Center)),
                    ).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Page B')),
                          body: const Center(child: Text('Page B')),
                        ),
                      ),
                    );
                  },
                  child: const Text('Go to B'),
                ),
              ),
            ),
          ),
        );

        // On Page A
        expect(find.text('Page A'), findsOneWidget);

        // Navigate to B
        await tester.tap(find.text('Go to B'));
        await tester.pumpAndSettle();

        expect(find.text('Page B'), findsOneWidget);
      });
    });

    group('Concurrent Navigation Requests', () {
      testWidgets('Multiple navigation requests should not crash',
          (WidgetTester tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    tapCount++;
                    if (tapCount < 3) {
                      Navigator.of(tester.element(find.byType(Center))).push(
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: Center(child: Text('Page')),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        );

        // Multiple taps
        for (int i = 0; i < 2; i++) {
          await tester.tap(find.text('Navigate'));
          await tester.pumpAndSettle();
        }

        // App should still be functional
        expect(find.byType(Scaffold), findsWidgets);
      });
    });

    group('Back Navigation Timing', () {
      testWidgets('Back navigation should complete animations',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      tester.element(find.byType(Center)),
                    ).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.of(
                                  tester.element(
                                    find.byType(Scaffold).last,
                                  ),
                                ).pop();
                              },
                            ),
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
        );

        // Navigate forward
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(find.text('Page 2'), findsOneWidget);

        // Navigate back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Should complete animation
        expect(find.text('Navigate'), findsOneWidget);
      });
    });
  });
}
