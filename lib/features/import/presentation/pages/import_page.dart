import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/celestial_background.dart';
import '../../../../api/import_api.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  final ImportApi _importApi = ImportApi();
  
  String? _fileName;
  bool _isLoading = false;
  bool _hasResult = false;
  Map<String, dynamic>? _analysisResult;
  String? _errorMessage;

  Future<void> _pickAndAnalyze() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      setState(() {
        _fileName = result.files.single.name;
        _isLoading = true;
        _errorMessage = null;
        _hasResult = false;
      });

      final analysis = await _importApi.analyzeWhatsAppChat(file);

      setState(() {
        _isLoading = false;
        _hasResult = true;
        _analysisResult = analysis;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CelestialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Import WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Upload card
                _buildUploadCard(),
                const SizedBox(height: 24),

                // Loading state
                if (_isLoading) _buildLoadingState(),

                // Error
                if (_errorMessage != null) _buildError(),

                // Results
                if (_hasResult && _analysisResult != null) _buildResults(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.upload_file_rounded, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyze Your Chat',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            _fileName != null
                ? 'Selected: $_fileName'
                : 'Export your WhatsApp chat as a .txt file, then upload it here for AI-powered relationship analysis.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndAnalyze,
              icon: const Icon(Icons.description_rounded),
              label: Text(_fileName != null ? 'Analyze Again' : 'Select .txt File'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48, height: 48,
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aura is reading your chat...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyzing patterns, tone, and compatibility from your conversation.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final analysis = _analysisResult!['analysis'] as Map<String, dynamic>? ?? {};
    final msgCount = _analysisResult!['message_count'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary.withValues(alpha: 0.15), AppColors.surface],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$msgCount messages analyzed',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                analysis['summary'] ?? 'Analysis complete.',
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Scores
        Row(
          children: [
            _buildScoreCard('Communication', analysis['communication_score'] ?? 0, const Color(0xFF8784B4)),
            const SizedBox(width: 12),
            _buildScoreCard('Emotional Health', analysis['emotional_health_score'] ?? 0, const Color(0xFFDEA080)),
          ],
        ),
        const SizedBox(height: 16),

        // Strengths
        if (analysis['relationship_strengths'] != null)
          _buildListSection('Strengths', analysis['relationship_strengths'], const Color(0xFF788B7A), Icons.star_rounded),

        // Growth areas
        if (analysis['areas_for_growth'] != null)
          _buildListSection('Areas to Grow', analysis['areas_for_growth'], const Color(0xFFE7AD5D), Icons.trending_up_rounded),

        // Suggestions
        if (analysis['suggestions'] != null)
          _buildListSection('Suggestions', analysis['suggestions'], AppColors.primary, Icons.lightbulb_outline_rounded),
      ],
    );
  }

  Widget _buildScoreCard(String label, dynamic score, Color color) {
    final scoreVal = (score is int) ? score : int.tryParse(score.toString()) ?? 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$scoreVal',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(String title, List<dynamic> items, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
