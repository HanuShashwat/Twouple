import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  void _sendOtp() {
    if (_phoneController.text.length != 10) return;
    context.read<AuthBloc>().add(SendOtpEvent(_phoneController.text));
  }

  void _verifyOtp() {
    if (_otpController.text.length != 6) return;
    context.read<AuthBloc>().add(VerifyOtpEvent(_phoneController.text, _otpController.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            final state = context.read<AuthBloc>().state;
            if (state is AuthOtpSent || state is AuthAuthenticated) {
              // Go back to phone input
              context.read<AuthBloc>().add(ResetAuthEvent());
              _otpController.clear();
            } else {
              // Go back to landing page
              context.go('/landing');
            }
          },
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AuthAuthenticated) {
            context.go('/onboarding-birth');
          }
        },
        builder: (context, state) {
          final isOtpPhase = state is AuthOtpSent || state is AuthAuthenticated;
          
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                // Hero Icon Animation
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.all(isOtpPhase ? 32 : 24),
                    decoration: BoxDecoration(
                      color: isOtpPhase 
                          ? AppColors.secondary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },
                      child: Icon(
                        isOtpPhase ? Icons.mark_email_read_rounded : Icons.phone_android_rounded,
                        key: ValueKey<bool>(isOtpPhase),
                        size: 64,
                        color: isOtpPhase ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Form Animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.05, 0), 
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: isOtpPhase 
                      ? _buildOtpForm(state) 
                      : _buildPhoneForm(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneForm(AuthState state) {
    return Column(
      key: const ValueKey('phone_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Number',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your phone number to receive a secure 6-digit verification code.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          label: 'Phone Number',
          hint: 'e.g. 9876543210',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text('+91 ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        ),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Send Code',
          onPressed: _sendOtp,
          isLoading: state is AuthLoading,
        ),
      ],
    );
  }

  Widget _buildOtpForm(AuthState state) {
    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 36),
        ),
        const SizedBox(height: 12),
        Text(
          'We\'ve sent a code to +91 ${_phoneController.text}.\nEnter it below to proceed.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 40),
        CustomTextField(
          label: '6-digit OTP',
          hint: '123456',
          controller: _otpController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 40),
        CustomButton(
          text: 'Verify Identity',
          onPressed: _verifyOtp,
          isLoading: state is AuthLoading,
        ),
      ],
    );
  }
}
