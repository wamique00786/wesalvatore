import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:wesalvatore/views/navbar.dart';

class UserDashBoardScreen extends StatefulWidget {
  const UserDashBoardScreen({super.key});

  @override
  State<UserDashBoardScreen> createState() => _UserDashBoardScreenState();
}

class _UserDashBoardScreenState extends State<UserDashBoardScreen> {
  final List<XFile> _capturedImages = [];
  Position? _currentPosition;
  String _selectedPriority = 'MEDIUM';
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handles Location Permission
  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnackbar('Location services are disabled.');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Location permissions are denied.');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Location permissions are permanently denied.');
      return false;
    }
    return true;
  }

  Future<void> _getCurrentLocation() async {
    if (!await _handleLocationPermission()) return;
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = position);
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showSnackbar('Failed to get current location. Retrying...');
      Future.delayed(const Duration(seconds: 2), _getCurrentLocation);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? photo = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo != null) {
        setState(() => _capturedImages.add(photo));
        await _getCurrentLocation();
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      _showSnackbar('Failed to capture image.');
    }
  }

  void _removeImage(int index) {
    setState(() => _capturedImages.removeAt(index));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _submitReport() async {
    // Validate required fields
    if (_capturedImages.isEmpty) {
      _showSnackbar('Please capture at least one photo.');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackbar('Please provide a description.');
      return;
    }
    if (_currentPosition == null) {
      _showSnackbar('Location not available. Please try again.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://144.24.122.171/api/accounts/user/'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      // Add text fields
      request.fields['description'] = _descriptionController.text.trim();
      request.fields['priority'] = _selectedPriority;
      request.fields['latitude'] = _currentPosition!.latitude.toString();
      request.fields['longitude'] = _currentPosition!.longitude.toString();

      // Add images
      for (var image in _capturedImages) {
        String? mimeType = lookupMimeType(image.path);
        var file = await http.MultipartFile.fromPath(
          'photo',
          image.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        request.files.add(file);
      }

      // Send request
      var response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        _showSnackbar('Report submitted successfully!');

        // Clear form
        setState(() {
          _capturedImages.clear();
          _descriptionController.clear();
          _selectedPriority = 'MEDIUM';
          _currentPosition = null;
        });
      } else {
        final errorResponse = await response.stream.bytesToString();
        _showSnackbar(
            'Failed to submit report: ${response.statusCode} - $errorResponse');
      }
    } catch (e) {
      debugPrint('Error submitting report: $e');
      _showSnackbar('Error submitting report: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Animal Rescue'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCameraSection(theme),
            if (_capturedImages.isNotEmpty) _buildImagePreviewList(),
            const SizedBox(height: 24),
            Text(
              'Report Details',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildPriorityDropdown(theme),
            const SizedBox(height: 16),
            _buildDescriptionField(theme),
            const SizedBox(height: 24),
            _buildSubmitButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraSection(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Capture Photo',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(height: 1),
          // Center camera button
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Tap to take a photo',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Photos (${_capturedImages.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _capturedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_capturedImages[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'Priority Level',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        prefixIcon: const Icon(Icons.warning_amber),
      ),
      items: [
        DropdownMenuItem(
          value: 'LOW',
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: Colors.green),
              const SizedBox(width: 8),
              const Text('LOW'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'MEDIUM',
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: Colors.orange),
              const SizedBox(width: 8),
              const Text('MEDIUM'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'HIGH',
          child: Row(
            children: [
              Icon(Icons.circle, size: 12, color: Colors.red),
              const SizedBox(width: 8),
              const Text('HIGH'),
            ],
          ),
        ),
      ],
      onChanged: (value) => setState(() => _selectedPriority = value!),
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Describe the animal and situation',
        hintText:
            'Include details about the animal, its condition, and the rescue situation',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        prefixIcon: const Icon(Icons.description),
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        child: _isSubmitting
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: theme.colorScheme.onPrimary,
                  strokeWidth: 2,
                ),
              )
            : const Text('SUBMIT REPORT', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
