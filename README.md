# multi_select

A customizable multi-select Flutter widget that displays selected items as
deletable chips and provides a live-search dropdown for picking more items.
Works seamlessly inside Flutter's `Form` / `FormField` system.

---

## Features

- 🔍 **Live search** — dropdown filters as the user types
- 🏷️ **Chip display** — selected items render as closeable chips above the field
- ✅ **Form integration** — plug into any `Form` with a `validator`
- 🎨 **Themeable** — uses `ColorScheme` tokens; override with a custom `BoxDecoration`
- 🚫 **No duplicates** — already-selected items are hidden from the dropdown
- 📦 **Zero dependencies** — pure Flutter, no third-party packages

---

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  multi_select: ^0.1.0
```

Then run:

```sh
flutter pub get
```

---

## Usage

### Basic example

```dart
import 'package:multi_select/multi_select.dart';

// Inside a StatefulWidget:
List<String> _selectedFruits = [];

MultiSelect(
  items: const ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'],
  selectedItems: _selectedFruits,
  onChanged: (updated) => setState(() => _selectedFruits = updated),
  label: 'Favourite fruits',
  hint: 'Search fruits…',
)
```

### Inside a Form with validation

```dart
final _formKey = GlobalKey<FormState>();
List<String> _selected = [];

Form(
  key: _formKey,
  child: Column(
    children: [
      MultiSelect(
        items: const ['Flutter', 'React Native', 'SwiftUI'],
        selectedItems: _selected,
        onChanged: (updated) => setState(() => _selected = updated),
        label: 'Frameworks',
        hint: 'Select one or more…',
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select at least one framework';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Form is valid
          }
        },
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

---

## Parameters

| Parameter          | Type                           | Default | Description                                                  |
|--------------------|--------------------------------|---------|--------------------------------------------------------------|
| `items`            | `List<String>`                 | —       | **Required.** All available items to choose from.            |
| `selectedItems`    | `List<String>`                 | —       | **Required.** Currently selected items (controlled).         |
| `onChanged`        | `ValueChanged<List<String>>?`  | `null`  | Called with the full updated list on add or remove.          |
| `label`            | `String?`                      | `null`  | Label displayed above the field.                             |
| `hint`             | `String?`                      | `null`  | Placeholder text inside the text field.                      |
| `validator`        | `FormFieldValidator<String>?`  | `null`  | Validator; receives selected items joined by `', '`.         |
| `maxDropdownItems` | `int`                          | `5`     | Maximum visible rows in the dropdown before scrolling.       |
| `controller`       | `TextEditingController?`       | `null`  | Optional external controller to observe the search field.    |
| `decoration`       | `BoxDecoration?`               | `null`  | Override for the outer container decoration.                 |

---

## Additional information

- **Bugs & feature requests** — please open an issue on
  [GitHub](https://github.com/trieu-dev/multi_select/issues).
- **Contributions** — pull requests are welcome! Please open an issue first to
  discuss significant changes.
- **License** — [MIT](LICENSE)
