import 'package:flutter/material.dart';
import 'package:multi_select/multi_select.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MultiSelect Example',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final _formKey = GlobalKey<FormState>();

  List<String> _selectedCountries = [];
  List<String> _selectedLanguages = [];

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Countries: ${_selectedCountries.join(', ')}\n'
            'Languages: ${_selectedLanguages.join(', ')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MultiSelect Example')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Countries ──────────────────────────────────────────────────
              MultiSelect(
                label: 'Countries',
                hint: 'Search countries…',
                items: _kCountries,
                selectedItems: _selectedCountries,
                onChanged: (updated) =>
                    setState(() => _selectedCountries = updated),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select at least one country';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Languages ─────────────────────────────────────────────────
              MultiSelect(
                label: 'Programming Languages',
                hint: 'Search languages…',
                items: _kLanguages,
                selectedItems: _selectedLanguages,
                onChanged: (updated) =>
                    setState(() => _selectedLanguages = updated),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const List<String> _kCountries = [
  'Vietnam',
  'Japan',
  'South Korea',
  'China',
  'Thailand',
  'Singapore',
  'Malaysia',
  'Indonesia',
  'Philippines',
  'India',
  'Australia',
  'New Zealand',
  'United States',
  'Canada',
  'United Kingdom',
  'Germany',
  'France',
  'Italy',
  'Spain',
  'Brazil',
];

const List<String> _kLanguages = [
  'Dart',
  'Kotlin',
  'Swift',
  'JavaScript',
  'TypeScript',
  'Python',
  'Rust',
  'Go',
  'Java',
  'C#',
  'C++',
];
