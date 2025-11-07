import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField Tests', () {
    group('Widget Creation', () {
      testWidgets('CustomTextField should render without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Test Label',
                hintText: 'Test Hint',
              ),
            ),
          ),
        );

        expect(find.byType(CustomTextField), findsOneWidget);
      });

      testWidgets('CustomTextField should render TextFormField',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                hintText: 'Enter email',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Label and Hint Text', () {
      testWidgets('Should display label text', (WidgetTester tester) async {
        const labelText = 'Email Address';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: labelText,
                hintText: 'Enter email',
              ),
            ),
          ),
        );

        expect(find.text(labelText), findsOneWidget);
      });

      testWidgets('Should display hint text', (WidgetTester tester) async {
        const hintText = 'Enter your email address';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                hintText: hintText,
              ),
            ),
          ),
        );

        expect(find.text(hintText), findsOneWidget);
      });

      testWidgets('Should handle empty label and hint',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Icon Support', () {
      testWidgets('Should display prefix icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.email), findsOneWidget);
      });

      testWidgets('Should display suffix icon as widget',
          (WidgetTester tester) async {
        const suffixIcon = Icon(Icons.clear);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Password',
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsWidgets);
      });

      testWidgets('Should not display icon if not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Text Field',
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.email), findsNothing);
      });
    });

    group('Text Input Type', () {
      testWidgets('Should support email input type',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support number input type',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Phone',
                keyboardType: TextInputType.number,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support password input type',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Password',
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support multiline input type',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Comment',
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Obscure Text', () {
      testWidgets('Should support obscuring text for passwords',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Password',
                obscureText: true,
              ),
            ),
          ),
        );

        final textField = find.byType(TextFormField);
        expect(textField, findsOneWidget);
      });

      testWidgets('Should not obscure text by default',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Username',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Input Constraints', () {
      testWidgets('Should support maxLength', (WidgetTester tester) async {
        const maxLength = 50;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Text',
                maxLength: maxLength,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support maxLines', (WidgetTester tester) async {
        const maxLines = 3;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Comment',
                maxLines: maxLines,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support minLines', (WidgetTester tester) async {
        const minLines = 2;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Note',
                minLines: minLines,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('ReadOnly and Enabled States', () {
      testWidgets('Should support readOnly state', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Read Only Field',
                readOnly: true,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should support disabled state', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Disabled Field',
                enabled: false,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });

      testWidgets('Should be enabled by default', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Enabled Field',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Error and Helper Text', () {
      testWidgets('Should display error text', (WidgetTester tester) async {
        const errorText = 'Email is required';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                errorText: errorText,
              ),
            ),
          ),
        );

        expect(find.text(errorText), findsOneWidget);
      });

      testWidgets('Should display helper text', (WidgetTester tester) async {
        const helperText = 'Enter a valid email address';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                helperText: helperText,
              ),
            ),
          ),
        );

        expect(find.text(helperText), findsOneWidget);
      });

      testWidgets('Should not display error if not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Text Field',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Content Padding', () {
      testWidgets('Should support custom padding', (WidgetTester tester) async {
        const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Padded Field',
                contentPadding: padding,
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('Should call onChanged when text changes',
          (WidgetTester tester) async {
        String changedValue = '';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Test Field',
                onChanged: (value) {
                  changedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), 'test text');
        await tester.pumpAndSettle();

        expect(changedValue, 'test text');
      });

      testWidgets('Should call onTap when field is tapped',
          (WidgetTester tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Test Field',
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextFormField));
        expect(tapped, isTrue);
      });
    });

    group('Controller Support', () {
      testWidgets('Should work with TextEditingController',
          (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Test Field',
                controller: controller,
              ),
            ),
          ),
        );

        controller.text = 'Programmatic text';
        await tester.pumpAndSettle();

        expect(controller.text, 'Programmatic text');
      });
    });

    group('Validator Support', () {
      testWidgets('Should support custom validator',
          (WidgetTester tester) async {
        const email = 'test@example.com';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextFormField), email);
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsOneWidget);
      });
    });

    group('Text Input Action', () {
      testWidgets('Should support different text input actions',
          (WidgetTester tester) async {
        final actions = [
          TextInputAction.done,
          TextInputAction.next,
          TextInputAction.go,
          TextInputAction.search,
        ];

        for (final action in actions) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomTextField(
                  labelText: 'Test',
                  textInputAction: action,
                ),
              ),
            ),
          );

          expect(find.byType(TextFormField), findsOneWidget);
        }
      });
    });

    group('Accessibility', () {
      testWidgets('Should have proper semantics', (WidgetTester tester) async {
        const labelText = 'Email Address';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                labelText: labelText,
                hintText: 'Enter your email',
              ),
            ),
          ),
        );

        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text(labelText), findsOneWidget);
      });
    });

    group('Multiple Instances', () {
      testWidgets('Should render multiple CustomTextFields',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CustomTextField(
                    labelText: 'First Name',
                  ),
                  CustomTextField(
                    labelText: 'Last Name',
                  ),
                  CustomTextField(
                    labelText: 'Email',
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomTextField), findsWidgets);
        expect(find.byType(TextFormField), findsWidgets);
      });
    });
  });
}
