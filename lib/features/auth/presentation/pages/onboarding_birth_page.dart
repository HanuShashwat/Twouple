import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/constants/app_constants.dart';

class OnboardingBirthPage extends StatefulWidget {
  const OnboardingBirthPage({super.key});

  @override
  State<OnboardingBirthPage> createState() => _OnboardingBirthPageState();
}

class _OnboardingBirthPageState extends State<OnboardingBirthPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _tobController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _debounceTimer;

  final MapController mapController = MapController();
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _submit() async {
    if (_nameController.text.isNotEmpty) {
      context.read<AuthBloc>().add(UpdateUserNameEvent(_nameController.text.trim()));
    }
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate save
    setState(() => _isLoading = false);

    if (mounted) {
      context.go('/home');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.background,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _tobController.text = picked.format(context);
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (query.trim().isEmpty) {
        setState(() => _searchResults = []);
        return;
      }
      setState(() => _isSearching = true);
      try {
        var response = await Dio().get(
          'https://nominatim.openstreetmap.org/search',
          queryParameters: {'q': query, 'format': 'json', 'limit': '5'},
          options: Options(headers: {'User-Agent': 'TwoupleApp'}),
        );
        if (response.statusCode == 200 && mounted) {
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(response.data);
          });
        }
      } catch (e) {
        // Suppress failure, keep list empty
      }
      if (mounted) setState(() => _isSearching = false);
    });
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    FocusScope.of(context).unfocus();
    double lat = double.parse(result['lat'].toString());
    double lon = double.parse(result['lon'].toString());
    LatLng newPos = LatLng(lat, lon);
    
    setState(() {
      _selectedLocation = newPos;
      _searchResults = [];
      _searchController.text = result['display_name'].toString().split(',').first;
    });
    mapController.move(newPos, 14.0);
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tell us about yourself',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 32),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Full Name',
              hint: 'John Doe',
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Date of Birth',
                    hint: 'DD/MM/YYYY',
                    controller: _dobController,
                    readOnly: true,
                    onTap: _selectDate,
                    suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Time of Birth',
                    hint: 'HH:MM AM/PM',
                    controller: _tobController,
                    readOnly: true,
                    onTap: _selectTime,
                    suffixIcon: const Icon(Icons.access_time_filled_rounded, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Place of Birth',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            // Search Input
            CustomTextField(
              label: '',
              hint: 'Search hospital, city, or area...',
              controller: _searchController,
              onChanged: _onSearchChanged,
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _isSearching 
                  ? const Padding(
                      padding: EdgeInsets.all(14.0),
                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            // Search Results Layout
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.surface),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      title: Text(
                        item['display_name'] ?? 'Unknown location',
                        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(Icons.place, color: AppColors.primary),
                      onTap: () => _selectSearchResult(item),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            // Map
            Container(
              height: 220,
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
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _searchResults = [];
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
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primary,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Coordinate readout
            Center(
              child: Text(
                'Coordinates: X: ${_selectedLocation.latitude.toStringAsFixed(6)}, Y: ${_selectedLocation.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Complete Setup',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
