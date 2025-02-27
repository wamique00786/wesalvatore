import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';
import 'package:wesalvatore/provider/user_provider.dart';
import 'package:wesalvatore/services/compressImage.dart';
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

  Future<bool> _fetchLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showSnackbar('Enable GPS to continue.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackbar('Location permissions are required.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackbar('Location access is permanently denied.');
        return false;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return true;
    } catch (e) {
      _showSnackbar('Error fetching location: $e');
      return false;
    }
  }

  Future<void> _pickImage() async {
    _showSnackbar('Fetching location, please wait...');
    if (!await _fetchLocation()) return;

    try {
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() => _capturedImages.add(photo));
      }
    } catch (e) {
      _showSnackbar('Error capturing image: $e');
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

  Future<String?> getBaseUrl() async {
    return await const FlutterSecureStorage().read(key: "BASE_URL");
  }

  Future<void> _submitReport() async {
    if (_capturedImages.isEmpty) {
      _showSnackbar('Capture at least one image.');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showSnackbar('Provide a description.');
      return;
    }
    if (_currentPosition == null) {
      _showSnackbar('Fetching location, please wait...');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String? token = userProvider.authToken;
      final String? baseUrl = await getBaseUrl();

      if (token == null || baseUrl == null) {
        _showSnackbar('Authentication failed. Please log in again.');
        return;
      }

      final uri = Uri.parse('$baseUrl/user/');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Token $token'
        ..headers['Accept'] = 'application/json'
        ..fields['description'] = _descriptionController.text.trim()
        ..fields['priority'] = _selectedPriority
        ..fields['latitude'] = _currentPosition!.latitude.toString()
        ..fields['longitude'] = _currentPosition!.longitude.toString();

      for (XFile image in _capturedImages) {
        File compressedImage = await compressImage(File(image.path));
        String mimeType = lookupMimeType(compressedImage.path) ?? 'image/jpeg';

        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          compressedImage.path,
          contentType: MediaType.parse(mimeType),
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        _showSnackbar('Report submitted successfully.');
        _resetForm();
      } else {
        _showSnackbar('Failed to submit. Try again.');
      }
    } catch (e) {
      _showSnackbar('Error submitting report. Check connection.');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _capturedImages.clear();
      _descriptionController.clear();
      _selectedPriority = 'MEDIUM';
      _currentPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavBar(),
      appBar: AppBar(title: const Text('Animal Rescue'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCameraSection(theme),
            if (_capturedImages.isNotEmpty) _buildImagePreviewList(),
            const SizedBox(height: 24),
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
      child: Column(
        children: [
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.camera_alt,
                  size: 64, color: theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tap to take a photo'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildImagePreviewList() {
    return SizedBox(
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
                  child: Image.file(File(_capturedImages[index].path),
                      width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPriorityDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      items: ['HIGH', 'MEDIUM', 'LOW'].map((priority) {
        return DropdownMenuItem(value: priority, child: Text(priority));
      }).toList(),
      onChanged: (value) => setState(() => _selectedPriority = value!),
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(labelText: 'Description'),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitReport,
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Submit Report'),
    );
  }
}
