import 'package:flutter/material.dart';
import 'package:wesalvatore/views/navbar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
// import translation file

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const NavBar(),
      appBar: AppBar(
        title: const Text('Rescue Dashboard',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal[900],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt,
                        color: Colors.teal, size: 80),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.photo_library,
                  //       color: Colors.teal, size: 30),
                  //   onPressed: () => _pickImage(ImageSource.gallery),
                  // ),
                ],
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
                            borderRadius: BorderRadius.circular(8),
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
            if (_currentPosition != null)
              Text(
                  'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                  labelText: 'Enter Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                  labelText: 'Select Priority', border: OutlineInputBorder()),
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
              decoration: const InputDecoration(
                  labelText: 'Describe the animal and situation',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _capturedImages.clear();
                  });
                  // Submit report logic
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  backgroundColor: Colors.teal[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('SUBMIT REPORT',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
