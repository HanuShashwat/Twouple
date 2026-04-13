import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  String _status = 'Upload your chat export for analysis.';
  bool _isLoading = false;

  void _pickFile() async {
    setState(() {
      _isLoading = true;
      _status = 'Processing chat_export.txt...';
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isLoading = false;
      _status = 'Processing complete. Reading simulated successfully.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import WhatsApp')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Select .txt File',
              onPressed: _pickFile,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
