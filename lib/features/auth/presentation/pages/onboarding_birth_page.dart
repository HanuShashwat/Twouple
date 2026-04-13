import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class OnboardingBirthPage extends StatefulWidget {
  const OnboardingBirthPage({super.key});

  @override
  State<OnboardingBirthPage> createState() => _OnboardingBirthPageState();
}

class _OnboardingBirthPageState extends State<OnboardingBirthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  bool _isLoading = false;

  final MapController mapController = MapController();
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default to New Delhi

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
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 11.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedLocation = point;
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.twouple_fs',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
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
