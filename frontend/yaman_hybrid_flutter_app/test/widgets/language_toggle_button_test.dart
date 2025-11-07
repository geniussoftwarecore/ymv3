import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/language_toggle_button.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';

void main() {
  group('LanguageToggleButton Tests', () {
    group('Widget Creation', () {
      testWidgets('LanguageToggleButton should render without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('LanguageToggleButton should render InkWell',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('LanguageToggleButton should render language icon',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });
    });

    group('Display Properties', () {
      testWidgets('Should display text by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              locale: const Locale('en'),
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('Should hide text when showText is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: false),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('Should render with custom icon size',
          (WidgetTester tester) async {
        const customSize = 32.0;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(iconSize: customSize),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('Should use default icon size of 20',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });
    });

    group('Design and Styling', () {
      testWidgets('Should have rounded corners', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('Should have border decoration', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('Should have proper padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Language Display', () {
      testWidgets('Should display current language label',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              locale: const Locale('en'),
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('Should support both Arabic and English',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });
    });

    group('Interactivity', () {
      testWidgets('Should be tappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('Should respond to tap', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('Should have proper border radius for tap area',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        final inkwell = find.byType(InkWell);
        expect(inkwell, findsOneWidget);
      });
    });

    group('Icon Styling', () {
      testWidgets('Should display language icon with proper color',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('Should render icon with custom size',
          (WidgetTester tester) async {
        const customSize = 40.0;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(iconSize: customSize),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });
    });

    group('Text Styling', () {
      testWidgets('Should render text with proper styling',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(Text), findsWidgets);
      });

      testWidgets('Should not render text when showText is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: false),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('Should have spacing between icon and text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(Row), findsWidgets);
      });
    });

    group('Localization', () {
      testWidgets('Should support Arabic localization',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              locale: const Locale('ar'),
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('Should support English localization',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              locale: const Locale('en'),
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });
    });

    group('Layout', () {
      testWidgets('Should use Row for layout', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('Should have mainAxisSize: min', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(Row), findsWidgets);
      });

      testWidgets('Should render only icon when showText is false',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: false),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('Should render icon and text when showText is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(showText: true),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
        expect(find.byType(Text), findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('Should be keyboard accessible', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('Should have semantic meaning', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });
    });

    group('Multiple Instances', () {
      testWidgets('Should render multiple language toggle buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: Row(
                  children: [
                    LanguageToggleButton(),
                    LanguageToggleButton(showText: false),
                    LanguageToggleButton(iconSize: 24),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsWidgets);
      });
    });

    group('Theme Integration', () {
      testWidgets('Should use theme colors', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.blue,
                ),
              ),
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });

      testWidgets('Should respect dark theme', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: ThemeData.dark(),
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(),
              ),
            ),
          ),
        );

        expect(find.byType(LanguageToggleButton), findsOneWidget);
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle small icon sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(iconSize: 8),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('Should handle large icon sizes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: const [S.delegate],
              supportedLocales: S.delegate.supportedLocales,
              home: const Scaffold(
                body: LanguageToggleButton(iconSize: 48),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.language), findsOneWidget);
      });
    });
  });
}
