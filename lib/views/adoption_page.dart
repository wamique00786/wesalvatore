import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AdoptionPage extends StatefulWidget {
  const AdoptionPage({super.key});

  @override
  _AdoptionPageState createState() => _AdoptionPageState();
}

class _AdoptionPageState extends State<AdoptionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> animals = [
    {
      'image': 'assets/parrot.jpg',
      'name': 'Buddy',
      'description': 'A friendly parrot looking for a home.'
    },
    {
      'image': 'assets/cat.jpg',
      'name': 'Whiskers',
      'description': 'A playful tabby cat full of energy!'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  Future<File> _saveImageToStorage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File newImage = await imageFile.copy(path);
    return newImage;
  }

  void _showAddAnimalDialog() {
    String name = '';
    String description = '';
    bool isAdoptable = false;
    File? image;

    Future<void> pickImage(ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        final File savedImage =
            await _saveImageToStorage(File(pickedFile.path));
        setState(() {
          image = savedImage;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Adoptable Animal',
            style: GoogleFonts.poppins(),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: [
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('Take a Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: image == null
                        ? Icon(Icons.camera_alt, color: Colors.teal)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(image!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(labelText: 'Animal Name'),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Is Adoptable?'),
                    Checkbox(
                      value: isAdoptable,
                      onChanged: (value) {
                        setState(() {
                          isAdoptable = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty &&
                    description.isNotEmpty &&
                    image != null) {
                  setState(() {
                    animals.add({
                      'image': image!.path,
                      'name': name,
                      'description': description,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text('Add Animal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: Text(
          'Adopt a Friend',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _showAddAnimalDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Animals Available for Adoption',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: animals[index]['image']!
                                      .startsWith('assets/')
                                  ? Image.asset(animals[index]['image']!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover)
                                  : Image.file(File(animals[index]['image']!),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover),
                            ),
                            SizedBox(height: 10),
                            Text(
                              animals[index]['name']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800]),
                            ),
                            Text(
                              animals[index]['description']!,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: Colors.teal[600]),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text('View Details'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
