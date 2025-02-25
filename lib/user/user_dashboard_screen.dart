import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wesalvatore/views/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class UserDashBoardScreen extends StatefulWidget {
  const UserDashBoardScreen({super.key});

  @override
  State<UserDashBoardScreen> createState() => _UserDashBoardScreenState();
}

class _UserDashBoardScreenState extends State<UserDashBoardScreen> {
  final List<XFile> _capturedImages = [];
  Position? _currentPosition;
  String _selectedPriority = 'MEDIUM'; // Default to MEDIUM
  final TextEditingController _descriptionController = TextEditingController();

  /// ✅ **Handles Location Permission**
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
      // Retry after a delay
      Future.delayed(const Duration(seconds: 2), () => _getCurrentLocation());
    }
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? photo =
          await ImagePicker().pickImage(source: source, imageQuality: 80);
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
        // Convert stream to string
        final responseString = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseString);

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavBar(),
      appBar: AppBar(
        title: Text('Rescue Dashboard', style: theme.textTheme.titleLarge),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 80),
                color: theme.colorScheme.primary,
                onPressed: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(height: 20),
            if (_capturedImages.isNotEmpty)
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
                          child: CircleAvatar(
                            backgroundColor: Colors.black54,
                            radius: 12,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close,
                                  size: 16, color: Colors.white),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                labelText: 'Select Priority',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: ['LOW', 'MEDIUM', 'HIGH']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
              onChanged: (value) => setState(() => _selectedPriority = value!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Describe the animal and situation',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitReport,
                child:
                    const Text('SUBMIT REPORT', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
