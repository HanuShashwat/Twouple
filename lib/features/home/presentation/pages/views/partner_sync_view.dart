import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/celestial_background.dart';
import 'partner_chat_page.dart';

class PartnerSyncView extends StatefulWidget {
  const PartnerSyncView();

  @override
  State<PartnerSyncView> createState() => PartnerSyncViewState();
}


class PartnerSyncViewState extends State<PartnerSyncView> with SingleTickerProviderStateMixin {
  final TextEditingController _partnerPhoneController = TextEditingController();
  bool _isLoading = false;
  SyncPhase _phase = SyncPhase.input;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _partnerPhoneController.dispose();
    super.dispose();
  }

  void _syncPartner() async {
    if (_partnerPhoneController.text.length != 10) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _phase = SyncPhase.splash;
    });

    // Automatically transition to the dashboard
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _phase = SyncPhase.synced);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phase == SyncPhase.synced) {
       return const PartnerChatPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: CelestialBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            switchInCurve: Curves.fastEaseInToSlowEaseOut,
            switchOutCurve: Curves.fastEaseInToSlowEaseOut,
            child: _buildCurrentPhase(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPhase() {
    switch (_phase) {
      case SyncPhase.input:
        return Padding(
          key: const ValueKey('input'),
          padding: const EdgeInsets.all(28.0),
          child: _buildInputState(),
        );
      case SyncPhase.splash:
        return Padding(
          key: const ValueKey('splash'),
          padding: const EdgeInsets.all(28.0),
          child: _buildSplashState(),
        );
      case SyncPhase.synced:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.connect_without_contact_rounded,
              size: 64,
              color: AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Joint Alignment',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32),
        ),
        const SizedBox(height: 16),
        Text(
          'Invite someone special to link charts. Our AI will automatically generate deep personalized astrological insights spanning both of your lives.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
        ),
        const SizedBox(height: 48),
        CustomTextField(
          label: "Partner's phone number",
          hint: 'e.g. 9876543210',
          controller: _partnerPhoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text('+91 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        ),
        const Spacer(),
        CustomButton(
          text: 'Send Invitation',
          isLoading: _isLoading,
          onPressed: _syncPartner,
        ),
      ],
    );
  }

  Widget _buildSplashState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140 + (_pulseController.value * 20),
                    height: 140 + (_pulseController.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.1 + (0.2 * (1 - _pulseController.value))),
                        width: 2,
                      ),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary.withValues(alpha: 0.1 + (0.1 * _pulseController.value)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(alpha: 0.2 * _pulseController.value),
                          blurRadius: 20 * _pulseController.value,
                          spreadRadius: 5 * _pulseController.value,
                        )
                      ]
                    ),
                    child: const Icon(Icons.flare_rounded, color: AppColors.secondary, size: 48),
                  ),
                ],
              );
            }
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'Cosmic Alignment\nComplete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 16),
        Text(
          "Unlocking your shared relationship dashboard...",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
        ),
        const Spacer(),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// AI Coach Page
// ─────────────────────────────────────────────


enum SyncPhase { input, splash, synced }

