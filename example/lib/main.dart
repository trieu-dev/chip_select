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
      home: Scaffold(
        appBar: AppBar(title: const Text('My Package Example')),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: MyForm(),
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MultiSelect(
            controller: _controller,
            label: 'Country',
            hint: 'Enter your country',
            items: countries,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Hello ${_controller.text}')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

const List<String> countries = [
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
