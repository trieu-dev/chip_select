import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multi_select/multi_select.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _kItems = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

Widget _buildApp({
  List<String> items = _kItems,
  List<String> selectedItems = const [],
  ValueChanged<List<String>>? onChanged,
  String? label,
  String? hint,
  FormFieldValidator<String>? validator,
  int maxDropdownItems = 5,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MultiSelect(
          items: items,
          selectedItems: selectedItems,
          onChanged: onChanged,
          label: label,
          hint: hint,
          validator: validator,
          maxDropdownItems: maxDropdownItems,
        ),
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('MultiSelect — rendering', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_buildApp());
      expect(find.byType(MultiSelect), findsOneWidget);
    });

    testWidgets('displays label when provided', (tester) async {
      await tester.pumpWidget(_buildApp(label: 'Fruits'));
      expect(find.text('Fruits'), findsOneWidget);
    });

    testWidgets('does not display label when omitted', (tester) async {
      await tester.pumpWidget(_buildApp());
      // No label text should be present (only hint which is inside the field).
      expect(find.text('Fruits'), findsNothing);
    });

    testWidgets('displays hint text in text field', (tester) async {
      await tester.pumpWidget(_buildApp(hint: 'Type to search…'));
      expect(find.text('Type to search…'), findsOneWidget);
    });

    testWidgets('renders chips for initially selected items', (tester) async {
      await tester.pumpWidget(
        _buildApp(selectedItems: ['Apple', 'Banana']),
      );
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(2));
    });
  });

  group('MultiSelect — dropdown', () {
    testWidgets('shows all unselected items when tapped', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      for (final item in _kItems) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('does not show already-selected items in dropdown',
        (tester) async {
      await tester.pumpWidget(
        _buildApp(selectedItems: ['Apple']),
      );
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      // 'Apple' chip exists but Apple should NOT appear in the dropdown list.
      // find.text('Apple') finds exactly 1 widget (the chip), not 2.
      expect(find.text('Apple'), findsOneWidget);

      // Others appear only in the dropdown.
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('filters items based on typed text', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'an');
      await tester.pumpAndSettle();

      // 'Banana' contains 'an', others do not.
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(find.text('Cherry'), findsNothing);
    });

    testWidgets('search is case-insensitive', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'CHERRY');
      await tester.pumpAndSettle();

      expect(find.text('Cherry'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
    });

    testWidgets('overlay closes when tapping outside', (tester) async {
      await tester.pumpWidget(_buildApp());
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);

      // Tap outside the overlay (top-left corner).
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
    });
  });

  group('MultiSelect — selection', () {
    testWidgets('calls onChanged with updated list when item is selected',
        (tester) async {
      List<String>? result;

      await tester.pumpWidget(_buildApp(
        onChanged: (list) => result = list,
      ));

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();

      expect(result, equals(['Cherry']));
    });

    testWidgets('appends to existing selection', (tester) async {
      List<String>? result;

      await tester.pumpWidget(_buildApp(
        selectedItems: ['Apple'],
        onChanged: (list) => result = list,
      ));

      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      expect(result, equals(['Apple', 'Banana']));
    });

    testWidgets('clears search field after item is selected', (tester) async {
      await tester.pumpWidget(_buildApp(
        onChanged: (_) {},
      ));
      await tester.tap(find.byType(TextFormField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Ban');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, isEmpty);
    });
  });

  group('MultiSelect — chip deletion', () {
    testWidgets('calls onChanged when chip delete icon is tapped',
        (tester) async {
      List<String>? result;

      await tester.pumpWidget(_buildApp(
        selectedItems: ['Apple', 'Banana'],
        onChanged: (list) => result = list,
      ));

      expect(find.byType(Chip), findsNWidgets(2));

      // Delete the first chip (Apple).
      await tester.tap(find.byIcon(Icons.cancel).first);
      await tester.pumpAndSettle();

      expect(result, equals(['Banana']));
    });

    testWidgets('removes correct item from middle of list', (tester) async {
      List<String>? result;

      await tester.pumpWidget(_buildApp(
        selectedItems: ['Apple', 'Banana', 'Cherry'],
        onChanged: (list) => result = list,
      ));

      // Delete 'Banana' (second chip, second cancel icon).
      await tester.tap(find.byIcon(Icons.cancel).at(1));
      await tester.pumpAndSettle();

      expect(result, equals(['Apple', 'Cherry']));
    });
  });

  group('MultiSelect — validation', () {
    testWidgets('shows error message when validator returns error',
        (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MultiSelect(
              items: _kItems,
              selectedItems: const [],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select at least one item';
                }
                return null;
              },
            ),
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Please select at least one item'), findsOneWidget);
    });

    testWidgets('passes selected items as comma-separated string to validator',
        (tester) async {
      String? received;
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MultiSelect(
              items: _kItems,
              selectedItems: const ['Apple', 'Banana'],
              validator: (value) {
                received = value;
                return null;
              },
            ),
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(received, equals('Apple, Banana'));
    });

    testWidgets('no error shown when validator returns null', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: MultiSelect(
              items: _kItems,
              selectedItems: const ['Apple'],
              validator: (value) => null,
            ),
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.byType(Text).evaluate().any(
            (e) => (e.widget as Text).data?.contains('error') ?? false,
          ), isFalse);
    });
  });
}
