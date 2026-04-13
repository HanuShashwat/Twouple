import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class ModeSelectorPage extends StatelessWidget {
  const ModeSelectorPage({super.key});

  Widget _buildCard(BuildContext context, String title, String desc, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Input Mode'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCard(
              context,
              'Import WhatsApp',
              'Upload your chat export for analysis.',
              Icons.upload_file,
              () => context.push('/import'),
            ),
            _buildCard(
              context,
              'Chat with Twouple',
              'Describe your situation to our AI guide.',
              Icons.chat_bubble_outline,
              () => context.push('/chatbot'),
            ),
            _buildCard(
              context,
              'Talk with Partner',
              'Invite your partner and chat in real-time.',
              Icons.people_alt_outlined,
              () => context.push('/native-chat'),
            ),
          ],
        ),
      ),
    );
  }
}
