import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, size: 50, color: AppColors.background),
          ),
          const SizedBox(height: 24),
          const ListTile(
            title: Text('Name'),
            subtitle: Text('Demo User'),
          ),
          const ListTile(
            title: Text('Phone'),
            subtitle: Text('+91 9876543210'),
          ),
          const ListTile(
            title: Text('Subscription tier'),
            subtitle: Text('Free Tier'),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Log out',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
