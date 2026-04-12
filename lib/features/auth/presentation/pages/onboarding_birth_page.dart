import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class OnboardingBirthPage extends StatefulWidget {
  const OnboardingBirthPage({Key? key}) : super(key: key);

  @override
  State<OnboardingBirthPage> createState() => _OnboardingBirthPageState();
}

class _OnboardingBirthPageState extends State<OnboardingBirthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  bool _isLoading = false;

  late GoogleMapController mapController;
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default to New Delhi

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _submit() async {
    setState(() => _isLoading = true);
    // Simulate Backend Save
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Birth Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Full Name',
              hint: 'John Doe',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Date of Birth',
              hint: 'DD/MM/YYYY',
              controller: _dobController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Time of Birth',
              hint: 'HH:MM AM/PM',
              controller: _tobController,
            ),
            const SizedBox(height: 24),
            Text(
              'Place of Birth',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 11.0,
                  ),
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('birth_place'),
                      position: _selectedLocation,
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Continue',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
