import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  final List<Map<String, String>> teamMembers = [
    {
      "name": "John Doe",
      "role": "Project Manager",
      "image": "assets/profile1.jpg"
    },
    {
      "name": "Jane Smith",
      "role": "Lead Developer",
      "image": "assets/profile2.jpg"
    },
    {
      "name": "Emily Johnson",
      "role": "UI/UX Designer",
      "image": "assets/profile3.jpg"
    },
    {
      "name": "Michael Brown",
      "role": "Backend Developer",
      "image": "assets/profile1.jpg"
    },
    {
      "name": "Sarah Wilson",
      "role": "QA Engineer",
      "image": "assets/profile2.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Wesalvatore",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal[900],
        leading: const Icon(
          Icons.pets,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            final member = teamMembers[index];
            return Card(
              color: Colors.teal[50],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: AssetImage(member["image"]!),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    member["name"]!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member["role"]!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
