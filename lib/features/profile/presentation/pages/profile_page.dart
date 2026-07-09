import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../api/relationship_api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _phoneController = TextEditingController();
  final _api = RelationshipApi();
  String _statusMessage = '';
  bool _isLoading = false;

  void _checkStatus() async {
    setState(() => _isLoading = true);
    try {
      final res = await _api.getRelationshipStatus();
      if (res['status'] == 'pending') {
        setState(() => _statusMessage = 'You have a pending invite!');
      } else if (res['status'] == 'active') {
        setState(() => _statusMessage = 'You are connected with a partner.');
      } else {
        setState(() => _statusMessage = 'No active relationship.');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Failed to check status');
    }
    setState(() => _isLoading = false);
  }

  void _invite() async {
    if (_phoneController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _api.invitePartner(_phoneController.text);
      setState(() => _statusMessage = 'Invite sent!');
    } catch (e) {
      setState(() => _statusMessage = 'Error sending invite');
    }
    setState(() => _isLoading = false);
  }

  void _accept() async {
    setState(() => _isLoading = true);
    try {
      await _api.acceptInvitation();
      setState(() => _statusMessage = 'Invite accepted!');
    } catch (e) {
      setState(() => _statusMessage = 'Error accepting invite');
    }
    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Sync'),
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
            title: Text('Subscription tier'),
            subtitle: Text('Free Tier'),
          ),
          const Divider(height: 48),
          const Text('Partner Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_statusMessage, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (_statusMessage == 'You have a pending invite!')
            CustomButton(
              text: _isLoading ? 'Accepting...' : 'Accept Invite',
              onPressed: _isLoading ? () {} : _accept,
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Partner Phone Number',
              hintText: 'e.g. +1234567890',
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: _isLoading ? 'Sending...' : 'Send Invite',
            onPressed: _isLoading ? () {} : _invite,
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
