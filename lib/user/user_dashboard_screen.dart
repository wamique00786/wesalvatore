import 'package:flutter/material.dart';
import 'package:wesalvatore/views/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

class UserDashBoardScreen extends StatefulWidget {
  const UserDashBoardScreen({super.key});

  @override
  State<UserDashBoardScreen> createState() => _UserDashBoardScreenState();
}

class _UserDashBoardScreenState extends State<UserDashBoardScreen> {
  final List<XFile> _capturedImages = [];
  Position? _currentPosition;
  String _selectedPriority = 'Medium';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Future<bool> _handleLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnackbar('Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Location permissions are permanently denied');
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
      _showSnackbar('Failed to capture image');
    }
  }

  void _removeImage(int index) {
    setState(() => _capturedImages.removeAt(index));
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Enter Address',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              items: ['Low', 'Medium', 'High']
                  .map((priority) =>
                      DropdownMenuItem(value: priority, child: Text(priority)))
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
                onPressed: () {
                  setState(() => _capturedImages.clear());
                },
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
