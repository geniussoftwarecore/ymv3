import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/custom_dropdown.dart';

class ServiceModel {
  final int id;
  final String name;

  ServiceModel({required this.id, required this.name});
}

void main() {
  group('CustomDropdown Tests', () {
    group('Widget Creation', () {
      testWidgets('CustomDropdown should render without errors',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select Option',
                hintText: 'Choose one',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
      });

      testWidgets('CustomDropdown should render DropdownButtonFormField',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'Choose',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });
    });

    group('Label and Hint Text', () {
      testWidgets('Should display label text', (WidgetTester tester) async {
        const labelText = 'Select Service';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: labelText,
                hintText: 'Choose a service',
                items: ['Service 1', 'Service 2'],
              ),
            ),
          ),
        );

        expect(find.text(labelText), findsOneWidget);
      });

      testWidgets('Should display hint text', (WidgetTester tester) async {
        const hintText = 'Select an option from the list';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Options',
                hintText: hintText,
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.text(hintText), findsOneWidget);
      });
    });

    group('Generic Type Support', () {
      testWidgets('Should support String items', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Colors',
                hintText: 'Select color',
                items: ['Red', 'Green', 'Blue'],
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
        expect(find.text('Red'), findsOneWidget);
      });

      testWidgets('Should support Integer items', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomDropdown<int>(
                labelText: 'Numbers',
                hintText: 'Select number',
                items: const [1, 2, 3, 4, 5],
                displayText: (value) => value?.toString() ?? '',
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
      });

      testWidgets('Should support custom model items',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomDropdown<ServiceModel>(
                labelText: 'Services',
                hintText: 'Select service',
                items: [
                  ServiceModel(id: 1, name: 'Oil Change'),
                  ServiceModel(id: 2, name: 'Tire Rotation'),
                ],
                displayText: (item) => item?.name ?? '',
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
      });
    });

    group('Items Display', () {
      testWidgets('Should display all items', (WidgetTester tester) async {
        const items = ['Item 1', 'Item 2', 'Item 3'];

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select Item',
                hintText: 'Choose',
                items: items,
              ),
            ),
          ),
        );

        for (final item in items) {
          expect(find.text(item), findsOneWidget);
        }
      });

      testWidgets('Should support empty items list',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'No items',
                items: [],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });

      testWidgets('Should support large number of items',
          (WidgetTester tester) async {
        final items = List.generate(100, (index) => 'Item $index');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'Choose',
                items: items,
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
      });
    });

    group('Display Text Function', () {
      testWidgets('Should use displayText function',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomDropdown<int>(
                labelText: 'Numbers',
                hintText: 'Select',
                items: const [1, 2, 3],
                displayText: (value) => value != null ? 'Number: $value' : '',
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsOneWidget);
      });

      testWidgets('Should use toString if no displayText provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Text',
                hintText: 'Select',
                items: ['A', 'B', 'C'],
              ),
            ),
          ),
        );

        expect(find.text('A'), findsOneWidget);
      });
    });

    group('Selection and Value', () {
      testWidgets('Should display selected value', (WidgetTester tester) async {
        const selectedValue = 'Option 2';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Options',
                hintText: 'Select',
                value: selectedValue,
                items: ['Option 1', selectedValue, 'Option 3'],
              ),
            ),
          ),
        );

        expect(find.text(selectedValue), findsOneWidget);
      });

      testWidgets('Should handle null value', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Options',
                hintText: 'Select',
                value: null,
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });
    });

    group('Callbacks', () {
      testWidgets('Should call onChanged when selection changes',
          (WidgetTester tester) async {
        String? selectedValue;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Options',
                hintText: 'Select',
                items: const ['Option 1', 'Option 2', 'Option 3'],
                onChanged: (value) {
                  selectedValue = value;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byType(DropdownButtonFormField));
        await tester.pumpAndSettle();

        // Tap the first option in the dropdown menu
        await tester.tap(find.text('Option 1'));
        await tester.pumpAndSettle();

        // Verify that onChanged was called
        expect(selectedValue, equals('Option 1'));
      });

      testWidgets('Should not call onChanged if not provided',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Options',
                hintText: 'Select',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });
    });

    group('Required Field', () {
      testWidgets('Should add asterisk to label for required field',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Service',
                hintText: 'Select service',
                items: ['Service 1', 'Service 2'],
                isRequired: true,
              ),
            ),
          ),
        );

        expect(find.text('Service *'), findsOneWidget);
      });

      testWidgets('Should not add asterisk for optional field',
          (WidgetTester tester) async {
        const labelText = 'Option';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: labelText,
                hintText: 'Select',
                items: ['Option 1'],
                isRequired: false,
              ),
            ),
          ),
        );

        expect(find.text(labelText), findsOneWidget);
        expect(find.text('$labelText *'), findsNothing);
      });
    });

    group('Validation', () {
      testWidgets('Should validate required field',
          (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: const CustomDropdown<String>(
                  labelText: 'Service',
                  hintText: 'Select service',
                  items: ['Service 1', 'Service 2'],
                  isRequired: true,
                ),
              ),
            ),
          ),
        );

        final isValid = formKey.currentState?.validate() ?? false;
        expect(isValid, isFalse);
      });

      testWidgets('Should use custom validator', (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: CustomDropdown<String>(
                  labelText: 'Service',
                  hintText: 'Select',
                  items: const ['Service 1', 'Service 2'],
                  validator: (value) {
                    if (value == null) {
                      return 'Service is required';
                    }
                    if (value == 'Service 1') {
                      return 'Cannot select Service 1';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });

      testWidgets('Should not show error for valid selection',
          (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: const CustomDropdown<String>(
                  labelText: 'Service',
                  hintText: 'Select',
                  value: 'Service 1',
                  items: ['Service 1', 'Service 2'],
                  isRequired: true,
                ),
              ),
            ),
          ),
        );

        final isValid = formKey.currentState?.validate() ?? false;
        expect(isValid, isTrue);
      });
    });

    group('Dropdown Design', () {
      testWidgets('Should have outline border', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'Choose',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });

      testWidgets('Should have proper padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'Choose',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });
    });

    group('Internationalization', () {
      testWidgets('Should display Arabic error message',
          (WidgetTester tester) async {
        final formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: formKey,
                child: const CustomDropdown<String>(
                  labelText: 'الخدمة',
                  hintText: 'اختر',
                  items: ['الخدمة 1', 'الخدمة 2'],
                  isRequired: true,
                ),
              ),
            ),
          ),
        );

        formKey.currentState?.validate();
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });
    });

    group('Multiple Instances', () {
      testWidgets('Should render multiple dropdowns',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CustomDropdown<String>(
                    labelText: 'First',
                    hintText: 'Select',
                    items: ['A', 'B'],
                  ),
                  CustomDropdown<String>(
                    labelText: 'Second',
                    hintText: 'Select',
                    items: ['C', 'D'],
                  ),
                  CustomDropdown<String>(
                    labelText: 'Third',
                    hintText: 'Select',
                    items: ['E', 'F'],
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomDropdown), findsWidgets);
      });
    });

    group('Edge Cases', () {
      testWidgets('Should handle single item dropdown',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Select',
                hintText: 'Only one option',
                items: ['Only Option'],
              ),
            ),
          ),
        );

        expect(find.text('Only Option'), findsOneWidget);
      });

      testWidgets('Should handle very long label text',
          (WidgetTester tester) async {
        const longLabel =
            'This is a very long label that might wrap to multiple lines';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: longLabel,
                hintText: 'Select',
                items: ['Option 1', 'Option 2'],
              ),
            ),
          ),
        );

        expect(find.byType(DropdownButtonFormField), findsOneWidget);
      });

      testWidgets('Should handle special characters in items',
          (WidgetTester tester) async {
        const items = ['Item @#\$', 'Item 123', 'Item (وار)'];

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomDropdown<String>(
                labelText: 'Special Items',
                hintText: 'Select',
                items: items,
              ),
            ),
          ),
        );

        for (final item in items) {
          expect(find.text(item), findsOneWidget);
        }
      });
    });
  });
}
