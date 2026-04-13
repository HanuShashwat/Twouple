import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade to Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.star, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Unlock Twouple Premium',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Get unlimited readings, native couple chat, and PDF reports.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Column(
                children: [
                  Text('Premium Tier', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('₹499 / month', style: TextStyle(color: AppColors.primary, fontSize: 20)),
                ],
              ),
            ),
            const Spacer(),
            CustomButton(text: 'Subscribe Now', onPressed: () {}),
            TextButton(onPressed: () {}, child: const Text('Restore Purchases')),
          ],
        ),
      ),
    );
  }
}
